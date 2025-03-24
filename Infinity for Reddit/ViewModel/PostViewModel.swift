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
    
    private var cancellables = Set<AnyCancellable>()
    
    let postRepository: PostRepositoryProtocol
    
    public init(account: Account, post: Post, postRepository: PostRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postRepository = postRepository
    }
    
    func votePost(vote: Int) {
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
        
        postRepository.votePost(post: post, point: point)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(_) = completion {
                    self?.post.likes = previousVote
                } else {
                    self?.post.likes = finalVote
                }
                self?.objectWillChange.send()
            }, receiveValue: {})
            .store(in: &cancellables)
        }
}
