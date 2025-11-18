//
//  CrosspostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-18.
//

import Foundation

@MainActor
class CrosspostViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var selectedAccount: Account
    @Published var submitPostTask: Task<Void, Error>?
    @Published var submittedPostId: String?
    @Published var error: Error? = nil
    
    let postToBeCrossposted: Post
    private let submitPostRepository: SubmitPostRepositoryProtocol
    
    init(postToBeCrossposted: Post, submitPostRepository: SubmitPostRepositoryProtocol) {
        self.selectedAccount = AccountViewModel.shared.account
        self.postToBeCrossposted = postToBeCrossposted
        self.title = postToBeCrossposted.title
        self.submitPostRepository = submitPostRepository
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
        
        submittedPostId = nil
        
        submitPostTask = Task {
            do {
                submittedPostId = try await submitPostRepository.crosspost(
                    account: selectedAccount,
                    subredditName: subreddit.name,
                    title: title,
                    crosspostFullname: postToBeCrossposted.name,
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
