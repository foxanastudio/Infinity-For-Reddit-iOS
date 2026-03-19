//
//  RedditSettings.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-19.
//

import Foundation
import SwiftyJSON

class RedditSettings : NSObject {
    var acceptPms : String!
    var activityRelevantAds : Bool!
    var allowClicktracking : Bool!
    var badCommentAutocollapse : String!
    var beta : Bool!
    var clickgadget : Bool!
    var collapseLeftBar : Bool!
    var collapseReadMessages : Bool!
    var compress : Bool!
    var countryCode : String!
    var defaultCommentSort : String!
    // May not be a String
    var defaultThemeSr : String!
    var designBeta : Bool!
    var domainDetails : Bool!
    var emailChatRequest : Bool!
    var emailCommentReply : Bool!
    var emailCommunityDiscovery : Bool!
    var emailDigests : Bool!
    var emailMessages : Bool!
    var emailNewUserWelcome : Bool!
    var emailPostReply : Bool!
    var emailPrivateMessage : Bool!
    var emailUnsubscribeAll : Bool!
    var emailUpvoteComment : Bool!
    var emailUpvotePost : Bool!
    var emailUserNewFollower : Bool!
    var emailUsernameMention : Bool!
    var enableDefaultThemes : Bool!
    var enableFollowers : Bool!
    var feedRecommendationsEnabled : Bool!
    var geopopular : String!
    var hideAds : Bool!
    var hideDowns : Bool!
    var hideFromRobots : Bool!
    var hideUps : Bool!
    var highlightControversial : Bool!
    var highlightNewComments : Bool!
    var ignoreSuggestedSort : Bool!
    var labelNsfw : Bool!
    var lang : String!
    var layout : String!
    var legacySearch : Bool!
    var liveBarRecommendationsEnabled : Bool!
    var liveOrangereds : Bool!
    var markMessagesRead : Bool!
    var media : String!
    var mediaPreview : String!
    var minCommentScore : Int!
    var minLinkScore : Int!
    var monitorMentions : Bool!
    var newwindow : Bool!
    var nightmode : Bool!
    var noProfanity : Bool!
    var numComments : Int!
    var numsites : Int!
    var over18 : Bool!
    var privateFeeds : Bool!
    var profileOptOut : Bool!
    var publicServerSeconds : Bool!
    var publicVotes : Bool!
    var research : Bool!
    var searchIncludeOver18 : Bool!
    var sendCrosspostMessages : Bool!
    var sendWelcomeMessages : Bool!
    var showFlair : Bool!
    var showGoldExpiration : Bool!
    var showLinkFlair : Bool!
    var showLocationBasedRecommendations : Bool!
    var showPresence : Bool!
    var showSnoovatar : Bool!
    var showStylesheets : Bool!
    var showTrending : Bool!
    var showTwitter : Bool!
    var smsNotificationsEnabled : Bool!
    var storeVisits : Bool!
    var surveyLastSeenTime : Int!
    var thirdPartyDataPersonalizedAds : Bool!
    var thirdPartyPersonalizedAds : Bool!
    var thirdPartySiteDataPersonalizedAds : Bool!
    var thirdPartySiteDataPersonalizedContent : Bool!
    var threadedMessages : Bool!
    var threadedModmail : Bool!
    var topKarmaSubreddits : Bool!
    var useGlobalDefaults : Bool!
    var videoAutoplay : Bool!
    var whatsappCommentReply : Bool!
    var whatsappEnabled : Bool!

