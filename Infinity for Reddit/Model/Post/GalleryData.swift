//
//  GalleryData.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-01.
//

import Foundation
import SwiftyJSON

class GalleryData : NSObject, ObservableObject, Identifiable {
    
    var items : [GalleryItem]!

    init(fromJson json: JSON!, mediaMetadataDictionary: [String : MediaMetadata]?) throws {
        if json.isEmpty || mediaMetadataDictionary == nil || mediaMetadataDictionary!.isEmpty {
            throw JSONError.invalidData
        }
        items = [GalleryItem]()
        let itemsArray = json["items"].arrayValue
        for itemsJson in itemsArray {
            let value = try GalleryItem(fromJson: itemsJson, mediaMetadataDictionary: mediaMetadataDictionary!)
            items.append(value)
        }
    }
}


class GalleryItem : NSObject {
    
    var caption : String!
    var id : Int!
    var mediaId : String!
    
    var mimeType: String
    var urlString: String!
    var fallbackUrlString: String?
    var hasFallback: Bool = false
    var captionUrl: String?
    var mediaType: GalleryMediaType
    
    enum GalleryMediaType {
        case image
        case gif
        case video
    }

    init(fromJson json: JSON!, mediaMetadataDictionary: [String: MediaMetadata]) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        
        mediaId = json["media_id"].stringValue
        
        guard let media = mediaMetadataDictionary[mediaId] else {
            throw JSONError.invalidData
        }
        
        id = json["id"].intValue
        caption = json["caption"].stringValue
        
        mimeType = media.m
        if media.m.contains("jpg") || media.m.contains("png") {
            urlString = media.s.u
            mediaType = .image
            
            if let urlString, !urlString.isEmpty, let mediaId, !mediaId.isEmpty {
                let fileExtension = mimeType.split(separator: "/").last ?? ""
                fallbackUrlString = "https://i.redd.it/\(mediaId).\(fileExtension)"
                hasFallback = true
            }
        } else if media.m.contains("gif") {
            urlString = media.s.gif
            mediaType = .gif
        } else {
            urlString = media.s.mp4
            mediaType = .video
        }
        
        captionUrl = json["outbound_url"].string?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func getFileName(subredditName: String) -> String {
        return "\(subredditName)-\(mediaId ?? Utils.randomString()).\(mimeType.split(separator: "/").last ?? "")"
    }
}
