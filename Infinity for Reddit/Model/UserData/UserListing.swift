//
//  UserListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Foundation
import SwiftyJSON

class UserListingRootClass: NSObject, NSCoding{
    var kind: String!
    var data: UserListing!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = UserListing(fromJson: dataJson)
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
        data = aDecoder.decodeObject(forKey: "data") as? UserListing
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

public class UserListing : NSObject, NSCoding {
    var users : [User]! = [User]()
    var after : String!
    var before : String!
    var dist : Int!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if !dataJson.isEmpty{
                users.append(User(fromJson: dataJson))
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
        if users != nil {
            dictionary["children"] = users
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
        users = aDecoder.decodeObject(forKey: "children") as? [User]
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
        if users != nil {
            aCoder.encode(users, forKey: "children")
        }
    }
}
