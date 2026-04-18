//
//  MediaMetadata.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-10.
//

import Foundation
import SwiftyJSON

class MediaMetadata : NSObject, ObservableObject, Identifiable {
    
    static let imageType = "Image"
    static let gifType = "AnimatedImage"
    static let redditVideoType = "RedditVideo"
    
    // Type (image: Image, gif: AnimatedImage)
    var e : String!
    var id : String!
    //MIME Type
    var m : String!
    // Preview, only images
    var p : [MediaMetadataPreview]! = [MediaMetadataPreview]()
    // Source, may contain gif and image
    var s : MediaMetadataSource?
    //E.g. "Valid"
    var status : String!
    var caption: String?
    // For video
    var x: Int!
    var y: Int!
    var dashUrl: String!
    var hlsUrl: String!
    var isGif: Bool!
    var videoLinkMarkdown: String?

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        status = json["status"].stringValue
        if status == "failed" {
            throw JSONError.invalidData
        }
        
        e = json["e"].stringValue
        id = json["id"].stringValue
        m = json["m"].stringValue
        let pArray = json["p"].arrayValue
        for pJson in pArray {
            do {
                let value = try MediaMetadataPreview(fromJson: pJson)
                p.append(value)
            } catch {
                // Ignore
            }
        }
        
        s = try? MediaMetadataSource(fromJson: json["s"])
        if s == nil && p.isEmpty {
            throw JSONError.invalidData
        }
        
        x = json["x"].intValue
        y = json["y"].intValue
        dashUrl = json["dashUrl"].stringValue
        hlsUrl = json["hlsUrl"].stringValue
        isGif = json["isGif"].boolValue
    }
    
    init(e: String, id: String, m: String, isGif: Bool, s: MediaMetadataSource) {
        self.e = e
        self.id = id
        self.m = m
        self.isGif = isGif
        self.s = s
        
        x = 0
        y = 0
        dashUrl = ""
        hlsUrl = ""
    }
}

class MediaMetadataPreview : NSObject, ObservableObject, Identifiable {
    
    //URL
    var u : String!
    //Width
    var x : Int!
    //Height
    var y : Int!
    var aspectRatio : CGSize

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        u = json["u"].stringValue
        x = json["x"].intValue
        y = json["y"].intValue
        aspectRatio = CGSize(width: x, height: y)
    }
}

class MediaMetadataSource : NSObject {
    
    // Image URL
    var u : String?
    var gif: String?
    var mp4: String?
    // Width
    var x : Int!
    // Height
    var y : Int!
    var aspectRatio : CGSize

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        u = json["u"].stringValue
        gif = json["gif"].stringValue
        mp4 = json["mp4"].stringValue
        x = json["x"].intValue
        y = json["y"].intValue
        aspectRatio = CGSize(width: x, height: y)
    }
    
    // Fallback for invalid giphy gifs
    init(gif: String, mp4: String) {
        self.gif = gif
        self.mp4 = mp4
        self.x = 480
        self.y = 480
        aspectRatio = CGSize(width: x, height: y)
    }
}