    init(fromJson json: JSON!) {
        if json.isEmpty {
            return
        }
        acceptPms = json["accept_pms"].stringValue
        activityRelevantAds = json["activity_relevant_ads"].boolValue
        allowClicktracking = json["allow_clicktracking"].boolValue
        badCommentAutocollapse = json["bad_comment_autocollapse"].stringValue
        beta = json["beta"].boolValue
        clickgadget = json["clickgadget"].boolValue
        collapseLeftBar = json["collapse_left_bar"].boolValue
        collapseReadMessages = json["collapse_read_messages"].boolValue
        compress = json["compress"].boolValue
        countryCode = json["country_code"].stringValue
        defaultCommentSort = json["default_comment_sort"].stringValue
        defaultThemeSr = json["default_theme_sr"].stringValue
        designBeta = json["design_beta"].boolValue
        domainDetails = json["domain_details"].boolValue
        emailChatRequest = json["email_chat_request"].boolValue
        emailCommentReply = json["email_comment_reply"].boolValue
        emailCommunityDiscovery = json["email_community_discovery"].boolValue
        emailDigests = json["email_digests"].boolValue
        emailMessages = json["email_messages"].boolValue
        emailNewUserWelcome = json["email_new_user_welcome"].boolValue
        emailPostReply = json["email_post_reply"].boolValue
        emailPrivateMessage = json["email_private_message"].boolValue
        emailUnsubscribeAll = json["email_unsubscribe_all"].boolValue
        emailUpvoteComment = json["email_upvote_comment"].boolValue
        emailUpvotePost = json["email_upvote_post"].boolValue
        emailUserNewFollower = json["email_user_new_follower"].boolValue
        emailUsernameMention = json["email_username_mention"].boolValue
        enableDefaultThemes = json["enable_default_themes"].boolValue
        enableFollowers = json["enable_followers"].boolValue
        feedRecommendationsEnabled = json["feed_recommendations_enabled"].boolValue
        geopopular = json["geopopular"].stringValue
        hideAds = json["hide_ads"].boolValue
        hideDowns = json["hide_downs"].boolValue
        hideFromRobots = json["hide_from_robots"].boolValue
        hideUps = json["hide_ups"].boolValue
        highlightControversial = json["highlight_controversial"].boolValue
        highlightNewComments = json["highlight_new_comments"].boolValue
        ignoreSuggestedSort = json["ignore_suggested_sort"].boolValue
        labelNsfw = json["label_nsfw"].boolValue
        lang = json["lang"].stringValue
        layout = json["layout"].stringValue
        legacySearch = json["legacy_search"].boolValue
        liveBarRecommendationsEnabled = json["live_bar_recommendations_enabled"].boolValue
        liveOrangereds = json["live_orangereds"].boolValue
        markMessagesRead = json["mark_messages_read"].boolValue
        media = json["media"].stringValue
        mediaPreview = json["media_preview"].stringValue
        minCommentScore = json["min_comment_score"].intValue
        minLinkScore = json["min_link_score"].intValue
        monitorMentions = json["monitor_mentions"].boolValue
        newwindow = json["newwindow"].boolValue
        nightmode = json["nightmode"].boolValue
        noProfanity = json["no_profanity"].boolValue
        numComments = json["num_comments"].intValue
        numsites = json["numsites"].intValue
        over18 = json["over_18"].boolValue
        privateFeeds = json["private_feeds"].boolValue
        profileOptOut = json["profile_opt_out"].boolValue
        publicServerSeconds = json["public_server_seconds"].boolValue
        publicVotes = json["public_votes"].boolValue
        research = json["research"].boolValue
        searchIncludeOver18 = json["search_include_over_18"].boolValue
        sendCrosspostMessages = json["send_crosspost_messages"].boolValue
        sendWelcomeMessages = json["send_welcome_messages"].boolValue
        showFlair = json["show_flair"].boolValue
        showGoldExpiration = json["show_gold_expiration"].boolValue
        showLinkFlair = json["show_link_flair"].boolValue
        showLocationBasedRecommendations = json["show_location_based_recommendations"].boolValue
        showPresence = json["show_presence"].boolValue
        showSnoovatar = json["show_snoovatar"].boolValue
        showStylesheets = json["show_stylesheets"].boolValue
        showTrending = json["show_trending"].boolValue
        showTwitter = json["show_twitter"].boolValue
        smsNotificationsEnabled = json["sms_notifications_enabled"].boolValue
        storeVisits = json["store_visits"].boolValue
        surveyLastSeenTime = json["survey_last_seen_time"].intValue
        thirdPartyDataPersonalizedAds = json["third_party_data_personalized_ads"].boolValue
        thirdPartyPersonalizedAds = json["third_party_personalized_ads"].boolValue
        thirdPartySiteDataPersonalizedAds = json["third_party_site_data_personalized_ads"].boolValue
        thirdPartySiteDataPersonalizedContent = json["third_party_site_data_personalized_content"].boolValue
        threadedMessages = json["threaded_messages"].boolValue
        threadedModmail = json["threaded_modmail"].boolValue
        topKarmaSubreddits = json["top_karma_subreddits"].boolValue
        useGlobalDefaults = json["use_global_defaults"].boolValue
        videoAutoplay = json["video_autoplay"].boolValue
        whatsappCommentReply = json["whatsapp_comment_reply"].boolValue
        whatsappEnabled = json["whatsapp_enabled"].boolValue
    }
}
