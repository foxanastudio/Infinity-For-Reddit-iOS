//
//  CustomizeCustomThemeViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-29.
//

import Foundation
import GRDB

@MainActor
class CustomizeCustomThemeViewModel: ObservableObject {
    @Published var customTheme: CustomTheme
    @Published var error: Error?
    
    var customThemeFields: [String] = []
    var customThemeFieldsBoolType: Set<String> = []
    var customThemeSettingsItems: [String: CustomThemeSettingsItem] = [:]
    
    private let customThemeDao: CustomThemeDao
    
    init(customTheme: CustomTheme) {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
        self.customThemeDao = CustomThemeDao(dbPool: resolvedDatabasePool)
        
        self.customTheme = customTheme
        
        customTheme.getProperties(customThemeFields: &customThemeFields, customThemeFieldsBoolType: &customThemeFieldsBoolType)
        
        initializeCustomThemeSettingsItems(customThemeSettingsItems: &customThemeSettingsItems)
    }
    
    func saveCustomTheme() {
        Task {
            do {
                if customTheme.isLightTheme {
                    try await customThemeDao.unsetLightTheme()
                } else if customTheme.isDarkTheme {
                    try await customThemeDao.unsetDarkTheme()
                } else if customTheme.isAmoledTheme {
                    try await customThemeDao.unsetAmoledTheme()
                }
                
                try await customThemeDao.insert(customTheme: customTheme)
            } catch {
                print(error.localizedDescription)
                self.error = error
            }
        }
    }
    
    class CustomThemeSettingsItem {
        let title: String
        let description: String?
        
        init(title: String, description: String? = nil) {
            self.title = title
            self.description = description
        }
    }
    
    func initializeCustomThemeSettingsItems(customThemeSettingsItems: inout [String: CustomThemeSettingsItem]) {
        customThemeSettingsItems["isLightTheme"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_is_light_theme", comment: ""),
            description: ""
        )
        
        customThemeSettingsItems["isDarkTheme"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_is_dark_theme", comment: ""),
            description: ""
        )
        
        customThemeSettingsItems["isAmoledTheme"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_is_amoled_theme", comment: ""),
            description: ""
        )
        
        customThemeSettingsItems["colorPrimary"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_color_primary", comment: ""),
            description: NSLocalizedString("theme_item_color_primary_detail", comment: "")
        )
        
        customThemeSettingsItems["colorPrimaryDark"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_color_primary_dark", comment: ""),
            description: NSLocalizedString("theme_item_color_primary_dark_detail", comment: "")
        )
        
        customThemeSettingsItems["colorAccent"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_color_accent", comment: ""),
            description: NSLocalizedString("theme_item_color_accent_detail", comment: "")
        )
        
        customThemeSettingsItems["colorPrimaryLightTheme"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_color_primary_light_theme", comment: ""),
            description: NSLocalizedString("theme_item_color_primary_light_theme_detail", comment: "")
        )
        
        customThemeSettingsItems["primaryTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_primary_text_color", comment: ""),
            description: NSLocalizedString("theme_item_primary_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["secondaryTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_secondary_text_color", comment: ""),
            description: NSLocalizedString("theme_item_secondary_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["postTitleColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_post_title_color", comment: ""),
            description: NSLocalizedString("theme_item_post_title_color_detail", comment: "")
        )
        
        customThemeSettingsItems["postContentColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_post_content_color", comment: ""),
            description: NSLocalizedString("theme_item_post_content_color_detail", comment: "")
        )
        
        customThemeSettingsItems["readPostTitleColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_read_post_title_color", comment: ""),
            description: NSLocalizedString("theme_item_read_post_title_color_detail", comment: "")
        )
        
