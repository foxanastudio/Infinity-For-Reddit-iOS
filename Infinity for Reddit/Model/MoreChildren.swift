//
//  MoreChildren.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-28.
//

import Foundation
import SwiftyJSON

public class MoreChildren : NSObject {
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
                            if childThing["kind"] == "t1" {
                                // Comment
                                let comment = try Comment(fromJson: dataJson)
                                if let parent = MoreChildren.findParentComment(commentItems: commentItems, comment.parentId) {
                                    // Has a parent
                                    if let repliesListing = parent.replies {
                                        repliesListing.comments.append(comment)
                                    } else {
                                        parent.replies = CommentListing(reply: comment)
                                    }
                                }
                                commentItems.append(CommentItem.comment(comment))
                            } else if dataJson["kind"] == "more" {
                                let commentMore = try CommentMore(fromJson: dataJson)
                                if commentMore.children.isEmpty {
                                    // Continue thread
                                    commentMore.commentMoreType = .continueThread
                                }
                                if let parent = MoreChildren.findParentComment(commentItems: commentItems, commentMore.parentFullname) {
                                    // Has a parent
                                    if let repliesListing = parent.replies {
                                        repliesListing.commentMore = commentMore
                                    } else {
                                        parent.replies = CommentListing(commentMore: commentMore)
                                    }
                                    commentItems.append(CommentItem.more(commentMore))
                                }
                            }
                        } catch {
                            // Ignore
                        }
                    }
                }
            }
        }
    }
    
    private static func findParentComment(commentItems: [CommentItem], _ commentParentFullname: String) -> Comment? {
        for comment in commentItems.reversed() {
            if case .comment(let c) = comment {
                if c.name == commentParentFullname {
                    return c
                }
            }
        }
        
        return nil
    }
}
