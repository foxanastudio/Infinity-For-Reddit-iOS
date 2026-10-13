//
//  ModeratedSubredditListing.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

import Foundation
import SwiftyJSON

class ModeratedSubredditListing: NSObject {
    var subreddits: [ModeratedSubreddit] = []
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        let subredditsJson = json["subreddits"]
        if subredditsJson.type != .dictionary {
            throw JSONError.invalidData
        }
        
        for (_, subredditJson):(String, JSON) in subredditsJson {
            do {
                subreddits.append(try ModeratedSubreddit(fromJson: subredditJson))
            } catch {
                printInDebugOnly("Error parsing ModeratedSubreddit: \(error.localizedDescription)")
            }
        }
    }
}

class ModeratedSubreddit: NSObject, Identifiable {
    let id: String
    let name: String
    let iconUrl: String?
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        id = json["id"].stringValue
        name = json["name"].stringValue
        
        let communityIcon = json["communityIcon"].stringValue
        let icon = json["icon"].stringValue
        iconUrl = !communityIcon.isEmpty ? communityIcon : (!icon.isEmpty ? icon : nil)
    }
}
