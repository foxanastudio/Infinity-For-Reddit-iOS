//
// SubmitVideoPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-19

import Foundation
import MarkdownUI
import SwiftUI
import AVFoundation

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
    
    private let submitPostRepository: SubmitPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    init(submitPostRepository: SubmitPostRepositoryProtocol, mediaUploadRepository: MediaUploadRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func setVideo(url: URL) {
        print(url)
        self.videoURL = url
        Task {
            if let image = await generateThumbnail(for: url) {
                self.thumbnail = image
            } else {
                print("Failed to generate thumbnail for \(url)")
                self.thumbnail = nil
            }
        }
        print("Video URL set: \(url.lastPathComponent)")
    }
    
    func clearVideo() {
        videoURL = nil
        thumbnail = nil
        print("Cleared video")
    }
    
    func generateThumbnail(for url: URL) async -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 0, preferredTimescale: 600)

        return await withCheckedContinuation { continuation in
            generator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                if let cgImage = cgImage {
                    continuation.resume(returning: UIImage(cgImage: cgImage))
                } else {
                    print("Thumbnail generation failed:", error?.localizedDescription ?? "unknown error")
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    func submitPost(
        subreddit: SubscribedSubredditData?,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool,
        isRichTextJSON: Bool
    ) {
        // TODO: submit video post logic
        print("Submit video post placeholder")
    }
}

