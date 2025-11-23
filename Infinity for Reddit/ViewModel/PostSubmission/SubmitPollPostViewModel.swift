//
// SubmitPollPostViewModel.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-24
        
import Foundation
import MarkdownUI
import SwiftyJSON
import UIKit
import SwiftUI

@MainActor
class SubmitPollPostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var selectedAccount: Account
    @Published var votingDuration: Int = 3
    @Published var pollOptions: [String] = [String](repeating: "", count: 6)
    @Published var embeddedImages: [UploadedImage] = []
    @Published var submitPostTask: Task<Void, Error>?
    @Published var submittedPostUrlString: String?
    @Published var error: Error? = nil
    
    private let submitPostRepository: SubmitPostRepositoryProtocol
    private let mediaUploadRepository: MediaUploadRepositoryProtocol
    
    init(submitPostRepository: SubmitPostRepositoryProtocol, mediaUploadRepository: MediaUploadRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.submitPostRepository = submitPostRepository
        self.mediaUploadRepository = mediaUploadRepository
    }
    
    func addEmbeddedImage(_ image: UIImage) {
        let embeddedImage = UploadedImage(image: image) {
            try await self.mediaUploadRepository.uploadImage(account: self.selectedAccount, image: image, getImageId: true)
        }
        embeddedImage.upload()
        embeddedImages.append(embeddedImage)
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
        
        guard !pollOptions[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !pollOptions[1].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            error = PostSubmissionError.pollOptionsNotEnoughError
            return
        }
        
        submittedPostUrlString = nil
        
        submitPostTask = Task {
            do {
                submittedPostUrlString = try await submitPostRepository.submitPollPost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    content: content,
                    options: pollOptions,
                    duration: votingDuration,
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
}
