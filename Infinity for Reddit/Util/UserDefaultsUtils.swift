//
//  SharePreferencesUtils.swift
//  Infinity for Reddit
//
//  Created by Joe Deng on 2024-12-06.
//

struct UserDefaultsUtils {
    
    // NotificationView
    static let ENABLE_NOTIFICATION_KEY = "enable_notification"
    static let NOTIFICATION_INTERVAL_KEY = "notificaiton_interval"
    
    // SettingsView
    static let HIDE_FAB_IN_POST_FEED = "hide_fab_in_post_feed"
    static let BOTTOM_APP_BAR_KEY = "bottom_app_bar"
    static let HIDE_SUBREDDIT_DESCRIPTION = "hide_subreddit_description"
    static let USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER = "use_bottom_toolbar_in_media_viewer"
    static let VOTE_BUTTONS_ON_THE_RIGHT_KEY = "vote_buttons_on_the_right"
    static let SHOW_ABSOLUTE_NUMBER_OF_VOTES = "show_absolute_number_of_votes"
    static let DEFAULT_SEARCH_RESULT_TAB = "default_search_result_tab"
    
    // FontView
    static let FONT_FAMILY_KEY = "font_family"
    static let FONT_SIZE_KEY = "font_size"
    static let TITLE_FONT_FAMILY_KEY = "title_font_family"
    static let TITLE_FONT_SIZE_KEY = "title_font_size"
    static let CONTENT_FONT_FAMILY_KEY = "content_font_family"
    static let CONTENT_FONT_SIZE_KEY = "content_font_size"
    
    // ImmersiveInterfaceView
    static let IMMERSIVE_INTERFACE_KEY = "immersive_interface"
    static let IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY = "immersive_interface_ignore_nav_bar"
    
    // NavigationDrawerView
    static let SHOW_AVATAR_ON_RIGHT = "show_avatar_on_the_right"
    static let COLLAPSE_ACCOUNT_SECTION = "collapse_account_section"
    static let COLLAPSE_REDDIT_SECTION = "collapse_reddit_section"
    static let COLLAPSE_POST_SECTION = "collapse_post_section"
    static let COLLAPSE_PREFERENCES_SECTION = "collapse_preferences_section"
    static let COLLAPSE_FAVORITE_SUBREDDITS_SECTION = "collapse_favorite_subreddits_section"
    static let COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION = "collapse_subscribed_subreddits_section"
    static let HIDE_FAVORITE_SUBREDDITS_SECTION = "hide_favorite_subreddits_section"
    static let HIDE_SUBSCRIBED_SUBREDDITS_SECTION = "hide_subscribed_subreddits_section"
    static let HIDE_ACCOUNT_KARMA_NAV_BAR = "hide_account_karma"

    // TimeFormatView
    static let SHOW_ELAPSED_TIME_KEY = "show_elapsed_time"
    static let TIME_FORMAT_KEY = "time_format"
    
    // PostView
    static let DEFAULT_POST_LAYOUT_KEY = "default_post_layout"
    static let DEFAULT_LINK_POST_LAYOUT_KEY = "default_link_post_layout"
    static let HIDE_POST_TYPE = "hide_post_type"
    static let HIDE_POST_FLAIR = "hide_post_fair"
    static let HIDE_SUBREDDIT_AND_USER_PREFIX = "hide_subreddit_and_user_prefix"
    static let HIDE_THE_NUMBER_OF_VOTES = "hide_the_number_of_votes"
    static let HIDE_THE_NUMBER_OF_COMMENTS = "hide_the_number_of_comments"
    static let HIDE_TEXT_POST_CONTENT = "hide_text_post_content"
    static let FIXED_HEIGHT_PREVIEW_IN_CARD = "fixed_height_preview_in_card"
    static let SHOW_DIVIDER_IN_COMPACT_LAYOUT = "show_divider_in_compact_layout"
    static let SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT = "show_thumbnail_on_the_left_in_compact_layout"
    static let LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT = "long_press_to_hide_toolbar_in_compact_layout"
    static let POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT = "post_compact_layout_toolbar_hidden_by_default"
    static let CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT = "click_to_show_media_in_gallery_layout"
}
