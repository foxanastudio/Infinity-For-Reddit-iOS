//
//  Post.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import Foundation
import SwiftyJSON
import MarkdownUI


class PostListingRootClass: NSObject {
    var kind: String!
    var data: PostListing!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            data = try PostListing(fromJson: dataJson)
        }
        kind = json["kind"].stringValue
    }
}

public class PostListing : NSObject {
    var posts : [Post]! = [Post]()
    var after : String!
    var before : String!
    var dist : Int!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            if childJSON["kind"].stringValue == "t3" {
                let dataJson = childJSON["data"]
                if !dataJson.isEmpty {
                    do {
                        posts.append(try Post(fromJson: dataJson))
                    } catch {
                        // Ignore the error
                        print(error.localizedDescription)
                    }
                }
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
}

public class Post : NSObject, ObservableObject, Identifiable {
    var approvedAtUtc : String!
    var approvedBy : String!
    var archived : Bool!
    @Published var author : String!
    var authorFlairRichtext : [FlairRichtext]! = [FlairRichtext]()
    var authorFlairText : String!
    var authorFlairType : String!
    var authorFullname : String!
    var authorIsBlocked : Bool!
    var canModPost : Bool!
    var created : Int64!
    var createdUtc : Int64!
    var crosspostParent: Post!
    var distinguished: String!
    var domain : String!
    var downs : Int!
    var edited : Bool!
    var galleryData : GalleryData?
    @Published var hidden : Bool!
    var id : String!
    var isCrosspostable : Bool!
    var isOriginalContent : Bool!
    var isRedditMediaDomain : Bool!
    var isSelf : Bool!
    var isVideo : Bool!
    @Published var likes: Int!
    var linkFlairRichtext : [FlairRichtext]! = [FlairRichtext]()
    var linkFlairText : String!
    var linkFlairType : String!
    var locked : Bool!
    var media : PostMedia!
    var mediaMetadata: [String: MediaMetadata]?
    var mediaOnly : Bool!
    // TODO Fix type, may not be String
    var modNote : String!
    var modReasonBy : String!
    var modReasonTitle : String!
    
    var modReports : [[Any]]! = [[Any]]()
    var name : String!
    var numComments : Int!
    var numCrossposts : Int!
    var numReports : Int!
    @Published var over18 : Bool!
    var permalink : String!
    var pinned : Bool!
    var preview : Preview!
    var pwls : Int!
    var quarantine : Bool!
    // TODO Fix the type, may not be String
    var removalReason : String!
    var removedBy : String!
    var removedByCategory : String!
    var reportReasons : String!
    
    @Published var saved : Bool!
    var score : Int!
    @Published var selftext : String!
    @Published var selftextProcessedMarkdown : MarkdownContent?
    var selftextHtml : String!
    var selftextTruncated: String! {
        if selftext == nil {
            return nil
        }
        if selftext.count > 200 {
            return String(selftext.prefix(200))
        }
        return selftext
    }
    var sendReplies : Bool!
    @Published var spoiler : Bool!
    var stickied : Bool!
    var subreddit : String!
    var subredditId : String!
    var subredditNamePrefixed : String!
    var subredditSubscribers : Int!
    var subredditType : String!
    var suggestedSort : String!
    var thumbnail : String!
    var thumbnailHeight : Int!
    var thumbnailWidth : Int!
    var title : String!
    var ups : Int!
    var upvoteRatio : Float!
    var url : String!
    var userReports : [[Any]]! = [[Any]]()
    
    var postType: PostType!
    @Published var subredditOrUserIcon: String?
    @Published var subredditOrUserIconInPostDetails: String?
    @Published var isRead: Bool = false
    
    var fileNameWithoutExtension: String {
        return "\(subreddit ?? "Unknown")-\(name ?? "id")"
    }
    
    var canEditBody: Bool {
        guard let postType else {
            return false
        }
        switch postType {
        case .text:
            return true
        default:
            return !selftext.isEmpty
        }
    }
    
