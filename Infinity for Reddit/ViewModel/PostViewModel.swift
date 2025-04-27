//
//  PostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-11.
//

import Foundation
import Alamofire
import Combine

public class PostViewModel: ObservableObject {
    let account: Account
    @Published var post: Post
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    let postRepository: PostRepositoryProtocol
    
    public init(account: Account, post: Post, postRepository: PostRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postRepository = postRepository
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
}
