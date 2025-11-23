//
// SubmitVideoPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-19

import Foundation
import MarkdownUI
import SwiftUI
import AVFoundation
import PhotosUI

@MainActor
class SubmitVideoPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var videoURL: URL? = nil
    @Published var thumbnail: UIImage? = nil
    @Published var submitPostTask: Task<Void, Error>?
    @Published var postSubmittedFlag: Bool = false
    @Published var error: Error? = nil
    @Published var processingVideoTask: Task<Void, Never>?
    
    private let submitPostRepository: SubmitPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    init(submitPostRepository: SubmitPostRepositoryProtocol, mediaUploadRepository: MediaUploadRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func processVideo(videoItem: PhotosPickerItem?) {
        processingVideoTask?.cancel()
        
        videoURL = nil
        thumbnail = nil
        
        guard let videoItem else {
            self.error = PostSubmissionError.videoDataError
            return
        }
        
        self.processingVideoTask = Task {
            do {
                if let video = try await videoItem.loadTransferable(type: LocalVideo.self) {
                    try await setVideo(url: video.url)
                } else {
                    throw PostSubmissionError.videoLoadingError
                }
            } catch is CancellationError {
                // Ignore
                self.videoURL = nil
                self.thumbnail = nil
            } catch {
                self.error = error
                self.videoURL = nil
                self.thumbnail = nil
            }
            
            processingVideoTask = nil
        }
    }
    
    func setVideo(url: URL) async throws {
        print(url)
        self.videoURL = url
        if let image = await generateThumbnail(for: url) {
            try Task.checkCancellation()
            
            self.thumbnail = image
        } else {
            throw PostSubmissionError.videoThumbnailError
        }
    }
    
    func setVideo(url: URL) {
        processingVideoTask?.cancel()
        
        videoURL = nil
        thumbnail = nil
        
        print(url)
        self.videoURL = url
        self.processingVideoTask = Task {
            do {
                if let image = await generateThumbnail(for: url) {
                    try Task.checkCancellation()
                    
                    self.thumbnail = image
                } else {
                    throw PostSubmissionError.videoThumbnailError
                }
            } catch is CancellationError {
                // Ignore
                self.videoURL = nil
                self.thumbnail = nil
            } catch {
                self.error = error
                self.videoURL = nil
                self.thumbnail = nil
            }
            
            self.processingVideoTask = nil
        }
    }
    
    func clearVideo() {
        processingVideoTask?.cancel()
        processingVideoTask = nil
        videoURL = nil
        thumbnail = nil
    }
    
    func generateThumbnail(for url: URL) async -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0, preferredTimescale: 600)

        do {
            return try await withCheckedThrowingContinuation { continuation in
                generator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                    if let cgImage = cgImage {
                        continuation.resume(returning: UIImage(cgImage: cgImage))
                    } else {
                        print("Thumbnail generation failed:", error?.localizedDescription ?? "unknown error")
                        continuation.resume(returning: nil)
                    }
                }
            }
        } catch {
            self.error = error
        }
        
        return nil
    }
    
    func submitPost(
        subreddit: SubscribedSubredditData?,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) {
        guard submitPostTask == nil else {
            return
        }
        
        guard let subreddit = subreddit, !subreddit.name.isEmpty else {
            error = PostSubmissionError.subredditNotSelectedError
            return
        }
        
        guard !title.isEmpty else {
            error = PostSubmissionError.noTitleError
            return
        }
        
        guard processingVideoTask == nil else {
            error = PostSubmissionError.videoStillBeingProcessedError
            return
        }
        
        guard let videoURL else {
            error = PostSubmissionError.videoNotSelectedError
            return
        }
        
        guard let thumbnail else {
            error = PostSubmissionError.videoThumbnailError
            return
        }
        
        postSubmittedFlag = false
        
        submitPostTask = Task {
            do {
                let videoUrlString = try await mediaUploadRepository.uploadVideo(account: selectedAccount, videoURL: videoURL)
                let posterUrlString = try await mediaUploadRepository.uploadImage(account: selectedAccount, image: thumbnail, getImageId: false)
                
                try await submitPostRepository.submitVideoPost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    content: content,
                    videoUrlString: videoUrlString,
                    posterUrlString: posterUrlString,
                    flair: flair,
                    isSpoiler: isSpoiler,
                    isSensitive: isSensitive,
                    receivePostReplyNotifications: receivePostReplyNotifications
                )
                
                postSubmittedFlag = true
            } catch {
                self.error = error
                print(error)
            }
            
            self.submitPostTask = nil
        }
    }
}