    enum PostType: Equatable {
        case text
        case image
        case imageWithUrlPreview(urlPreview: String)
        case gif
        case redditVideo(videoUrlString: String, downloadUrlString: String)
        case video(videoUrlString: String, downloadUrlString: String)
        case gallery
        case link
        case noPreviewLink
        case poll
        case imgurVideo(url: String)
        case redgifs(redgifsId: String)
        case streamable(shortCode: String)
        
        var isMedia: Bool {
            switch self {
            case .image, .imageWithUrlPreview, .gif, .redditVideo, .video, .gallery, .link, .imgurVideo, .redgifs, .streamable:
                return true
            default:
                return false
            }
        }
        
        var text: String {
            switch self {
            case .text:
                return "Text"
            case .image, .imageWithUrlPreview:
                return "Image"
            case .gif:
                return "Gif"
            case .redditVideo, .video, .imgurVideo, .redgifs, .streamable:
                return "Video"
            case .gallery:
                return "Gallery"
            case .link, .noPreviewLink:
                return "Link"
            case .poll:
                return "Poll"
            }
        }
    }

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        approvedAtUtc = json["approved_at_utc"].stringValue
        approvedBy = json["approved_by"].stringValue
        archived = json["archived"].boolValue
        author = json["author"].stringValue
        let authorFlairRichtextArray = json["author_flair_richtext"].arrayValue
        for authorFlairRichtextJson in authorFlairRichtextArray {
            do {
                let flairRichtext = try FlairRichtext(fromJson: authorFlairRichtextJson)
                authorFlairRichtext.append(flairRichtext)
            } catch {
                //Ignore
            }
        }
        authorFlairText = json["author_flair_text"].stringValue
        authorFlairType = json["author_flair_type"].stringValue
        authorFullname = json["author_fullname"].stringValue
        authorIsBlocked = json["author_is_blocked"].boolValue
        canModPost = json["can_mod_post"].boolValue
        created = json["created"].int64Value
        createdUtc = json["created_utc"].int64Value
        if let crosspostParentListArray = json["crosspost_parent_list"].array, !crosspostParentListArray.isEmpty {
            crosspostParent = try Post(fromJson: crosspostParentListArray[0])
        }
        distinguished = json["distinguished"].stringValue
        domain = json["domain"].stringValue
        downs = json["downs"].intValue
        edited = json["edited"].boolValue
        
        if let mediaMetaData = json["media_metadata"].dictionary {
            var parsedMediaMetadata = [String: MediaMetadata]()
            
            for (key, value) in mediaMetaData {
                do {
                    let media = try MediaMetadata(fromJson: value)
                    parsedMediaMetadata[key] = media
                } catch {
                    // Ignore
                }
            }
            mediaMetadata = parsedMediaMetadata
        }
        let galleryDataJson = json["gallery_data"]
        if !galleryDataJson.isEmpty {
            print(json["title"].stringValue)
            galleryData = try? GalleryData(fromJson: galleryDataJson, mediaMetadataDictionary: mediaMetadata)
        }
        
        hidden = json["hidden"].boolValue
        id = json["id"].stringValue
        isCrosspostable = json["is_crosspostable"].boolValue
        isOriginalContent = json["is_original_content"].boolValue
        isRedditMediaDomain = json["is_reddit_media_domain"].boolValue
        isSelf = json["is_self"].boolValue
        isVideo = json["is_video"].boolValue
        let likes = json["likes"] == JSON.null ? 0 : json["likes"].boolValue == true ? 1 : -1
        self.likes = likes
        let linkFlairRichtextArray = json["link_flair_richtext"].arrayValue
        for linkFlairRichtextJson in linkFlairRichtextArray {
            do {
                let richtext = try FlairRichtext(fromJson: linkFlairRichtextJson)
                linkFlairRichtext.append(richtext)
            } catch {
                //Ignore
            }
        }
        linkFlairText = json["link_flair_text"].stringValue
        linkFlairType = json["link_flair_type"].stringValue
        locked = json["locked"].boolValue
        let mediaJson = json["media"]
        if !mediaJson.isEmpty {
            media = PostMedia(fromJson: mediaJson)
        }
        
