//
//  MoreChildren.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-28.
//

import Foundation
import SwiftyJSON

public class MoreChildren : NSObject {
    var comments : [Comment]! = [Comment]()
    var errors : [String]!
    
    var commentItems : [CommentItem] = []

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        let jsonJson = json["json"]
        if !jsonJson.isEmpty {
            errors = [String]()
            let errorsArray = jsonJson["errors"].arrayValue
            for errorsJson in errorsArray{
                errors.append(errorsJson.stringValue)
            }
            
            if !jsonJson["data"].isEmpty && !jsonJson["data"]["things"].isEmpty {
                let thingsJsonArray = jsonJson["data"]["things"].arrayValue
                for childThing in thingsJsonArray {
                    let dataJson = childThing["data"]
                    if !dataJson.isEmpty {
                        do {
                            try comments.append(Comment(fromJson: dataJson))
                        } catch {
                            // Ignore
                        }
                    }
                }
            }
        }
    }
    
    func makeCommentList() {
        commentItems = []
        for comment in comments {
            commentItems.append(CommentItem.comment(comment))
            makeCommentList(commentListing: comment.replies)
        }
    }
    
    private func makeCommentList(commentListing: CommentListing?) {
        guard let commentListing = commentListing else {
            return
        }
        
        for comment in commentListing.comments {
            guard let childrenCommentListing = comment.replies else {
                commentItems.append(CommentItem.comment(comment))
                continue
            }
            
            commentItems.append(CommentItem.comment(comment))
            makeCommentList(commentListing: childrenCommentListing)
        }
        
        if let commentMore = commentListing.commentMore {
            commentItems.append(CommentItem.more(commentMore))
        }
    }
}
