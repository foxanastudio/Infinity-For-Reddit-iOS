//
//  PartialUserDataListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-26.
//

import Foundation
import SwiftyJSON
import GRDB

struct PartialUserDataListing {
    var partialUserDataDictionary: [String: PartialUserData] = [:]

    init(fromJson json: JSON) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        json.dictionaryValue.forEach { key, value in
            do {
                partialUserDataDictionary[key] = try PartialUserData(fromJson: value)
            } catch {
                // Ignore
                print(error.localizedDescription)
            }
        }
    }
}

class PartialUserData: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName: String = "partial_users"
    
    var username : String
    var profileImageUrlString : String
    var linkKarma : Int
    var commentKarma : Int
    var createdUtc : Int64
    var profileOver18 : Bool
    var profileColor : String

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        commentKarma = json["comment_karma"].intValue
        createdUtc = json["created_utc"].int64Value
        linkKarma = json["link_karma"].intValue
        username = json["name"].stringValue
        profileColor = json["profile_color"].stringValue
        profileImageUrlString = json["profile_img"].stringValue
        profileOver18 = json["profile_over_18"].boolValue
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case username
        case profileImageUrlString = "profile_image_url"
        case linkKarma = "link_karma"
        case commentKarma = "comment_karma"
        case createdUtc = "created_utc"
        case profileOver18 = "over_18"
        case profileColor = "profile_color"
    }
}
