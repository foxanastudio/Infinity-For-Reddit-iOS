//
//  PostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-11.
//

import Foundation
import Alamofire

public class PostViewModel: ObservableObject {
    let account: Account
    let session: Session
    @Published var post: Post
    
    public init(account: Account, post: Post) {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
        self.account = account
        self.post = post
    }
    
    func votePost(vote: Int) {
        guard let accessToken = account.accessToken, let fullName = post.name else { return }
        
        let previousVote = post.likes
        
        var point: String
        if vote == post.likes {
            point = "0"
            post.likes = 0
        } else {
            point = String(vote)
            post.likes = vote
        }
        self.objectWillChange.send()
        
        let params = ["dir": point, "id": fullName, "rank": "10"]
        session.request(RedditOAuthAPI.vote(params: params))
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.post.likes = Int(vote)
                    self.objectWillChange.send()
                case .failure(let error):
                    self.post.likes = previousVote
                    self.objectWillChange.send()
                }
            }
        }
}