        customThemeSettingsItems["readPostContentColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_read_post_content_color", comment: ""),
            description: NSLocalizedString("theme_item_read_post_content_color_detail", comment: "")
        )
        
        customThemeSettingsItems["commentColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_color", comment: ""),
            description: NSLocalizedString("theme_item_comment_color_detail", comment: "")
        )
        
        customThemeSettingsItems["buttonTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_button_text_color", comment: ""),
            description: NSLocalizedString("theme_item_button_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["chipTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_chip_text_color", comment: ""),
            description: NSLocalizedString("theme_item_chip_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["linkColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_link_color", comment: ""),
            description: NSLocalizedString("theme_item_link_color_detail", comment: "")
        )
        
        customThemeSettingsItems["receivedMessageTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_received_message_text_color", comment: ""),
            description: NSLocalizedString("theme_item_received_message_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["sentMessageTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_sent_message_text_color", comment: ""),
            description: NSLocalizedString("theme_item_sent_message_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["backgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_background_color", comment: ""),
            description: NSLocalizedString("theme_item_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["cardViewBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_card_view_background_color", comment: ""),
            description: NSLocalizedString("theme_item_card_view_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["readPostCardViewBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_read_post_card_view_background_color", comment: ""),
            description: NSLocalizedString("theme_item_read_post_card_view_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["filledCardViewBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_filled_card_view_background_color", comment: ""),
            description: NSLocalizedString("theme_item_filled_card_view_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["readPostFilledCardViewBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_read_post_filled_card_view_background_color", comment: ""),
            description: NSLocalizedString("theme_item_read_post_filled_card_view_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["commentBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_background_color", comment: ""),
            description: NSLocalizedString("theme_item_comment_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["fullyCollapsedCommentBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_fully_collapsed_comment_background_color", comment: ""),
            description: NSLocalizedString("theme_item_fully_collapsed_comment_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["awardedCommentBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_awarded_comment_background_color", comment: ""),
            description: NSLocalizedString("theme_item_awarded_comment_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["receivedMessageBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_received_message_background_color", comment: ""),
            description: NSLocalizedString("theme_item_received_message_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["sentMessageBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_sent_message_background_color", comment: ""),
            description: NSLocalizedString("theme_item_sent_message_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["bottomAppBarBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_bottom_app_bar_background_color", comment: ""),
            description: NSLocalizedString("theme_item_bottom_app_bar_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["primaryIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_primary_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_primary_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["bottomAppBarIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_bottom_app_bar_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_bottom_app_bar_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["postIconAndInfoColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_post_icon_and_info_color", comment: ""),
            description: NSLocalizedString("theme_item_post_icon_and_info_color_detail", comment: "")
        )
        
        customThemeSettingsItems["commentIconAndInfoColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_icon_and_info_color", comment: ""),
            description: NSLocalizedString("theme_item_comment_icon_and_info_color_detail", comment: "")
        )
        
        customThemeSettingsItems["fabIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_fab_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_fab_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["sendMessageIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_send_message_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_send_message_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["toolbarPrimaryTextAndIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_toolbar_primary_text_and_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_toolbar_primary_text_and_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["toolbarSecondaryTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_toolbar_secondary_text_color", comment: ""),
            description: NSLocalizedString("theme_item_toolbar_secondary_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["circularProgressBarBackground"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_circular_progress_bar_background_color", comment: ""),
            description: NSLocalizedString("theme_item_circular_progress_bar_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["mediaIndicatorIconColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_media_indicator_icon_color", comment: ""),
            description: NSLocalizedString("theme_item_media_indicator_icon_color_detail", comment: "")
        )
        
        customThemeSettingsItems["mediaIndicatorBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_media_indicator_background_color", comment: ""),
            description: NSLocalizedString("theme_item_media_indicator_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithExpandedCollapsingToolbarTabBackground"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_tab_background", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_tab_background_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithExpandedCollapsingToolbarTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_text_color", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithExpandedCollapsingToolbarTabIndicator"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_tab_indicator", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_expanded_collapsing_toolbar_tab_indicator_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithCollapsedCollapsingToolbarTabBackground"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_tab_background", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_tab_background_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithCollapsedCollapsingToolbarTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_text_color", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["tabLayoutWithCollapsedCollapsingToolbarTabIndicator"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_tab_indicator", comment: ""),
            description: NSLocalizedString("theme_item_tab_layout_with_collapsed_collapsing_toolbar_tab_indicator_detail", comment: "")
        )
        
        customThemeSettingsItems["upvoted"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_upvoted_color", comment: ""),
            description: NSLocalizedString("theme_item_upvoted_color_detail", comment: "")
        )
        
        customThemeSettingsItems["downvoted"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_downvoted_color", comment: ""),
            description: NSLocalizedString("theme_item_downvoted_color_detail", comment: "")
        )
        
        customThemeSettingsItems["postTypeBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_post_type_background_color", comment: ""),
            description: NSLocalizedString("theme_item_post_type_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["postTypeTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_post_type_text_color", comment: ""),
            description: NSLocalizedString("theme_item_post_type_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["spoilerBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_spoiler_background_color", comment: ""),
            description: NSLocalizedString("theme_item_spoiler_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["spoilerTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_spoiler_text_color", comment: ""),
            description: NSLocalizedString("theme_item_spoiler_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["nsfwBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_nsfw_background_color", comment: ""),
            description: NSLocalizedString("theme_item_nsfw_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["nsfwTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_nsfw_text_color", comment: ""),
            description: NSLocalizedString("theme_item_nsfw_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["flairBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_flair_background_color", comment: ""),
            description: NSLocalizedString("theme_item_flair_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["flairTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_flair_text_color", comment: ""),
            description: NSLocalizedString("theme_item_flair_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["awardsBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_awards_background_color", comment: ""),
            description: NSLocalizedString("theme_item_awards_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["awardsTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_awards_text_color", comment: ""),
            description: NSLocalizedString("theme_item_awards_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["archivedTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_archived_tint", comment: ""),
            description: NSLocalizedString("theme_item_archived_tint_detail", comment: "")
        )
        
        
        customThemeSettingsItems["lockedIconTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_locked_icon_tint", comment: ""),
            description: NSLocalizedString("theme_item_locked_icon_tint_detail", comment: "")
        )
        
        customThemeSettingsItems["crosspostIconTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_crosspost_icon_tint", comment: ""),
            description: NSLocalizedString("theme_item_crosspost_icon_tint_detail", comment: "")
        )
        
        customThemeSettingsItems["upvoteRatioIconTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_upvote_ratio_icon_tint", comment: ""),
            description: NSLocalizedString("theme_item_upvote_ratio_icon_tint_detail", comment: "")
        )
        
        customThemeSettingsItems["stickiedPostIconTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_stickied_post_icon_tint", comment: ""),
            description: NSLocalizedString("theme_item_stickied_post_icon_tint_detail", comment: "")
        )
        
        customThemeSettingsItems["noPreviewPostTypeIconTint"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_no_preview_post_type_icon_tint", comment: ""),
            description: NSLocalizedString("theme_item_no_preview_post_type_icon_tint_detail", comment: "")
        )
        
        customThemeSettingsItems["subscribed"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_subscribed_color", comment: ""),
            description: NSLocalizedString("theme_item_subscribed_color_detail", comment: "")
        )
        
        customThemeSettingsItems["unsubscribed"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_unsubscribed_color", comment: ""),
            description: NSLocalizedString("theme_item_unsubscribed_color_detail", comment: "")
        )
        
        customThemeSettingsItems["username"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_username_color", comment: ""),
            description: NSLocalizedString("theme_item_username_color_detail", comment: "")
        )
        
        customThemeSettingsItems["subreddit"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_subreddit_color", comment: ""),
            description: NSLocalizedString("theme_item_subreddit_color_detail", comment: "")
        )
        
        customThemeSettingsItems["authorFlairTextColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_author_flair_text_color", comment: ""),
            description: NSLocalizedString("theme_item_author_flair_text_color_detail", comment: "")
        )
        
        customThemeSettingsItems["submitter"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_submitter_color", comment: ""),
            description: NSLocalizedString("theme_item_submitter_color_detail", comment: "")
        )
        
        customThemeSettingsItems["moderator"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_moderator_color", comment: ""),
            description: NSLocalizedString("theme_item_moderator_color_detail", comment: "")
        )
        
        customThemeSettingsItems["currentUser"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_current_user_color", comment: ""),
            description: NSLocalizedString("theme_item_current_user_color_detail", comment: "")
        )
        
        customThemeSettingsItems["singleCommentThreadBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_single_comment_thread_background_color", comment: ""),
            description: NSLocalizedString("theme_item_single_comment_thread_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["unreadMessageBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_unread_message_background_color", comment: ""),
            description: NSLocalizedString("theme_item_unread_message_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["dividerColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_divider_color", comment: ""),
            description: NSLocalizedString("theme_item_divider_color_detail", comment: "")
        )
        
        customThemeSettingsItems["noPreviewPostTypeBackgroundColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_no_preview_post_type_background_color", comment: ""),
            description: NSLocalizedString("theme_item_no_preview_post_type_background_color_detail", comment: "")
        )
        
        customThemeSettingsItems["voteAndReplyUnavailableButtonColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_vote_and_reply_unavailable_button_color", comment: ""),
            description: NSLocalizedString("theme_item_vote_and_reply_unavailable_button_color_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor1"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_1", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_1_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor2"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_2", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_2_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor3"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_3", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_3_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor4"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_4", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_4_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor5"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_5", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_5_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor6"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_6", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_6_detail", comment: "")
        )
        
        customThemeSettingsItems["commentVerticalBarColor7"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_comment_vertical_bar_color_7", comment: ""),
            description: NSLocalizedString("theme_item_comment_vertical_bar_color_7_detail", comment: "")
        )
        
        customThemeSettingsItems["navBarColor"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_nav_bar_color", comment: ""),
            description: NSLocalizedString("theme_item_nav_bar_color_detail", comment: "")
        )
        
        customThemeSettingsItems["isLightStatusBar"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_light_status_bar", comment: "")
        )
        
        customThemeSettingsItems["isLightNavBar"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_light_nav_bar", comment: "")
        )
        
        customThemeSettingsItems["isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface"] = CustomThemeSettingsItem(
            title: NSLocalizedString("theme_item_change_status_bar_icon_color_after_toolbar_collapsed_in_immersive_interface", comment: "")
        )
    }
    
}
