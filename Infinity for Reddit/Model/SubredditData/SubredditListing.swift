//
//  SubredditListing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-19.
//

import Foundation
import SwiftyJSON

class SubredditListingRootClass: NSObject {
    var kind: String!
    var data: SubredditListing!

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            data = try SubredditListing(fromJson: dataJson)
        } else {
            throw JSONError.invalidData
        }
        kind = json["kind"].stringValue
    }
}

public class SubredditListing : NSObject {
    var subreddits : [Subreddit]! = [Subreddit]()
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
            if !dataJson.isEmpty {
                do {
                    subreddits.append(try Subreddit(fromJson: dataJson))
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        after = json["after"].stringValue
        before = json["before"].stringValue
        dist = json["dist"].intValue
    }
}

class Subreddit: NSObject, Identifiable {
    var acceptFollowers : Bool!
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
    var bannerSize : Size!
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
    var emojisCustomSize : Size!
    var emojisEnabled : Bool!
    var freeFormReports : Bool!
    var hasMenuWidget : Bool!
    var headerImg : String!
    var headerSize : [Int]!
    var headerTitle : String!
    var hideAds : Bool!
    var iconImg : String!
    var iconSize : Size!
    public var id : String!
    var isCrosspostableSubreddit : Bool!
    var isEnrolledInNewModmail : Bool!
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
    var suggestedCommentSort : String!
    var title : String!
    var url : String!
    var userCanFlairInSr : String!
    var userFlairBackgroundColor : String!
    var userFlairCssClass : String!
    var userFlairEnabledInSr : Bool!
    var userFlairPosition : String!
    var userFlairRichtext : [FlairRichtext]! = [FlairRichtext]()
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

    var iconUrl: String {
        return iconImg.isEmpty ? communityIcon : iconImg
    }
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        acceptFollowers = json["accept_followers"].boolValue
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
        if let bannerArray = json["banner_size"].array, bannerArray.count == 2 {
            let width = bannerArray[0].intValue
            let height = bannerArray[1].intValue
            bannerSize = Size(width: width, height: height)
        }
        bannerSize = JSONUtils.parseNullableSize(json, "banner_size")
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
        createdUtc = json["created_utc"].int64Value
        descriptionField = json["description"].stringValue
        descriptionHtml = json["description_html"].stringValue
        disableContributorRequests = json["disable_contributor_requests"].boolValue
        displayName = json["display_name"].stringValue
        displayNamePrefixed = json["display_name_prefixed"].stringValue
        emojisCustomSize = JSONUtils.parseNullableSize(json, "emojis_custom_size")
        emojisEnabled = json["emojis_enabled"].boolValue
        freeFormReports = json["free_form_reports"].boolValue
        hasMenuWidget = json["has_menu_widget"].boolValue
        headerImg = json["header_img"].stringValue
        headerSize = [Int]()
        let headerSizeArray = json["header_size"].arrayValue
        for headerSizeJson in headerSizeArray{
            headerSize.append(headerSizeJson.intValue)
        }
        headerTitle = json["header_title"].stringValue
        hideAds = json["hide_ads"].boolValue
        iconImg = json["icon_img"].stringValue
        iconSize = JSONUtils.parseNullableSize(json, "icon_size")
        id = json["id"].stringValue
        isCrosspostableSubreddit = json["is_crosspostable_subreddit"].boolValue
        isEnrolledInNewModmail = json["is_enrolled_in_new_modmail"].boolValue
        keyColor = json["key_color"].stringValue
        lang = json["lang"].stringValue
        linkFlairEnabled = json["link_flair_enabled"].boolValue
        linkFlairPosition = json["link_flair_position"].stringValue
        mobileBannerImage = json["mobile_banner_image"].stringValue
        name = json["name"].stringValue
        notificationLevel = json["notification_level"].string
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
        userCanFlairInSr = json["user_can_flair_in_sr"].stringValue
        userFlairBackgroundColor = json["user_flair_background_color"].stringValue
        userFlairCssClass = json["user_flair_css_class"].stringValue
        userFlairEnabledInSr = json["user_flair_enabled_in_sr"].boolValue
        userFlairPosition = json["user_flair_position"].stringValue
        let userFlairRichtextArray = json["user_flair_richtext"].arrayValue
        for userFlairRichtextJson in userFlairRichtextArray {
            do {
                let flairRichtext = try FlairRichtext(fromJson: userFlairRichtextJson)
                userFlairRichtext.append(flairRichtext)
            } catch {
                // Ignore
            }
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
    
    public func toSubredditData() -> SubredditData {
        return SubredditData(
            id: id,
            name: displayName,
            fullName: name,
            iconUrl: iconUrl,
            bannerUrl: bannerBackgroundImage,
            description: descriptionField,
            sidebarDescription: publicDescription,
            nSubscribers: subscribers,
            createdUTC: createdUtc,
            suggestedCommentSort: suggestedCommentSort,
            isNSFW: over18
        )
    }
}
