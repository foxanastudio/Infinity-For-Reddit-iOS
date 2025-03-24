//
//  CommentViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-17.
//  

import Foundation
import Alamofire

public class CommentViewModel: ObservableObject {
    let account: Account
    let session: Session
    @Published var comment: Comment
    
    public init(account: Account, comment: Comment) {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
        self.account = account
        self.comment = comment
    }
    
    func voteComment(vote: Int) {
        guard let _ = account.accessToken, let fullName = comment.name else { return }
        let previousVote = comment.likes
        
        var point: String
        let finalVote: Int
        if vote == comment.likes {
            point = "0"
            finalVote = 0
            comment.likes = 0
        } else {
            point = String(vote)
            finalVote = vote
            comment.likes = vote
        }
        self.objectWillChange.send()
        
        let params = ["dir": point, "id": fullName, "rank": "10"]
        session.request(RedditOAuthAPI.vote(params: params))
            .validate()
            .responseData { response in
                switch response.result {
                case .success(_):
                    self.comment.likes = finalVote
                    self.objectWillChange.send()
                case .failure(_):
                    self.comment.likes = previousVote
                    self.objectWillChange.send()
                }
            }
        }
}
