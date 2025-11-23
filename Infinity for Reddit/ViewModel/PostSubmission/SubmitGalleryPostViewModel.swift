//
// SubmitGalleryPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-04
        
import Foundation
import UIKit
import PhotosUI

@MainActor
class SubmitGalleryPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var galleryImages: [UploadedImage] = []
    @Published var submitPostTask: Task<Void, Error>?
    @Published var submittedPostUrlString: String?
    @Published var error: Error? = nil
    
    private let submitPostRepository: SubmitPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepository
    
    init(submitPostRepository: SubmitPostRepositoryProtocol, mediaUploadRepository: MediaUploadRepository) {
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func addImage(_ image: UIImage) {
        if galleryImages.count < 20 {
            let galleryImage = UploadedImage(image: image) {
                try await self.mediaUploadRepository.uploadImage(account: self.selectedAccount, image: image, getImageId: true)
            }
            galleryImage.upload()
            galleryImages.append(galleryImage)
        }
    }
    
    func clearCapturedImages() {
        for image in galleryImages {
            image.cancelUpload()
        }
        galleryImages.removeAll()
    }
    
    func deleteCapturedImage(at index: Int) {
        guard index >= 0 && index < galleryImages.count else {
            return
        }
        galleryImages[index].cancelUpload()
        galleryImages.remove(at: index)
    }
    
    func setCaptionAndUrlString(index: Int, caption: String?, outboundUrlString: String?) {
        if galleryImages.indices.contains(index) {
            galleryImages[index].caption = caption
            galleryImages[index].outboundUrlString = outboundUrlString
        }
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
        
        guard galleryImages.count >= 2 else {
            error = PostSubmissionError.galleryImagesNotEnoughError
            return
        }
        
        if let uploadErrorIndex = galleryImages.firstIndex(where: { $0.uploadError != nil }) {
            error = PostSubmissionError.galleryImageUploadError(uploadErrorIndex)
            return
        }
        
        for image in galleryImages where image.isUploading {
            error = PostSubmissionError.galleryImageUploadingInProgress
            return
        }
        
        submittedPostUrlString = nil
        
        submitPostTask = Task {
            do {
                submittedPostUrlString = try await submitPostRepository.submitGalleryPost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    content: content,
                    galleryImages: galleryImages,
                    flair: flair,
                    isSpoiler: isSpoiler,
                    isSensitive: isSensitive,
                    receivePostReplyNotifications: receivePostReplyNotifications
                )
            } catch {
                self.error = error
                print(error)
            }
            
            self.submitPostTask = nil
        }
    }
}
