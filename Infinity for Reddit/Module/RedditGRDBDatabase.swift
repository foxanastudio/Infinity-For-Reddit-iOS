//
//  RedditGRDBDatabase.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-11-30.
//

import Foundation
import GRDB

struct RedditGRDBDatabase {
    public static func create() throws -> DatabasePool {
        let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("reddit_data.sqlite")
            .path
        
        var config = Configuration()
        config.prepareDatabase { db in
            try db.execute(sql: "PRAGMA journal_mode = WAL")
        }
        
        let dbPool = try DatabasePool(path: path, configuration: config)
        try setupDatabaseScheme(dbPool)
        try setupMigrations(dbPool)
        return dbPool
    }
    
    private static func setupMigrations(_ dbPool: DatabasePool) throws {
        // TODO for future database scheme migration
    }
    
    private static func setupDatabaseScheme(_ dbPool: DatabasePool) throws {
        try dbPool.write { db in
            try db.create(table: Account.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text).primaryKey()
                t.column("profile_image_url", .text)
                t.column("banner_image_url", .text)
                t.column("karma", .integer)
                t.column("is_mod", .boolean)
                t.column("access_token", .text)
                t.column("refresh_token", .text)
                t.column("is_current_user", .boolean)
                t.column("code", .text)
                t.column("subscription_sync_time", .integer)
                t.column("created_utc", .double)
            }
            
            try db.create(table: PostFilter.databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("maxVote", .integer)
                t.column("minVote", .integer)
                t.column("maxComments", .integer)
                t.column("minComments", .integer)
                t.column("maxAwards", .integer)
                t.column("minAwards", .integer)
                t.column("allowNSFW", .boolean)
                t.column("onlyNSFW", .boolean)
                t.column("onlySpoiler", .boolean)
                t.column("postTitleExcludesRegex", .text)
                t.column("postTitleContainsRegex", .text)
                t.column("postTitleExcludesStrings", .text)
                t.column("postTitleContainsStrings", .text)
                t.column("excludeSubreddits", .text)
                t.column("excludeUsers", .text)
                t.column("containFlairs", .text)
                t.column("excludeFlairs", .text)
                t.column("excludeDomains", .text)
                t.column("containDomains", .text)
                t.column("containTextType", .boolean)
                t.column("containLinkType", .boolean)
                t.column("containImageType", .boolean)
                t.column("containGifType", .boolean)
                t.column("containVideoType", .boolean)
                t.column("containGalleryType", .boolean)
            }
            
            try db.create(table: SubscribedSubredditData.databaseTableName, ifNotExists: true) { t in
                t.column("full_name", .text).notNull()
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["full_name", "name"])
            }
            
