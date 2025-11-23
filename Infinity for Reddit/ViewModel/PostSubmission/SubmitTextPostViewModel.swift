//
// SubmitTextPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import Foundation
import MarkdownUI
import SwiftyJSON
import UIKit
import SwiftUI

@MainActor
class SubmitTextPostViewModel: ObservableObject {
    @Published var title: String = ""  
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var embeddedImages: [UploadedImage] = []
    @Published var submitPostTask: Task<Void, Never>?
    @Published var submittedPostId: String?
    @Published var error: Error? = nil
    
    private let submitPostRepository: SubmitPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    init(submitPostRepository: SubmitPostRepositoryProtocol, mediaUploadRepository: MediaUploadRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func submitPost(
        subreddit: SubscribedSubredditData?,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) {
        let richtext = RichtextJSONConverter().constructRichtextJSON(markdownString: content)
        print(richtext)
        
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
        
        submittedPostId = nil
        
        submitPostTask = Task {
            do {
                submittedPostId = try await submitPostRepository.submitTextPost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    content: content,
                    flair: flair,
                    isSpoiler: isSpoiler,
                    isSensitive: isSensitive,
                    receivePostReplyNotifications: receivePostReplyNotifications,
                    embeddedImages: embeddedImages
                )
            } catch {
                self.error = error
                print(error)
            }
            
            self.submitPostTask = nil
        }
    }
    
    func addEmbeddedImage(_ image: UIImage) {
        let embeddedImage = UploadedImage(image: image) {
            try await self.mediaUploadRepository.uploadImage(account: self.selectedAccount, image: image, getImageId: true)
        }
        embeddedImage.upload()
        embeddedImages.append(embeddedImage)
    }
}
