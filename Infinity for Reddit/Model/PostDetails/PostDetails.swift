//
//  PostDetails.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation
import SwiftyJSON
import MarkdownUI

public class PostDetailsRootClass: NSObject, NSCoding, Validatable {
    var postListing: PostListing!
    var commentListing: CommentListing!
    var comments: [Comment] = []
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) throws {
        try Self.validate(json: json)
        
        if json.isEmpty{
            return
        }
        
        let postListingJson = json[0]
        if !postListingJson.isEmpty {
            postListing = PostListingRootClass(fromJson: postListingJson).data
        }
        let commentListingJson = json[1]
        if !commentListingJson.isEmpty {
            commentListing = try CommentListingRootClass(fromJson: commentListingJson).data
        }
    }
    
    func makeCommentList() {
        comments = []
        makeCommentList(commentListing: commentListing)
    }
    
    private func makeCommentList(commentListing: CommentListing) {
        guard !commentListing.comments.isEmpty else { return }
        for comment in commentListing.comments {
            guard let childrenCommentListing = comment.replies else {
                comments.append(comment)
                continue
            }
            
            comments.append(comment)
            makeCommentList(commentListing: childrenCommentListing)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if postListing != nil {
            dictionary["postListing"] = postListing.toDictionary()
        }
        if commentListing != nil {
            dictionary["commentListing"] = commentListing.toDictionary()
        }
        return dictionary
    }
    
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        postListing = aDecoder.decodeObject(forKey: "postListing") as? PostListing
        commentListing = aDecoder.decodeObject(forKey: "commentListing") as? CommentListing
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if postListing != nil{
            aCoder.encode(postListing, forKey: "postListing")
        }
        if commentListing != nil{
            aCoder.encode(commentListing, forKey: "commentListing")
        }
    }
}