        mediaOnly = json["media_only"].boolValue
        modNote = json["mod_note"].stringValue
        modReasonBy = json["mod_reason_by"].stringValue
        modReasonTitle = json["mod_reason_title"].stringValue
        for modReportArray in json["mod_reports"].arrayValue {
            var subArray: [Any] = []
            for modReport in modReportArray.arrayValue {
                if let intValue = modReport.int {
                    subArray.append(intValue)
                } else if let stringValue = modReport.string {
                    subArray.append(stringValue)
                } else if let boolValue = modReport.bool {
                    subArray.append(boolValue)
                }
            }
            modReports.append(subArray)
        }
        name = json["name"].stringValue
        numComments = json["num_comments"].intValue
        numCrossposts = json["num_crossposts"].intValue
        numReports = json["num_reports"].intValue
        over18 = json["over_18"].boolValue
        permalink = json["permalink"].stringValue
        pinned = json["pinned"].boolValue
        let previewJson = json["preview"]
        if !previewJson.isEmpty {
            preview = Preview(fromJson: previewJson)
        }
        pwls = json["pwls"].intValue
        quarantine = json["quarantine"].boolValue
        removalReason = json["removal_reason"].stringValue
        removedBy = json["removed_by"].stringValue
        removedByCategory = json["removed_by_category"].stringValue
        reportReasons = json["report_reasons"].stringValue
        saved = json["saved"].boolValue
        var score = json["score"].intValue
        score -= likes
        self.score = score
        selftext = json["selftext"].stringValue
        selftextHtml = json["selftext_html"].stringValue
        sendReplies = json["send_replies"].boolValue
        spoiler = json["spoiler"].boolValue
        stickied = json["stickied"].boolValue
        subreddit = json["subreddit"].stringValue
        subredditId = json["subreddit_id"].stringValue
        subredditNamePrefixed = json["subreddit_name_prefixed"].stringValue
        subredditSubscribers = json["subreddit_subscribers"].intValue
        subredditType = json["subreddit_type"].stringValue
        suggestedSort = json["suggested_sort"].stringValue
        thumbnail = json["thumbnail"].stringValue
        thumbnailHeight = json["thumbnail_height"].intValue
        thumbnailWidth = json["thumbnail_width"].intValue
        title = json["title"].stringValue
        ups = json["ups"].intValue
        upvoteRatio = json["upvote_ratio"].floatValue
        url = json["url"].stringValue
        for userReportArray in json["user_reports"].arrayValue {
            var subArray: [Any] = []
            for userReport in userReportArray.arrayValue {
                if let intValue = userReport.int {
                    subArray.append(intValue)
                } else if let stringValue = userReport.string {
                    subArray.append(stringValue)
                } else if let boolValue = userReport.bool {
                    subArray.append(boolValue)
                }
            }
            userReports.append(subArray)
        }
        
        postType = Post.checkPostType(url: url, preview: preview, galleryData: galleryData, media: media, isVideo: isVideo, permalink: permalink)
    }
    
    static func checkPostType(url: String,
                              preview: Preview?,
                              galleryData: GalleryData?,
                              media: PostMedia?,
                              isVideo: Bool,
                              permalink: String,
                              isCrosspost: Bool = false
    ) -> PostType {
        if galleryData != nil {
            return PostType.gallery
        }
        
        let realUrl = URL(string: url)
        let path = realUrl?.path ?? ""
        let host = realUrl?.host ?? ""
        if preview == nil || preview?.images?.isEmpty ?? true {
            if url.contains(permalink) {
                return PostType.text
            } else {
                if path.hasSuffix(".jpg") || path.hasSuffix(".png") || path.hasSuffix(".jpeg") {
                    if host == "i.redgifs.com" {
                        return PostType.noPreviewLink
                    }
                    return PostType.imageWithUrlPreview(urlPreview: url)
                } else {
                    if isVideo {
                        return PostType.redditVideo(videoUrlString: media?.redditVideo?.hlsUrl ?? "", downloadUrlString: media?.redditVideo?.fallbackUrl ?? "")
                    } else {
                        if host.contains("redgifs.com") {
                            return PostType.redgifs(redgifsId: url.components(separatedBy: "/").last?.lowercased() ?? "")
                        } else if host == "streamable.com" {
                            return PostType.streamable(shortCode: url.components(separatedBy: "/").last ?? "")
                        }
                        return PostType.noPreviewLink
                    }
                }
            }
        } else {
            if isVideo {
                return PostType.redditVideo(videoUrlString: media?.redditVideo?.hlsUrl ?? "", downloadUrlString: media?.redditVideo?.fallbackUrl ?? "")
            } else {
                if path.hasSuffix(".jpg") || path.hasSuffix(".png") || path.hasSuffix(".jpeg") {
                    return PostType.image
                } else if path.hasSuffix(".gif") {
                    return PostType.gif
                } else if host.contains("imgur.com") && (path.hasSuffix(".gifv") || path.hasSuffix(".mp4")) {
                    if url.hasSuffix("gifv") {
                        return PostType.imgurVideo(url: String(url.dropLast(5)) + ".mp4")
                    }
                    return PostType.imgurVideo(url: url)
                } else if path.hasSuffix(".mp4") {
                    return PostType.video(videoUrlString: url, downloadUrlString: url)
                } else {
                    if url.contains(permalink) {
                        return PostType.text
                    } else {
                        if host.contains("redgifs.com") {
                            return PostType.redgifs(redgifsId: url.components(separatedBy: "/").last?.lowercased() ?? "")
                        } else if host == "streamable.com" {
                            return PostType.streamable(shortCode: url.components(separatedBy: "/").last ?? "")
                        }
                        return PostType.link
                    }
                }
            }
        }
    }
    
