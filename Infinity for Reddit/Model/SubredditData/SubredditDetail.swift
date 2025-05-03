//
// SubredditDetail.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-02
        
import Foundation
import SwiftyJSON


class SubredditDetailRootClass : NSObject, NSCoding{

    var data : SubredditDetail!
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
            data = SubredditDetail(fromJson: dataJson)
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
         data = aDecoder.decodeObject(forKey: "data") as? SubredditDetail
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
    
    public func toSubredditData() -> SubredditData {
        return SubredditData(
            id: data.id,
            name: data.displayName,
            iconUrl: data.iconImg,
            bannerUrl: data.bannerImg,
            description: data.descriptionField,
            sidebarDescription: data.publicDescription,
            nSubscribers: data.subscribers,
            createdUTC: data.createdUtc,
            suggestedCommentSort: data.suggestedCommentSort,
            isNSFW: data.over18
        )
    }

}

class SubredditDetail : NSObject, NSCoding{

    var acceptFollowers : Bool!
    var accountsActive : Int!
    var accountsActiveIsFuzzed : Bool!
    var activeUserCount : Int!
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
    var bannerSize : String!
    var canAssignLinkFlair : Bool!
    var canAssignUserFlair : Bool!
    var collapseDeletedComments : Bool!
    var commentContributionSettings : CommentContributionSetting!
    var commentScoreHideMins : Int!
    var communityIcon : String!
    var communityReviewed : Bool!
    var created : Float!
    var createdUtc : Int64!
    var descriptionField : String!
    var descriptionHtml : String!
    var disableContributorRequests : Bool!
    var displayName : String!
    var displayNamePrefixed : String!
    var emojisCustomSize : String!
    var emojisEnabled : Bool!
    var freeFormReports : Bool!
    var hasMenuWidget : Bool!
    var headerImg : String!
    var headerSize : String!
    var headerTitle : String!
    var hideAds : Bool!
    var iconImg : String!
    var iconSize : String!
    var id : String!
    var isCrosspostableSubreddit : Bool!
    var isEnrolledInNewModmail : Bool!
    var keyColor : String!
    var lang : String!
    var linkFlairEnabled : Bool!
    var linkFlairPosition : String!
    var mobileBannerImage : String!
    var name : String!
    var notificationLevel : Int!
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
    var suggestedCommentSort : String!
    var title : String!
    var url : String!
    var userCanFlairInSr : Bool!
    var userFlairBackgroundColor : String!
    var userFlairCssClass : String!
    var userFlairEnabledInSr : Bool!
    var userFlairPosition : String!
    var userFlairRichtext : [String]!
    var userFlairTemplateId : String!
    var userFlairText : String!
    var userFlairTextColor : String!
    var userFlairType : String!
    var userHasFavorited : Bool!
    var userIsBanned : Bool!
    var userIsContributor : Bool!
    var userIsModerator : Bool!
    var userIsMuted : Bool!
    var userIsSubscriber : Bool!
    var userSrFlairEnabled : Bool!
    var userSrThemeEnabled : Bool!
    var videostreamLinksCount : Int!
    var wikiEnabled : Bool!
    var wls : Int!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        acceptFollowers = json["accept_followers"].boolValue
        accountsActive = json["accounts_active"].intValue
        accountsActiveIsFuzzed = json["accounts_active_is_fuzzed"].boolValue
        activeUserCount = json["active_user_count"].intValue
        advertiserCategory = json["advertiser_category"].stringValue
        allOriginalContent = json["all_original_content"].boolValue
        allowDiscovery = json["allow_discovery"].boolValue
        allowGalleries = json["allow_galleries"].boolValue
        allowImages = json["allow_images"].boolValue
        allowPolls = json["allow_polls"].boolValue
        allowPredictionContributors = json["allow_prediction_contributors"].boolValue
        allowPredictions = json["allow_predictions"].boolValue
        allowPredictionsTournament = json["allow_predictions_tournament"].boolValue
        allowTalks = json["allow_talks"].boolValue
        allowVideogifs = json["allow_videogifs"].boolValue
        allowVideos = json["allow_videos"].boolValue
        allowedMediaInComments = [String]()
        let allowedMediaInCommentsArray = json["allowed_media_in_comments"].arrayValue
        for allowedMediaInCommentsJson in allowedMediaInCommentsArray{
            allowedMediaInComments.append(allowedMediaInCommentsJson.stringValue)
        }
        bannerBackgroundColor = json["banner_background_color"].stringValue
        bannerBackgroundImage = json["banner_background_image"].stringValue
        bannerImg = json["banner_img"].stringValue
        bannerSize = json["banner_size"].stringValue
        canAssignLinkFlair = json["can_assign_link_flair"].boolValue
        canAssignUserFlair = json["can_assign_user_flair"].boolValue
        collapseDeletedComments = json["collapse_deleted_comments"].boolValue
        let commentContributionSettingsJson = json["comment_contribution_settings"]
        if !commentContributionSettingsJson.isEmpty{
            commentContributionSettings = CommentContributionSetting(fromJson: commentContributionSettingsJson)
        }
        commentScoreHideMins = json["comment_score_hide_mins"].intValue
        communityIcon = json["community_icon"].stringValue
        communityReviewed = json["community_reviewed"].boolValue
        created = json["created"].floatValue
        createdUtc = Int64(json["created_utc"].intValue)
        descriptionField = json["description"].stringValue
        descriptionHtml = json["description_html"].stringValue
        disableContributorRequests = json["disable_contributor_requests"].boolValue
        displayName = json["display_name"].stringValue
        displayNamePrefixed = json["display_name_prefixed"].stringValue
        emojisCustomSize = json["emojis_custom_size"].stringValue
        emojisEnabled = json["emojis_enabled"].boolValue
        freeFormReports = json["free_form_reports"].boolValue
        hasMenuWidget = json["has_menu_widget"].boolValue
        headerImg = json["header_img"].stringValue
        headerSize = json["header_size"].stringValue
        headerTitle = json["header_title"].stringValue
        hideAds = json["hide_ads"].boolValue
        iconImg = json["icon_img"].stringValue
        iconSize = json["icon_size"].stringValue
        id = json["id"].stringValue
        isCrosspostableSubreddit = json["is_crosspostable_subreddit"].boolValue
        isEnrolledInNewModmail = json["is_enrolled_in_new_modmail"].boolValue
        keyColor = json["key_color"].stringValue
        lang = json["lang"].stringValue
        linkFlairEnabled = json["link_flair_enabled"].boolValue
        linkFlairPosition = json["link_flair_position"].stringValue
        mobileBannerImage = json["mobile_banner_image"].stringValue
        name = json["name"].stringValue
        notificationLevel = json["notification_level"].intValue
        originalContentTagEnabled = json["original_content_tag_enabled"].boolValue
        over18 = json["over18"].boolValue
        predictionLeaderboardEntryType = json["prediction_leaderboard_entry_type"].intValue
        primaryColor = json["primary_color"].stringValue
        publicDescription = json["public_description"].stringValue
        publicDescriptionHtml = json["public_description_html"].stringValue
        publicTraffic = json["public_traffic"].boolValue
        quarantine = json["quarantine"].boolValue
        restrictCommenting = json["restrict_commenting"].boolValue
        restrictPosting = json["restrict_posting"].boolValue
        shouldArchivePosts = json["should_archive_posts"].boolValue
        shouldShowMediaInCommentsSetting = json["should_show_media_in_comments_setting"].boolValue
        showMedia = json["show_media"].boolValue
        showMediaPreview = json["show_media_preview"].boolValue
        spoilersEnabled = json["spoilers_enabled"].boolValue
        submissionType = json["submission_type"].stringValue
        submitLinkLabel = json["submit_link_label"].stringValue
        submitText = json["submit_text"].stringValue
        submitTextHtml = json["submit_text_html"].stringValue
        submitTextLabel = json["submit_text_label"].stringValue
        subredditType = json["subreddit_type"].stringValue
        subscribers = json["subscribers"].intValue
        suggestedCommentSort = json["suggested_comment_sort"].stringValue
        title = json["title"].stringValue
        url = json["url"].stringValue
        userCanFlairInSr = json["user_can_flair_in_sr"].boolValue
        userFlairBackgroundColor = json["user_flair_background_color"].stringValue
        userFlairCssClass = json["user_flair_css_class"].stringValue
        userFlairEnabledInSr = json["user_flair_enabled_in_sr"].boolValue
        userFlairPosition = json["user_flair_position"].stringValue
        userFlairRichtext = [String]()
        let userFlairRichtextArray = json["user_flair_richtext"].arrayValue
        for userFlairRichtextJson in userFlairRichtextArray{
            userFlairRichtext.append(userFlairRichtextJson.stringValue)
        }
        userFlairTemplateId = json["user_flair_template_id"].stringValue
        userFlairText = json["user_flair_text"].stringValue
        userFlairTextColor = json["user_flair_text_color"].stringValue
        userFlairType = json["user_flair_type"].stringValue
        userHasFavorited = json["user_has_favorited"].boolValue
        userIsBanned = json["user_is_banned"].boolValue
        userIsContributor = json["user_is_contributor"].boolValue
        userIsModerator = json["user_is_moderator"].boolValue
        userIsMuted = json["user_is_muted"].boolValue
        userIsSubscriber = json["user_is_subscriber"].boolValue
        userSrFlairEnabled = json["user_sr_flair_enabled"].boolValue
        userSrThemeEnabled = json["user_sr_theme_enabled"].boolValue
        videostreamLinksCount = json["videostream_links_count"].intValue
        wikiEnabled = json["wiki_enabled"].boolValue
        wls = json["wls"].intValue
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
        if accountsActive != nil{
            dictionary["accounts_active"] = accountsActive
        }
        if accountsActiveIsFuzzed != nil{
            dictionary["accounts_active_is_fuzzed"] = accountsActiveIsFuzzed
        }
        if activeUserCount != nil{
            dictionary["active_user_count"] = activeUserCount
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
        if emojisCustomSize != nil{
            dictionary["emojis_custom_size"] = emojisCustomSize
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
        if userCanFlairInSr != nil{
            dictionary["user_can_flair_in_sr"] = userCanFlairInSr
        }
        if userFlairBackgroundColor != nil{
            dictionary["user_flair_background_color"] = userFlairBackgroundColor
        }
        if userFlairCssClass != nil{
            dictionary["user_flair_css_class"] = userFlairCssClass
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
        if userFlairTemplateId != nil{
            dictionary["user_flair_template_id"] = userFlairTemplateId
        }
        if userFlairText != nil{
            dictionary["user_flair_text"] = userFlairText
        }
        if userFlairTextColor != nil{
            dictionary["user_flair_text_color"] = userFlairTextColor
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
        if userSrFlairEnabled != nil{
            dictionary["user_sr_flair_enabled"] = userSrFlairEnabled
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
         acceptFollowers = aDecoder.decodeObject(forKey: "accept_followers") as? Bool
         accountsActive = aDecoder.decodeObject(forKey: "accounts_active") as? Int
         accountsActiveIsFuzzed = aDecoder.decodeObject(forKey: "accounts_active_is_fuzzed") as? Bool
         activeUserCount = aDecoder.decodeObject(forKey: "active_user_count") as? Int
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
         bannerSize = aDecoder.decodeObject(forKey: "banner_size") as? String
         canAssignLinkFlair = aDecoder.decodeObject(forKey: "can_assign_link_flair") as? Bool
         canAssignUserFlair = aDecoder.decodeObject(forKey: "can_assign_user_flair") as? Bool
         collapseDeletedComments = aDecoder.decodeObject(forKey: "collapse_deleted_comments") as? Bool
         commentContributionSettings = aDecoder.decodeObject(forKey: "comment_contribution_settings") as? CommentContributionSetting
         commentScoreHideMins = aDecoder.decodeObject(forKey: "comment_score_hide_mins") as? Int
         communityIcon = aDecoder.decodeObject(forKey: "community_icon") as? String
         communityReviewed = aDecoder.decodeObject(forKey: "community_reviewed") as? Bool
         created = aDecoder.decodeObject(forKey: "created") as? Float
         createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Int64
         descriptionField = aDecoder.decodeObject(forKey: "description") as? String
         descriptionHtml = aDecoder.decodeObject(forKey: "description_html") as? String
         disableContributorRequests = aDecoder.decodeObject(forKey: "disable_contributor_requests") as? Bool
         displayName = aDecoder.decodeObject(forKey: "display_name") as? String
         displayNamePrefixed = aDecoder.decodeObject(forKey: "display_name_prefixed") as? String
         emojisCustomSize = aDecoder.decodeObject(forKey: "emojis_custom_size") as? String
         emojisEnabled = aDecoder.decodeObject(forKey: "emojis_enabled") as? Bool
         freeFormReports = aDecoder.decodeObject(forKey: "free_form_reports") as? Bool
         hasMenuWidget = aDecoder.decodeObject(forKey: "has_menu_widget") as? Bool
         headerImg = aDecoder.decodeObject(forKey: "header_img") as? String
         headerSize = aDecoder.decodeObject(forKey: "header_size") as? String
         headerTitle = aDecoder.decodeObject(forKey: "header_title") as? String
         hideAds = aDecoder.decodeObject(forKey: "hide_ads") as? Bool
         iconImg = aDecoder.decodeObject(forKey: "icon_img") as? String
         iconSize = aDecoder.decodeObject(forKey: "icon_size") as? String
         id = aDecoder.decodeObject(forKey: "id") as? String
         isCrosspostableSubreddit = aDecoder.decodeObject(forKey: "is_crosspostable_subreddit") as? Bool
         isEnrolledInNewModmail = aDecoder.decodeObject(forKey: "is_enrolled_in_new_modmail") as? Bool
         keyColor = aDecoder.decodeObject(forKey: "key_color") as? String
         lang = aDecoder.decodeObject(forKey: "lang") as? String
         linkFlairEnabled = aDecoder.decodeObject(forKey: "link_flair_enabled") as? Bool
         linkFlairPosition = aDecoder.decodeObject(forKey: "link_flair_position") as? String
         mobileBannerImage = aDecoder.decodeObject(forKey: "mobile_banner_image") as? String
         name = aDecoder.decodeObject(forKey: "name") as? String
         notificationLevel = aDecoder.decodeObject(forKey: "notification_level") as? Int
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
         userCanFlairInSr = aDecoder.decodeObject(forKey: "user_can_flair_in_sr") as? Bool
         userFlairBackgroundColor = aDecoder.decodeObject(forKey: "user_flair_background_color") as? String
         userFlairCssClass = aDecoder.decodeObject(forKey: "user_flair_css_class") as? String
         userFlairEnabledInSr = aDecoder.decodeObject(forKey: "user_flair_enabled_in_sr") as? Bool
         userFlairPosition = aDecoder.decodeObject(forKey: "user_flair_position") as? String
         userFlairRichtext = aDecoder.decodeObject(forKey: "user_flair_richtext") as? [String]
         userFlairTemplateId = aDecoder.decodeObject(forKey: "user_flair_template_id") as? String
         userFlairText = aDecoder.decodeObject(forKey: "user_flair_text") as? String
         userFlairTextColor = aDecoder.decodeObject(forKey: "user_flair_text_color") as? String
         userFlairType = aDecoder.decodeObject(forKey: "user_flair_type") as? String
         userHasFavorited = aDecoder.decodeObject(forKey: "user_has_favorited") as? Bool
         userIsBanned = aDecoder.decodeObject(forKey: "user_is_banned") as? Bool
         userIsContributor = aDecoder.decodeObject(forKey: "user_is_contributor") as? Bool
         userIsModerator = aDecoder.decodeObject(forKey: "user_is_moderator") as? Bool
         userIsMuted = aDecoder.decodeObject(forKey: "user_is_muted") as? Bool
         userIsSubscriber = aDecoder.decodeObject(forKey: "user_is_subscriber") as? Bool
         userSrFlairEnabled = aDecoder.decodeObject(forKey: "user_sr_flair_enabled") as? Bool
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
        if acceptFollowers != nil{
            aCoder.encode(acceptFollowers, forKey: "accept_followers")
        }
        if accountsActive != nil{
            aCoder.encode(accountsActive, forKey: "accounts_active")
        }
        if accountsActiveIsFuzzed != nil{
            aCoder.encode(accountsActiveIsFuzzed, forKey: "accounts_active_is_fuzzed")
        }
        if activeUserCount != nil{
            aCoder.encode(activeUserCount, forKey: "active_user_count")
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
        if emojisCustomSize != nil{
            aCoder.encode(emojisCustomSize, forKey: "emojis_custom_size")
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
        if userCanFlairInSr != nil{
            aCoder.encode(userCanFlairInSr, forKey: "user_can_flair_in_sr")
        }
        if userFlairBackgroundColor != nil{
            aCoder.encode(userFlairBackgroundColor, forKey: "user_flair_background_color")
        }
        if userFlairCssClass != nil{
            aCoder.encode(userFlairCssClass, forKey: "user_flair_css_class")
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
        if userFlairTemplateId != nil{
            aCoder.encode(userFlairTemplateId, forKey: "user_flair_template_id")
        }
        if userFlairText != nil{
            aCoder.encode(userFlairText, forKey: "user_flair_text")
        }
        if userFlairTextColor != nil{
            aCoder.encode(userFlairTextColor, forKey: "user_flair_text_color")
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
        if userSrFlairEnabled != nil{
            aCoder.encode(userSrFlairEnabled, forKey: "user_sr_flair_enabled")
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

//class CommentContributionSetting : NSObject, NSCoding{
//
//    var allowedMediaTypes : [String]!
//
//
//    /**
//     * Instantiate the instance using the passed json values to set the properties values
//     */
//    init(fromJson json: JSON!){
//        if json.isEmpty{
//            return
//        }
//        allowedMediaTypes = [String]()
//        let allowedMediaTypesArray = json["allowed_media_types"].arrayValue
//        for allowedMediaTypesJson in allowedMediaTypesArray{
//            allowedMediaTypes.append(allowedMediaTypesJson.stringValue)
//        }
//    }
//
//    /**
//     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
//     */
//    func toDictionary() -> [String:Any]
//    {
//        var dictionary = [String:Any]()
//        if allowedMediaTypes != nil{
//            dictionary["allowed_media_types"] = allowedMediaTypes
//        }
//        return dictionary
//    }
//
//    /**
//    * NSCoding required initializer.
//    * Fills the data from the passed decoder
//    */
//    @objc required init(coder aDecoder: NSCoder)
//    {
//         allowedMediaTypes = aDecoder.decodeObject(forKey: "allowed_media_types") as? [String]
//
//    }
//
//    /**
//    * NSCoding required method.
//    * Encodes mode properties into the decoder
//    */
//    func encode(with aCoder: NSCoder)
//    {
//        if allowedMediaTypes != nil{
//            aCoder.encode(allowedMediaTypes, forKey: "allowed_media_types")
//        }
//
//    }
//
//}
