//
//  CommentListing.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//

import Foundation
import SwiftyJSON
import MarkdownUI

public class CommentListingRootClass: NSObject, NSCoding{
    var kind: String!
    var data: CommentListing!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) throws {
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = try CommentListing(fromJson: dataJson)
        }
        kind = json["kind"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the appropriate json key and the value is the value of the corresponding property
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
    @objc required public init(coder aDecoder: NSCoder)
    {
        data = aDecoder.decodeObject(forKey: "data") as? CommentListing
        kind = aDecoder.decodeObject(forKey: "kind") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if data != nil{
            aCoder.encode(data, forKey: "data")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        
    }
}

public class CommentListing : NSObject, NSCoding, Validatable {
    var comments : [Comment]! = [Comment]()
    var commentMore: CommentMore?
    var after : String!
    var before : String!
    var dist : Int!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) throws {
        try Self.validate(json: json)
        
        if json.isEmpty {
            return
        }
        
        let childrenArray = json["children"].arrayValue
        for childJSON in childrenArray {
            let dataJson = childJSON["data"]
            if childJSON["kind"].stringValue == "more" {
                commentMore = try CommentMore(fromJson: dataJson)
            } else {
                if !dataJson.isEmpty {
                    do {
                        try comments.append(Comment(fromJson: dataJson))
                    } catch {
                        // Ignore
                    }
                }
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

public class Comment : NSObject, NSCoding, Validatable, Identifiable, ObservableObject {
    //    var allAwardings : [AnyObject]!
    var approvedAtUtc : String!
    var approvedBy : String!
    var archived : Bool!
    //    var associatedAward : AnyObject!
    var author : String!
    var authorFlairBackgroundColor : String!
    var authorFlairCssClass : String!
    var authorFlairRichtext : [FlairRichtext]! = [FlairRichtext]()
    var authorFlairTemplateId : String!
    var authorFlairText : String!
    var authorFlairTextColor : String!
    var authorFlairType : String!
    var authorFullname : String!
    var authorIsBlocked : Bool!
    var authorPatreonFlair : Bool!
    var authorPremium : Bool!
    //    var awarders : [AnyObject]!
    var bannedAtUtc : String!
    var bannedBy : String!
    var body : String!
    var bodyProcessedMarkdown : MarkdownContent?
    var bodyHtml : String!
    var canGild : Bool!
    var canModPost : Bool!
    var collapsed : Bool!
    var collapsedBecauseCrowdControl : String!
    var collapsedReason : String!
    var collapsedReasonCode : String!
    var commentType : String!
    var controversiality : Int!
    var created : Float!
    var createdUtc : Float!
    var depth : Int!
    var distinguished : String!
    var downs : Int!
    var edited : Bool!
    var gilded : Int!
    public var id : String
    var isSubmitter : Bool!
    @Published var likes: Int!
    var linkAuthor : String!
    var linkId : String!
    var linkPermalink : String!
    var linkTitle : String!
    var linkUrl : String!
    var locked : Bool!
    var modNote : String!
    var modReasonBy : String!
    var modReasonTitle : String!
    var modReports : [[Any]]! = [[Any]]()
    var mediaMetadata: [String: MediaMetadata]?
    var name : String!
    var noFollow : Bool!
    var numComments : Int!
    var numReports : Int!
    var over18 : Bool!
    var parentId : String!
    var permalink : String!
    var quarantine : Bool!
    var removalReason : String!
    var replies : CommentListing?
    var reportReasons : String!
    var saved : Bool!
    var score : Int!
    var scoreHidden : Bool!
    var sendReplies : Bool!
    var stickied : Bool!
    var subreddit : String!
    var subredditId : String!
    var subredditNamePrefixed : String!
    var subredditType : String!
    var topAwardedType : String!
    var totalAwardsReceived : Int!
    var unrepliableReason : String!
    var ups : Int!
    var userReports : [[Any]]! = [[Any]]()
    
    var isCollasped: Bool = false
    @Published var authorIconUrl: URL? = nil
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) throws {
        try Self.validate(json: json)
        
        if json.isEmpty {
            id = UUID().uuidString
            return
        }
        
        approvedAtUtc = json["approved_at_utc"].stringValue
        approvedBy = json["approved_by"].stringValue
        archived = json["archived"].boolValue
        author = json["author"].stringValue
        authorFlairBackgroundColor = json["author_flair_background_color"].stringValue
        authorFlairCssClass = json["author_flair_css_class"].stringValue
        let authorFlairRichtextArray = json["author_flair_richtext"].arrayValue
        for authorFlairRichtextJson in authorFlairRichtextArray{
            authorFlairRichtext.append(FlairRichtext(fromJson: authorFlairRichtextJson))
        }
        authorFlairTemplateId = json["author_flair_template_id"].stringValue
        authorFlairText = json["author_flair_text"].stringValue
        authorFlairTextColor = json["author_flair_text_color"].stringValue
        authorFlairType = json["author_flair_type"].stringValue
        authorFullname = json["author_fullname"].stringValue
        authorIsBlocked = json["author_is_blocked"].boolValue
        authorPatreonFlair = json["author_patreon_flair"].boolValue
        authorPremium = json["author_premium"].boolValue
        bannedAtUtc = json["banned_at_utc"].stringValue
        bannedBy = json["banned_by"].stringValue
        body = json["body"].stringValue
        bodyHtml = json["body_html"].stringValue
        canGild = json["can_gild"].boolValue
        canModPost = json["can_mod_post"].boolValue
        collapsed = json["collapsed"].boolValue
        collapsedBecauseCrowdControl = json["collapsed_because_crowd_control"].stringValue
        collapsedReason = json["collapsed_reason"].stringValue
        collapsedReasonCode = json["collapsed_reason_code"].stringValue
        commentType = json["comment_type"].stringValue
        controversiality = json["controversiality"].intValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].floatValue
        depth = json["depth"].intValue
        distinguished = json["distinguished"].stringValue
        downs = json["downs"].intValue
        edited = json["edited"].boolValue
        gilded = json["gilded"].intValue
        self.id = json["id"].stringValue
        isSubmitter = json["is_submitter"].boolValue
        likes = json["likes"] == JSON.null ? 0 : json["likes"].boolValue == true ? 1 : -1
        linkAuthor = json["link_author"].stringValue
        linkId = json["link_id"].stringValue
        linkPermalink = json["link_permalink"].stringValue
        linkTitle = json["link_title"].stringValue
        linkUrl = json["link_url"].stringValue
        locked = json["locked"].boolValue
        modNote = json["mod_note"].stringValue
        modReasonBy = json["mod_reason_by"].stringValue
        modReasonTitle = json["mod_reason_title"].stringValue
        if let mediaMetaData = json["media_metadata"].dictionary {
            var parsedMediaMetadata = [String: MediaMetadata]()
            
            for (key, value) in mediaMetaData {
                let media = MediaMetadata(fromJson: value)
                parsedMediaMetadata[key] = media
            }
            mediaMetadata = parsedMediaMetadata
        }
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
        noFollow = json["no_follow"].boolValue
        numComments = json["num_comments"].intValue
        numReports = json["num_reports"].intValue
        over18 = json["over_18"].boolValue
        parentId = json["parent_id"].stringValue
        permalink = json["permalink"].stringValue
        quarantine = json["quarantine"].boolValue
        removalReason = json["removal_reason"].stringValue
        if (json["replies"].string == nil) {
            // It has replies
            do {
                replies = try CommentListing(fromJson: json["replies"]["data"])
            } catch {
                // Ignore
            }
        }
        reportReasons = json["report_reasons"].stringValue
        saved = json["saved"].boolValue
        score = json["score"].intValue
        scoreHidden = json["score_hidden"].boolValue
        sendReplies = json["send_replies"].boolValue
        stickied = json["stickied"].boolValue
        subreddit = json["subreddit"].stringValue
        subredditId = json["subreddit_id"].stringValue
        subredditNamePrefixed = json["subreddit_name_prefixed"].stringValue
        subredditType = json["subreddit_type"].stringValue
        topAwardedType = json["top_awarded_type"].stringValue
        totalAwardsReceived = json["total_awards_received"].intValue
        unrepliableReason = json["unrepliable_reason"].stringValue
        ups = json["ups"].intValue
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
        if authorFlairBackgroundColor != nil{
            dictionary["author_flair_background_color"] = authorFlairBackgroundColor
        }
        if authorFlairCssClass != nil{
            dictionary["author_flair_css_class"] = authorFlairCssClass
        }
        if authorFlairRichtext != nil{
            dictionary["author_flair_richtext"] = authorFlairRichtext
        }
        if authorFlairTemplateId != nil{
            dictionary["author_flair_template_id"] = authorFlairTemplateId
        }
        if authorFlairText != nil{
            dictionary["author_flair_text"] = authorFlairText
        }
        if authorFlairTextColor != nil{
            dictionary["author_flair_text_color"] = authorFlairTextColor
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
        if authorPatreonFlair != nil{
            dictionary["author_patreon_flair"] = authorPatreonFlair
        }
        if authorPremium != nil{
            dictionary["author_premium"] = authorPremium
        }
        if bannedAtUtc != nil{
            dictionary["banned_at_utc"] = bannedAtUtc
        }
        if bannedBy != nil{
            dictionary["banned_by"] = bannedBy
        }
        if body != nil{
            dictionary["body"] = body
        }
        if bodyHtml != nil{
            dictionary["body_html"] = bodyHtml
        }
        if canGild != nil{
            dictionary["can_gild"] = canGild
        }
        if canModPost != nil{
            dictionary["can_mod_post"] = canModPost
        }
        if collapsed != nil{
            dictionary["collapsed"] = collapsed
        }
        if collapsedBecauseCrowdControl != nil{
            dictionary["collapsed_because_crowd_control"] = collapsedBecauseCrowdControl
        }
        if collapsedReason != nil{
            dictionary["collapsed_reason"] = collapsedReason
        }
        if collapsedReasonCode != nil{
            dictionary["collapsed_reason_code"] = collapsedReasonCode
        }
        if commentType != nil{
            dictionary["comment_type"] = commentType
        }
        if controversiality != nil{
            dictionary["controversiality"] = controversiality
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if depth != nil {
            dictionary["depth"] = depth
        }
        if distinguished != nil{
            dictionary["distinguished"] = distinguished
        }
        if downs != nil{
            dictionary["downs"] = downs
        }
        if edited != nil{
            dictionary["edited"] = edited
        }
        if gilded != nil{
            dictionary["gilded"] = gilded
        }
        dictionary["id"] = id
        if isSubmitter != nil{
            dictionary["is_submitter"] = isSubmitter
        }
        if likes != nil{
            dictionary["likes"] = likes
        }
        if linkAuthor != nil{
            dictionary["link_author"] = linkAuthor
        }
        if linkId != nil{
            dictionary["link_id"] = linkId
        }
        if linkPermalink != nil{
            dictionary["link_permalink"] = linkPermalink
        }
        if linkTitle != nil{
            dictionary["link_title"] = linkTitle
        }
        if linkUrl != nil{
            dictionary["link_url"] = linkUrl
        }
        if locked != nil{
            dictionary["locked"] = locked
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
        if mediaMetadata != nil{
            dictionary["media_metadata"] = mediaMetadata
        }
        if name != nil{
            dictionary["name"] = name
        }
        if noFollow != nil{
            dictionary["no_follow"] = noFollow
        }
        if numComments != nil{
            dictionary["num_comments"] = numComments
        }
        if numReports != nil{
            dictionary["num_reports"] = numReports
        }
        if over18 != nil{
            dictionary["over_18"] = over18
        }
        if parentId != nil{
            dictionary["parent_id"] = parentId
        }
        if permalink != nil{
            dictionary["permalink"] = permalink
        }
        if quarantine != nil{
            dictionary["quarantine"] = quarantine
        }
        if removalReason != nil{
            dictionary["removal_reason"] = removalReason
        }
        if replies != nil{
            dictionary["replies"] = replies
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
        if scoreHidden != nil{
            dictionary["score_hidden"] = scoreHidden
        }
        if sendReplies != nil{
            dictionary["send_replies"] = sendReplies
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
        if subredditType != nil{
            dictionary["subreddit_type"] = subredditType
        }
        if topAwardedType != nil{
            dictionary["top_awarded_type"] = topAwardedType
        }
        if totalAwardsReceived != nil{
            dictionary["total_awards_received"] = totalAwardsReceived
        }
        if unrepliableReason != nil{
            dictionary["unrepliable_reason"] = unrepliableReason
        }
        if ups != nil{
            dictionary["ups"] = ups
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
        authorFlairBackgroundColor = aDecoder.decodeObject(forKey: "author_flair_background_color") as? String
        authorFlairCssClass = aDecoder.decodeObject(forKey: "author_flair_css_class") as? String
        authorFlairRichtext = aDecoder.decodeObject(forKey: "author_flair_richtext") as? [FlairRichtext]
        authorFlairTemplateId = aDecoder.decodeObject(forKey: "author_flair_template_id") as? String
        authorFlairText = aDecoder.decodeObject(forKey: "author_flair_text") as? String
        authorFlairTextColor = aDecoder.decodeObject(forKey: "author_flair_text_color") as? String
        authorFlairType = aDecoder.decodeObject(forKey: "author_flair_type") as? String
        authorFullname = aDecoder.decodeObject(forKey: "author_fullname") as? String
        authorIsBlocked = aDecoder.decodeObject(forKey: "author_is_blocked") as? Bool
        authorPatreonFlair = aDecoder.decodeObject(forKey: "author_patreon_flair") as? Bool
        authorPremium = aDecoder.decodeObject(forKey: "author_premium") as? Bool
        bannedAtUtc = aDecoder.decodeObject(forKey: "banned_at_utc") as? String
        bannedBy = aDecoder.decodeObject(forKey: "banned_by") as? String
        body = aDecoder.decodeObject(forKey: "body") as? String
        bodyHtml = aDecoder.decodeObject(forKey: "body_html") as? String
        canGild = aDecoder.decodeObject(forKey: "can_gild") as? Bool
        canModPost = aDecoder.decodeObject(forKey: "can_mod_post") as? Bool
        collapsed = aDecoder.decodeObject(forKey: "collapsed") as? Bool
        collapsedBecauseCrowdControl = aDecoder.decodeObject(forKey: "collapsed_because_crowd_control") as? String
        collapsedReason = aDecoder.decodeObject(forKey: "collapsed_reason") as? String
        collapsedReasonCode = aDecoder.decodeObject(forKey: "collapsed_reason_code") as? String
        commentType = aDecoder.decodeObject(forKey: "comment_type") as? String
        controversiality = aDecoder.decodeObject(forKey: "controversiality") as? Int
        created = aDecoder.decodeObject(forKey: "created") as? Float
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Float
        depth = aDecoder.decodeObject(forKey: "depth") as? Int
        distinguished = aDecoder.decodeObject(forKey: "distinguished") as? String
        downs = aDecoder.decodeObject(forKey: "downs") as? Int
        edited = aDecoder.decodeObject(forKey: "edited") as? Bool
        gilded = aDecoder.decodeObject(forKey: "gilded") as? Int
        id = aDecoder.decodeObject(forKey: "id") as? String ?? UUID().uuidString
        isSubmitter = aDecoder.decodeObject(forKey: "is_submitter") as? Bool
        likes = aDecoder.decodeObject(forKey: "likes") as? Int
        linkAuthor = aDecoder.decodeObject(forKey: "link_author") as? String
        linkId = aDecoder.decodeObject(forKey: "link_id") as? String
        linkPermalink = aDecoder.decodeObject(forKey: "link_permalink") as? String
        linkTitle = aDecoder.decodeObject(forKey: "link_title") as? String
        linkUrl = aDecoder.decodeObject(forKey: "link_url") as? String
        locked = aDecoder.decodeObject(forKey: "locked") as? Bool
        modNote = aDecoder.decodeObject(forKey: "mod_note") as? String
        modReasonBy = aDecoder.decodeObject(forKey: "mod_reason_by") as? String
        modReasonTitle = aDecoder.decodeObject(forKey: "mod_reason_title") as? String
        modReports = aDecoder.decodeObject(forKey: "mod_reports") as? [[Any]]
        mediaMetadata = aDecoder.decodeObject(forKey: "media_metadata") as? [String: MediaMetadata]
        name = aDecoder.decodeObject(forKey: "name") as? String
        noFollow = aDecoder.decodeObject(forKey: "no_follow") as? Bool
        numComments = aDecoder.decodeObject(forKey: "num_comments") as? Int
        numReports = aDecoder.decodeObject(forKey: "num_reports") as? Int
        over18 = aDecoder.decodeObject(forKey: "over_18") as? Bool
        parentId = aDecoder.decodeObject(forKey: "parent_id") as? String
        permalink = aDecoder.decodeObject(forKey: "permalink") as? String
        quarantine = aDecoder.decodeObject(forKey: "quarantine") as? Bool
        removalReason = aDecoder.decodeObject(forKey: "removal_reason") as? String
        replies = aDecoder.decodeObject(forKey: "replies") as? CommentListing
        reportReasons = aDecoder.decodeObject(forKey: "report_reasons") as? String
        saved = aDecoder.decodeObject(forKey: "saved") as? Bool
        score = aDecoder.decodeObject(forKey: "score") as? Int
        scoreHidden = aDecoder.decodeObject(forKey: "score_hidden") as? Bool
        sendReplies = aDecoder.decodeObject(forKey: "send_replies") as? Bool
        stickied = aDecoder.decodeObject(forKey: "stickied") as? Bool
        subreddit = aDecoder.decodeObject(forKey: "subreddit") as? String
        subredditId = aDecoder.decodeObject(forKey: "subreddit_id") as? String
        subredditNamePrefixed = aDecoder.decodeObject(forKey: "subreddit_name_prefixed") as? String
        subredditType = aDecoder.decodeObject(forKey: "subreddit_type") as? String
        topAwardedType = aDecoder.decodeObject(forKey: "top_awarded_type") as? String
        totalAwardsReceived = aDecoder.decodeObject(forKey: "total_awards_received") as? Int
        unrepliableReason = aDecoder.decodeObject(forKey: "unrepliable_reason") as? String
        ups = aDecoder.decodeObject(forKey: "ups") as? Int
        userReports = aDecoder.decodeObject(forKey: "user_reports") as? [[String]]
        
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
        if authorFlairBackgroundColor != nil{
            aCoder.encode(authorFlairBackgroundColor, forKey: "author_flair_background_color")
        }
        if authorFlairCssClass != nil{
            aCoder.encode(authorFlairCssClass, forKey: "author_flair_css_class")
        }
        if authorFlairRichtext != nil{
            aCoder.encode(authorFlairRichtext, forKey: "author_flair_richtext")
        }
        if authorFlairTemplateId != nil{
            aCoder.encode(authorFlairTemplateId, forKey: "author_flair_template_id")
        }
        if authorFlairText != nil{
            aCoder.encode(authorFlairText, forKey: "author_flair_text")
        }
        if authorFlairTextColor != nil{
            aCoder.encode(authorFlairTextColor, forKey: "author_flair_text_color")
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
        if authorPatreonFlair != nil{
            aCoder.encode(authorPatreonFlair, forKey: "author_patreon_flair")
        }
        if authorPremium != nil{
            aCoder.encode(authorPremium, forKey: "author_premium")
        }
        //        if awarders != nil{
        //            aCoder.encode(awarders, forKey: "awarders")
        //        }
        if bannedAtUtc != nil{
            aCoder.encode(bannedAtUtc, forKey: "banned_at_utc")
        }
        if bannedBy != nil{
            aCoder.encode(bannedBy, forKey: "banned_by")
        }
        if body != nil{
            aCoder.encode(body, forKey: "body")
        }
        if bodyHtml != nil{
            aCoder.encode(bodyHtml, forKey: "body_html")
        }
        if canGild != nil{
            aCoder.encode(canGild, forKey: "can_gild")
        }
        if canModPost != nil{
            aCoder.encode(canModPost, forKey: "can_mod_post")
        }
        if collapsed != nil{
            aCoder.encode(collapsed, forKey: "collapsed")
        }
        if collapsedBecauseCrowdControl != nil{
            aCoder.encode(collapsedBecauseCrowdControl, forKey: "collapsed_because_crowd_control")
        }
        if collapsedReason != nil{
            aCoder.encode(collapsedReason, forKey: "collapsed_reason")
        }
        if collapsedReasonCode != nil{
            aCoder.encode(collapsedReasonCode, forKey: "collapsed_reason_code")
        }
        if commentType != nil{
            aCoder.encode(commentType, forKey: "comment_type")
        }
        if controversiality != nil{
            aCoder.encode(controversiality, forKey: "controversiality")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if depth != nil {
            aCoder.encode(depth, forKey: "depth")
        }
        if distinguished != nil{
            aCoder.encode(distinguished, forKey: "distinguished")
        }
        if downs != nil{
            aCoder.encode(downs, forKey: "downs")
        }
        if edited != nil{
            aCoder.encode(edited, forKey: "edited")
        }
        if gilded != nil{
            aCoder.encode(gilded, forKey: "gilded")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if isSubmitter != nil{
            aCoder.encode(isSubmitter, forKey: "is_submitter")
        }
        if likes != nil{
            aCoder.encode(likes, forKey: "likes")
        }
        if linkAuthor != nil{
            aCoder.encode(linkAuthor, forKey: "link_author")
        }
        if linkId != nil{
            aCoder.encode(linkId, forKey: "link_id")
        }
        if linkPermalink != nil{
            aCoder.encode(linkPermalink, forKey: "link_permalink")
        }
        if linkTitle != nil{
            aCoder.encode(linkTitle, forKey: "link_title")
        }
        if linkUrl != nil{
            aCoder.encode(linkUrl, forKey: "link_url")
        }
        if locked != nil{
            aCoder.encode(locked, forKey: "locked")
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
        if mediaMetadata != nil{
            aCoder.encode(mediaMetadata, forKey: "media_metadata")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if noFollow != nil{
            aCoder.encode(noFollow, forKey: "no_follow")
        }
        if numComments != nil{
            aCoder.encode(numComments, forKey: "num_comments")
        }
        if numReports != nil{
            aCoder.encode(numReports, forKey: "num_reports")
        }
        if over18 != nil{
            aCoder.encode(over18, forKey: "over_18")
        }
        if parentId != nil{
            aCoder.encode(parentId, forKey: "parent_id")
        }
        if permalink != nil{
            aCoder.encode(permalink, forKey: "permalink")
        }
        if quarantine != nil{
            aCoder.encode(quarantine, forKey: "quarantine")
        }
        if removalReason != nil{
            aCoder.encode(removalReason, forKey: "removal_reason")
        }
        if replies != nil{
            aCoder.encode(replies, forKey: "replies")
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
        if scoreHidden != nil{
            aCoder.encode(scoreHidden, forKey: "score_hidden")
        }
        if sendReplies != nil{
            aCoder.encode(sendReplies, forKey: "send_replies")
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
        if subredditType != nil{
            aCoder.encode(subredditType, forKey: "subreddit_type")
        }
        if topAwardedType != nil{
            aCoder.encode(topAwardedType, forKey: "top_awarded_type")
        }
        if totalAwardsReceived != nil{
            aCoder.encode(totalAwardsReceived, forKey: "total_awards_received")
        }
        if unrepliableReason != nil{
            aCoder.encode(unrepliableReason, forKey: "unrepliable_reason")
        }
        if ups != nil{
            aCoder.encode(ups, forKey: "ups")
        }
        if userReports != nil{
            aCoder.encode(userReports, forKey: "user_reports")
        }
    }
}

public class CommentMore: NSObject, Validatable, Identifiable {
    var children : [String]!
    var count : Int!
    var depth : Int!
    public var id : String
    var name : String!
    var parentFullname : String!

    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!) throws {
        try Self.validate(json: json)
        
        if json.isEmpty {
            id = UUID().uuidString
            return
        }
        
        children = [String]()
        let childrenArray = json["children"].arrayValue
        for childrenJson in childrenArray{
            children.append(childrenJson.stringValue)
        }
        count = json["count"].intValue
        depth = json["depth"].intValue
        id = json["id"].stringValue
        name = json["name"].stringValue
        parentFullname = json["parent_id"].stringValue
    }
}

enum CommentItem: Identifiable {
    var id: String {
        switch self {
        case .comment(let comment):
            return comment.id
        case .more(let more):
            return more.id
        }
    }
    
    var depth: Int {
        switch self {
        case .comment(let comment):
            return comment.depth
        case .more(let more):
            return more.depth
        }
    }
    
    case comment(Comment)
    case more(CommentMore)
}
