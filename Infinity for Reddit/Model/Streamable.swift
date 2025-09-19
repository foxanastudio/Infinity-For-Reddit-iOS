//
//  Streamable.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-18.
//

import Foundation
import SwiftyJSON

class Streamable {
    var embedCode : String!
    var title : String!
    var url : String!
    var mp4 : StreamableMedia?
    var mp4mobile : StreamableMedia?

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        embedCode = json["embed_code"].stringValue
        let filesJson = json["files"]
        if !filesJson.isEmpty {
            let mp4Json = filesJson["mp4"]
            if !mp4Json.isEmpty {
                mp4 = StreamableMedia(fromJson: mp4Json)
            }
            let mp4mobileJson = filesJson["mp4-mobile"]
            if !mp4mobileJson.isEmpty {
                mp4mobile = StreamableMedia(fromJson: mp4mobileJson)
            }
        }
        title = json["title"].stringValue
        url = json["url"].stringValue
    }
}

class StreamableMedia {
    var duration : Float!
    var height : Int!
    var size : Int!
    var url : String!
    var width : Int!

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        duration = json["duration"].floatValue
        height = json["height"].intValue
        size = json["size"].intValue
        url = json["url"].stringValue
        width = json["width"].intValue
    }
}
