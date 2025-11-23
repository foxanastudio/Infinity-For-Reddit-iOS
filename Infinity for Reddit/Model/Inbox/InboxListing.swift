//
//  Inbox.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-23.
//

import Foundation
import SwiftyJSON

class InboxListingRootClass: NSObject {
    var kind: String!
    var data: InboxListing!

    init(fromJson json: JSON!, messageWhere: MessageWhere) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            data = try InboxListing(fromJson: dataJson, messageWhere: messageWhere)
        } else {
            throw JSONError.invalidData
        }
        kind = json["kind"].stringValue
    }
    
    init(inbox: Inbox) {
        // I know it looks ugly
        kind = "t4"
        data = InboxListing(inbox: inbox)
    }
}

public class InboxListing : NSObject {
    var inboxes : [Inbox]! = [Inbox]()
    var after : String!
    var before : String!
    var dist : Int!

    init(fromJson json: JSON!, messageWhere: MessageWhere) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if !dataJson.isEmpty {
                if !(messageWhere == .inbox && childJSON["kind"].stringValue == "t4") {
                    do {
                        inboxes.append(try Inbox(fromJson: dataJson, kind: childJSON["kind"].stringValue, messageWhere: messageWhere))
                    } catch {
                        print("Error parsing Inbox in InboxListing: \(error.localizedDescription)")
                    }
                }
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
    
    init(inbox: Inbox) {
        inboxes = [inbox]
        after = ""
        before = ""
        dist = 0
    }
}
