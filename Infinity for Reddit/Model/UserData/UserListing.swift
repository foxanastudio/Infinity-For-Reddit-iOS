//
//  UserListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Foundation
import SwiftyJSON

class UserListingRootClass: NSObject {
    var kind: String!
    var data: UserListing!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            data = try UserListing(fromJson: dataJson)
        } else {
            throw JSONError.invalidData
        }
        kind = json["kind"].stringValue
    }
}

public class UserListing : NSObject {
    var users : [User]! = [User]()
    var after : String!
    var before : String!
    var dist : Int!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if !dataJson.isEmpty {
                do {
                    users.append(try User(fromJson: dataJson))
                } catch {
                    // Ignore
                    print(error)
                }
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
}