    public func isAuthorDeleted() -> Bool {
        return author != nil && author! == "[deleted]"
    }
}

class Preview : NSObject {
    
    var enabled : Bool!
    var images : [Image]!

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        enabled = json["enabled"].boolValue
        images = [Image]()
        let imagesArray = json["images"].arrayValue
        for imagesJson in imagesArray{
            let value = Image(fromJson: imagesJson)
            images.append(value)
        }
    }
}

class Image : NSObject {
    
    var resolutions : [Resolution]! = [Resolution]()
    var source : Resolution!
    var gifVariant: Image!
    var mp4Variant: Image!

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        resolutions = [Resolution]()
        let resolutionsArray = json["resolutions"].arrayValue
        for resolutionsJson in resolutionsArray{
            let value = Resolution(fromJson: resolutionsJson)
            resolutions.append(value)
        }
        let sourceJson = json["source"]
        if !sourceJson.isEmpty {
            source = Resolution(fromJson: sourceJson)
        }
        let variantsJson = json["variants"]
        if !variantsJson.isEmpty {
            if variantsJson["gif"].exists() {
                gifVariant = Image(fromJson: variantsJson["gif"])
            }
            if variantsJson["mp4"].exists() {
                mp4Variant = Image(fromJson: variantsJson["mp4"])
            }
        }
    }
}

class Resolution : NSObject {
    
    var height : Int!
    var url : String!
    var width : Int!
    var aspectRatio : CGSize {
        return CGSize(width: width, height: height)
    }

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        height = json["height"].intValue
        url = json["url"].stringValue
        width = json["width"].intValue
    }
}


class PostMedia : NSObject {
    
    var redditVideo : RedditVideo!

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        let redditVideoJson = json["reddit_video"]
        if !redditVideoJson.isEmpty{
            redditVideo = RedditVideo(fromJson: redditVideoJson)
        }
    }
}

class RedditVideo : NSObject {
    
    var bitrateKbps : Int!
    var dashUrl : String!
    var duration : Int!
    var fallbackUrl : String!
    var hasAudio : Bool!
    var height : Int!
    var hlsUrl : String!
    var isGif : Bool!
    var scrubberMediaUrl : String!
    var transcodingStatus : String!
    var width : Int!
    
    
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        bitrateKbps = json["bitrate_kbps"].intValue
        dashUrl = json["dash_url"].stringValue
        duration = json["duration"].intValue
        fallbackUrl = json["fallback_url"].stringValue
        hasAudio = json["has_audio"].boolValue
        height = json["height"].intValue
        hlsUrl = json["hls_url"].stringValue
        isGif = json["is_gif"].boolValue
        scrubberMediaUrl = json["scrubber_media_url"].stringValue
        transcodingStatus = json["transcoding_status"].stringValue
        width = json["width"].intValue
    }
}
