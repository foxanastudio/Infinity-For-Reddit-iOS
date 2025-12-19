//
//  ImgurMedia.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-07.
//

import SwiftyJSON
import Foundation

class ImgurMediaRootClass {

    var imgurMedia : ImgurMedia!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            imgurMedia = try ImgurMedia(fromJson: dataJson)
        }
    }
}

class ImgurMedia {

    var accountId : Int!
    var accountUrl : String!
    var adType : Int!
    var adUrl : String!
    var commentCount : Int!
    var cover : String!
    var coverHeight : Int!
    var coverWidth : Int!
    var datetime : Int!
    var description : String!
    var downs : Int!
    var favorite : Bool!
    var favoriteCount : Int!
    var id : String!
    var images : [ImgurMediaItem]!
    var imagesCount : Int!
    var inGallery : Bool!
    var inMostViral : Bool!
    var includeAlbumAds : Bool!
    var isAd : Bool!
    var isAlbum : Bool!
    var layout : String!
    var link : String!
    var nsfw : Bool!
    var points : Int!
    var privacy : String!
    var score : Int!
    var section : String!
    var title : String!
    var type : String!
    var ups : Int!
    var views : Int!

    init(fromJson json: JSON!) throws {
        if json.isEmpty{
            throw JSONError.invalidData
        }
        accountId = json["account_id"].intValue
        accountUrl = json["account_url"].stringValue
        adType = json["ad_type"].intValue
        adUrl = json["ad_url"].stringValue
        commentCount = json["comment_count"].intValue
        cover = json["cover"].stringValue
        coverHeight = json["cover_height"].intValue
        coverWidth = json["cover_width"].intValue
        datetime = json["datetime"].intValue
        description = json["description"].stringValue
        downs = json["downs"].intValue
        favorite = json["favorite"].boolValue
        favoriteCount = json["favorite_count"].intValue
        id = json["id"].stringValue
        images = [ImgurMediaItem]()
        let imagesArray = json["images"].arrayValue
        for imagesJson in imagesArray {
            do {
                let value = try ImgurMediaItem(fromJson: imagesJson)
                images.append(value)
            } catch {
                print(error.localizedDescription)
                // Ignore
            }
        }
        imagesCount = json["images_count"].intValue
        inGallery = json["in_gallery"].boolValue
        inMostViral = json["in_most_viral"].boolValue
        includeAlbumAds = json["include_album_ads"].boolValue
        isAd = json["is_ad"].boolValue
        isAlbum = json["is_album"].boolValue
        layout = json["layout"].stringValue
        link = json["link"].stringValue
        nsfw = json["nsfw"].boolValue
        points = json["points"].intValue
        privacy = json["privacy"].stringValue
        score = json["score"].intValue
        section = json["section"].stringValue
        title = json["title"].stringValue
        type = json["type"].stringValue
        ups = json["ups"].intValue
        views = json["views"].intValue
        
        if images.isEmpty {
            images.append(ImgurMediaItem(id: id, link: link, title: title, description: description, type: type))
        }
    }
}

class ImgurMediaItem: Identifiable {

    var adType : Int!
    var adUrl : String!
    var animated : Bool!
    var bandwidth : Int!
    var datetime : Int!
    var description: String!
    var edited : String!
    var favorite : Bool!
    var gifv : String!
    var hasSound : Bool!
    var height : Int!
    var hls : String!
    var id : String!
    var inGallery : Bool!
    var inMostViral : Bool!
    var isAd : Bool!
    var link : String!
    var mp4 : String!
    var mp4Size : Int!
    var size : Int!
    var title: String!
    var type : String!
    var views : Int!
    var width : Int!
    
    enum ImgurMediaItemType {
        case image
        case gif
        case video
    }
    
    var mediaType : ImgurMediaItemType {
        if type.contains("mp4") {
            return .video
        } else if type.contains("gif") {
            return .gif
        } else {
            return .image
        }
    }

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        adType = json["ad_type"].intValue
        adUrl = json["ad_url"].stringValue
        animated = json["animated"].boolValue
        bandwidth = json["bandwidth"].intValue
        datetime = json["datetime"].intValue
        description = json["description"].stringValue
        edited = json["edited"].stringValue
        favorite = json["favorite"].boolValue
        gifv = json["gifv"].stringValue.ensureHTTPS()
        hasSound = json["has_sound"].boolValue
        height = json["height"].intValue
        hls = json["hls"].stringValue.ensureHTTPS()
        id = json["id"].stringValue
        inGallery = json["in_gallery"].boolValue
        inMostViral = json["in_most_viral"].boolValue
        isAd = json["is_ad"].boolValue
        mp4 = json["mp4"].stringValue.ensureHTTPS()
        link = json["link"].stringValue.ensureHTTPS()
        let type = json["type"].stringValue
        if type.contains("gif") {
            if let normalizedLink = mp4ToGif(mp4) {
                link = normalizedLink
            }
        }
        mp4Size = json["mp4_size"].intValue
        size = json["size"].intValue
        title = json["title"].stringValue
        self.type = json["type"].stringValue
        views = json["views"].intValue
        width = json["width"].intValue
    }
    
    init(id: String, link: String, title: String, description: String, type: String) {
        self.id = id
        self.link = link
        self.title = title
        self.description = description
        self.type = type
    }
    
    private func mp4ToGif(_ mp4: String) -> String? {
        guard var url = URL(string: mp4) else {
            return nil
        }
        url.deletePathExtension()
        url.appendPathExtension("gif")
        return url.absoluteString
    }
}