            try db.create(table: SubscribedUserData.databaseTableName, ifNotExists: true) { t in
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["name", "username"])
            }
            
            try db.create(table: UserData.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).notNull()
                t.column("name", .text)
                t.column("icon_url", .text)
                t.column("banner_url", .text)
                t.column("comment_karma", .text)
                t.column("link_karma", .integer)
                t.column("awarder_karma", .integer)
                t.column("awardee_karma", .integer)
                t.column("total_karma", .integer)
                t.column("cakeday", .integer)
                t.column("is_gold", .boolean).notNull().defaults(to: false)
                t.column("is_subscribed", .boolean).notNull().defaults(to: false)
                t.column("can_follow", .boolean).notNull().defaults(to: false)
                t.column("is_nsfw", .boolean).notNull().defaults(to: false)
                t.column("description", .text)
                t.column("title", .text)
                t.column("is_selected", .boolean).notNull().defaults(to: false)
                t.primaryKey(["id"])
            }
            
            try db.create(table: SubredditData.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).notNull()
                t.column("name", .text)
                t.column("icon_url", .text)
                t.column("banner_url", .text)
                t.column("description", .text)
                t.column("sidebar_description", .text)
                t.column("n_subscribers", .integer).notNull()
                t.column("created_utc", .integer).notNull()
                t.column("suggested_comment_sort", .text)
                t.column("active_users", .integer).notNull().defaults(to: 0)
                t.column("is_nsfw", .boolean).notNull().defaults(to: false)
                t.column("is_selected", .boolean).notNull().defaults(to: false)
                t.primaryKey(["id"])
            }
            
            try db.create(table: MyCustomFeed.databaseTableName, ifNotExists: true) { t in
                t.column("path", .text).notNull()
                t.column("display_name", .text).notNull()
                t.column("name", .text).notNull()
                t.column("description", .text)
                t.column("copied_from", .text)
                t.column("icon_url", .text)
                t.column("visibility", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("n_subscribers", .integer).notNull()
                t.column("created_utc", .integer).notNull()
                t.column("over18", .boolean).notNull().defaults(to: false)
                t.column("is_subscriber", .boolean).notNull().defaults(to: false)
                t.column("is_favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["path", "username"])
            }
            
            try db.create(table: CustomTheme.databaseTableName, ifNotExists: true) { t in
                // Primary key
                t.column("id", .integer).primaryKey(autoincrement: true)
                
                // String properties
                t.column("name", .text).notNull()
                t.column("username", .text).notNull()
                
                // Boolean properties
                t.column("isLightTheme", .boolean).notNull()
                t.column("isDarkTheme", .boolean).notNull()
                t.column("isAmoledTheme", .boolean).notNull()
                t.column("isLightStatusBar", .boolean).notNull()
                t.column("isLightNavBar", .boolean).notNull()
                t.column("isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface", .boolean).notNull()
                
                // Integer color properties
                let colorColumns = [
                    "colorPrimary", "colorPrimaryDark", "colorAccent", "colorPrimaryLightTheme",
                    "primaryTextColor", "secondaryTextColor", "postTitleColor", "postContentColor",
                    "readPostTitleColor", "readPostContentColor", "commentColor", "buttonTextColor",
                    "backgroundColor", "cardViewBackgroundColor", "readPostCardViewBackgroundColor",
                    "filledCardViewBackgroundColor", "readPostFilledCardViewBackgroundColor",
                    "commentBackgroundColor", "bottomAppBarBackgroundColor", "primaryIconColor",
                    "bottomAppBarIconColor", "postIconAndInfoColor", "commentIconAndInfoColor",
                    "toolbarPrimaryTextAndIconColor", "toolbarSecondaryTextColor",
                    "circularProgressBarBackground", "mediaIndicatorIconColor", "mediaIndicatorBackgroundColor",
                    "tabLayoutWithExpandedCollapsingToolbarTabBackground", "tabLayoutWithExpandedCollapsingToolbarTextColor",
                    "tabLayoutWithExpandedCollapsingToolbarTabIndicator", "tabLayoutWithCollapsedCollapsingToolbarTabBackground",
                    "tabLayoutWithCollapsedCollapsingToolbarTextColor", "tabLayoutWithCollapsedCollapsingToolbarTabIndicator",
                    "navBarColor", "upvoted", "downvoted", "postTypeBackgroundColor", "postTypeTextColor",
                    "spoilerBackgroundColor", "spoilerTextColor", "nsfwBackgroundColor", "nsfwTextColor",
                    "flairBackgroundColor", "flairTextColor", "awardsBackgroundColor", "awardsTextColor",
                    "archivedTint", "lockedIconTint", "crosspostIconTint", "upvoteRatioIconTint",
                    "stickiedPostIconTint", "noPreviewPostTypeIconTint", "subscribed", "unsubscribed",
                    "subreddit", "authorFlairTextColor", "submitter", "moderator", "currentUser",
                    "singleCommentThreadBackgroundColor", "unreadMessageBackgroundColor", "dividerColor",
                    "noPreviewPostTypeBackgroundColor", "voteAndReplyUnavailableButtonColor",
                    "commentVerticalBarColor1", "commentVerticalBarColor2", "commentVerticalBarColor3",
                    "commentVerticalBarColor4", "commentVerticalBarColor5", "commentVerticalBarColor6",
                    "commentVerticalBarColor7", "fabIconColor", "chipTextColor", "linkColor",
                    "receivedMessageTextColor", "sentMessageTextColor", "receivedMessageBackgroundColor",
                    "sentMessageBackgroundColor", "sendMessageIconColor", "fullyCollapsedCommentBackgroundColor",
                    "awardedCommentBackgroundColor"
                ]
                colorColumns.forEach { columnName in
                    t.column(columnName, .integer).notNull()
                }
            }
        }
    }
}
