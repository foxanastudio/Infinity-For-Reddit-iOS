//
//  Inbox.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation
import SwiftyJSON

public class Inbox : NSObject {
    
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
    var replies : InboxListingRootClass!
    var score : Int!
    var subject : String!
    var subreddit : String!
    var subredditNamePrefixed : String!
    var type : String!
    var wasComment : Bool!

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
        let repliesJson = json["replies"]
        if repliesJson.type == .dictionary, let messageWhere = messageWhere {
            do {
                replies = try InboxListingRootClass(fromJson: json["replies"], messageWhere: messageWhere)
            } catch {
                print("Error parsing InboxListingRootClass in Inbox: \(error.localizedDescription)")
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

extension Inbox {
    enum MessageKind: String {
        case t1, t2, t3, t4, t5, t6, unknown
    }
    
    var messageKind: MessageKind {
        MessageKind(rawValue: (kind ?? "").lowercased()) ?? .unknown
    }
    
    var createdDate: Date? {
        guard let timestamp = createdUtc, timestamp > 0 else { return nil }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}
