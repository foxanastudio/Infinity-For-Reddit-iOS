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
            try db.execute(sql: "PRAGMA foreign_keys = ON")
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
                t.column("custom_feed_sync_time", .integer)
                t.column("created_utc", .double)
            }
            
            try Account.ANONYMOUS_ACCOUNT.insert(db, onConflict: .ignore)
            
            try db.create(table: PostFilter.databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("max_vote", .integer)
                t.column("min_vote", .integer)
                t.column("max_comments", .integer)
                t.column("min_comments", .integer)
                t.column("max_awards", .integer)
                t.column("min_awards", .integer)
                t.column("only_sensitive", .boolean)
                t.column("only_spoiler", .boolean)
                t.column("post_title_excludes_regex", .text)
                t.column("post_title_contains_regex", .text)
                t.column("post_title_excludes_strings", .text)
                t.column("post_title_contains_strings", .text)
                t.column("exclude_subreddits", .text)
                t.column("exclude_users", .text)
                t.column("contain_flairs", .text)
                t.column("exclude_flairs", .text)
                t.column("exclude_domains", .text)
                t.column("contain_domains", .text)
                t.column("contain_text_type", .boolean)
                t.column("contain_link_type", .boolean)
                t.column("contain_image_type", .boolean)
                t.column("contain_gif_type", .boolean)
                t.column("contain_video_type", .boolean)
                t.column("contain_gallery_type", .boolean)
            }
            
            try db.create(table: PostFilterUsage.databaseTableName, ifNotExists: true) { t in
                t.column("post_filter_id", .integer)
                    .notNull()
                    .indexed()
                    .references(PostFilter.databaseTableName, column: "id", onDelete: .cascade, onUpdate: .cascade)
                t.column("usage_type", .integer)
                t.column("name_of_usage", .text)
                t.primaryKey(["post_filter_id", "usage_type", "name_of_usage"])
            }
            
            try db.create(table: CommentFilter.databaseTableName, ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("name", .text)
                t.column("display_mode", .integer)
                t.column("max_vote", .integer)
                t.column("min_vote", .integer)
                t.column("exclude_strings", .text)
                t.column("exclude_users", .text)
            }
            
            try db.create(table: CommentFilterUsage.databaseTableName, ifNotExists: true) { t in
                t.column("comment_filter_id", .integer)
                    .notNull()
                    .indexed()
                    .references(CommentFilter.databaseTableName, column: "id", onDelete: .cascade, onUpdate: .cascade)
                t.column("usage_type", .integer)
                t.column("name_of_usage", .text)
                t.primaryKey(["comment_filter_id", "usage_type", "name_of_usage"])
            }
            
            try db.create(table: SubscribedSubredditData.databaseTableName, ifNotExists: true) { t in
                t.column("full_name", .text).notNull()
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("is_favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["full_name", "name"])
            }
            
            try db.create(table: SubscribedUserData.databaseTableName, ifNotExists: true) { t in
                t.column("name", .text).notNull()
                t.column("icon_url", .text)
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("is_favorite", .boolean).notNull().defaults(to: false)
                t.primaryKey(["name", "username"])
            }
            
            try db.create(table: UserData.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).notNull()
                t.column("name", .text)
                t.column("icon_url", .text)
                t.column("banner_url", .text)
                t.column("comment_karma", .integer)
                t.column("link_karma", .integer)
                t.column("awarder_karma", .integer)
                t.column("awardee_karma", .integer)
                t.column("total_karma", .integer)
                t.column("cakeday", .integer)
                t.column("is_gold", .boolean)
                t.column("can_follow", .boolean)
                t.column("is_nsfw", .boolean)
                t.column("description", .text)
                t.column("title", .text)
                t.column("is_selected", .boolean)
                t.primaryKey(["id"])
            }
            
            try db.create(table: SubredditData.databaseTableName, ifNotExists: true) { t in
                t.column("id", .text).notNull()
                t.column("name", .text)
                t.column("full_name", .text)
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
                
                // Integer color properties
                let colorColumns = [
                    "colorPrimary", "colorAccent", "colorPrimaryLightTheme",
                    "primaryTextColor", "secondaryTextColor", "postTitleColor", "postContentColor",
                    "readPostTitleColor", "readPostContentColor", "commentColor", "buttonTextColor", "switchColor",
                    "backgroundColor", "cardViewBackgroundColor", "readPostCardViewBackgroundColor",
                    "filledCardViewBackgroundColor", "readPostFilledCardViewBackgroundColor",
                    "commentBackgroundColor", "tabBarBackgroundColor", "snackbarTextColor",
                    "snackbarActionTextColor", "snackbarBackgroundColor", "primaryIconColor",
                    "tabBarTextAndIconColor", "postIconAndInfoColor", "commentIconAndInfoColor",
                    "toolbarPrimaryTextAndIconColor", "mediaIndicatorIconColor", "mediaIndicatorBackgroundColor",
                    "pickerItemTextColor", "pickerSelectedItemTextColor", "pickerSelectedItemBackgroundColor",
                    "upvoted", "downvoted", "postTypeBackgroundColor", "postTypeTextColor",
                    "spoilerBackgroundColor", "spoilerTextColor", "nsfwBackgroundColor", "nsfwTextColor",
                    "flairBackgroundColor", "flairTextColor",
                    "archivedTint", "lockedIconTint", "crosspostIconTint", "upvoteRatioIconTint",
                    "stickiedPostIconTint", "noPreviewPostTypeIconTint", "subscribed", "unsubscribed",
                    "subreddit", "authorFlairTextColor", "submitter", "moderator", "currentUser",
                    "singleCommentThreadBackgroundColor", "unreadMessageBackgroundColor", "dividerColor",
                    "noPreviewPostTypeBackgroundColor", "voteAndReplyUnavailableButtonColor",
                    "commentVerticalBarColor1", "commentVerticalBarColor2", "commentVerticalBarColor3",
                    "commentVerticalBarColor4", "commentVerticalBarColor5", "commentVerticalBarColor6",
                    "commentVerticalBarColor7", "fabIconColor", "linkColor",
                    "receivedMessageTextColor", "sentMessageTextColor", "receivedMessageBackgroundColor",
                    "sentMessageBackgroundColor", "sendMessageIconColor", "fullyCollapsedCommentBackgroundColor"
                ]
                colorColumns.forEach { columnName in
                    t.column(columnName, .integer).notNull()
                }
            }
            
            try db.create(table: RecentSearchQuery.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text)
                    .notNull()
                    .references(Account.databaseTableName, onDelete: .cascade)
                t.column("search_query", .text).notNull()
                t.column("search_in_subreddit_or_user_name", .text)
                t.column("search_in_multireddit_path", .text)
                t.column("search_in_multireddit_display_name", .text)
                t.column("search_in_thing_type", .integer).notNull()
                t.column("time", .integer).notNull()
                t.primaryKey(["username", "search_query"])
            }
            
            try db.create(table: PostHistory.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text).notNull()
                    .references(Account.databaseTableName, column: "username", onDelete: .cascade)
                t.column("post_id", .text).notNull()
                t.column("post_history_type", .integer).notNull()
                t.column("time", .integer).notNull()

                t.primaryKey(["username", "post_id", "post_history_type"], onConflict: .replace)
            }
            
            try db.create(table: AnonymousCustomFeedSubreddit.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text).notNull()
                    .references(Account.databaseTableName, column: "username", onDelete: .cascade)
                t.column("path", .text).notNull()
                t.column("subreddit_name", .text).notNull()
                t.column("icon_url_string", .text).notNull()

                t.primaryKey(["username", "path", "subreddit_name", "icon_url_string"], onConflict: .replace)
                t.foreignKey(["path", "username"], references: MyCustomFeed.databaseTableName, columns: ["path", "username"], onDelete: .cascade, onUpdate: .cascade)
            }
            
            try db.create(table: PartialUserData.databaseTableName, ifNotExists: true) { t in
                t.column("username", .text).notNull()
                t.column("profile_image_url", .text)
                t.column("link_karma", .integer)
                t.column("comment_karma", .integer)
                t.column("created_utc", .integer)
                t.column("over_18", .boolean)
                t.column("profile_color", .text)
                t.primaryKey(["username"])
            }
        }
    }
}
