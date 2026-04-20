//
//  ModMailConversationDetail.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-17.
//

import Foundation
import SwiftyJSON

public class ModMailConversationDetail: NSObject {
    var conversation: ModMailConversation
    var messages: [String: ModMailMessage] = [:]
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        let conversationJson = json["conversation"]
        if conversationJson.isEmpty {
            throw JSONError.invalidData
        }
        
        conversation = try ModMailConversation(fromJson: conversationJson)
        
        for (messageId, messageJson):(String, JSON) in json["messages"] {
            do {
                messages[messageId] = try ModMailMessage(fromJson: messageJson)
            } catch {
                printInDebugOnly("Error parsing ModMailMessage: \(error.localizedDescription)")
            }
        }
    }
    
    var orderedMessages: [ModMailMessage] {
        conversation.objIds.compactMap { objectId in
            guard objectId.key == "messages" else {
                return nil
            }
            
            return messages[objectId.id]
        }
    }

    func appendMessage(body: String, isInternal: Bool, authorName: String) -> ModMailMessage {
        let messageId = "local-\(UUID().uuidString)"
        let message = ModMailMessage(
            localId: messageId,
            body: body,
            isInternal: isInternal,
            authorName: authorName
        )

        messages[messageId] = message
        conversation.objIds.append(ModMailObjectId(localMessageId: messageId))
        conversation.numMessages += 1
        conversation.lastUpdatedUtc = message.dateUtc
        conversation.lastUpdated = message.date

        return message
    }
}
