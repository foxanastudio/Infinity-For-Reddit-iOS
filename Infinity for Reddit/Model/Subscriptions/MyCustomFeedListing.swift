//
//  MyCustomFeedListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Foundation
import SwiftyJSON

public class MyCustomFeedListing : NSObject, NSCoding{
    
    var customFeeds : [CustomFeed]!
    var kind : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        customFeeds = [CustomFeed]()
        let childrenArray = json.arrayValue
        for childrenJson in childrenArray{
            let value = CustomFeed(fromJson: childrenJson["data"])
            customFeeds.append(value)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if customFeeds != nil{
            var dictionaryElements = [[String:Any]]()
            for customFeed in customFeeds {
                dictionaryElements.append(customFeed.toDictionary())
            }
            dictionary["customFeeds"] = dictionaryElements
        }
        if kind != nil{
            dictionary["kind"] = kind
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc public required init(coder aDecoder: NSCoder)
    {
        customFeeds = aDecoder.decodeObject(forKey: "data") as? [CustomFeed]
        kind = aDecoder.decodeObject(forKey: "kind") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if customFeeds != nil{
            aCoder.encode(customFeeds, forKey: "data")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        
    }
    
}

class CustomFeed : NSObject, NSCoding{
    
    var canEdit : Bool!
    var created : Float!
    var createdUtc : Float!
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
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        canEdit = json["can_edit"].boolValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].floatValue
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
        for subredditsJson in subredditsArray{
            let value = SubredditInCustomFeed(fromJson: subredditsJson)
            subredditsInCustomFeed.append(value)
        }
        visibility = json["visibility"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if canEdit != nil{
            dictionary["can_edit"] = canEdit
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if descriptionHtml != nil{
            dictionary["description_html"] = descriptionHtml
        }
        if descriptionMd != nil{
            dictionary["description_md"] = descriptionMd
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if iconUrl != nil{
            dictionary["icon_url"] = iconUrl
        }
        if isFavorited != nil{
            dictionary["is_favorited"] = isFavorited
        }
        if isSubscriber != nil{
            dictionary["is_subscriber"] = isSubscriber
        }
        if name != nil{
            dictionary["name"] = name
        }
        if numSubscribers != nil{
            dictionary["num_subscribers"] = numSubscribers
        }
        if over18 != nil{
            dictionary["over_18"] = over18
        }
        if owner != nil{
            dictionary["owner"] = owner
        }
        if ownerId != nil{
            dictionary["owner_id"] = ownerId
        }
        if path != nil{
            dictionary["path"] = path
        }
        if subredditsInCustomFeed != nil{
            var dictionaryElements = [[String:Any]]()
            for subredditsElement in subredditsInCustomFeed {
                dictionaryElements.append(subredditsElement.toDictionary())
            }
            dictionary["subreddits"] = dictionaryElements
        }
        if visibility != nil{
            dictionary["visibility"] = visibility
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        canEdit = aDecoder.decodeObject(forKey: "can_edit") as? Bool
        created = aDecoder.decodeObject(forKey: "created") as? Float
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Float
        descriptionHtml = aDecoder.decodeObject(forKey: "description_html") as? String
        descriptionMd = aDecoder.decodeObject(forKey: "description_md") as? String
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        iconUrl = aDecoder.decodeObject(forKey: "icon_url") as? String
        isFavorited = aDecoder.decodeObject(forKey: "is_favorited") as? Bool
        isSubscriber = aDecoder.decodeObject(forKey: "is_subscriber") as? Bool
        name = aDecoder.decodeObject(forKey: "name") as? String
        numSubscribers = aDecoder.decodeObject(forKey: "num_subscribers") as? Int
        over18 = aDecoder.decodeObject(forKey: "over_18") as? Bool
        owner = aDecoder.decodeObject(forKey: "owner") as? String
        ownerId = aDecoder.decodeObject(forKey: "owner_id") as? String
        path = aDecoder.decodeObject(forKey: "path") as? String
        subredditsInCustomFeed = aDecoder.decodeObject(forKey: "subreddits") as? [SubredditInCustomFeed]
        visibility = aDecoder.decodeObject(forKey: "visibility") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if canEdit != nil{
            aCoder.encode(canEdit, forKey: "can_edit")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if descriptionHtml != nil{
            aCoder.encode(descriptionHtml, forKey: "description_html")
        }
        if descriptionMd != nil{
            aCoder.encode(descriptionMd, forKey: "description_md")
        }
        if displayName != nil{
            aCoder.encode(displayName, forKey: "display_name")
        }
        if iconUrl != nil{
            aCoder.encode(iconUrl, forKey: "icon_url")
        }
        if isFavorited != nil{
            aCoder.encode(isFavorited, forKey: "is_favorited")
        }
        if isSubscriber != nil{
            aCoder.encode(isSubscriber, forKey: "is_subscriber")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if numSubscribers != nil{
            aCoder.encode(numSubscribers, forKey: "num_subscribers")
        }
        if over18 != nil{
            aCoder.encode(over18, forKey: "over_18")
        }
        if owner != nil{
            aCoder.encode(owner, forKey: "owner")
        }
        if ownerId != nil{
            aCoder.encode(ownerId, forKey: "owner_id")
        }
        if path != nil{
            aCoder.encode(path, forKey: "path")
        }
        if subredditsInCustomFeed != nil{
            aCoder.encode(subredditsInCustomFeed, forKey: "subreddits")
        }
        if visibility != nil{
            aCoder.encode(visibility, forKey: "visibility")
        }
    }
}

class SubredditInCustomFeed : NSObject, NSCoding{
    
    var name : String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        name = json["name"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if name != nil{
            dictionary["name"] = name
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        name = aDecoder.decodeObject(forKey: "name") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        
    }
    
}
