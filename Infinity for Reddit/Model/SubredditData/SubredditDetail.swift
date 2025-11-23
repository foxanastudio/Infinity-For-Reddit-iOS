//
// SubredditDetail.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-02
        
import Foundation
import SwiftyJSON


class SubredditDetailRootClass : NSObject {
    var data : Subreddit!
    var kind : String!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            data = try Subreddit(fromJson: dataJson)
        } else {
            throw JSONError.invalidData
        }
        kind = json["kind"].stringValue
    }
    
    // Helper method
    public func toSubredditData() -> SubredditData {
        return data.toSubredditData()
    }
}

//class CommentContributionSetting : NSObject, NSCoding{
//
//    var allowedMediaTypes : [String]!
//
//
//    /**
//     * Instantiate the instance using the passed json values to set the properties values
//     */
//    init(fromJson json: JSON!){
//        if json.isEmpty{
//            return
//        }
//        allowedMediaTypes = [String]()
//        let allowedMediaTypesArray = json["allowed_media_types"].arrayValue
//        for allowedMediaTypesJson in allowedMediaTypesArray{
//            allowedMediaTypes.append(allowedMediaTypesJson.stringValue)
//        }
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if allowedMediaTypes != nil{
//            dictionary["allowed_media_types"] = allowedMediaTypes
//        }
//        return dictionary
//    }
//
//    /**
//    * NSCoding required initializer.
//    * Fills the data from the passed decoder
//    */
//    @objc required init(coder aDecoder: NSCoder)
//    {
//         allowedMediaTypes = aDecoder.decodeObject(forKey: "allowed_media_types") as? [String]
//
//    }
//
//    /**
//    * NSCoding required method.
//    * Encodes mode properties into the decoder
//    */
//    func encode(with aCoder: NSCoder)
//    {
//        if allowedMediaTypes != nil{
//            aCoder.encode(allowedMediaTypes, forKey: "allowed_media_types")
//        }
//
//    }
//
//}
