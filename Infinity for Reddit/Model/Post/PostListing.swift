//
//  Post.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import Foundation
import SwiftyJSON
import MarkdownUI


class PostListingRootClass: NSObject, NSCoding{
    var kind: String!
    var data: PostListing!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = PostListing(fromJson: dataJson)
        }
        kind = json["kind"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if data != nil{
            dictionary["data"] = data.toDictionary()
        }
        if kind != nil{
            dictionary["kind"] = kind
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        data = aDecoder.decodeObject(forKey: "data") as? PostListing
        kind = aDecoder.decodeObject(forKey: "kind") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if data != nil{
            aCoder.encode(data, forKey: "data")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        
    }
}

public class PostListing : NSObject, NSCoding{
    var posts : [Post]! = [Post]()
    var after : String!
    var before : String!
    var dist : Int!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) {
        if json.isEmpty{
            return
        }
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if !dataJson.isEmpty{
                posts.append(Post(fromJson: dataJson))
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if after != nil{
            dictionary["after"] = after
        }
        if before != nil{
            dictionary["before"] = before
        }
        if dist != nil{
            dictionary["dist"] = dist
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc public required init(coder aDecoder: NSCoder)
    {
        after = aDecoder.decodeObject(forKey: "after") as? String
        before = aDecoder.decodeObject(forKey: "before") as? String
        dist = aDecoder.decodeObject(forKey: "dist") as? Int
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if after != nil{
            aCoder.encode(after, forKey: "after")
        }
        if before != nil{
            aCoder.encode(before, forKey: "before")
        }
        if dist != nil{
            aCoder.encode(dist, forKey: "dist")
        }
    }
}

public class Post : NSObject, NSCoding, ObservableObject, Identifiable {
    var approvedAtUtc : String!
    var approvedBy : String!
    var archived : Bool!
    var author : String!
    var authorFlairRichtext : [FlairRichtext]! = [FlairRichtext]()
    var authorFlairText : String!
    var authorFlairType : String!
    var authorFullname : String!
    var authorIsBlocked : Bool!
    var canModPost : Bool!
    var created : Int64!
    var createdUtc : Int64!
    var crosspostParent: Post!
    var domain : String!
    var downs : Int!
    var edited : Bool!
    var galleryData : GalleryData?
    var hidden : Bool!
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
    var over18 : Bool!
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
    
    var saved : Bool!
    var score : Int!
    var selftext : String!
    var selftextProcessedMarkdown : MarkdownContent?
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
    var spoiler : Bool!
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
    
    enum PostType: Equatable {
        case text, image, imageWithUrlPreview(urlPreview: String), gif, video(videoUrl: String, downloadUrl: String), gallery, link, noPreviewLink, poll, imgurVideo(url: String), redgifs(redgifsId: String), streamable(shortCode: String)
        
        var isMedia: Bool {
            switch self {
            case .image, .imageWithUrlPreview(urlPreview: _), .gif, .video(videoUrl: _, downloadUrl: _), .gallery, .imgurVideo(url: _), .redgifs(redgifsId: _), .streamable(shortCode: _):
                return true
            default:
                return false
            }
        }
    }
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty {
            return
        }
        approvedAtUtc = json["approved_at_utc"].stringValue
        approvedBy = json["approved_by"].stringValue
        archived = json["archived"].boolValue
        author = json["author"].stringValue
        let authorFlairRichtextArray = json["author_flair_richtext"].arrayValue
        for authorFlairRichtextJson in authorFlairRichtextArray{
            authorFlairRichtext.append(FlairRichtext(fromJson: authorFlairRichtextJson))
        }
        authorFlairText = json["author_flair_text"].stringValue
        authorFlairType = json["author_flair_type"].stringValue
        authorFullname = json["author_fullname"].stringValue
        authorIsBlocked = json["author_is_blocked"].boolValue
        canModPost = json["can_mod_post"].boolValue
        created = json["created"].int64Value
        createdUtc = json["created_utc"].int64Value
        if let crosspostParentListArray = json["crosspost_parent_list"].array, !crosspostParentListArray.isEmpty {
            crosspostParent = Post(fromJson: crosspostParentListArray[0])
        }
        domain = json["domain"].stringValue
        downs = json["downs"].intValue
        edited = json["edited"].boolValue
        let galleryDataJson = json["gallery_data"]
        if !galleryDataJson.isEmpty {
            galleryData = GalleryData(fromJson: galleryDataJson)
        }
        hidden = json["hidden"].boolValue
        id = json["id"].stringValue
        isCrosspostable = json["is_crosspostable"].boolValue
        isOriginalContent = json["is_original_content"].boolValue
        isRedditMediaDomain = json["is_reddit_media_domain"].boolValue
        isSelf = json["is_self"].boolValue
        isVideo = json["is_video"].boolValue
        likes = json["likes"] == JSON.null ? 0 : json["likes"].boolValue == true ? 1 : -1
        let linkFlairRichtextArray = json["link_flair_richtext"].arrayValue
        for linkFlairRichtextJson in linkFlairRichtextArray{
            linkFlairRichtext.append(FlairRichtext(fromJson: linkFlairRichtextJson))
        }
        linkFlairText = json["link_flair_text"].stringValue
        linkFlairType = json["link_flair_type"].stringValue
        locked = json["locked"].boolValue
        let mediaJson = json["media"]
        if !mediaJson.isEmpty {
            media = PostMedia(fromJson: mediaJson)
        }
        if let mediaMetaData = json["media_metadata"].dictionary {
            var parsedMediaMetadata = [String: MediaMetadata]()
            
            for (key, value) in mediaMetaData {
                let media = MediaMetadata(fromJson: value)
                parsedMediaMetadata[key] = media
            }
            mediaMetadata = parsedMediaMetadata
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
        if !previewJson.isEmpty{
            preview = Preview(fromJson: previewJson)
        }
        pwls = json["pwls"].intValue
        quarantine = json["quarantine"].boolValue
        removalReason = json["removal_reason"].stringValue
        removedBy = json["removed_by"].stringValue
        removedByCategory = json["removed_by_category"].stringValue
        reportReasons = json["report_reasons"].stringValue
        saved = json["saved"].boolValue
        score = json["score"].intValue
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
                        return PostType.video(videoUrl: media?.redditVideo?.hlsUrl ?? "", downloadUrl: media?.redditVideo?.fallbackUrl ?? "")
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
                return PostType.video(videoUrl: media?.redditVideo?.hlsUrl ?? "", downloadUrl: media?.redditVideo?.fallbackUrl ?? "")
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
                    return PostType.video(videoUrl: url, downloadUrl: url)
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
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if approvedAtUtc != nil{
            dictionary["approved_at_utc"] = approvedAtUtc
        }
        if approvedBy != nil{
            dictionary["approved_by"] = approvedBy
        }
        if archived != nil{
            dictionary["archived"] = archived
        }
        if author != nil{
            dictionary["author"] = author
        }
        if authorFlairRichtext != nil{
            dictionary["author_flair_richtext"] = authorFlairRichtext
        }
        if authorFlairText != nil{
            dictionary["author_flair_text"] = authorFlairText
        }
        if authorFlairType != nil{
            dictionary["author_flair_type"] = authorFlairType
        }
        if authorFullname != nil{
            dictionary["author_fullname"] = authorFullname
        }
        if authorIsBlocked != nil{
            dictionary["author_is_blocked"] = authorIsBlocked
        }
        if canModPost != nil{
            dictionary["can_mod_post"] = canModPost
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if crosspostParent != nil {
            dictionary["crosspost_parent_list"] = crosspostParent
        }
        if domain != nil{
            dictionary["domain"] = domain
        }
        if downs != nil{
            dictionary["downs"] = downs
        }
        if edited != nil{
            dictionary["edited"] = edited
        }
        if galleryData != nil{
            dictionary["gallery_data"] = galleryData
        }
        if hidden != nil{
            dictionary["hidden"] = hidden
        }
        if id != nil{
            dictionary["id"] = id
        }
        if isCrosspostable != nil{
            dictionary["is_crosspostable"] = isCrosspostable
        }
        if isOriginalContent != nil{
            dictionary["is_original_content"] = isOriginalContent
        }
        if isRedditMediaDomain != nil{
            dictionary["is_reddit_media_domain"] = isRedditMediaDomain
        }
        if isSelf != nil{
            dictionary["is_self"] = isSelf
        }
        if isVideo != nil{
            dictionary["is_video"] = isVideo
        }
        if likes != nil {
            dictionary["likes"] = likes
        }
        if linkFlairRichtext != nil{
            dictionary["link_flair_richtext"] = linkFlairRichtext
        }
        if linkFlairText != nil{
            dictionary["link_flair_text"] = linkFlairText
        }
        if linkFlairType != nil{
            dictionary["link_flair_type"] = linkFlairType
        }
        if locked != nil{
            dictionary["locked"] = locked
        }
        if media != nil{
            dictionary["media"] = media
        }
        if mediaMetadata != nil{
            dictionary["media_metadata"] = mediaMetadata
        }
        if mediaOnly != nil{
            dictionary["media_only"] = mediaOnly
        }
        if modNote != nil{
            dictionary["mod_note"] = modNote
        }
        if modReasonBy != nil{
            dictionary["mod_reason_by"] = modReasonBy
        }
        if modReasonTitle != nil{
            dictionary["mod_reason_title"] = modReasonTitle
        }
        if modReports != nil{
            dictionary["mod_reports"] = modReports
        }
        if name != nil{
            dictionary["name"] = name
        }
        if numComments != nil{
            dictionary["num_comments"] = numComments
        }
        if numCrossposts != nil{
            dictionary["num_crossposts"] = numCrossposts
        }
        if numReports != nil{
            dictionary["num_reports"] = numReports
        }
        if over18 != nil{
            dictionary["over_18"] = over18
        }
        if permalink != nil{
            dictionary["permalink"] = permalink
        }
        if pinned != nil{
            dictionary["pinned"] = pinned
        }
        if preview != nil{
            dictionary["preview"] = preview.toDictionary()
        }
        if pwls != nil{
            dictionary["pwls"] = pwls
        }
        if quarantine != nil{
            dictionary["quarantine"] = quarantine
        }
        if removalReason != nil{
            dictionary["removal_reason"] = removalReason
        }
        if removedBy != nil{
            dictionary["removed_by"] = removedBy
        }
        if removedByCategory != nil{
            dictionary["removed_by_category"] = removedByCategory
        }
        if reportReasons != nil{
            dictionary["report_reasons"] = reportReasons
        }
        if saved != nil{
            dictionary["saved"] = saved
        }
        if score != nil{
            dictionary["score"] = score
        }
        if selftext != nil{
            dictionary["selftext"] = selftext
        }
        if selftextHtml != nil{
            dictionary["selftext_html"] = selftextHtml
        }
        if sendReplies != nil{
            dictionary["send_replies"] = sendReplies
        }
        if spoiler != nil{
            dictionary["spoiler"] = spoiler
        }
        if stickied != nil{
            dictionary["stickied"] = stickied
        }
        if subreddit != nil{
            dictionary["subreddit"] = subreddit
        }
        if subredditId != nil{
            dictionary["subreddit_id"] = subredditId
        }
        if subredditNamePrefixed != nil{
            dictionary["subreddit_name_prefixed"] = subredditNamePrefixed
        }
        if subredditSubscribers != nil{
            dictionary["subreddit_subscribers"] = subredditSubscribers
        }
        if subredditType != nil{
            dictionary["subreddit_type"] = subredditType
        }
        if suggestedSort != nil{
            dictionary["suggested_sort"] = suggestedSort
        }
        if thumbnail != nil{
            dictionary["thumbnail"] = thumbnail
        }
        if thumbnailHeight != nil{
            dictionary["thumbnail_height"] = thumbnailHeight
        }
        if thumbnailWidth != nil{
            dictionary["thumbnail_width"] = thumbnailWidth
        }
        if title != nil{
            dictionary["title"] = title
        }
        if ups != nil{
            dictionary["ups"] = ups
        }
        if upvoteRatio != nil{
            dictionary["upvote_ratio"] = upvoteRatio
        }
        if url != nil{
            dictionary["url"] = url
        }
        if userReports != nil{
            dictionary["user_reports"] = userReports
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        approvedAtUtc = aDecoder.decodeObject(forKey: "approved_at_utc") as? String
        approvedBy = aDecoder.decodeObject(forKey: "approved_by") as? String
        archived = aDecoder.decodeObject(forKey: "archived") as? Bool
        author = aDecoder.decodeObject(forKey: "author") as? String
        authorFlairRichtext = aDecoder.decodeObject(forKey: "author_flair_richtext") as? [FlairRichtext]
        authorFlairText = aDecoder.decodeObject(forKey: "author_flair_text") as? String
        authorFlairType = aDecoder.decodeObject(forKey: "author_flair_type") as? String
        authorFullname = aDecoder.decodeObject(forKey: "author_fullname") as? String
        authorIsBlocked = aDecoder.decodeObject(forKey: "author_is_blocked") as? Bool
        canModPost = aDecoder.decodeObject(forKey: "can_mod_post") as? Bool
        created = aDecoder.decodeObject(forKey: "created") as? Int64
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Int64
        crosspostParent = aDecoder.decodeObject(forKey: "crosspost_parent_list") as? Post
        domain = aDecoder.decodeObject(forKey: "domain") as? String
        downs = aDecoder.decodeObject(forKey: "downs") as? Int
        edited = aDecoder.decodeObject(forKey: "edited") as? Bool
        galleryData = aDecoder.decodeObject(forKey: "gallery_data") as? GalleryData
        hidden = aDecoder.decodeObject(forKey: "hidden") as? Bool
        id = aDecoder.decodeObject(forKey: "id") as? String
        isCrosspostable = aDecoder.decodeObject(forKey: "is_crosspostable") as? Bool
        isOriginalContent = aDecoder.decodeObject(forKey: "is_original_content") as? Bool
        isSelf = aDecoder.decodeObject(forKey: "is_self") as? Bool
        isVideo = aDecoder.decodeObject(forKey: "is_video") as? Bool
        likes = aDecoder.decodeObject(forKey: "likes") as? Int
        linkFlairRichtext = aDecoder.decodeObject(forKey: "link_flair_richtext") as? [FlairRichtext]
        linkFlairText = aDecoder.decodeObject(forKey: "link_flair_text") as? String
        linkFlairType = aDecoder.decodeObject(forKey: "link_flair_type") as? String
        locked = aDecoder.decodeObject(forKey: "locked") as? Bool
        media = aDecoder.decodeObject(forKey: "media") as? PostMedia
        mediaMetadata = aDecoder.decodeObject(forKey: "media_metadata") as? [String: MediaMetadata]
        mediaOnly = aDecoder.decodeObject(forKey: "media_only") as? Bool
        modNote = aDecoder.decodeObject(forKey: "mod_note") as? String
        modReasonBy = aDecoder.decodeObject(forKey: "mod_reason_by") as? String
        modReasonTitle = aDecoder.decodeObject(forKey: "mod_reason_title") as? String
        modReports = aDecoder.decodeObject(forKey: "mod_reports") as? [[Any]]
        name = aDecoder.decodeObject(forKey: "name") as? String
        numComments = aDecoder.decodeObject(forKey: "num_comments") as? Int
        numCrossposts = aDecoder.decodeObject(forKey: "num_crossposts") as? Int
        numReports = aDecoder.decodeObject(forKey: "num_reports") as? Int
        over18 = aDecoder.decodeObject(forKey: "over_18") as? Bool
        permalink = aDecoder.decodeObject(forKey: "permalink") as? String
        pinned = aDecoder.decodeObject(forKey: "pinned") as? Bool
        preview = aDecoder.decodeObject(forKey: "preview") as? Preview
        pwls = aDecoder.decodeObject(forKey: "pwls") as? Int
        quarantine = aDecoder.decodeObject(forKey: "quarantine") as? Bool
        removalReason = aDecoder.decodeObject(forKey: "removal_reason") as? String
        removedBy = aDecoder.decodeObject(forKey: "removed_by") as? String
        removedByCategory = aDecoder.decodeObject(forKey: "removed_by_category") as? String
        reportReasons = aDecoder.decodeObject(forKey: "report_reasons") as? String
        saved = aDecoder.decodeObject(forKey: "saved") as? Bool
        score = aDecoder.decodeObject(forKey: "score") as? Int
        selftext = aDecoder.decodeObject(forKey: "selftext") as? String
        selftextHtml = aDecoder.decodeObject(forKey: "selftext_html") as? String
        sendReplies = aDecoder.decodeObject(forKey: "send_replies") as? Bool
        spoiler = aDecoder.decodeObject(forKey: "spoiler") as? Bool
        stickied = aDecoder.decodeObject(forKey: "stickied") as? Bool
        subreddit = aDecoder.decodeObject(forKey: "subreddit") as? String
        subredditId = aDecoder.decodeObject(forKey: "subreddit_id") as? String
        subredditNamePrefixed = aDecoder.decodeObject(forKey: "subreddit_name_prefixed") as? String
        subredditSubscribers = aDecoder.decodeObject(forKey: "subreddit_subscribers") as? Int
        subredditType = aDecoder.decodeObject(forKey: "subreddit_type") as? String
        suggestedSort = aDecoder.decodeObject(forKey: "suggested_sort") as? String
        thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as? String
        thumbnailHeight = aDecoder.decodeObject(forKey: "thumbnail_height") as? Int
        thumbnailWidth = aDecoder.decodeObject(forKey: "thumbnail_width") as? Int
        title = aDecoder.decodeObject(forKey: "title") as? String
        ups = aDecoder.decodeObject(forKey: "ups") as? Int
        upvoteRatio = aDecoder.decodeObject(forKey: "upvote_ratio") as? Float
        url = aDecoder.decodeObject(forKey: "url") as? String
        userReports = aDecoder.decodeObject(forKey: "user_reports") as? [[String]]
        
        postType = aDecoder.decodeObject(forKey: "post_type") as? PostType ?? .text
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if approvedAtUtc != nil{
            aCoder.encode(approvedAtUtc, forKey: "approved_at_utc")
        }
        if approvedBy != nil{
            aCoder.encode(approvedBy, forKey: "approved_by")
        }
        if archived != nil{
            aCoder.encode(archived, forKey: "archived")
        }
        if author != nil{
            aCoder.encode(author, forKey: "author")
        }
        if authorFlairRichtext != nil{
            aCoder.encode(authorFlairRichtext, forKey: "author_flair_richtext")
        }
        if authorFlairText != nil{
            aCoder.encode(authorFlairText, forKey: "author_flair_text")
        }
        if authorFlairType != nil{
            aCoder.encode(authorFlairType, forKey: "author_flair_type")
        }
        if authorFullname != nil{
            aCoder.encode(authorFullname, forKey: "author_fullname")
        }
        if authorIsBlocked != nil{
            aCoder.encode(authorIsBlocked, forKey: "author_is_blocked")
        }
        if canModPost != nil{
            aCoder.encode(canModPost, forKey: "can_mod_post")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if crosspostParent != nil {
            aCoder.encode(crosspostParent, forKey: "crosspost_parent_list")
        }
        if domain != nil{
            aCoder.encode(domain, forKey: "domain")
        }
        if downs != nil{
            aCoder.encode(downs, forKey: "downs")
        }
        if edited != nil{
            aCoder.encode(edited, forKey: "edited")
        }
        if galleryData != nil{
            aCoder.encode(galleryData, forKey: "gallery_data")
        }
        if hidden != nil{
            aCoder.encode(hidden, forKey: "hidden")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if isCrosspostable != nil{
            aCoder.encode(isCrosspostable, forKey: "is_crosspostable")
        }
        if isOriginalContent != nil{
            aCoder.encode(isOriginalContent, forKey: "is_original_content")
        }
        if isRedditMediaDomain != nil{
            aCoder.encode(isRedditMediaDomain, forKey: "is_reddit_media_domain")
        }
        if isSelf != nil{
            aCoder.encode(isSelf, forKey: "is_self")
        }
        if isVideo != nil{
            aCoder.encode(isVideo, forKey: "is_video")
        }
        if likes != nil {
            aCoder.encode(likes, forKey: "likes")
        }
        if linkFlairRichtext != nil{
            aCoder.encode(linkFlairRichtext, forKey: "link_flair_richtext")
        }
        if linkFlairText != nil{
            aCoder.encode(linkFlairText, forKey: "link_flair_text")
        }
        if linkFlairType != nil{
            aCoder.encode(linkFlairType, forKey: "link_flair_type")
        }
        if locked != nil{
            aCoder.encode(locked, forKey: "locked")
        }
        if media != nil{
            aCoder.encode(media, forKey: "media")
        }
        if mediaMetadata != nil{
            aCoder.encode(mediaMetadata, forKey: "media_metadata")
        }
        if mediaOnly != nil{
            aCoder.encode(mediaOnly, forKey: "media_only")
        }
        if modNote != nil{
            aCoder.encode(modNote, forKey: "mod_note")
        }
        if modReasonBy != nil{
            aCoder.encode(modReasonBy, forKey: "mod_reason_by")
        }
        if modReasonTitle != nil{
            aCoder.encode(modReasonTitle, forKey: "mod_reason_title")
        }
        if modReports != nil{
            aCoder.encode(modReports, forKey: "mod_reports")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if numComments != nil{
            aCoder.encode(numComments, forKey: "num_comments")
        }
        if numCrossposts != nil{
            aCoder.encode(numCrossposts, forKey: "num_crossposts")
        }
        if numReports != nil{
            aCoder.encode(numReports, forKey: "num_reports")
        }
        if over18 != nil{
            aCoder.encode(over18, forKey: "over_18")
        }
        if permalink != nil{
            aCoder.encode(permalink, forKey: "permalink")
        }
        if pinned != nil{
            aCoder.encode(pinned, forKey: "pinned")
        }
        if preview != nil{
            aCoder.encode(preview, forKey: "preview")
        }
        if pwls != nil{
            aCoder.encode(pwls, forKey: "pwls")
        }
        if quarantine != nil{
            aCoder.encode(quarantine, forKey: "quarantine")
        }
        if removalReason != nil{
            aCoder.encode(removalReason, forKey: "removal_reason")
        }
        if removedBy != nil{
            aCoder.encode(removedBy, forKey: "removed_by")
        }
        if removedByCategory != nil{
            aCoder.encode(removedByCategory, forKey: "removed_by_category")
        }
        if reportReasons != nil{
            aCoder.encode(reportReasons, forKey: "report_reasons")
        }
        if saved != nil{
            aCoder.encode(saved, forKey: "saved")
        }
        if score != nil{
            aCoder.encode(score, forKey: "score")
        }
        if selftext != nil{
            aCoder.encode(selftext, forKey: "selftext")
        }
        if selftextHtml != nil{
            aCoder.encode(selftextHtml, forKey: "selftext_html")
        }
        if sendReplies != nil{
            aCoder.encode(sendReplies, forKey: "send_replies")
        }
        if spoiler != nil{
            aCoder.encode(spoiler, forKey: "spoiler")
        }
        if stickied != nil{
            aCoder.encode(stickied, forKey: "stickied")
        }
        if subreddit != nil{
            aCoder.encode(subreddit, forKey: "subreddit")
        }
        if subredditId != nil{
            aCoder.encode(subredditId, forKey: "subreddit_id")
        }
        if subredditNamePrefixed != nil{
            aCoder.encode(subredditNamePrefixed, forKey: "subreddit_name_prefixed")
        }
        if subredditSubscribers != nil{
            aCoder.encode(subredditSubscribers, forKey: "subreddit_subscribers")
        }
        if subredditType != nil{
            aCoder.encode(subredditType, forKey: "subreddit_type")
        }
        if suggestedSort != nil{
            aCoder.encode(suggestedSort, forKey: "suggested_sort")
        }
        if thumbnail != nil{
            aCoder.encode(thumbnail, forKey: "thumbnail")
        }
        if thumbnailHeight != nil{
            aCoder.encode(thumbnailHeight, forKey: "thumbnail_height")
        }
        if thumbnailWidth != nil{
            aCoder.encode(thumbnailWidth, forKey: "thumbnail_width")
        }
        if title != nil{
            aCoder.encode(title, forKey: "title")
        }
        if ups != nil{
            aCoder.encode(ups, forKey: "ups")
        }
        if upvoteRatio != nil{
            aCoder.encode(upvoteRatio, forKey: "upvote_ratio")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if userReports != nil{
            aCoder.encode(userReports, forKey: "user_reports")
        }
        
        if postType != nil {
            aCoder.encode(postType, forKey: "post_type")
        }
    }
    
//    static func == (lhs: Post, rhs: Post) -> Bool {
//        return lhs.id == rhs.id
//    }
}

class Preview : NSObject, NSCoding{
    
    var enabled : Bool!
    var images : [Image]!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
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
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if enabled != nil{
            dictionary["enabled"] = enabled
        }
        if images != nil{
            var dictionaryElements = [[String:Any]]()
            for imagesElement in images {
                dictionaryElements.append(imagesElement.toDictionary())
            }
            dictionary["images"] = dictionaryElements
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        enabled = aDecoder.decodeObject(forKey: "enabled") as? Bool
        images = aDecoder.decodeObject(forKey: "images") as? [Image]
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if enabled != nil{
            aCoder.encode(enabled, forKey: "enabled")
        }
        if images != nil{
            aCoder.encode(images, forKey: "images")
        }
        
    }
    
}

class Image : NSObject, NSCoding{
    
    var resolutions : [Resolution]! = [Resolution]()
    var source : Resolution!
    var gifVariant: Image!
    var mp4Variant: Image!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
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
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if resolutions != nil{
            var dictionaryElements = [[String:Any]]()
            for resolutionsElement in resolutions {
                dictionaryElements.append(resolutionsElement.toDictionary())
            }
            dictionary["resolutions"] = dictionaryElements
        }
        if source != nil{
            dictionary["source"] = source.toDictionary()
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        resolutions = aDecoder.decodeObject(forKey: "resolutions") as? [Resolution]
        source = aDecoder.decodeObject(forKey: "source") as? Resolution
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if resolutions != nil{
            aCoder.encode(resolutions, forKey: "resolutions")
        }
        if source != nil{
            aCoder.encode(source, forKey: "source")
        }
    }
    
}

class Resolution : NSObject, NSCoding{
    
    var height : Int!
    var url : String!
    var width : Int!
    var aspectRatio : CGSize {
        return CGSize(width: width, height: height)
    }
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        height = json["height"].intValue
        url = json["url"].stringValue
        width = json["width"].intValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if height != nil{
            dictionary["height"] = height
        }
        if url != nil{
            dictionary["url"] = url
        }
        if width != nil{
            dictionary["width"] = width
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        height = aDecoder.decodeObject(forKey: "height") as? Int
        url = aDecoder.decodeObject(forKey: "url") as? String
        width = aDecoder.decodeObject(forKey: "width") as? Int
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if height != nil{
            aCoder.encode(height, forKey: "height")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if width != nil{
            aCoder.encode(width, forKey: "width")
        }
        
    }
    
}


class PostMedia : NSObject, NSCoding{
    
    var redditVideo : RedditVideo!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let redditVideoJson = json["reddit_video"]
        if !redditVideoJson.isEmpty{
            redditVideo = RedditVideo(fromJson: redditVideoJson)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if redditVideo != nil{
            dictionary["reddit_video"] = redditVideo.toDictionary()
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        redditVideo = aDecoder.decodeObject(forKey: "reddit_video") as? RedditVideo
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if redditVideo != nil{
            aCoder.encode(redditVideo, forKey: "reddit_video")
        }
        
    }
    
}

class RedditVideo : NSObject, NSCoding{
    
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
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
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
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if bitrateKbps != nil{
            dictionary["bitrate_kbps"] = bitrateKbps
        }
        if dashUrl != nil{
            dictionary["dash_url"] = dashUrl
        }
        if duration != nil{
            dictionary["duration"] = duration
        }
        if fallbackUrl != nil{
            dictionary["fallback_url"] = fallbackUrl
        }
        if hasAudio != nil{
            dictionary["has_audio"] = hasAudio
        }
        if height != nil{
            dictionary["height"] = height
        }
        if hlsUrl != nil{
            dictionary["hls_url"] = hlsUrl
        }
        if isGif != nil{
            dictionary["is_gif"] = isGif
        }
        if scrubberMediaUrl != nil{
            dictionary["scrubber_media_url"] = scrubberMediaUrl
        }
        if transcodingStatus != nil{
            dictionary["transcoding_status"] = transcodingStatus
        }
        if width != nil{
            dictionary["width"] = width
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        bitrateKbps = aDecoder.decodeObject(forKey: "bitrate_kbps") as? Int
        dashUrl = aDecoder.decodeObject(forKey: "dash_url") as? String
        duration = aDecoder.decodeObject(forKey: "duration") as? Int
        fallbackUrl = aDecoder.decodeObject(forKey: "fallback_url") as? String
        hasAudio = aDecoder.decodeObject(forKey: "has_audio") as? Bool
        height = aDecoder.decodeObject(forKey: "height") as? Int
        hlsUrl = aDecoder.decodeObject(forKey: "hls_url") as? String
        isGif = aDecoder.decodeObject(forKey: "is_gif") as? Bool
        scrubberMediaUrl = aDecoder.decodeObject(forKey: "scrubber_media_url") as? String
        transcodingStatus = aDecoder.decodeObject(forKey: "transcoding_status") as? String
        width = aDecoder.decodeObject(forKey: "width") as? Int
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if bitrateKbps != nil{
            aCoder.encode(bitrateKbps, forKey: "bitrate_kbps")
        }
        if dashUrl != nil{
            aCoder.encode(dashUrl, forKey: "dash_url")
        }
        if duration != nil{
            aCoder.encode(duration, forKey: "duration")
        }
        if fallbackUrl != nil{
            aCoder.encode(fallbackUrl, forKey: "fallback_url")
        }
        if hasAudio != nil{
            aCoder.encode(hasAudio, forKey: "has_audio")
        }
        if height != nil{
            aCoder.encode(height, forKey: "height")
        }
        if hlsUrl != nil{
            aCoder.encode(hlsUrl, forKey: "hls_url")
        }
        if isGif != nil{
            aCoder.encode(isGif, forKey: "is_gif")
        }
        if scrubberMediaUrl != nil{
            aCoder.encode(scrubberMediaUrl, forKey: "scrubber_media_url")
        }
        if transcodingStatus != nil{
            aCoder.encode(transcodingStatus, forKey: "transcoding_status")
        }
        if width != nil{
            aCoder.encode(width, forKey: "width")
        }
        
    }
}
