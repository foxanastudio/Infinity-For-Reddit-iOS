//
//  Inbox.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation
import SwiftyJSON

public class Inbox: NSObject {
    
    var kind: String
    
    var associatedAwardingId : String!
    var author : String
    var authorFullname : String!
    var body : String
    var bodyHtml : String!
    var context : String!
    var created : Int64!
    var createdUtc : Int64
    var dest : String!
    var distinguished : String!
    var firstMessage : Int64!
    var firstMessageName : String!
    var id : String!
    var isNew : Bool!
    var likes : Bool!
    var linkTitle : String!
    var name : String!
    var numComments : Int!
    var parentId : String!
    var replies : InboxListingRootClass?
    var score : Int!
    var subject : String!
    var subreddit : String!
    var subredditNamePrefixed : String!
    var type : String!
    var wasComment : Bool!
    
    enum InboxKind: String {
        case comment = "t1"
        case account = "t2"
        case link = "t3"
        case message = "t4"
        case subreddit = "t5"
        case award = "t6"
        case unknown
    }
    
    var inboxKind: InboxKind {
        return Inbox.InboxKind(rawValue: kind) ?? .unknown
    }
    
    var authorDisplayName: String {
        Inbox.resolveDisplayName(author, subreddit: subreddit)
    }
    
    var destDisplayName: String {
        Inbox.resolveDisplayName(dest, subreddit: subreddit)
    }
    
    private static func resolveDisplayName(_ rawValue: String, subreddit: String) -> String {
        guard rawValue.isEmpty || rawValue.hasPrefix("#") else {
            return rawValue
        }
        return subreddit.isEmpty ? rawValue : "r/\(subreddit)"
    }
    
    init(fromJson json: JSON!, kind: String!, messageWhere: MessageWhere?) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        self.kind = kind
        associatedAwardingId = json["associated_awarding_id"].stringValue
        author = json["author"].stringValue
        authorFullname = json["author_fullname"].stringValue
        body = json["body"].stringValue
        bodyHtml = json["body_html"].stringValue
        context = json["context"].stringValue
        created = json["created"].int64Value
        createdUtc = json["created_utc"].int64Value
        dest = json["dest"].stringValue
        distinguished = json["distinguished"].stringValue
        firstMessage = json["first_message"].int64Value
        firstMessageName = json["first_message_name"].stringValue
        id = json["id"].stringValue
        isNew = json["new"].boolValue
        likes = json["likes"].boolValue
        linkTitle = json["link_title"].stringValue
        name = json["name"].stringValue
        numComments = json["num_comments"].intValue
        parentId = json["parent_id"].stringValue
        let repliesJson = json["replies"]
        if repliesJson.type == .dictionary, let messageWhere = messageWhere {
            do {
                replies = try InboxListingRootClass(fromJson: json["replies"], messageWhere: messageWhere)
            } catch {
                printInDebugOnly("Error parsing InboxListingRootClass in Inbox: \(error.localizedDescription)")
            }
        }
        score = json["score"].intValue
        subject = json["subject"].stringValue
        subreddit = json["subreddit"].stringValue
        subredditNamePrefixed = json["subreddit_name_prefixed"].stringValue
        type = json["type"].stringValue
        wasComment = json["was_comment"].boolValue
    }
}
