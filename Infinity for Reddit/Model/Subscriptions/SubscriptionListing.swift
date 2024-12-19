//
//  SubscriptionListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-15.
//

import Foundation
import SwiftyJSON

class SubscriptionListingRootClass : NSObject, NSCoding{
    
    var kind : String!
    var subscriptionListing : SubscriptionListing!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        kind = json["kind"].stringValue
        let listsJson = json["data"]
        if !listsJson.isEmpty{
            subscriptionListing = SubscriptionListing(fromJson: listsJson)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if kind != nil{
            dictionary["kind"] = kind
        }
        if subscriptionListing != nil{
            dictionary["lists"] = subscriptionListing.toDictionary()
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        kind = aDecoder.decodeObject(forKey: "kind") as? String
        subscriptionListing = aDecoder.decodeObject(forKey: "lists") as? SubscriptionListing
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        if subscriptionListing != nil{
            aCoder.encode(subscriptionListing, forKey: "lists")
        }
        
    }
    
}

public class SubscriptionListing : NSObject, NSCoding{
    
    var after : String!
    var subscriptions : [Subscription]!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        after = json["after"].stringValue
        subscriptions = [Subscription]()
        let childrenArray = json["children"].arrayValue
        for childrenJson in childrenArray{
            let value = Subscription(fromJson: childrenJson)
            subscriptions.append(value)
        }
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
        if subscriptions != nil{
            var dictionaryElements = [[String:Any]]()
            for childrenElement in subscriptions {
                dictionaryElements.append(childrenElement.toDictionary())
            }
            dictionary["children"] = dictionaryElements
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
        subscriptions = aDecoder.decodeObject(forKey: "children") as? [Subscription]
        
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
        if subscriptions != nil{
            aCoder.encode(subscriptions, forKey: "children")
        }
    }
}

class Subscription : NSObject, NSCoding{
    
    var kind : String!
    
    var acceptFollowers : Bool!
    var accountsActiveIsFuzzed : Bool!
    var advertiserCategory : String!
    var allOriginalContent : Bool!
    var allowDiscovery : Bool!
    var allowGalleries : Bool!
    var allowImages : Bool!
    var allowPolls : Bool!
    var allowPredictionContributors : Bool!
    var allowPredictions : Bool!
    var allowPredictionsTournament : Bool!
    var allowTalks : Bool!
    var allowVideogifs : Bool!
    var allowVideos : Bool!
    var allowedMediaInComments : [String]!
    var bannerBackgroundColor : String!
    var bannerBackgroundImage : String!
    var bannerImg : String!
    var bannerSize : [Int]!
    var canAssignLinkFlair : Bool!
    var canAssignUserFlair : Bool!
    var collapseDeletedComments : Bool!
    var commentContributionSettings : CommentContributionSetting!
    var commentScoreHideMins : Int!
    var communityIcon : String!
    var communityReviewed : Bool!
    var created : Int64!
    var createdUtc : Int64!
    var descriptionField : String!
    var descriptionHtml : String!
    var disableContributorRequests : Bool!
    var displayName : String!
    var displayNamePrefixed : String!
    var emojisEnabled : Bool!
    var freeFormReports : Bool!
    var hasMenuWidget : Bool!
    var headerImg : String!
    var headerSize : [Int]!
    var headerTitle : String!
    var hideAds : Bool!
    var iconImg : String!
    var iconSize : [Int]!
    var id : String!
    var isCrosspostableSubreddit : Bool?
    var isEnrolledInNewModmail : Bool?
    var keyColor : String!
    var lang : String!
    var linkFlairEnabled : Bool!
    var linkFlairPosition : String!
    var mobileBannerImage : String!
    var name : String!
    var notificationLevel : String!
    var originalContentTagEnabled : Bool!
    var over18 : Bool!
    var predictionLeaderboardEntryType : Int!
    var primaryColor : String!
    var publicDescription : String!
    var publicDescriptionHtml : String!
    var publicTraffic : Bool!
    var quarantine : Bool!
    var restrictCommenting : Bool!
    var restrictPosting : Bool!
    var shouldArchivePosts : Bool!
    var shouldShowMediaInCommentsSetting : Bool!
    var showMedia : Bool!
    var showMediaPreview : Bool!
    var spoilersEnabled : Bool!
    var submissionType : String!
    var submitLinkLabel : String!
    var submitText : String!
    var submitTextHtml : String!
    var submitTextLabel : String!
    var subredditType : String!
    var subscribers : Int!
    var suggestedCommentSort : String?
    var title : String!
    var url : String!
    var userFlairEnabledInSr : Bool!
    var userFlairPosition : String!
    var userFlairRichtext : [UserFlairRichtext]!
    var userFlairType : String!
    var userHasFavorited : Bool!
    var userIsBanned : Bool!
    var userIsContributor : Bool!
    var userIsModerator : Bool!
    var userIsMuted : Bool!
    var userIsSubscriber : Bool!
    var userSrThemeEnabled : Bool!
    var videostreamLinksCount : Int!
    var wikiEnabled : Bool?
    var wls : Int!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        kind = json["kind"].stringValue
        
