//
//  Inbox.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation
import SwiftyJSON

class InboxListingRootClass: NSObject, NSCoding{
    var kind: String!
    var data: InboxListing!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!, messageWhere: MessageWhere) {
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = InboxListing(fromJson: dataJson, messageWhere: messageWhere)
        }
        kind = json["kind"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if data != nil{
            dictionary["data"] = data.toDictionary()
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
    @objc required init(coder aDecoder: NSCoder)
    {
        data = aDecoder.decodeObject(forKey: "data") as? InboxListing
        kind = aDecoder.decodeObject(forKey: "kind") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if data != nil{
            aCoder.encode(data, forKey: "data")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
    }
}

public class InboxListing : NSObject, NSCoding {
    var inboxes : [Inbox]! = [Inbox]()
    var after : String!
    var before : String!
    var dist : Int!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!, messageWhere: MessageWhere) {
        if json.isEmpty {
            return
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if !dataJson.isEmpty {
                if !(messageWhere == .inbox && childJSON["kind"].stringValue == "t4") {
                    inboxes.append(Inbox(fromJson: dataJson, kind: childJSON["kind"].stringValue, messageWhere: messageWhere))
                }
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if after != nil{
            dictionary["after"] = after
        }
        if before != nil{
            dictionary["before"] = before
        }
        if dist != nil{
            dictionary["dist"] = dist
        }
        if inboxes != nil {
            dictionary["children"] = inboxes
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc public required init(coder aDecoder: NSCoder)
    {
        after = aDecoder.decodeObject(forKey: "after") as? String
        before = aDecoder.decodeObject(forKey: "before") as? String
        dist = aDecoder.decodeObject(forKey: "dist") as? Int
        inboxes = aDecoder.decodeObject(forKey: "children") as? [Inbox]
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if after != nil{
            aCoder.encode(after, forKey: "after")
        }
        if before != nil{
            aCoder.encode(before, forKey: "before")
        }
        if dist != nil{
            aCoder.encode(dist, forKey: "dist")
        }
        if inboxes != nil {
            aCoder.encode(inboxes, forKey: "children")
        }
    }
}
