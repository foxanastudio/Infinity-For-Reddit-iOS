//
//  MyCustomFeedListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Foundation
import SwiftyJSON

public class MyCustomFeedListing : NSObject {
    var customFeeds : [CustomFeed]!
    var kind : String!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        customFeeds = [CustomFeed]()
        let childrenArray = json.arrayValue
        for childrenJson in childrenArray {
            do {
                let value = try CustomFeed(fromJson: childrenJson["data"])
                customFeeds.append(value)
            } catch {
                // Ignore
            }
        }
    }
}

class CustomFeed : NSObject {
    var canEdit : Bool!
    var copiedFrom: String!
    var created : Float!
    var createdUtc : Int64!
    var descriptionHtml : String!
    var descriptionMd : String!
    var displayName : String!
    var iconUrl : String!
    var isFavorited : Bool!
    var isSubscriber : Bool!
    var name : String!
    var numSubscribers : Int!
    var over18 : Bool!
    var owner : String!
    var ownerId : String!
    var path : String!
    var subredditsInCustomFeed : [SubredditInCustomFeed]!
    var visibility : String!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        canEdit = json["can_edit"].boolValue
        copiedFrom = json["copied_from"].stringValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].int64Value
        descriptionHtml = json["description_html"].stringValue
        descriptionMd = json["description_md"].stringValue
        displayName = json["display_name"].stringValue
        iconUrl = json["icon_url"].stringValue
        isFavorited = json["is_favorited"].boolValue
        isSubscriber = json["is_subscriber"].boolValue
        name = json["name"].stringValue
        numSubscribers = json["num_subscribers"].intValue
        over18 = json["over_18"].boolValue
        owner = json["owner"].stringValue
        ownerId = json["owner_id"].stringValue
        path = json["path"].stringValue
        subredditsInCustomFeed = [SubredditInCustomFeed]()
        let subredditsArray = json["subreddits"].arrayValue
        for subredditsJson in subredditsArray {
            do {
                let value = try SubredditInCustomFeed(fromJson: subredditsJson)
                subredditsInCustomFeed.append(value)
            } catch {
                // Ignore
            }
        }
        visibility = json["visibility"].stringValue
    }
}

class SubredditInCustomFeed : NSObject {
    var name : String!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        name = json["name"].stringValue
    }
}
