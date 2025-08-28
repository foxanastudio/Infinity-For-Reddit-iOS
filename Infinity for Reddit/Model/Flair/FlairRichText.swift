//
//  FlairRichText.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-21.
//

import Foundation
import SwiftyJSON

public class FlairRichtext : NSObject, NSCoding {
    
    //Type e.g. "text", "emoji"
    var e : String!
    //Text
    var t : String!
    //Media id, e.g. :pixel9proxlporcelain:
    var a : String!
    //Media URL
    var u : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        e = json["e"].stringValue
        t = json["t"].stringValue
        a = json["a"].stringValue
        u = json["u"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if e != nil{
            dictionary["e"] = e
        }
        if t != nil{
            dictionary["t"] = t
        }
        if a != nil{
            dictionary["a"] = t
        }
        if u != nil{
            dictionary["u"] = t
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        e = aDecoder.decodeObject(forKey: "e") as? String
        t = aDecoder.decodeObject(forKey: "t") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if e != nil{
            aCoder.encode(e, forKey: "e")
        }
        if t != nil{
            aCoder.encode(t, forKey: "t")
        }
        
    }
    
}
