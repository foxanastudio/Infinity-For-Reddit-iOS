//
//  CommentListing.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-15.
//

import Foundation
import SwiftyJSON
import MarkdownUI

public class CommentListingRootClass: NSObject {
    var kind: String!
    var data: CommentListing!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = try CommentListing(fromJson: dataJson)
        }
        kind = json["kind"].stringValue
    }
}

public class CommentListing : NSObject, Validatable {
    var comments : [Comment] = [Comment]()
    var commentMore: CommentMore?
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
    
    init(reply comment: Comment) {
        comments.append(comment)
        after = ""
        before = ""
        dist = 0
    }
    
    init(commentMore: CommentMore) {
        self.commentMore = commentMore
        after = ""
        before = ""
        dist = 0
    }
}

public class Comment : NSObject, Validatable, Identifiable, ObservableObject {
    //    var allAwardings : [AnyObject]!
    @Published var approved: Bool!
    @Published var approvedAtUtc : Int64!
    @Published var approvedBy : String!
    var archived : Bool!
    //    var associatedAward : AnyObject!
    @Published var author : String!
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
    @Published var body : String!
    @Published var bodyProcessedMarkdown : MarkdownContent?
    var bodyHtml : String!
    var canGild : Bool!
    var canModComment : Bool!
    var collapsed : Bool!
    var collapsedBecauseCrowdControl : String!
    var collapsedReason : String!
    var collapsedReasonCode : String!
    var commentType : String!
    var controversiality : Int!
    var created : Float!
    var createdUtc : Int64!
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
    @Published var locked : Bool!
    var modNote : String!
    var modReasonBy : String!
    var modReasonTitle : String!
    var modReports : [[Any]]! = [[Any]]()
    @Published var mediaMetadata: [String: MediaMetadata]?
    var name : String!
    var noFollow : Bool!
    var numComments : Int!
    var numReports : Int!
    var over18 : Bool!
    var parentId : String!
    var permalink : String!
    var quarantine : Bool!
    @Published var removed: Bool!
    var removalReason : String!
    var replies : CommentListing?
    var reportReasons : String!
    var saved : Bool!
    var score : Int!
    var scoreHidden : Bool!
    var sendReplies : Bool!
    @Published var spam: Bool!
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
    var hasExpandedBefore: Bool = false
    var isFilteredOut: Bool = false
    @Published var authorIconUrlString: String? = nil
    
    //This is for Continue Thread
    var commentMore: CommentMore?
    var hasReplies: Bool {
        return replies?.comments.count ?? -1 > 0 || commentMore != nil
    }
    
    init(fromJson json: JSON!) throws {
        try Self.validate(json: json)
        
        if json.isEmpty {
            id = UUID().uuidString
            return
        }
        
        approved = json["approved"].boolValue
        approvedAtUtc = json["approved_at_utc"].int64Value
        approvedBy = json["approved_by"].stringValue
        archived = json["archived"].boolValue
        author = json["author"].stringValue
        authorFlairBackgroundColor = json["author_flair_background_color"].stringValue
        authorFlairCssClass = json["author_flair_css_class"].stringValue
        let authorFlairRichtextArray = json["author_flair_richtext"].arrayValue
        for authorFlairRichtextJson in authorFlairRichtextArray {
            do {
                let flairRichtext = try FlairRichtext(fromJson: authorFlairRichtextJson)
                authorFlairRichtext.append(flairRichtext)
            } catch {
                // Ignore
            }
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
        canModComment = json["can_mod_post"].boolValue
        collapsed = json["collapsed"].boolValue
        collapsedBecauseCrowdControl = json["collapsed_because_crowd_control"].stringValue
        collapsedReason = json["collapsed_reason"].stringValue
        collapsedReasonCode = json["collapsed_reason_code"].stringValue
        commentType = json["comment_type"].stringValue
        controversiality = json["controversiality"].intValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].int64Value
        depth = json["depth"].intValue
        distinguished = json["distinguished"].stringValue
        downs = json["downs"].intValue
        edited = json["edited"].boolValue
        gilded = json["gilded"].intValue
        self.id = json["id"].stringValue
        isSubmitter = json["is_submitter"].boolValue
        let likes = json["likes"] == JSON.null ? 0 : json["likes"].boolValue == true ? 1 : -1
        self.likes = likes
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
                let media = try MediaMetadata(fromJson: value)
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
        removed = json["removed"].boolValue
        replies = try? CommentListing(fromJson: json["replies"]["data"])
        reportReasons = json["report_reasons"].stringValue
        saved = json["saved"].boolValue
        var score = json["score"].intValue
        score -= likes
        self.score = score
        scoreHidden = json["score_hidden"].boolValue
        sendReplies = json["send_replies"].boolValue
        spam = json["spam"].boolValue
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
}

public class CommentMore: NSObject, Validatable, Identifiable {
    var children : [String]!
    var count : Int!
    var depth : Int!
    public var id : String
    var name : String!
    var parentFullname : String!
    var commentMoreType: CommentMoreType = .normal
    
    enum CommentMoreType {
        case normal
        case continueThread
    }

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
    
    var isComment: Bool {
        switch self {
        case .comment:
            return true
        case .more:
            return false
        }
    }
    
    func containsSearchQuery(_ query: String) -> Bool {
        switch self {
        case .comment(let comment):
            return comment.body.range(of: query, options: .caseInsensitive) != nil
        case .more:
            return false
        }
    }
    
    case comment(Comment)
    case more(CommentMore)
}
