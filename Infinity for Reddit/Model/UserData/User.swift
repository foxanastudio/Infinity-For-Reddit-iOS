//
//  User.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-22.
//

import Foundation
import SwiftyJSON

public class User: NSObject, Identifiable {
    var acceptChats: Bool!
    var acceptFollowers : Bool!
    var acceptPms : Bool!
    var awardeeKarma : Int!
    var awarderKarma : Int!
    var commentKarma : Int!
    var created : Double!
    var createdUtc : Int64!
    var hasSubscribed : Bool!
    var hasVerifiedEmail : Bool!
    var hideFromRobots : Bool!
    var iconImg : String!
    public var id : String!
    var isBlocked : Bool!
    var isEmployee : Bool!
    var isFriend : Bool!
    var isGold : Bool!
    var isMod : Bool!
    var linkKarma : Int!
    var name : String
    var prefShowSnoovatar : Bool!
    var snoovatarImg : String!
    var snoovatarSize : Size!
    var subreddit : SubredditInUserJSON!
    var totalKarma : Int!
    var verified : Bool!
    
    var iconUrl: String {
        return iconImg.isEmpty ? subreddit?.iconImg ?? "" : iconImg
    }

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        id = json["id"].stringValue
        if id.isEmpty {
            // The user is banned
            throw JSONError.invalidData
        }
        
        acceptFollowers = json["accept_followers"].boolValue
        awardeeKarma = json["awardee_karma"].intValue
        awarderKarma = json["awarder_karma"].intValue
        commentKarma = json["comment_karma"].intValue
        created = json["created"].doubleValue
        createdUtc = json["created_utc"].int64Value
        hasSubscribed = json["has_subscribed"].boolValue
        hasVerifiedEmail = json["has_verified_email"].boolValue
        hideFromRobots = json["hide_from_robots"].boolValue
        iconImg = json["icon_img"].stringValue
        isBlocked = json["is_blocked"].boolValue
        isEmployee = json["is_employee"].boolValue
        isFriend = json["is_friend"].boolValue
        isGold = json["is_gold"].boolValue
        isMod = json["is_mod"].boolValue
        linkKarma = json["link_karma"].intValue
        name = json["name"].stringValue
        prefShowSnoovatar = json["pref_show_snoovatar"].boolValue
        snoovatarImg = json["snoovatar_img"].stringValue
        snoovatarSize = JSONUtils.parseNullableSize(json, "snoovatar_size")
        let subredditJson = json["subreddit"]
        if !subredditJson.isEmpty{
            subreddit = SubredditInUserJSON(fromJson: subredditJson)
        }
        totalKarma = json["total_karma"].intValue
        verified = json["verified"].boolValue
    }
    
    public func toUserData() -> UserData {
        return UserData(
            id: id,
            name: name,
            iconUrl: iconImg,
            banner: subreddit?.bannerImg,
            commentKarma: commentKarma,
            linkKarma: linkKarma,
            awarderKarma: awarderKarma,
            awardeeKarma: awardeeKarma,
            totalKarma : totalKarma,
            cakeday : createdUtc,
            isGold : isGold,
            canBeFollowed : acceptFollowers,
            isSensitive : subreddit?.over18,
            description : subreddit?.publicDescription,
            title : subreddit?.title,
            syncTimeInSecond: Utils.getCurrentTimeEpochInSecond()
        )
    }
}

class SubredditInUserJSON : NSObject {
    var acceptFollowers : Bool!
    var allowedMediaInComments : [AnyObject]!
    var bannerImg : String!
    var bannerSize : Size!
    var communityIcon : String!
    var defaultSet : Bool!
    var descriptionField : String!
    var disableContributorRequests : Bool!
    var displayName : String!
    var displayNamePrefixed : String!
    var freeFormReports : Bool!
    var headerImg : String!
    var headerSize : Size!
    var iconColor : String!
    var iconImg : String!
    var iconSize : Size!
    var isDefaultBanner : Bool!
    var isDefaultIcon : Bool!
    var keyColor : String!
    var linkFlairEnabled : Bool!
    var linkFlairPosition : String!
    var name : String!
    var over18 : Bool!
    var previousNames : [String]!
    var primaryColor : String!
    var publicDescription : String!
    var quarantine : Bool!
    var restrictCommenting : Bool!
    var restrictPosting : Bool!
    var showMedia : Bool!
    var submitLinkLabel : String!
    var submitTextLabel : String!
    var subredditType : String!
    var subscribers : Int!
    var title : String!
    var url : String!
    var userIsBanned : Bool!
    var userIsContributor : Bool!
    var userIsModerator : Bool!
    var userIsMuted : Bool!
    var userIsSubscriber : Bool!
    

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        acceptFollowers = json["accept_followers"].boolValue
        let allowedMediaInCommentsArray = json["allowed_media_in_comments"].arrayValue
        var allowedMediaInComments: [String] = []
        
        for allowedMediaInCommentsJson in allowedMediaInCommentsArray {
            allowedMediaInComments.append(allowedMediaInCommentsJson.stringValue)
        }
        bannerImg = json["banner_img"].stringValue
        bannerSize = JSONUtils.parseNullableSize(json, "banner_size")
        communityIcon = json["community_icon"].stringValue
        defaultSet = json["default_set"].boolValue
        descriptionField = json["description"].stringValue
        disableContributorRequests = json["disable_contributor_requests"].boolValue
        displayName = json["display_name"].stringValue
        displayNamePrefixed = json["display_name_prefixed"].stringValue
        freeFormReports = json["free_form_reports"].boolValue
        headerImg = json["header_img"].stringValue
        headerSize = JSONUtils.parseNullableSize(json, "header_size")
        iconColor = json["icon_color"].stringValue
        iconImg = json["icon_img"].stringValue
        iconSize = JSONUtils.parseNullableSize(json, "icon_size")
        isDefaultBanner = json["is_default_banner"].boolValue
        isDefaultIcon = json["is_default_icon"].boolValue
        keyColor = json["key_color"].stringValue
        linkFlairEnabled = json["link_flair_enabled"].boolValue
        linkFlairPosition = json["link_flair_position"].stringValue
        name = json["name"].stringValue
        over18 = json["over_18"].boolValue
        previousNames = [String]()
        let previousNamesArray = json["previous_names"].arrayValue
        for previousNamesJson in previousNamesArray{
            previousNames.append(previousNamesJson.stringValue)
        }
        primaryColor = json["primary_color"].stringValue
        publicDescription = json["public_description"].stringValue
        quarantine = json["quarantine"].boolValue
        restrictCommenting = json["restrict_commenting"].boolValue
        restrictPosting = json["restrict_posting"].boolValue
        showMedia = json["show_media"].boolValue
        submitLinkLabel = json["submit_link_label"].stringValue
        submitTextLabel = json["submit_text_label"].stringValue
        subredditType = json["subreddit_type"].stringValue
        subscribers = json["subscribers"].intValue
        title = json["title"].stringValue
        url = json["url"].stringValue
        userIsBanned = json["user_is_banned"].boolValue
        userIsContributor = json["user_is_contributor"].boolValue
        userIsModerator = json["user_is_moderator"].boolValue
        userIsMuted = json["user_is_muted"].boolValue
        userIsSubscriber = json["user_is_subscriber"].boolValue
    }
}
