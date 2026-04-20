//
//  ModMailListing.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-09.
//

import Foundation
import SwiftyJSON

public class ModMailListing: NSObject {
    var viewerId: String!
    var after: String!
    var conversationIds: [String]! = []
    var conversations: [String: ModMailConversation]! = [:]
    var messages: [String: ModMailMessage]! = [:]
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        viewerId = json["viewerId"].stringValue
        conversationIds = json["conversationIds"].arrayValue.map(\.stringValue)
        after = json["after"].string ?? conversationIds.last
        
        for (conversationId, conversationJson):(String, JSON) in json["conversations"] {
            do {
                conversations[conversationId] = try ModMailConversation(fromJson: conversationJson)
            } catch {
                printInDebugOnly("Error parsing ModMailConversation: \(error.localizedDescription)")
            }
        }
        
        for (messageId, messageJson):(String, JSON) in json["messages"] {
            do {
                messages[messageId] = try ModMailMessage(fromJson: messageJson)
            } catch {
                printInDebugOnly("Error parsing ModMailMessage: \(error.localizedDescription)")
            }
        }
    }
    
    var orderedConversations: [ModMailConversation] {
        conversationIds.compactMap { conversations[$0] }
    }
    
    func latestMessagePreview(for conversation: ModMailConversation) -> String {
        for objectId in conversation.objIds.reversed() {
            guard objectId.key == "messages", let message = messages[objectId.id] else {
                continue
            }
            
            let bodyMarkdown = message.bodyMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
            if !bodyMarkdown.isEmpty {
                return bodyMarkdown
            }
            
            return message.body.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return ""
    }
}

public class ModMailConversation: NSObject {
    var id: String!
    var subject: String!
    var owner: ModMailOwner!
    var lastModUpdate: String!
    var participantSubreddit: JSON!
    var isHighlighted: Bool!
    var conversationType: String!
    var numMessages: Int!
    var authors: [ModMailAuthor]! = []
    var objIds: [ModMailObjectId]! = []
    var lastUpdated: String!
    var lastUpdatedUtc: Int64
    var isAuto: Bool!
    var legacyFirstMessageId: String!
    var isRepliable: Bool!
    var participant: ModMailAuthor!
    var lastUserUpdate: String!
    var state: Int!
    var lastUnread: String!
    var isInternal: Bool!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].stringValue
        subject = json["subject"].stringValue
        owner = try ModMailOwner(fromJson: json["owner"])
        lastModUpdate = json["lastModUpdate"].string
        participantSubreddit = json["participantSubreddit"]
        isHighlighted = json["isHighlighted"].boolValue
        conversationType = json["conversationType"].stringValue
        numMessages = json["numMessages"].intValue
        authors = json["authors"].arrayValue.compactMap { try? ModMailAuthor(fromJson: $0) }
        objIds = json["objIds"].arrayValue.compactMap { try? ModMailObjectId(fromJson: $0) }
        lastUpdated = json["lastUpdated"].stringValue
        lastUpdatedUtc = ModMailDateParser.parseSeconds(from: lastUpdated)
        isAuto = json["isAuto"].boolValue
        legacyFirstMessageId = json["legacyFirstMessageId"].stringValue
        isRepliable = json["isRepliable"].boolValue
        participant = try ModMailAuthor(fromJson: json["participant"])
        lastUserUpdate = json["lastUserUpdate"].stringValue
        state = json["state"].intValue
        lastUnread = json["lastUnread"].string
        isInternal = json["isInternal"].boolValue
    }
    
    var replyCount: Int {
        max(0, numMessages - 1)
    }
    
    var isUnread: Bool {
        lastUnread != nil
    }
}

public class ModMailOwner: NSObject {
    var id: String!
    var type: String!
    var displayName: String!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].stringValue
        type = json["type"].stringValue
        displayName = json["displayName"].stringValue
    }
}

public class ModMailAuthor: NSObject {
    var id: Int64!
    var name: String!
    var isAdmin: Bool!
    var isDeleted: Bool!
    var isHidden: Bool!
    var isApproved: Bool!
    var isParticipant: Bool!
    var isMod: Bool!
    var isOp: Bool!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].int64Value
        name = json["name"].stringValue
        isAdmin = json["isAdmin"].boolValue
        isDeleted = json["isDeleted"].boolValue
        isHidden = json["isHidden"].boolValue
        isApproved = json["isApproved"].boolValue
        isParticipant = json["isParticipant"].boolValue
        isMod = json["isMod"].boolValue
        isOp = json["isOp"].boolValue
    }

    init(localName: String) {
        id = 0
        name = localName
        isAdmin = false
        isDeleted = false
        isHidden = false
        isApproved = false
        isParticipant = false
        isMod = true
        isOp = false
    }
}

public class ModMailMessage: NSObject {
    var id: String!
    var body: String!
    var bodyMarkdown: String!
    var date: String!
    var dateUtc: Int64
    var isInternal: Bool!
    var participatingAs: String!
    var author: ModMailAuthor!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].stringValue
        body = json["body"].stringValue
        bodyMarkdown = json["bodyMarkdown"].stringValue
        date = json["date"].stringValue
        dateUtc = ModMailDateParser.parseSeconds(from: date)
        isInternal = json["isInternal"].boolValue
        participatingAs = json["participatingAs"].stringValue
        author = try ModMailAuthor(fromJson: json["author"])
    }

    init(localId: String, body: String, isInternal: Bool, authorName: String) {
        id = localId
        self.body = body
        bodyMarkdown = body
        date = ISO8601DateFormatter().string(from: Date())
        dateUtc = Int64(Date().timeIntervalSince1970)
        self.isInternal = isInternal
        participatingAs = "moderator"
        author = ModMailAuthor(localName: authorName)
    }

    var displayBody: String {
        let bodyMarkdown = bodyMarkdown.trimmingCharacters(in: .whitespacesAndNewlines)
        if !bodyMarkdown.isEmpty {
            return bodyMarkdown
        }

        return body.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

public class ModMailObjectId: NSObject {
    var id: String!
    var key: String!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].stringValue
        key = json["key"].stringValue
    }

    init(localMessageId: String) {
        id = localMessageId
        key = "messages"
    }
}

private enum ModMailDateParser {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        return formatter
    }()
    
    static func parseSeconds(from string: String) -> Int64 {
        guard !string.isEmpty, let date = formatter.date(from: string) else {
            return 0
        }
        
        return Int64(date.timeIntervalSince1970)
    }
}
