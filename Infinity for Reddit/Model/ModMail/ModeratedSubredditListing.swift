//
//  ModeratedSubredditListing.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-07.
//

import Foundation
import SwiftyJSON

class ModeratedSubredditListing: NSObject {
    var after: String?
    var subreddits: [ModeratedSubreddit] = []
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        let dataJson = json["data"]
        if dataJson.isEmpty {
            throw JSONError.invalidData
        }

        after = dataJson["after"].string
        
        for childJson in dataJson["children"].arrayValue {
            do {
                subreddits.append(try ModeratedSubreddit(fromJson: childJson["data"]))
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
        
        id = json["name"].stringValue
        name = json["display_name"].stringValue
        
        let iconImg = json["icon_img"].stringValue
        let communityIcon = json["community_icon"].stringValue
        iconUrl = !iconImg.isEmpty ? iconImg : (!communityIcon.isEmpty ? communityIcon : nil)
    }
}
