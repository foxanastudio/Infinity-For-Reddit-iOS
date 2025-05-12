//
//  UserDetail.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import Foundation
import SwiftyJSON
import GRDB

class UserDetailRootClass : NSObject, NSCoding{
    
    var data : UserDetail!
    var kind : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            data = UserDetail(fromJson: dataJson)
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
        data = aDecoder.decodeObject(forKey: "data") as? UserDetail
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
    
    public func toUserData() -> UserData {
        return UserData(
            id: data.id,
            name: data.name,
            iconUrl: data.iconImg,
            banner: data.subreddit.bannerImg,
            commentKarma: data.commentKarma,
            linkKarma: data.linkKarma,
            awarderKarma: data.awarderKarma,
            awardeeKarma: data.awardeeKarma,
            totalKarma : data.totalKarma,
            cakeday : data.createdUtc,
            isGold : data.isGold,
            isSubscribed : data.subreddit.userIsSubscriber,
            canBeFollowed : data.acceptFollowers,
            isNSFW : data.subreddit.over18,
            description : data.subreddit.publicDescription,
            title : data.subreddit.title
        )
    }
    
}

public class UserDetail : NSObject, NSCoding{
    
    var acceptFollowers : Bool!
    var awardeeKarma : Int!
    var awarderKarma : Int!
    var commentKarma : Int!
    var created : Float!
    var createdUtc : Double!
    var hasSubscribed : Bool!
    var hasVerifiedEmail : Bool!
    var hideFromRobots : Bool!
    var iconImg : String!
    var id : String!
    var isBlocked : Bool!
    var isEmployee : Bool!
    var isFriend : Bool!
    var isGold : Bool!
    var isMod : Bool!
    var linkKarma : Int!
    var name : String!
    var prefShowSnoovatar : Bool!
    var snoovatarImg : String!
    var snoovatarSize : String!
    var subreddit : Subreddit!
    var totalKarma : Int!
    var verified : Bool!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        acceptFollowers = json["accept_followers"].boolValue
        awardeeKarma = json["awardee_karma"].intValue
        awarderKarma = json["awarder_karma"].intValue
        commentKarma = json["comment_karma"].intValue
        created = json["created"].floatValue
        createdUtc = json["created_utc"].doubleValue
        hasSubscribed = json["has_subscribed"].boolValue
        hasVerifiedEmail = json["has_verified_email"].boolValue
        hideFromRobots = json["hide_from_robots"].boolValue
        iconImg = json["icon_img"].stringValue
        id = json["id"].stringValue
        isBlocked = json["is_blocked"].boolValue
        isEmployee = json["is_employee"].boolValue
        isFriend = json["is_friend"].boolValue
        isGold = json["is_gold"].boolValue
        isMod = json["is_mod"].boolValue
        linkKarma = json["link_karma"].intValue
        name = json["name"].stringValue
        prefShowSnoovatar = json["pref_show_snoovatar"].boolValue
        snoovatarImg = json["snoovatar_img"].stringValue
        snoovatarSize = json["snoovatar_size"].stringValue
        let subredditJson = json["subreddit"]
        if !subredditJson.isEmpty{
            subreddit = Subreddit(fromJson: subredditJson)
        }
        totalKarma = json["total_karma"].intValue
        verified = json["verified"].boolValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if acceptFollowers != nil{
            dictionary["accept_followers"] = acceptFollowers
        }
        if awardeeKarma != nil{
            dictionary["awardee_karma"] = awardeeKarma
        }
        if awarderKarma != nil{
            dictionary["awarder_karma"] = awarderKarma
        }
        if commentKarma != nil{
            dictionary["comment_karma"] = commentKarma
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if hasSubscribed != nil{
            dictionary["has_subscribed"] = hasSubscribed
        }
        if hasVerifiedEmail != nil{
            dictionary["has_verified_email"] = hasVerifiedEmail
        }
        if hideFromRobots != nil{
            dictionary["hide_from_robots"] = hideFromRobots
        }
        if iconImg != nil{
            dictionary["icon_img"] = iconImg
        }
        if id != nil{
            dictionary["id"] = id
        }
        if isBlocked != nil{
            dictionary["is_blocked"] = isBlocked
        }
        if isEmployee != nil{
            dictionary["is_employee"] = isEmployee
        }
        if isFriend != nil{
            dictionary["is_friend"] = isFriend
        }
        if isGold != nil{
            dictionary["is_gold"] = isGold
        }
        if isMod != nil{
            dictionary["is_mod"] = isMod
        }
        if linkKarma != nil{
            dictionary["link_karma"] = linkKarma
        }
        if name != nil{
            dictionary["name"] = name
        }
        if prefShowSnoovatar != nil{
            dictionary["pref_show_snoovatar"] = prefShowSnoovatar
        }
        if snoovatarImg != nil{
            dictionary["snoovatar_img"] = snoovatarImg
        }
        if snoovatarSize != nil{
            dictionary["snoovatar_size"] = snoovatarSize
        }
        if subreddit != nil{
            dictionary["subreddit"] = subreddit.toDictionary()
        }
        if totalKarma != nil{
            dictionary["total_karma"] = totalKarma
        }
        if verified != nil{
            dictionary["verified"] = verified
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required public init(coder aDecoder: NSCoder)
    {
        acceptFollowers = aDecoder.decodeObject(forKey: "accept_followers") as? Bool
        awardeeKarma = aDecoder.decodeObject(forKey: "awardee_karma") as? Int
        awarderKarma = aDecoder.decodeObject(forKey: "awarder_karma") as? Int
        commentKarma = aDecoder.decodeObject(forKey: "comment_karma") as? Int
        created = aDecoder.decodeObject(forKey: "created") as? Float
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Double
        hasSubscribed = aDecoder.decodeObject(forKey: "has_subscribed") as? Bool
        hasVerifiedEmail = aDecoder.decodeObject(forKey: "has_verified_email") as? Bool
        hideFromRobots = aDecoder.decodeObject(forKey: "hide_from_robots") as? Bool
        iconImg = aDecoder.decodeObject(forKey: "icon_img") as? String
        id = aDecoder.decodeObject(forKey: "id") as? String
        isBlocked = aDecoder.decodeObject(forKey: "is_blocked") as? Bool
        isEmployee = aDecoder.decodeObject(forKey: "is_employee") as? Bool
        isFriend = aDecoder.decodeObject(forKey: "is_friend") as? Bool
        isGold = aDecoder.decodeObject(forKey: "is_gold") as? Bool
        isMod = aDecoder.decodeObject(forKey: "is_mod") as? Bool
        linkKarma = aDecoder.decodeObject(forKey: "link_karma") as? Int
        name = aDecoder.decodeObject(forKey: "name") as? String
        prefShowSnoovatar = aDecoder.decodeObject(forKey: "pref_show_snoovatar") as? Bool
        snoovatarImg = aDecoder.decodeObject(forKey: "snoovatar_img") as? String
        snoovatarSize = aDecoder.decodeObject(forKey: "snoovatar_size") as? String
        subreddit = aDecoder.decodeObject(forKey: "subreddit") as? Subreddit
        totalKarma = aDecoder.decodeObject(forKey: "total_karma") as? Int
        verified = aDecoder.decodeObject(forKey: "verified") as? Bool
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    public func encode(with aCoder: NSCoder)
    {
        if acceptFollowers != nil{
            aCoder.encode(acceptFollowers, forKey: "accept_followers")
        }
        if awardeeKarma != nil{
            aCoder.encode(awardeeKarma, forKey: "awardee_karma")
        }
        if awarderKarma != nil{
            aCoder.encode(awarderKarma, forKey: "awarder_karma")
        }
        if commentKarma != nil{
            aCoder.encode(commentKarma, forKey: "comment_karma")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if hasSubscribed != nil{
            aCoder.encode(hasSubscribed, forKey: "has_subscribed")
        }
        if hasVerifiedEmail != nil{
            aCoder.encode(hasVerifiedEmail, forKey: "has_verified_email")
        }
        if hideFromRobots != nil{
            aCoder.encode(hideFromRobots, forKey: "hide_from_robots")
        }
        if iconImg != nil{
            aCoder.encode(iconImg, forKey: "icon_img")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if isBlocked != nil{
            aCoder.encode(isBlocked, forKey: "is_blocked")
        }
        if isEmployee != nil{
            aCoder.encode(isEmployee, forKey: "is_employee")
        }
        if isFriend != nil{
            aCoder.encode(isFriend, forKey: "is_friend")
        }
        if isGold != nil{
            aCoder.encode(isGold, forKey: "is_gold")
        }
        if isMod != nil{
            aCoder.encode(isMod, forKey: "is_mod")
        }
        if linkKarma != nil{
            aCoder.encode(linkKarma, forKey: "link_karma")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if prefShowSnoovatar != nil{
            aCoder.encode(prefShowSnoovatar, forKey: "pref_show_snoovatar")
        }
        if snoovatarImg != nil{
            aCoder.encode(snoovatarImg, forKey: "snoovatar_img")
        }
        if snoovatarSize != nil{
            aCoder.encode(snoovatarSize, forKey: "snoovatar_size")
        }
        if subreddit != nil{
            aCoder.encode(subreddit, forKey: "subreddit")
        }
        if totalKarma != nil{
            aCoder.encode(totalKarma, forKey: "total_karma")
        }
        if verified != nil{
            aCoder.encode(verified, forKey: "verified")
        }
        
    }
    
}

class Subreddit : NSObject, NSCoding{
    
    var acceptFollowers : Bool!
    var allowedMediaInComments : [AnyObject]!
    var bannerImg : String!
    var bannerSize : String!
    var communityIcon : String!
    var defaultSet : Bool!
    var descriptionField : String!
    var disableContributorRequests : Bool!
    var displayName : String!
    var displayNamePrefixed : String!
    var freeFormReports : Bool!
    var headerImg : String!
    var headerSize : String!
    var iconColor : String!
    var iconImg : String!
    var iconSize : [Int]!
    var isDefaultBanner : Bool!
    var isDefaultIcon : Bool!
    var keyColor : String!
    var linkFlairEnabled : Bool!
    var linkFlairPosition : String!
    var name : String!
    var over18 : Bool!
    var previousNames : [AnyObject]!
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
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        acceptFollowers = json["accept_followers"].boolValue
        let allowedMediaInCommentsArray = json["allowed_media_in_comments"].arrayValue
        var allowedMediaInComments: [String] = []
        
        for allowedMediaInCommentsJson in allowedMediaInCommentsArray {
            allowedMediaInComments.append(allowedMediaInCommentsJson.stringValue)
        }
        bannerImg = json["banner_img"].stringValue
        bannerSize = json["banner_size"].stringValue
        communityIcon = json["community_icon"].stringValue
        defaultSet = json["default_set"].boolValue
        descriptionField = json["description"].stringValue
        disableContributorRequests = json["disable_contributor_requests"].boolValue
        displayName = json["display_name"].stringValue
        displayNamePrefixed = json["display_name_prefixed"].stringValue
        freeFormReports = json["free_form_reports"].boolValue
        headerImg = json["header_img"].stringValue
        headerSize = json["header_size"].stringValue
        iconColor = json["icon_color"].stringValue
        iconImg = json["icon_img"].stringValue
        iconSize = [Int]()
        let iconSizeArray = json["icon_size"].arrayValue
        for iconSizeJson in iconSizeArray{
            iconSize.append(iconSizeJson.intValue)
        }
        isDefaultBanner = json["is_default_banner"].boolValue
        isDefaultIcon = json["is_default_icon"].boolValue
        keyColor = json["key_color"].stringValue
        linkFlairEnabled = json["link_flair_enabled"].boolValue
        linkFlairPosition = json["link_flair_position"].stringValue
        name = json["name"].stringValue
        over18 = json["over_18"].boolValue
        previousNames = [AnyObject]()
        let previousNamesArray = json["previous_names"].arrayValue
        var previousNames: [String] = []
        
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
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if acceptFollowers != nil{
            dictionary["accept_followers"] = acceptFollowers
        }
        if allowedMediaInComments != nil{
            dictionary["allowed_media_in_comments"] = allowedMediaInComments
        }
        if bannerImg != nil{
            dictionary["banner_img"] = bannerImg
        }
        if bannerSize != nil{
            dictionary["banner_size"] = bannerSize
        }
        if communityIcon != nil{
            dictionary["community_icon"] = communityIcon
        }
        if defaultSet != nil{
            dictionary["default_set"] = defaultSet
        }
        if descriptionField != nil{
            dictionary["description"] = descriptionField
        }
        if disableContributorRequests != nil{
            dictionary["disable_contributor_requests"] = disableContributorRequests
        }
        if displayName != nil{
            dictionary["display_name"] = displayName
        }
        if displayNamePrefixed != nil{
            dictionary["display_name_prefixed"] = displayNamePrefixed
        }
        if freeFormReports != nil{
            dictionary["free_form_reports"] = freeFormReports
        }
        if headerImg != nil{
            dictionary["header_img"] = headerImg
        }
        if headerSize != nil{
            dictionary["header_size"] = headerSize
        }
        if iconColor != nil{
            dictionary["icon_color"] = iconColor
        }
        if iconImg != nil{
            dictionary["icon_img"] = iconImg
        }
        if iconSize != nil{
            dictionary["icon_size"] = iconSize
        }
        if isDefaultBanner != nil{
            dictionary["is_default_banner"] = isDefaultBanner
        }
        if isDefaultIcon != nil{
            dictionary["is_default_icon"] = isDefaultIcon
        }
        if keyColor != nil{
            dictionary["key_color"] = keyColor
        }
        if linkFlairEnabled != nil{
            dictionary["link_flair_enabled"] = linkFlairEnabled
        }
        if linkFlairPosition != nil{
            dictionary["link_flair_position"] = linkFlairPosition
        }
        if name != nil{
            dictionary["name"] = name
        }
        if over18 != nil{
            dictionary["over_18"] = over18
        }
        if previousNames != nil{
            dictionary["previous_names"] = previousNames
        }
        if primaryColor != nil{
            dictionary["primary_color"] = primaryColor
        }
        if publicDescription != nil{
            dictionary["public_description"] = publicDescription
        }
        if quarantine != nil{
            dictionary["quarantine"] = quarantine
        }
        if restrictCommenting != nil{
            dictionary["restrict_commenting"] = restrictCommenting
        }
        if restrictPosting != nil{
            dictionary["restrict_posting"] = restrictPosting
        }
        if showMedia != nil{
            dictionary["show_media"] = showMedia
        }
        if submitLinkLabel != nil{
            dictionary["submit_link_label"] = submitLinkLabel
        }
        if submitTextLabel != nil{
            dictionary["submit_text_label"] = submitTextLabel
        }
        if subredditType != nil{
            dictionary["subreddit_type"] = subredditType
        }
        if subscribers != nil{
            dictionary["subscribers"] = subscribers
        }
        if title != nil{
            dictionary["title"] = title
        }
        if url != nil{
            dictionary["url"] = url
        }
        if userIsBanned != nil{
            dictionary["user_is_banned"] = userIsBanned
        }
        if userIsContributor != nil{
            dictionary["user_is_contributor"] = userIsContributor
        }
        if userIsModerator != nil{
            dictionary["user_is_moderator"] = userIsModerator
        }
        if userIsMuted != nil{
            dictionary["user_is_muted"] = userIsMuted
        }
        if userIsSubscriber != nil{
            dictionary["user_is_subscriber"] = userIsSubscriber
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        acceptFollowers = aDecoder.decodeObject(forKey: "accept_followers") as? Bool
        allowedMediaInComments = aDecoder.decodeObject(forKey: "allowed_media_in_comments") as? [AnyObject]
        bannerImg = aDecoder.decodeObject(forKey: "banner_img") as? String
        bannerSize = aDecoder.decodeObject(forKey: "banner_size") as? String
        communityIcon = aDecoder.decodeObject(forKey: "community_icon") as? String
        defaultSet = aDecoder.decodeObject(forKey: "default_set") as? Bool
        descriptionField = aDecoder.decodeObject(forKey: "description") as? String
        disableContributorRequests = aDecoder.decodeObject(forKey: "disable_contributor_requests") as? Bool
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        displayNamePrefixed = aDecoder.decodeObject(forKey: "display_name_prefixed") as? String
        freeFormReports = aDecoder.decodeObject(forKey: "free_form_reports") as? Bool
        headerImg = aDecoder.decodeObject(forKey: "header_img") as? String
        headerSize = aDecoder.decodeObject(forKey: "header_size") as? String
        iconColor = aDecoder.decodeObject(forKey: "icon_color") as? String
        iconImg = aDecoder.decodeObject(forKey: "icon_img") as? String
        iconSize = aDecoder.decodeObject(forKey: "icon_size") as? [Int]
        isDefaultBanner = aDecoder.decodeObject(forKey: "is_default_banner") as? Bool
        isDefaultIcon = aDecoder.decodeObject(forKey: "is_default_icon") as? Bool
        keyColor = aDecoder.decodeObject(forKey: "key_color") as? String
        linkFlairEnabled = aDecoder.decodeObject(forKey: "link_flair_enabled") as? Bool
        linkFlairPosition = aDecoder.decodeObject(forKey: "link_flair_position") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        over18 = aDecoder.decodeObject(forKey: "over_18") as? Bool
        previousNames = aDecoder.decodeObject(forKey: "previous_names") as? [AnyObject]
        primaryColor = aDecoder.decodeObject(forKey: "primary_color") as? String
        publicDescription = aDecoder.decodeObject(forKey: "public_description") as? String
        quarantine = aDecoder.decodeObject(forKey: "quarantine") as? Bool
        restrictCommenting = aDecoder.decodeObject(forKey: "restrict_commenting") as? Bool
        restrictPosting = aDecoder.decodeObject(forKey: "restrict_posting") as? Bool
        showMedia = aDecoder.decodeObject(forKey: "show_media") as? Bool
        submitLinkLabel = aDecoder.decodeObject(forKey: "submit_link_label") as? String
        submitTextLabel = aDecoder.decodeObject(forKey: "submit_text_label") as? String
        subredditType = aDecoder.decodeObject(forKey: "subreddit_type") as? String
        subscribers = aDecoder.decodeObject(forKey: "subscribers") as? Int
        title = aDecoder.decodeObject(forKey: "title") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
        userIsBanned = aDecoder.decodeObject(forKey: "user_is_banned") as? Bool
        userIsContributor = aDecoder.decodeObject(forKey: "user_is_contributor") as? Bool
        userIsModerator = aDecoder.decodeObject(forKey: "user_is_moderator") as? Bool
        userIsMuted = aDecoder.decodeObject(forKey: "user_is_muted") as? Bool
        userIsSubscriber = aDecoder.decodeObject(forKey: "user_is_subscriber") as? Bool
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if acceptFollowers != nil{
            aCoder.encode(acceptFollowers, forKey: "accept_followers")
        }
        if allowedMediaInComments != nil{
            aCoder.encode(allowedMediaInComments, forKey: "allowed_media_in_comments")
        }
        if bannerImg != nil{
            aCoder.encode(bannerImg, forKey: "banner_img")
        }
        if bannerSize != nil{
            aCoder.encode(bannerSize, forKey: "banner_size")
        }
        if communityIcon != nil{
            aCoder.encode(communityIcon, forKey: "community_icon")
        }
        if defaultSet != nil{
            aCoder.encode(defaultSet, forKey: "default_set")
        }
        if descriptionField != nil{
            aCoder.encode(descriptionField, forKey: "description")
        }
        if disableContributorRequests != nil{
            aCoder.encode(disableContributorRequests, forKey: "disable_contributor_requests")
        }
        if displayName != nil{
            aCoder.encode(displayName, forKey: "display_name")
        }
        if displayNamePrefixed != nil{
            aCoder.encode(displayNamePrefixed, forKey: "display_name_prefixed")
        }
        if freeFormReports != nil{
            aCoder.encode(freeFormReports, forKey: "free_form_reports")
        }
        if headerImg != nil{
            aCoder.encode(headerImg, forKey: "header_img")
        }
        if headerSize != nil{
            aCoder.encode(headerSize, forKey: "header_size")
        }
        if iconColor != nil{
            aCoder.encode(iconColor, forKey: "icon_color")
        }
        if iconImg != nil{
            aCoder.encode(iconImg, forKey: "icon_img")
        }
        if iconSize != nil{
            aCoder.encode(iconSize, forKey: "icon_size")
        }
        if isDefaultBanner != nil{
            aCoder.encode(isDefaultBanner, forKey: "is_default_banner")
        }
        if isDefaultIcon != nil{
            aCoder.encode(isDefaultIcon, forKey: "is_default_icon")
        }
        if keyColor != nil{
            aCoder.encode(keyColor, forKey: "key_color")
        }
        if linkFlairEnabled != nil{
            aCoder.encode(linkFlairEnabled, forKey: "link_flair_enabled")
        }
        if linkFlairPosition != nil{
            aCoder.encode(linkFlairPosition, forKey: "link_flair_position")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if over18 != nil{
            aCoder.encode(over18, forKey: "over_18")
        }
        if previousNames != nil{
            aCoder.encode(previousNames, forKey: "previous_names")
        }
        if primaryColor != nil{
            aCoder.encode(primaryColor, forKey: "primary_color")
        }
        if publicDescription != nil{
            aCoder.encode(publicDescription, forKey: "public_description")
        }
        if quarantine != nil{
            aCoder.encode(quarantine, forKey: "quarantine")
        }
        if restrictCommenting != nil{
            aCoder.encode(restrictCommenting, forKey: "restrict_commenting")
        }
        if restrictPosting != nil{
            aCoder.encode(restrictPosting, forKey: "restrict_posting")
        }
        if showMedia != nil{
            aCoder.encode(showMedia, forKey: "show_media")
        }
        if submitLinkLabel != nil{
            aCoder.encode(submitLinkLabel, forKey: "submit_link_label")
        }
        if submitTextLabel != nil{
            aCoder.encode(submitTextLabel, forKey: "submit_text_label")
        }
        if subredditType != nil{
            aCoder.encode(subredditType, forKey: "subreddit_type")
        }
        if subscribers != nil{
            aCoder.encode(subscribers, forKey: "subscribers")
        }
        if title != nil{
            aCoder.encode(title, forKey: "title")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if userIsBanned != nil{
            aCoder.encode(userIsBanned, forKey: "user_is_banned")
        }
        if userIsContributor != nil{
            aCoder.encode(userIsContributor, forKey: "user_is_contributor")
        }
        if userIsModerator != nil{
            aCoder.encode(userIsModerator, forKey: "user_is_moderator")
        }
        if userIsMuted != nil{
            aCoder.encode(userIsMuted, forKey: "user_is_muted")
        }
        if userIsSubscriber != nil{
            aCoder.encode(userIsSubscriber, forKey: "user_is_subscriber")
        }
        
    }
    
}