        let dataJson = json["data"]
        if !dataJson.isEmpty{
            acceptFollowers = dataJson["accept_followers"].boolValue
            accountsActiveIsFuzzed = dataJson["accounts_active_is_fuzzed"].boolValue
            advertiserCategory = dataJson["advertiser_category"].stringValue
            allOriginalContent = dataJson["all_original_content"].boolValue
            allowDiscovery = dataJson["allow_discovery"].boolValue
            allowGalleries = dataJson["allow_galleries"].boolValue
            allowImages = dataJson["allow_images"].boolValue
            allowPolls = dataJson["allow_polls"].boolValue
            allowPredictionContributors = dataJson["allow_prediction_contributors"].boolValue
            allowPredictions = dataJson["allow_predictions"].boolValue
            allowPredictionsTournament = dataJson["allow_predictions_tournament"].boolValue
            allowTalks = dataJson["allow_talks"].boolValue
            allowVideogifs = dataJson["allow_videogifs"].boolValue
            allowVideos = dataJson["allow_videos"].boolValue
            allowedMediaInComments = [String]()
            let allowedMediaInCommentsArray = dataJson["allowed_media_in_comments"].arrayValue
            for allowedMediaInCommentsJson in allowedMediaInCommentsArray{
                allowedMediaInComments.append(allowedMediaInCommentsJson.stringValue)
            }
            bannerBackgroundColor = dataJson["banner_background_color"].stringValue
            bannerBackgroundImage = dataJson["banner_background_image"].stringValue
            bannerImg = dataJson["banner_img"].stringValue
            bannerSize = [Int]()
            let bannerSizeArray = dataJson["banner_size"].arrayValue
            for bannerSizeJson in bannerSizeArray{
                bannerSize.append(bannerSizeJson.intValue)
            }
            canAssignLinkFlair = dataJson["can_assign_link_flair"].boolValue
            canAssignUserFlair = dataJson["can_assign_user_flair"].boolValue
            collapseDeletedComments = dataJson["collapse_deleted_comments"].boolValue
            let commentContributionSettingsJson = dataJson["comment_contribution_settings"]
            if !commentContributionSettingsJson.isEmpty{
                commentContributionSettings = CommentContributionSetting(fromJson: commentContributionSettingsJson)
            }
            commentScoreHideMins = dataJson["comment_score_hide_mins"].intValue
            communityIcon = dataJson["community_icon"].stringValue
            communityReviewed = dataJson["community_reviewed"].boolValue
            created = dataJson["created"].int64Value
            createdUtc = dataJson["created_utc"].int64Value
            descriptionField = dataJson["description"].stringValue
            descriptionHtml = dataJson["description_html"].stringValue
            disableContributorRequests = dataJson["disable_contributor_requests"].boolValue
            displayName = dataJson["display_name"].stringValue
            displayNamePrefixed = dataJson["display_name_prefixed"].stringValue
            emojisEnabled = dataJson["emojis_enabled"].boolValue
            freeFormReports = dataJson["free_form_reports"].boolValue
            hasMenuWidget = dataJson["has_menu_widget"].boolValue
            headerImg = dataJson["header_img"].stringValue
            headerSize = [Int]()
            let headerSizeArray = dataJson["header_size"].arrayValue
            for headerSizeJson in headerSizeArray{
                headerSize.append(headerSizeJson.intValue)
            }
            headerTitle = dataJson["header_title"].stringValue
            hideAds = dataJson["hide_ads"].boolValue
            iconImg = dataJson["icon_img"].stringValue
            iconSize = [Int]()
            let iconSizeArray = dataJson["icon_size"].arrayValue
            for iconSizeJson in iconSizeArray{
                iconSize.append(iconSizeJson.intValue)
            }
            id = dataJson["id"].stringValue
            isCrosspostableSubreddit = dataJson["is_crosspostable_subreddit"].boolValue
            isEnrolledInNewModmail = dataJson["is_enrolled_in_new_modmail"].boolValue
            keyColor = dataJson["key_color"].stringValue
            lang = dataJson["lang"].stringValue
            linkFlairEnabled = dataJson["link_flair_enabled"].boolValue
            linkFlairPosition = dataJson["link_flair_position"].stringValue
            mobileBannerImage = dataJson["mobile_banner_image"].stringValue
            name = dataJson["name"].stringValue
            notificationLevel = dataJson["notification_level"].stringValue
            originalContentTagEnabled = dataJson["original_content_tag_enabled"].boolValue
            over18 = dataJson["over18"].boolValue
            predictionLeaderboardEntryType = dataJson["prediction_leaderboard_entry_type"].intValue
            primaryColor = dataJson["primary_color"].stringValue
            publicDescription = dataJson["public_description"].stringValue
            publicDescriptionHtml = dataJson["public_description_html"].stringValue
            publicTraffic = dataJson["public_traffic"].boolValue
            quarantine = dataJson["quarantine"].boolValue
            restrictCommenting = dataJson["restrict_commenting"].boolValue
            restrictPosting = dataJson["restrict_posting"].boolValue
            shouldArchivePosts = dataJson["should_archive_posts"].boolValue
            shouldShowMediaInCommentsSetting = dataJson["should_show_media_in_comments_setting"].boolValue
            showMedia = dataJson["show_media"].boolValue
            showMediaPreview = dataJson["show_media_preview"].boolValue
            spoilersEnabled = dataJson["spoilers_enabled"].boolValue
            submissionType = dataJson["submission_type"].stringValue
            submitLinkLabel = dataJson["submit_link_label"].stringValue
            submitText = dataJson["submit_text"].stringValue
            submitTextHtml = dataJson["submit_text_html"].stringValue
            submitTextLabel = dataJson["submit_text_label"].stringValue
            subredditType = dataJson["subreddit_type"].stringValue
            subscribers = dataJson["subscribers"].intValue
            suggestedCommentSort = dataJson["suggested_comment_sort"].stringValue
            title = dataJson["title"].stringValue
            url = dataJson["url"].stringValue
            userFlairEnabledInSr = dataJson["user_flair_enabled_in_sr"].boolValue
            userFlairPosition = dataJson["user_flair_position"].stringValue
            userFlairRichtext = [UserFlairRichtext]()
            let userFlairRichtextArray = dataJson["user_flair_richtext"].arrayValue
            for userFlairRichtextJson in userFlairRichtextArray{
                userFlairRichtext.append(UserFlairRichtext(fromJson: userFlairRichtextJson))
            }
            userFlairType = dataJson["user_flair_type"].stringValue
            userHasFavorited = dataJson["user_has_favorited"].boolValue
            userIsBanned = dataJson["user_is_banned"].boolValue
            userIsContributor = dataJson["user_is_contributor"].boolValue
            userIsModerator = dataJson["user_is_moderator"].boolValue
            userIsMuted = dataJson["user_is_muted"].boolValue
            userIsSubscriber = dataJson["user_is_subscriber"].boolValue
            userSrThemeEnabled = dataJson["user_sr_theme_enabled"].boolValue
            videostreamLinksCount = dataJson["videostream_links_count"].intValue
            wikiEnabled = dataJson["wiki_enabled"].boolValue
            wls = dataJson["wls"].intValue
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if kind != nil {
            dictionary["kind"] = kind
        }
        if acceptFollowers != nil{
            dictionary["accept_followers"] = acceptFollowers
        }
        if accountsActiveIsFuzzed != nil{
            dictionary["accounts_active_is_fuzzed"] = accountsActiveIsFuzzed
        }
        if advertiserCategory != nil{
            dictionary["advertiser_category"] = advertiserCategory
        }
        if allOriginalContent != nil{
            dictionary["all_original_content"] = allOriginalContent
        }
        if allowDiscovery != nil{
            dictionary["allow_discovery"] = allowDiscovery
        }
        if allowGalleries != nil{
            dictionary["allow_galleries"] = allowGalleries
        }
        if allowImages != nil{
            dictionary["allow_images"] = allowImages
        }
        if allowPolls != nil{
            dictionary["allow_polls"] = allowPolls
        }
        if allowPredictionContributors != nil{
            dictionary["allow_prediction_contributors"] = allowPredictionContributors
        }
        if allowPredictions != nil{
            dictionary["allow_predictions"] = allowPredictions
        }
        if allowPredictionsTournament != nil{
            dictionary["allow_predictions_tournament"] = allowPredictionsTournament
        }
        if allowTalks != nil{
            dictionary["allow_talks"] = allowTalks
        }
        if allowVideogifs != nil{
            dictionary["allow_videogifs"] = allowVideogifs
        }
        if allowVideos != nil{
            dictionary["allow_videos"] = allowVideos
        }
        if allowedMediaInComments != nil{
            dictionary["allowed_media_in_comments"] = allowedMediaInComments
        }
        if bannerBackgroundColor != nil{
            dictionary["banner_background_color"] = bannerBackgroundColor
        }
        if bannerBackgroundImage != nil{
            dictionary["banner_background_image"] = bannerBackgroundImage
        }
        if bannerImg != nil{
            dictionary["banner_img"] = bannerImg
        }
        if bannerSize != nil{
            dictionary["banner_size"] = bannerSize
        }
        if canAssignLinkFlair != nil{
            dictionary["can_assign_link_flair"] = canAssignLinkFlair
        }
        if canAssignUserFlair != nil{
            dictionary["can_assign_user_flair"] = canAssignUserFlair
        }
        if collapseDeletedComments != nil{
            dictionary["collapse_deleted_comments"] = collapseDeletedComments
        }
        if commentContributionSettings != nil{
            dictionary["comment_contribution_settings"] = commentContributionSettings.toDictionary()
        }
        if commentScoreHideMins != nil{
            dictionary["comment_score_hide_mins"] = commentScoreHideMins
        }
        if communityIcon != nil{
            dictionary["community_icon"] = communityIcon
        }
        if communityReviewed != nil{
            dictionary["community_reviewed"] = communityReviewed
        }
        if created != nil{
            dictionary["created"] = created
        }
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if descriptionField != nil{
            dictionary["description"] = descriptionField
        }
        if descriptionHtml != nil{
            dictionary["description_html"] = descriptionHtml
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
        if emojisEnabled != nil{
            dictionary["emojis_enabled"] = emojisEnabled
        }
        if freeFormReports != nil{
            dictionary["free_form_reports"] = freeFormReports
        }
        if hasMenuWidget != nil{
            dictionary["has_menu_widget"] = hasMenuWidget
        }
        if headerImg != nil{
            dictionary["header_img"] = headerImg
        }
        if headerSize != nil{
            dictionary["header_size"] = headerSize
        }
        if headerTitle != nil{
            dictionary["header_title"] = headerTitle
        }
        if hideAds != nil{
            dictionary["hide_ads"] = hideAds
        }
        if iconImg != nil{
            dictionary["icon_img"] = iconImg
        }
        if iconSize != nil{
            dictionary["icon_size"] = iconSize
        }
        if id != nil{
            dictionary["id"] = id
        }
        if isCrosspostableSubreddit != nil{
            dictionary["is_crosspostable_subreddit"] = isCrosspostableSubreddit
        }
        if isEnrolledInNewModmail != nil{
            dictionary["is_enrolled_in_new_modmail"] = isEnrolledInNewModmail
        }
        if keyColor != nil{
            dictionary["key_color"] = keyColor
        }
        if lang != nil{
            dictionary["lang"] = lang
        }
        if linkFlairEnabled != nil{
            dictionary["link_flair_enabled"] = linkFlairEnabled
        }
        if linkFlairPosition != nil{
            dictionary["link_flair_position"] = linkFlairPosition
        }
        if mobileBannerImage != nil{
            dictionary["mobile_banner_image"] = mobileBannerImage
        }
        if name != nil{
            dictionary["name"] = name
        }
        if notificationLevel != nil{
            dictionary["notification_level"] = notificationLevel
        }
        if originalContentTagEnabled != nil{
            dictionary["original_content_tag_enabled"] = originalContentTagEnabled
        }
        if over18 != nil{
            dictionary["over18"] = over18
        }
        if predictionLeaderboardEntryType != nil{
            dictionary["prediction_leaderboard_entry_type"] = predictionLeaderboardEntryType
        }
        if primaryColor != nil{
            dictionary["primary_color"] = primaryColor
        }
        if publicDescription != nil{
            dictionary["public_description"] = publicDescription
        }
        if publicDescriptionHtml != nil{
            dictionary["public_description_html"] = publicDescriptionHtml
        }
        if publicTraffic != nil{
            dictionary["public_traffic"] = publicTraffic
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
        if shouldArchivePosts != nil{
            dictionary["should_archive_posts"] = shouldArchivePosts
        }
        if shouldShowMediaInCommentsSetting != nil{
            dictionary["should_show_media_in_comments_setting"] = shouldShowMediaInCommentsSetting
        }
        if showMedia != nil{
            dictionary["show_media"] = showMedia
        }
        if showMediaPreview != nil{
            dictionary["show_media_preview"] = showMediaPreview
        }
        if spoilersEnabled != nil{
            dictionary["spoilers_enabled"] = spoilersEnabled
        }
        if submissionType != nil{
            dictionary["submission_type"] = submissionType
        }
        if submitLinkLabel != nil{
            dictionary["submit_link_label"] = submitLinkLabel
        }
        if submitText != nil{
            dictionary["submit_text"] = submitText
        }
        if submitTextHtml != nil{
            dictionary["submit_text_html"] = submitTextHtml
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
        if suggestedCommentSort != nil{
            dictionary["suggested_comment_sort"] = suggestedCommentSort
        }
        if title != nil{
            dictionary["title"] = title
        }
        if url != nil{
            dictionary["url"] = url
        }
        if userFlairEnabledInSr != nil{
            dictionary["user_flair_enabled_in_sr"] = userFlairEnabledInSr
        }
        if userFlairPosition != nil{
            dictionary["user_flair_position"] = userFlairPosition
        }
        if userFlairRichtext != nil{
            dictionary["user_flair_richtext"] = userFlairRichtext
        }
        if userFlairType != nil{
            dictionary["user_flair_type"] = userFlairType
        }
        if userHasFavorited != nil{
            dictionary["user_has_favorited"] = userHasFavorited
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
        if userSrThemeEnabled != nil{
            dictionary["user_sr_theme_enabled"] = userSrThemeEnabled
        }
        if videostreamLinksCount != nil{
            dictionary["videostream_links_count"] = videostreamLinksCount
        }
        if wikiEnabled != nil{
            dictionary["wiki_enabled"] = wikiEnabled
        }
        if wls != nil{
            dictionary["wls"] = wls
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        kind = aDecoder.decodeObject(forKey: "kind") as? String
        acceptFollowers = aDecoder.decodeObject(forKey: "accept_followers") as? Bool
        accountsActiveIsFuzzed = aDecoder.decodeObject(forKey: "accounts_active_is_fuzzed") as? Bool
        advertiserCategory = aDecoder.decodeObject(forKey: "advertiser_category") as? String
        allOriginalContent = aDecoder.decodeObject(forKey: "all_original_content") as? Bool
        allowDiscovery = aDecoder.decodeObject(forKey: "allow_discovery") as? Bool
        allowGalleries = aDecoder.decodeObject(forKey: "allow_galleries") as? Bool
        allowImages = aDecoder.decodeObject(forKey: "allow_images") as? Bool
        allowPolls = aDecoder.decodeObject(forKey: "allow_polls") as? Bool
        allowPredictionContributors = aDecoder.decodeObject(forKey: "allow_prediction_contributors") as? Bool
        allowPredictions = aDecoder.decodeObject(forKey: "allow_predictions") as? Bool
        allowPredictionsTournament = aDecoder.decodeObject(forKey: "allow_predictions_tournament") as? Bool
        allowTalks = aDecoder.decodeObject(forKey: "allow_talks") as? Bool
        allowVideogifs = aDecoder.decodeObject(forKey: "allow_videogifs") as? Bool
        allowVideos = aDecoder.decodeObject(forKey: "allow_videos") as? Bool
        allowedMediaInComments = aDecoder.decodeObject(forKey: "allowed_media_in_comments") as? [String]
        bannerBackgroundColor = aDecoder.decodeObject(forKey: "banner_background_color") as? String
        bannerBackgroundImage = aDecoder.decodeObject(forKey: "banner_background_image") as? String
        bannerImg = aDecoder.decodeObject(forKey: "banner_img") as? String
        bannerSize = aDecoder.decodeObject(forKey: "banner_size") as? [Int]
        canAssignLinkFlair = aDecoder.decodeObject(forKey: "can_assign_link_flair") as? Bool
        canAssignUserFlair = aDecoder.decodeObject(forKey: "can_assign_user_flair") as? Bool
        collapseDeletedComments = aDecoder.decodeObject(forKey: "collapse_deleted_comments") as? Bool
        commentContributionSettings = aDecoder.decodeObject(forKey: "comment_contribution_settings") as? CommentContributionSetting
        commentScoreHideMins = aDecoder.decodeObject(forKey: "comment_score_hide_mins") as? Int
        communityIcon = aDecoder.decodeObject(forKey: "community_icon") as? String
        communityReviewed = aDecoder.decodeObject(forKey: "community_reviewed") as? Bool
        created = aDecoder.decodeObject(forKey: "created") as? Int64
        createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Int64
        descriptionField = aDecoder.decodeObject(forKey: "description") as? String
        descriptionHtml = aDecoder.decodeObject(forKey: "description_html") as? String
        disableContributorRequests = aDecoder.decodeObject(forKey: "disable_contributor_requests") as? Bool
        displayName = aDecoder.decodeObject(forKey: "display_name") as? String
        displayNamePrefixed = aDecoder.decodeObject(forKey: "display_name_prefixed") as? String
        emojisEnabled = aDecoder.decodeObject(forKey: "emojis_enabled") as? Bool
        freeFormReports = aDecoder.decodeObject(forKey: "free_form_reports") as? Bool
        hasMenuWidget = aDecoder.decodeObject(forKey: "has_menu_widget") as? Bool
        headerImg = aDecoder.decodeObject(forKey: "header_img") as? String
        headerSize = aDecoder.decodeObject(forKey: "header_size") as? [Int]
        headerTitle = aDecoder.decodeObject(forKey: "header_title") as? String
        hideAds = aDecoder.decodeObject(forKey: "hide_ads") as? Bool
        iconImg = aDecoder.decodeObject(forKey: "icon_img") as? String
        iconSize = aDecoder.decodeObject(forKey: "icon_size") as? [Int]
        id = aDecoder.decodeObject(forKey: "id") as? String
        isCrosspostableSubreddit = aDecoder.decodeObject(forKey: "is_crosspostable_subreddit") as? Bool
        isEnrolledInNewModmail = aDecoder.decodeObject(forKey: "is_enrolled_in_new_modmail") as? Bool
        keyColor = aDecoder.decodeObject(forKey: "key_color") as? String
        lang = aDecoder.decodeObject(forKey: "lang") as? String
        linkFlairEnabled = aDecoder.decodeObject(forKey: "link_flair_enabled") as? Bool
        linkFlairPosition = aDecoder.decodeObject(forKey: "link_flair_position") as? String
        mobileBannerImage = aDecoder.decodeObject(forKey: "mobile_banner_image") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        notificationLevel = aDecoder.decodeObject(forKey: "notification_level") as? String
        originalContentTagEnabled = aDecoder.decodeObject(forKey: "original_content_tag_enabled") as? Bool
        over18 = aDecoder.decodeObject(forKey: "over18") as? Bool
        predictionLeaderboardEntryType = aDecoder.decodeObject(forKey: "prediction_leaderboard_entry_type") as? Int
        primaryColor = aDecoder.decodeObject(forKey: "primary_color") as? String
        publicDescription = aDecoder.decodeObject(forKey: "public_description") as? String
        publicDescriptionHtml = aDecoder.decodeObject(forKey: "public_description_html") as? String
        publicTraffic = aDecoder.decodeObject(forKey: "public_traffic") as? Bool
        quarantine = aDecoder.decodeObject(forKey: "quarantine") as? Bool
        restrictCommenting = aDecoder.decodeObject(forKey: "restrict_commenting") as? Bool
        restrictPosting = aDecoder.decodeObject(forKey: "restrict_posting") as? Bool
        shouldArchivePosts = aDecoder.decodeObject(forKey: "should_archive_posts") as? Bool
        shouldShowMediaInCommentsSetting = aDecoder.decodeObject(forKey: "should_show_media_in_comments_setting") as? Bool
        showMedia = aDecoder.decodeObject(forKey: "show_media") as? Bool
        showMediaPreview = aDecoder.decodeObject(forKey: "show_media_preview") as? Bool
        spoilersEnabled = aDecoder.decodeObject(forKey: "spoilers_enabled") as? Bool
        submissionType = aDecoder.decodeObject(forKey: "submission_type") as? String
        submitLinkLabel = aDecoder.decodeObject(forKey: "submit_link_label") as? String
        submitText = aDecoder.decodeObject(forKey: "submit_text") as? String
        submitTextHtml = aDecoder.decodeObject(forKey: "submit_text_html") as? String
        submitTextLabel = aDecoder.decodeObject(forKey: "submit_text_label") as? String
        subredditType = aDecoder.decodeObject(forKey: "subreddit_type") as? String
        subscribers = aDecoder.decodeObject(forKey: "subscribers") as? Int
        suggestedCommentSort = aDecoder.decodeObject(forKey: "suggested_comment_sort") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
        userFlairEnabledInSr = aDecoder.decodeObject(forKey: "user_flair_enabled_in_sr") as? Bool
        userFlairPosition = aDecoder.decodeObject(forKey: "user_flair_position") as? String
        userFlairRichtext = aDecoder.decodeObject(forKey: "user_flair_richtext") as? [UserFlairRichtext]
        userFlairType = aDecoder.decodeObject(forKey: "user_flair_type") as? String
        userHasFavorited = aDecoder.decodeObject(forKey: "user_has_favorited") as? Bool
        userIsBanned = aDecoder.decodeObject(forKey: "user_is_banned") as? Bool
        userIsContributor = aDecoder.decodeObject(forKey: "user_is_contributor") as? Bool
        userIsModerator = aDecoder.decodeObject(forKey: "user_is_moderator") as? Bool
        userIsMuted = aDecoder.decodeObject(forKey: "user_is_muted") as? Bool
        userIsSubscriber = aDecoder.decodeObject(forKey: "user_is_subscriber") as? Bool
        userSrThemeEnabled = aDecoder.decodeObject(forKey: "user_sr_theme_enabled") as? Bool
        videostreamLinksCount = aDecoder.decodeObject(forKey: "videostream_links_count") as? Int
        wikiEnabled = aDecoder.decodeObject(forKey: "wiki_enabled") as? Bool
        wls = aDecoder.decodeObject(forKey: "wls") as? Int
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if kind != nil {
            aCoder.encode(kind, forKey: "kind")
        }
        if acceptFollowers != nil{
            aCoder.encode(acceptFollowers, forKey: "accept_followers")
        }
        if accountsActiveIsFuzzed != nil{
            aCoder.encode(accountsActiveIsFuzzed, forKey: "accounts_active_is_fuzzed")
        }
        if advertiserCategory != nil{
            aCoder.encode(advertiserCategory, forKey: "advertiser_category")
        }
        if allOriginalContent != nil{
            aCoder.encode(allOriginalContent, forKey: "all_original_content")
        }
        if allowDiscovery != nil{
            aCoder.encode(allowDiscovery, forKey: "allow_discovery")
        }
        if allowGalleries != nil{
            aCoder.encode(allowGalleries, forKey: "allow_galleries")
        }
        if allowImages != nil{
            aCoder.encode(allowImages, forKey: "allow_images")
        }
        if allowPolls != nil{
            aCoder.encode(allowPolls, forKey: "allow_polls")
        }
        if allowPredictionContributors != nil{
            aCoder.encode(allowPredictionContributors, forKey: "allow_prediction_contributors")
        }
        if allowPredictions != nil{
            aCoder.encode(allowPredictions, forKey: "allow_predictions")
        }
        if allowPredictionsTournament != nil{
            aCoder.encode(allowPredictionsTournament, forKey: "allow_predictions_tournament")
        }
        if allowTalks != nil{
            aCoder.encode(allowTalks, forKey: "allow_talks")
        }
        if allowVideogifs != nil{
            aCoder.encode(allowVideogifs, forKey: "allow_videogifs")
        }
        if allowVideos != nil{
            aCoder.encode(allowVideos, forKey: "allow_videos")
        }
        if allowedMediaInComments != nil{
            aCoder.encode(allowedMediaInComments, forKey: "allowed_media_in_comments")
        }
        if bannerBackgroundColor != nil{
            aCoder.encode(bannerBackgroundColor, forKey: "banner_background_color")
        }
        if bannerBackgroundImage != nil{
            aCoder.encode(bannerBackgroundImage, forKey: "banner_background_image")
        }
        if bannerImg != nil{
            aCoder.encode(bannerImg, forKey: "banner_img")
        }
        if bannerSize != nil{
            aCoder.encode(bannerSize, forKey: "banner_size")
        }
        if canAssignLinkFlair != nil{
            aCoder.encode(canAssignLinkFlair, forKey: "can_assign_link_flair")
        }
        if canAssignUserFlair != nil{
            aCoder.encode(canAssignUserFlair, forKey: "can_assign_user_flair")
        }
        if collapseDeletedComments != nil{
            aCoder.encode(collapseDeletedComments, forKey: "collapse_deleted_comments")
        }
        if commentContributionSettings != nil{
            aCoder.encode(commentContributionSettings, forKey: "comment_contribution_settings")
        }
        if commentScoreHideMins != nil{
            aCoder.encode(commentScoreHideMins, forKey: "comment_score_hide_mins")
        }
        if communityIcon != nil{
            aCoder.encode(communityIcon, forKey: "community_icon")
        }
        if communityReviewed != nil{
            aCoder.encode(communityReviewed, forKey: "community_reviewed")
        }
        if created != nil{
            aCoder.encode(created, forKey: "created")
        }
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if descriptionField != nil{
            aCoder.encode(descriptionField, forKey: "description")
        }
        if descriptionHtml != nil{
            aCoder.encode(descriptionHtml, forKey: "description_html")
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
        if emojisEnabled != nil{
            aCoder.encode(emojisEnabled, forKey: "emojis_enabled")
        }
        if freeFormReports != nil{
            aCoder.encode(freeFormReports, forKey: "free_form_reports")
        }
        if hasMenuWidget != nil{
            aCoder.encode(hasMenuWidget, forKey: "has_menu_widget")
        }
        if headerImg != nil{
            aCoder.encode(headerImg, forKey: "header_img")
        }
        if headerSize != nil{
            aCoder.encode(headerSize, forKey: "header_size")
        }
        if headerTitle != nil{
            aCoder.encode(headerTitle, forKey: "header_title")
        }
        if hideAds != nil{
            aCoder.encode(hideAds, forKey: "hide_ads")
        }
        if iconImg != nil{
            aCoder.encode(iconImg, forKey: "icon_img")
        }
        if iconSize != nil{
            aCoder.encode(iconSize, forKey: "icon_size")
        }
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if isCrosspostableSubreddit != nil{
            aCoder.encode(isCrosspostableSubreddit, forKey: "is_crosspostable_subreddit")
        }
        if isEnrolledInNewModmail != nil{
            aCoder.encode(isEnrolledInNewModmail, forKey: "is_enrolled_in_new_modmail")
        }
        if keyColor != nil{
            aCoder.encode(keyColor, forKey: "key_color")
        }
        if lang != nil{
            aCoder.encode(lang, forKey: "lang")
        }
        if linkFlairEnabled != nil{
            aCoder.encode(linkFlairEnabled, forKey: "link_flair_enabled")
        }
        if linkFlairPosition != nil{
            aCoder.encode(linkFlairPosition, forKey: "link_flair_position")
        }
        if mobileBannerImage != nil{
            aCoder.encode(mobileBannerImage, forKey: "mobile_banner_image")
        }
        if name != nil{
            aCoder.encode(name, forKey: "name")
        }
        if notificationLevel != nil{
            aCoder.encode(notificationLevel, forKey: "notification_level")
        }
        if originalContentTagEnabled != nil{
            aCoder.encode(originalContentTagEnabled, forKey: "original_content_tag_enabled")
        }
        if over18 != nil{
            aCoder.encode(over18, forKey: "over18")
        }
        if predictionLeaderboardEntryType != nil{
            aCoder.encode(predictionLeaderboardEntryType, forKey: "prediction_leaderboard_entry_type")
        }
        if primaryColor != nil{
            aCoder.encode(primaryColor, forKey: "primary_color")
        }
        if publicDescription != nil{
            aCoder.encode(publicDescription, forKey: "public_description")
        }
        if publicDescriptionHtml != nil{
            aCoder.encode(publicDescriptionHtml, forKey: "public_description_html")
        }
        if publicTraffic != nil{
            aCoder.encode(publicTraffic, forKey: "public_traffic")
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
        if shouldArchivePosts != nil{
            aCoder.encode(shouldArchivePosts, forKey: "should_archive_posts")
        }
        if shouldShowMediaInCommentsSetting != nil{
            aCoder.encode(shouldShowMediaInCommentsSetting, forKey: "should_show_media_in_comments_setting")
        }
        if showMedia != nil{
            aCoder.encode(showMedia, forKey: "show_media")
        }
        if showMediaPreview != nil{
            aCoder.encode(showMediaPreview, forKey: "show_media_preview")
        }
        if spoilersEnabled != nil{
            aCoder.encode(spoilersEnabled, forKey: "spoilers_enabled")
        }
        if submissionType != nil{
            aCoder.encode(submissionType, forKey: "submission_type")
        }
        if submitLinkLabel != nil{
            aCoder.encode(submitLinkLabel, forKey: "submit_link_label")
        }
        if submitText != nil{
            aCoder.encode(submitText, forKey: "submit_text")
        }
        if submitTextHtml != nil{
            aCoder.encode(submitTextHtml, forKey: "submit_text_html")
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
        if suggestedCommentSort != nil{
            aCoder.encode(suggestedCommentSort, forKey: "suggested_comment_sort")
        }
        if title != nil{
            aCoder.encode(title, forKey: "title")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if userFlairEnabledInSr != nil{
            aCoder.encode(userFlairEnabledInSr, forKey: "user_flair_enabled_in_sr")
        }
        if userFlairPosition != nil{
            aCoder.encode(userFlairPosition, forKey: "user_flair_position")
        }
        if userFlairRichtext != nil{
            aCoder.encode(userFlairRichtext, forKey: "user_flair_richtext")
        }
        if userFlairType != nil{
            aCoder.encode(userFlairType, forKey: "user_flair_type")
        }
        if userHasFavorited != nil{
            aCoder.encode(userHasFavorited, forKey: "user_has_favorited")
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
        if userSrThemeEnabled != nil{
            aCoder.encode(userSrThemeEnabled, forKey: "user_sr_theme_enabled")
        }
        if videostreamLinksCount != nil{
            aCoder.encode(videostreamLinksCount, forKey: "videostream_links_count")
        }
        if wikiEnabled != nil{
            aCoder.encode(wikiEnabled, forKey: "wiki_enabled")
        }
        if wls != nil{
            aCoder.encode(wls, forKey: "wls")
        }
        
    }
    
}

class CommentContributionSetting : NSObject, NSCoding{
    
    var allowedMediaTypes : [String]!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        allowedMediaTypes = [String]()
        let allowedMediaTypesArray = json["allowed_media_types"].arrayValue
        for allowedMediaTypesJson in allowedMediaTypesArray{
            allowedMediaTypes.append(allowedMediaTypesJson.stringValue)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if allowedMediaTypes != nil{
            dictionary["allowed_media_types"] = allowedMediaTypes
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        allowedMediaTypes = aDecoder.decodeObject(forKey: "allowed_media_types") as? [String]
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if allowedMediaTypes != nil{
            aCoder.encode(allowedMediaTypes, forKey: "allowed_media_types")
        }
        
    }
    
}

class UserFlairRichtext : NSObject, NSCoding{
    
    //Type e.g. "text", "emoji"
    var e : String!
    //Text
    var t : String!
    //Media id, e.g. :pixel9proxlporcelain: (Not sure)
    var a : String!
    //Media URL
    var u : String!
    
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        e = json["e"].stringValue
        t = json["t"].stringValue
        a = json["a"].stringValue
        u = json["u"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if e != nil{
            dictionary["e"] = e
        }
        if t != nil{
            dictionary["t"] = t
        }
        if a != nil{
            dictionary["a"] = t
        }
        if u != nil{
            dictionary["u"] = t
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        e = aDecoder.decodeObject(forKey: "e") as? String
        t = aDecoder.decodeObject(forKey: "t") as? String
        
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if e != nil{
            aCoder.encode(e, forKey: "e")
        }
        if t != nil{
            aCoder.encode(t, forKey: "t")
        }
        
    }
    
}
