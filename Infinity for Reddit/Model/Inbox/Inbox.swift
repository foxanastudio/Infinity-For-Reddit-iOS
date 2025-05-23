//
//  Inbox.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation
import SwiftyJSON

class Inbox : NSObject, NSCoding{
    
    var kind: String!
    
    var associatedAwardingId : String!
    var author : String!
    var authorFullname : String!
    var body : String!
    var bodyHtml : String!
    var context : String!
    var created : Float!
    var createdUtc : Float!
    var dest : String!
    var distinguished : String!
    var firstMessage : Int64!
    var firstMessageName : String!
    var id : String!
    var likes : Bool!
    var linkTitle : String!
    var name : String!
    var newField : Bool!
    var numComments : Int!
    var parentId : String!
    var replies : String!
    var score : Int!
    var subject : String!
    var subreddit : String!
    var subredditNamePrefixed : String!
    var type : String!
    var wasComment : Bool!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!, kind: String!){
        if json.isEmpty{
            return
        }
        self.kind = kind
        associatedAwardingId = json["associated_awarding_id"].stringValue
        author = json["author"].stringValue
        authorFullname = json["author_fullname"].stringValue
        body = json["body"].stringValue
        bodyHtml = json["body_html"].stringValue
        context = json["context"].stringValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].floatValue
        dest = json["dest"].stringValue
        distinguished = json["distinguished"].stringValue
        firstMessage = json["first_message"].int64Value
        firstMessageName = json["first_message_name"].stringValue
        id = json["id"].stringValue
        likes = json["likes"].boolValue
        linkTitle = json["link_title"].stringValue
        name = json["name"].stringValue
        newField = json["new"].boolValue
        numComments = json["num_comments"].intValue
        parentId = json["parent_id"].stringValue
        replies = json["replies"].stringValue
        score = json["score"].intValue
        subject = json["subject"].stringValue
        subreddit = json["subreddit"].stringValue
        subredditNamePrefixed = json["subreddit_name_prefixed"].stringValue
        type = json["type"].stringValue
        wasComment = json["was_comment"].boolValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if kind != nil {
            dictionary["kind"] = kind
        }
        if associatedAwardingId != nil{
            dictionary["associated_awarding_id"] = associatedAwardingId
        }
        if author != nil{
            dictionary["author"] = author
        }
        if authorFullname != nil{
            dictionary["author_fullname"] = authorFullname
        }
        if body != nil{
            dictionary["body"] = body
        }
        if bodyHtml != nil{
            dictionary["body_html"] = bodyHtml
        }
        if context != nil{
            dictionary["context"] = context
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if dest != nil{
            dictionary["dest"] = dest
        }
        if distinguished != nil{
            dictionary["distinguished"] = distinguished
        }
        if firstMessage != nil{
            dictionary["first_message"] = firstMessage
        }
        if firstMessageName != nil{
            dictionary["first_message_name"] = firstMessageName
        }
        if id != nil{
            dictionary["id"] = id
        }
        if likes != nil{
            dictionary["likes"] = likes
        }
        if linkTitle != nil{
            dictionary["link_title"] = linkTitle
        }
        if name != nil{
            dictionary["name"] = name
        }
        if newField != nil{
            dictionary["new"] = newField
        }
        if numComments != nil{
            dictionary["num_comments"] = numComments
        }
        if parentId != nil{
            dictionary["parent_id"] = parentId
        }
        if replies != nil{
            dictionary["replies"] = replies
        }
        if score != nil{
            dictionary["score"] = score
        }
        if subject != nil{
            dictionary["subject"] = subject
        }
        if subreddit != nil{
            dictionary["subreddit"] = subreddit
        }
        if subredditNamePrefixed != nil{
            dictionary["subreddit_name_prefixed"] = subredditNamePrefixed
        }
        if type != nil{
            dictionary["type"] = type
        }
        if wasComment != nil{
            dictionary["was_comment"] = wasComment
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        kind = aDecoder.decodeObject(forKey: "kind") as? String
        associatedAwardingId = aDecoder.decodeObject(forKey: "associated_awarding_id") as? String
        author = aDecoder.decodeObject(forKey: "author") as? String
        authorFullname = aDecoder.decodeObject(forKey: "author_fullname") as? String
        body = aDecoder.decodeObject(forKey: "body") as? String
        bodyHtml = aDecoder.decodeObject(forKey: "body_html") as? String
        context = aDecoder.decodeObject(forKey: "context") as? String
        created = aDecoder.decodeObject(forKey: "created") as? Float
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Float
        dest = aDecoder.decodeObject(forKey: "dest") as? String
        distinguished = aDecoder.decodeObject(forKey: "distinguished") as? String
        firstMessage = aDecoder.decodeObject(forKey: "first_message") as? Int64
        firstMessageName = aDecoder.decodeObject(forKey: "first_message_name") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        likes = aDecoder.decodeObject(forKey: "likes") as? Bool
        linkTitle = aDecoder.decodeObject(forKey: "link_title") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        newField = aDecoder.decodeObject(forKey: "new") as? Bool
        numComments = aDecoder.decodeObject(forKey: "num_comments") as? Int
        parentId = aDecoder.decodeObject(forKey: "parent_id") as? String
        replies = aDecoder.decodeObject(forKey: "replies") as? String
        score = aDecoder.decodeObject(forKey: "score") as? Int
        subject = aDecoder.decodeObject(forKey: "subject") as? String
        subreddit = aDecoder.decodeObject(forKey: "subreddit") as? String
        subredditNamePrefixed = aDecoder.decodeObject(forKey: "subreddit_name_prefixed") as? String
        type = aDecoder.decodeObject(forKey: "type") as? String
        wasComment = aDecoder.decodeObject(forKey: "was_comment") as? Bool
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if kind != nil {
            aCoder.encode(kind, forKey: "kind")
        }
        if associatedAwardingId != nil{
            aCoder.encode(associatedAwardingId, forKey: "associated_awarding_id")
        }
        if author != nil{
            aCoder.encode(author, forKey: "author")
        }
        if authorFullname != nil{
            aCoder.encode(authorFullname, forKey: "author_fullname")
        }
        if body != nil{
            aCoder.encode(body, forKey: "body")
        }
        if bodyHtml != nil{
            aCoder.encode(bodyHtml, forKey: "body_html")
        }
        if context != nil{
            aCoder.encode(context, forKey: "context")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if dest != nil{
            aCoder.encode(dest, forKey: "dest")
        }
        if distinguished != nil{
            aCoder.encode(distinguished, forKey: "distinguished")
        }
        if firstMessage != nil{
            aCoder.encode(firstMessage, forKey: "first_message")
        }
        if firstMessageName != nil{
            aCoder.encode(firstMessageName, forKey: "first_message_name")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if likes != nil{
            aCoder.encode(likes, forKey: "likes")
        }
        if linkTitle != nil{
            aCoder.encode(linkTitle, forKey: "link_title")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if newField != nil{
            aCoder.encode(newField, forKey: "new")
        }
        if numComments != nil{
            aCoder.encode(numComments, forKey: "num_comments")
        }
        if parentId != nil{
            aCoder.encode(parentId, forKey: "parent_id")
        }
        if replies != nil{
            aCoder.encode(replies, forKey: "replies")
        }
        if score != nil{
            aCoder.encode(score, forKey: "score")
        }
        if subject != nil{
            aCoder.encode(subject, forKey: "subject")
        }
        if subreddit != nil{
            aCoder.encode(subreddit, forKey: "subreddit")
        }
        if subredditNamePrefixed != nil{
            aCoder.encode(subredditNamePrefixed, forKey: "subreddit_name_prefixed")
        }
        if type != nil{
            aCoder.encode(type, forKey: "type")
        }
        if wasComment != nil{
            aCoder.encode(wasComment, forKey: "was_comment")
        }
    }
}
