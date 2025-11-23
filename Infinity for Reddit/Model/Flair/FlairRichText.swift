//
//  FlairRichText.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-21.
//

import Foundation
import SwiftyJSON

public class FlairRichtext: NSObject, Codable {    
    //Type e.g. "text", "emoji"
    var e : String!
    //Text
    var t : String!
    //Media id, e.g. :pixel9proxlporcelain:
    var a : String!
    //Media URL
    var u : String!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        e = json["e"].stringValue
        t = json["t"].stringValue
        a = json["a"].stringValue
        u = json["u"].stringValue
    }
}
