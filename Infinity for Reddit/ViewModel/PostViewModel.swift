//
//  PostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-11.
//

import Foundation
import Alamofire
import Combine

@MainActor
class PostViewModel: ObservableObject {
    let account: Account
    @Published var post: Post
    @Published var error: Error?
    @Published var shouldBlurMedia: Bool = false
    
    // User defaults
    private var markPostsAsRead: Bool
    private var limitReadPosts: Bool
    private var readPostsLimit: Int
    
    private var cancellables = Set<AnyCancellable>()
    
    let postRepository: PostRepositoryProtocol
    
    init(account: Account, post: Post, postRepository: PostRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postRepository = postRepository
        self.markPostsAsRead = PostHistoryUserDefaultsUtils.markPostsAsRead
        self.limitReadPosts = PostHistoryUserDefaultsUtils.limitReadPosts
        self.readPostsLimit = PostHistoryUserDefaultsUtils.readPostsLimit
        
        post.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                self?.markPostsAsRead = UserDefaults.postHistory.bool(forKey: PostHistoryUserDefaultsUtils.markPostsAsReadKey)
                self?.limitReadPosts = UserDefaults.postHistory.bool(forKey: PostHistoryUserDefaultsUtils.limitReadPostsKey)
                self?.readPostsLimit = UserDefaults.postHistory.integer(forKey: PostHistoryUserDefaultsUtils.readPostsLimitKey)
            }
            .store(in: &cancellables)
    }
    
    func votePost(vote: Int) async {
        guard let _ = account.accessToken, let _ = post.name else { return }
        
        let previousVote = post.likes
        
        var point: String
        let finalVote: Int
        if vote == post.likes {
            point = "0"
            finalVote = 0
            post.likes = 0
        } else {
            point = String(vote)
            finalVote = vote
            post.likes = vote
        }
        self.objectWillChange.send()
        
        defer {
            self.objectWillChange.send()
        }
        
        do {
            try await postRepository.votePost(post: post, point: point)
            self.post.likes = finalVote
        } catch {
            self.post.likes = previousVote
            self.error = error
            print("Error voting post: \(error)")
        }
    }
    
    func savePost(save: Bool) async {
        guard let _ = account.accessToken, let _ = post.name else { return }
        
        let previousSaved = post.saved
        
        post.saved = save
        
        self.objectWillChange.send()
        
        defer {
            self.objectWillChange.send()
        }
        
        do {
            try await postRepository.savePost(post: post, save: save)
        } catch {
            self.post.saved = previousSaved
            self.error = error
            print("Error (un)saving post: \(error)")
        }
    }
    
    func readPost() async {
        guard !post.isRead, markPostsAsRead else {
            return
        }
        
        do {
            try await postRepository.readPost(
                post: post,
                account: AccountViewModel.shared.account,
                limitReadPosts: limitReadPosts,
                readPostsLimit: readPostsLimit
            )
            
            await MainActor.run {
                post.isRead = true
            }
        } catch {
            print("Mark post as read failed with error: \(error)")
        }
    }
}
