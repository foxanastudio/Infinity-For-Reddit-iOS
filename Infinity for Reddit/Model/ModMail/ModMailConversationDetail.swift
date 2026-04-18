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
}
