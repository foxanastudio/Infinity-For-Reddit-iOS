//
//  CustomTheme.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-10.
//

import GRDB
import Foundation

class CustomTheme: NSObject, Codable, FetchableRecord, PersistableRecord {
    var id: Int?
    @objc var name: String
    @objc var isLightTheme: Bool
    @objc var isDarkTheme: Bool
    @objc var isAmoledTheme: Bool
    @objc var colorPrimary: Int
    @objc var colorPrimaryDark: Int
    @objc var colorAccent: Int
    @objc var colorPrimaryLightTheme: Int
    @objc var primaryTextColor: Int
    @objc var secondaryTextColor: Int
    @objc var postTitleColor: Int
    @objc var postContentColor: Int
    @objc var readPostTitleColor: Int
    @objc var readPostContentColor: Int
    @objc var commentColor: Int
    @objc var buttonTextColor: Int
    @objc var backgroundColor: Int
    @objc var cardViewBackgroundColor: Int
    @objc var readPostCardViewBackgroundColor: Int
    @objc var filledCardViewBackgroundColor: Int
    @objc var readPostFilledCardViewBackgroundColor: Int
    @objc var commentBackgroundColor: Int
    @objc var bottomAppBarBackgroundColor: Int
    @objc var primaryIconColor: Int
    @objc var bottomAppBarIconColor: Int
    @objc var postIconAndInfoColor: Int
    @objc var commentIconAndInfoColor: Int
    @objc var toolbarPrimaryTextAndIconColor: Int
    @objc var toolbarSecondaryTextColor: Int
    @objc var circularProgressBarBackground: Int
    @objc var mediaIndicatorIconColor: Int
    @objc var mediaIndicatorBackgroundColor: Int
    @objc var tabLayoutWithExpandedCollapsingToolbarTabBackground: Int
    @objc var tabLayoutWithExpandedCollapsingToolbarTextColor: Int
    @objc var tabLayoutWithExpandedCollapsingToolbarTabIndicator: Int
    @objc var tabLayoutWithCollapsedCollapsingToolbarTabBackground: Int
    @objc var tabLayoutWithCollapsedCollapsingToolbarTextColor: Int
    @objc var tabLayoutWithCollapsedCollapsingToolbarTabIndicator: Int
    @objc var upvoted: Int
    @objc var downvoted: Int
    @objc var postTypeBackgroundColor: Int
    @objc var postTypeTextColor: Int
    @objc var spoilerBackgroundColor: Int
    @objc var spoilerTextColor: Int
    @objc var nsfwBackgroundColor: Int
    @objc var nsfwTextColor: Int
    @objc var flairBackgroundColor: Int
    @objc var flairTextColor: Int
    @objc var awardsBackgroundColor: Int
    @objc var awardsTextColor: Int
    @objc var archivedTint: Int
    @objc var lockedIconTint: Int
    @objc var crosspostIconTint: Int
    @objc var upvoteRatioIconTint: Int
    @objc var stickiedPostIconTint: Int
    @objc var noPreviewPostTypeIconTint: Int
    @objc var subscribed: Int
    @objc var unsubscribed: Int
    @objc var username: Int
    @objc var subreddit: Int
    @objc var authorFlairTextColor: Int
    @objc var submitter: Int
    @objc var moderator: Int
    @objc var currentUser: Int
    @objc var singleCommentThreadBackgroundColor: Int
    @objc var unreadMessageBackgroundColor: Int
    @objc var dividerColor: Int
    @objc var noPreviewPostTypeBackgroundColor: Int
    @objc var voteAndReplyUnavailableButtonColor: Int
    @objc var commentVerticalBarColor1: Int
    @objc var commentVerticalBarColor2: Int
    @objc var commentVerticalBarColor3: Int
    @objc var commentVerticalBarColor4: Int
    @objc var commentVerticalBarColor5: Int
    @objc var commentVerticalBarColor6: Int
    @objc var commentVerticalBarColor7: Int
    @objc var fabIconColor: Int
    @objc var chipTextColor: Int
    @objc var linkColor: Int
    @objc var receivedMessageTextColor: Int
    @objc var sentMessageTextColor: Int
    @objc var receivedMessageBackgroundColor: Int
    @objc var sentMessageBackgroundColor: Int
    @objc var sendMessageIconColor: Int
    @objc var fullyCollapsedCommentBackgroundColor: Int
    @objc var awardedCommentBackgroundColor: Int
    @objc var navBarColor: Int
    @objc var isLightStatusBar: Bool
    @objc var isLightNavBar: Bool
    @objc var isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: Bool
    
    
    static var databaseTableName: String {
        return "custom_theme"
    }
    
    init(
        name: String,
        isLightTheme: Bool,
        isDarkTheme: Bool,
        isAmoledTheme: Bool,
        colorPrimary: Int,
        colorPrimaryDark: Int,
        colorAccent: Int,
        colorPrimaryLightTheme: Int,
        primaryTextColor: Int,
        secondaryTextColor: Int,
        postTitleColor: Int,
        postContentColor: Int,
        readPostTitleColor: Int,
        readPostContentColor: Int,
        commentColor: Int,
        buttonTextColor: Int,
        backgroundColor: Int,
        cardViewBackgroundColor: Int,
        readPostCardViewBackgroundColor: Int,
        filledCardViewBackgroundColor: Int,
        readPostFilledCardViewBackgroundColor: Int,
        commentBackgroundColor: Int,
        bottomAppBarBackgroundColor: Int,
        primaryIconColor: Int,
        bottomAppBarIconColor: Int,
        postIconAndInfoColor: Int,
        commentIconAndInfoColor: Int,
        toolbarPrimaryTextAndIconColor: Int,
        toolbarSecondaryTextColor: Int,
        circularProgressBarBackground: Int,
        mediaIndicatorIconColor: Int,
        mediaIndicatorBackgroundColor: Int,
        tabLayoutWithExpandedCollapsingToolbarTabBackground: Int,
        tabLayoutWithExpandedCollapsingToolbarTextColor: Int,
        tabLayoutWithExpandedCollapsingToolbarTabIndicator: Int,
        tabLayoutWithCollapsedCollapsingToolbarTabBackground: Int,
        tabLayoutWithCollapsedCollapsingToolbarTextColor: Int,
        tabLayoutWithCollapsedCollapsingToolbarTabIndicator: Int,
        upvoted: Int,
        downvoted: Int,
        postTypeBackgroundColor: Int,
        postTypeTextColor: Int,
        spoilerBackgroundColor: Int,
        spoilerTextColor: Int,
        nsfwBackgroundColor: Int,
        nsfwTextColor: Int,
        flairBackgroundColor: Int,
        flairTextColor: Int,
        awardsBackgroundColor: Int,
        awardsTextColor: Int,
        archivedTint: Int,
        lockedIconTint: Int,
        crosspostIconTint: Int,
        upvoteRatioIconTint: Int,
        stickiedPostIconTint: Int,
        noPreviewPostTypeIconTint: Int,
        subscribed: Int,
        unsubscribed: Int,
        username: Int,
        subreddit: Int,
        authorFlairTextColor: Int,
        submitter: Int,
        moderator: Int,
        currentUser: Int,
        singleCommentThreadBackgroundColor: Int,
        unreadMessageBackgroundColor: Int,
        dividerColor: Int,
        noPreviewPostTypeBackgroundColor: Int,
        voteAndReplyUnavailableButtonColor: Int,
        commentVerticalBarColor1: Int,
        commentVerticalBarColor2: Int,
        commentVerticalBarColor3: Int,
        commentVerticalBarColor4: Int,
        commentVerticalBarColor5: Int,
        commentVerticalBarColor6: Int,
        commentVerticalBarColor7: Int,
        fabIconColor: Int,
        chipTextColor: Int,
        linkColor: Int,
        receivedMessageTextColor: Int,
        sentMessageTextColor: Int,
        receivedMessageBackgroundColor: Int,
        sentMessageBackgroundColor: Int,
        sendMessageIconColor: Int,
        fullyCollapsedCommentBackgroundColor: Int,
        awardedCommentBackgroundColor: Int,
        navBarColor: Int,
        isLightStatusBar: Bool,
        isLightNavBar: Bool,
        isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: Bool
    ) {
        self.name = name
        self.username = username
        self.isLightTheme = isLightTheme
        self.isDarkTheme = isDarkTheme
        self.isAmoledTheme = isAmoledTheme
        self.colorPrimary = colorPrimary
        self.colorPrimaryDark = colorPrimaryDark
        self.colorAccent = colorAccent
        self.colorPrimaryLightTheme = colorPrimaryLightTheme
        self.primaryTextColor = primaryTextColor
        self.secondaryTextColor = secondaryTextColor
        self.postTitleColor = postTitleColor
        self.postContentColor = postContentColor
        self.readPostTitleColor = readPostTitleColor
        self.readPostContentColor = readPostContentColor
        self.commentColor = commentColor
        self.buttonTextColor = buttonTextColor
        self.backgroundColor = backgroundColor
        self.cardViewBackgroundColor = cardViewBackgroundColor
        self.readPostCardViewBackgroundColor = readPostCardViewBackgroundColor
        self.filledCardViewBackgroundColor = filledCardViewBackgroundColor
        self.readPostFilledCardViewBackgroundColor = readPostFilledCardViewBackgroundColor
        self.commentBackgroundColor = commentBackgroundColor
        self.bottomAppBarBackgroundColor = bottomAppBarBackgroundColor
        self.primaryIconColor = primaryIconColor
        self.bottomAppBarIconColor = bottomAppBarIconColor
        self.postIconAndInfoColor = postIconAndInfoColor
        self.commentIconAndInfoColor = commentIconAndInfoColor
        self.toolbarPrimaryTextAndIconColor = toolbarPrimaryTextAndIconColor
        self.toolbarSecondaryTextColor = toolbarSecondaryTextColor
        self.circularProgressBarBackground = circularProgressBarBackground
        self.mediaIndicatorIconColor = mediaIndicatorIconColor
        self.mediaIndicatorBackgroundColor = mediaIndicatorBackgroundColor
        self.tabLayoutWithExpandedCollapsingToolbarTabBackground = tabLayoutWithExpandedCollapsingToolbarTabBackground
        self.tabLayoutWithExpandedCollapsingToolbarTextColor = tabLayoutWithExpandedCollapsingToolbarTextColor
        self.tabLayoutWithExpandedCollapsingToolbarTabIndicator = tabLayoutWithExpandedCollapsingToolbarTabIndicator
        self.tabLayoutWithCollapsedCollapsingToolbarTabBackground = tabLayoutWithCollapsedCollapsingToolbarTabBackground
        self.tabLayoutWithCollapsedCollapsingToolbarTextColor = tabLayoutWithCollapsedCollapsingToolbarTextColor
        self.tabLayoutWithCollapsedCollapsingToolbarTabIndicator = tabLayoutWithCollapsedCollapsingToolbarTabIndicator
        self.navBarColor = navBarColor
        self.upvoted = upvoted
        self.downvoted = downvoted
        self.postTypeBackgroundColor = postTypeBackgroundColor
        self.postTypeTextColor = postTypeTextColor
        self.spoilerBackgroundColor = spoilerBackgroundColor
        self.spoilerTextColor = spoilerTextColor
        self.nsfwBackgroundColor = nsfwBackgroundColor
        self.nsfwTextColor = nsfwTextColor
        self.flairBackgroundColor = flairBackgroundColor
        self.flairTextColor = flairTextColor
        self.awardsBackgroundColor = awardsBackgroundColor
        self.awardsTextColor = awardsTextColor
        self.archivedTint = archivedTint
        self.lockedIconTint = lockedIconTint
        self.crosspostIconTint = crosspostIconTint
        self.upvoteRatioIconTint = upvoteRatioIconTint
        self.stickiedPostIconTint = stickiedPostIconTint
        self.noPreviewPostTypeIconTint = noPreviewPostTypeIconTint
        self.subscribed = subscribed
        self.unsubscribed = unsubscribed
        self.subreddit = subreddit
        self.authorFlairTextColor = authorFlairTextColor
        self.submitter = submitter
        self.moderator = moderator
        self.currentUser = currentUser
        self.singleCommentThreadBackgroundColor = singleCommentThreadBackgroundColor
        self.unreadMessageBackgroundColor = unreadMessageBackgroundColor
        self.dividerColor = dividerColor
        self.noPreviewPostTypeBackgroundColor = noPreviewPostTypeBackgroundColor
        self.voteAndReplyUnavailableButtonColor = voteAndReplyUnavailableButtonColor
        self.commentVerticalBarColor1 = commentVerticalBarColor1
        self.commentVerticalBarColor2 = commentVerticalBarColor2
        self.commentVerticalBarColor3 = commentVerticalBarColor3
        self.commentVerticalBarColor4 = commentVerticalBarColor4
        self.commentVerticalBarColor5 = commentVerticalBarColor5
        self.commentVerticalBarColor6 = commentVerticalBarColor6
        self.commentVerticalBarColor7 = commentVerticalBarColor7
        self.fabIconColor = fabIconColor
        self.chipTextColor = chipTextColor
        self.linkColor = linkColor
        self.receivedMessageTextColor = receivedMessageTextColor
        self.sentMessageTextColor = sentMessageTextColor
        self.receivedMessageBackgroundColor = receivedMessageBackgroundColor
        self.sentMessageBackgroundColor = sentMessageBackgroundColor
        self.sendMessageIconColor = sendMessageIconColor
        self.fullyCollapsedCommentBackgroundColor = fullyCollapsedCommentBackgroundColor
        self.awardedCommentBackgroundColor = awardedCommentBackgroundColor
        self.isLightStatusBar = isLightStatusBar
        self.isLightNavBar = isLightNavBar
        self.isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface = isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface
    }
    
    func getProperties(customThemeFields: inout [String], customThemeFieldsBoolType: inout Set<String>) {
        let mirror = Mirror(reflecting: self)
            
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            if child.value is Bool {
                customThemeFieldsBoolType.insert(label)
            }
            
            if child.label != "id" {
                customThemeFields.append(label)
            }
        }
    }
    
    func updateField(_ fieldName: String, with value: Any) {
        switch fieldName {
        case "name":
            if let value = value as? String { name = value }
        case "isLightTheme":
            if let value = value as? Bool { isLightTheme = value }
        case "isDarkTheme":
            if let value = value as? Bool { isDarkTheme = value }
        case "isAmoledTheme":
            if let value = value as? Bool { isAmoledTheme = value }
        case "isLightStatusBar":
            if let value = value as? Bool { isLightStatusBar = value }
        case "isLightNavBar":
            if let value = value as? Bool { isLightNavBar = value }
        case "isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface":
            if let value = value as? Bool { isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface = value }
        default:
            if let value = value as? Int {
                let mirror = Mirror(reflecting: self)
                if mirror.children.contains(where: { $0.label == fieldName }) {
                    self.setValue(value, forKey: fieldName)
                }
            }
        }
    }
    
    static func getIndigo() -> CustomTheme {
        let customTheme = CustomTheme(
            name: "Indigo",
            isLightTheme: true,
            isDarkTheme: false,
            isAmoledTheme: false,
            colorPrimary: 0x0336FF,
            colorPrimaryDark: 0x002BF0,
            colorAccent: 0xFF1868,
            colorPrimaryLightTheme: 0x0336FF,
            primaryTextColor: 0x000000,
            secondaryTextColor: 0x8A000000,
            postTitleColor: 0x000000,
            postContentColor: 0x8A000000,
            readPostTitleColor: 0x9D9D9D,
            readPostContentColor: 0x9D9D9D,
            commentColor: 0x000000,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0xFFFFFF,
            cardViewBackgroundColor: 0xFFFFFF,
            readPostCardViewBackgroundColor: 0xF5F5F5,
            filledCardViewBackgroundColor: 0xE6F4FF,
            readPostFilledCardViewBackgroundColor: 0xF5F5F5,
            commentBackgroundColor: 0xFFFFFF,
            bottomAppBarBackgroundColor: 0xFFFFFF,
            primaryIconColor: 0x000000,
            bottomAppBarIconColor: 0x000000,
            postIconAndInfoColor: 0x8A000000,
            commentIconAndInfoColor: 0x8A000000,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0xFFFFFF,
            mediaIndicatorIconColor: 0xFFFFFF,
            mediaIndicatorBackgroundColor: 0x000000,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0x0336FF,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0x0336FF,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0x0336FF,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x002BF0,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x002BF0,
            noPreviewPostTypeIconTint: 0x808080,
            subscribed: 0xFF1868,
            unsubscribed: 0x002BF0,
            username: 0x002BF0,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0xB3E5F9,
            unreadMessageBackgroundColor: 0xB3E5F9,
            dividerColor: 0xE0E0E0,
            noPreviewPostTypeBackgroundColor: 0xE0E0E0,
            voteAndReplyUnavailableButtonColor: 0xF0F0F0,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xEE02BE,
            commentVerticalBarColor3: 0x02DFEE,
            commentVerticalBarColor4: 0xEED502,
            commentVerticalBarColor5: 0xEE0220,
            commentVerticalBarColor6: 0x02EE6E,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0xFFFFFF,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x8EDFBA,
            awardedCommentBackgroundColor: 0xFFFFFF,
            navBarColor: 0xFFFFFF,
            isLightStatusBar: false,
            isLightNavBar: true,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: true
        )
        return customTheme
    }
    
    static func getIndigoDark() -> CustomTheme {
        let customTheme = CustomTheme(
            name: "Indigo Dark",
            isLightTheme: false,
            isDarkTheme: true,
            isAmoledTheme: false,
            colorPrimary: 0x242424,
            colorPrimaryDark: 0x121212,
            colorAccent: 0xFF1868,
            colorPrimaryLightTheme: 0x0336FF,
            primaryTextColor: 0xFFFFFF,
            secondaryTextColor: 0xB3FFFFFF,
            postTitleColor: 0xFFFFFF,
            postContentColor: 0xB3FFFFFF,
            readPostTitleColor: 0x979797,
            readPostContentColor: 0x979797,
            commentColor: 0xFFFFFF,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0x121212,
            cardViewBackgroundColor: 0x242424,
            readPostCardViewBackgroundColor: 0x101010,
            filledCardViewBackgroundColor: 0x242424,
            readPostFilledCardViewBackgroundColor: 0x101010,
            commentBackgroundColor: 0x242424,
            bottomAppBarBackgroundColor: 0x121212,
            primaryIconColor: 0xFFFFFF,
            bottomAppBarIconColor: 0xFFFFFF,
            postIconAndInfoColor: 0xB3FFFFFF,
            commentIconAndInfoColor: 0xB3FFFFFF,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0x242424,
            mediaIndicatorIconColor: 0x000000,
            mediaIndicatorBackgroundColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0x242424,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0x242424,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x0336FF,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x0336FF,
            noPreviewPostTypeIconTint: 0x808080,
            subscribed: 0xFF1868,
            unsubscribed: 0x0336FF,
            username: 0x1E88E5,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0x123E77,
            unreadMessageBackgroundColor: 0x123E77,
            dividerColor: 0x69666C,
            noPreviewPostTypeBackgroundColor: 0x424242,
            voteAndReplyUnavailableButtonColor: 0x3C3C3C,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xC300B3,
            commentVerticalBarColor3: 0x00B8DA,
            commentVerticalBarColor4: 0xEDCA00,
            commentVerticalBarColor5: 0xEE0219,
            commentVerticalBarColor6: 0x00B925,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0xFFFFFF,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x21C561,
            awardedCommentBackgroundColor: 0x242424,
            navBarColor: 0x121212,
            isLightStatusBar: false,
            isLightNavBar: false,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: false
        )
        return customTheme
    }
    
    static func getIndigoAmoled() -> CustomTheme {
        return CustomTheme(
            name: "Indigo Amoled",
            isLightTheme: false,
            isDarkTheme: false,
            isAmoledTheme: true,
            colorPrimary: 0x000000,
            colorPrimaryDark: 0x000000,
            colorAccent: 0xFF1868,
            colorPrimaryLightTheme: 0x0336FF,
            primaryTextColor: 0xFFFFFF,
            secondaryTextColor: 0xB3FFFF,
            postTitleColor: 0xFFFFFF,
            postContentColor: 0xB3FFFF,
            readPostTitleColor: 0x979797,
            readPostContentColor: 0x979797,
            commentColor: 0xFFFFFF,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0x000000,
            cardViewBackgroundColor: 0x000000,
            readPostCardViewBackgroundColor: 0x000000,
            filledCardViewBackgroundColor: 0x000000,
            readPostFilledCardViewBackgroundColor: 0x000000,
            commentBackgroundColor: 0x000000,
            bottomAppBarBackgroundColor: 0x000000,
            primaryIconColor: 0xFFFFFF,
            bottomAppBarIconColor: 0xFFFFFF,
            postIconAndInfoColor: 0xB3FFFF,
            commentIconAndInfoColor: 0xB3FFFF,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0x000000,
            mediaIndicatorIconColor: 0x000000,
            mediaIndicatorBackgroundColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0x000000,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0x000000,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x0336FF,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x0336FF,
            noPreviewPostTypeIconTint: 0x808080,
            subscribed: 0xFF1868,
            unsubscribed: 0x0336FF,
            username: 0x1E88E5,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0x123E77,
            unreadMessageBackgroundColor: 0x123E77,
            dividerColor: 0x69666C,
            noPreviewPostTypeBackgroundColor: 0x424242,
            voteAndReplyUnavailableButtonColor: 0x3C3C3C,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xC300B3,
            commentVerticalBarColor3: 0x00B8DA,
            commentVerticalBarColor4: 0xEDCA00,
            commentVerticalBarColor5: 0xEE0219,
            commentVerticalBarColor6: 0x00B925,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0xFFFFFF,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x21C561,
            awardedCommentBackgroundColor: 0x000000,
            navBarColor: 0x000000,
            isLightStatusBar: false,
            isLightNavBar: false,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: false
        )
    }
    
    static func getWhite() -> CustomTheme {
        return CustomTheme(
            name: "White",
            isLightTheme: true,
            isDarkTheme: false,
            isAmoledTheme: false,
            colorPrimary: 0xFFFFFF,
            colorPrimaryDark: 0xFFFFFF,
            colorAccent: 0x000000,
            colorPrimaryLightTheme: 0x000000,
            primaryTextColor: 0x000000,
            secondaryTextColor: 0x8A0000,
            postTitleColor: 0x000000,
            postContentColor: 0x8A0000,
            readPostTitleColor: 0x9D9D9D,
            readPostContentColor: 0x9D9D9D,
            commentColor: 0x000000,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0xFFFFFF,
            cardViewBackgroundColor: 0xFFFFFF,
            readPostCardViewBackgroundColor: 0xF5F5F5,
            filledCardViewBackgroundColor: 0xE6F4FF,
            readPostFilledCardViewBackgroundColor: 0xF5F5F5,
            commentBackgroundColor: 0xFFFFFF,
            bottomAppBarBackgroundColor: 0xFFFFFF,
            primaryIconColor: 0x000000,
            bottomAppBarIconColor: 0x000000,
            postIconAndInfoColor: 0x3C4043,
            commentIconAndInfoColor: 0x3C4043,
            toolbarPrimaryTextAndIconColor: 0x3C4043,
            toolbarSecondaryTextColor: 0x3C4043,
            circularProgressBarBackground: 0xFFFFFF,
            mediaIndicatorIconColor: 0xFFFFFF,
            mediaIndicatorBackgroundColor: 0x000000,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0x3C4043,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0x3C4043,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0x3C4043,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0x3C4043,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x002BF0,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x002BF0,
            noPreviewPostTypeIconTint: 0xFFFFFF,
            subscribed: 0xFF1868,
            unsubscribed: 0x002BF0,
            username: 0x002BF0,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0xB3E5F9,
            unreadMessageBackgroundColor: 0xB3E5F9,
            dividerColor: 0xE0E0E0,
            noPreviewPostTypeBackgroundColor: 0x000000,
            voteAndReplyUnavailableButtonColor: 0xF0F0F0,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xEE02BE,
            commentVerticalBarColor3: 0x02DFEE,
            commentVerticalBarColor4: 0xEED502,
            commentVerticalBarColor5: 0xEE0220,
            commentVerticalBarColor6: 0x02EE6E,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0xFFFFFF,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x8EDFBA,
            awardedCommentBackgroundColor: 0xFFFFFF,
            navBarColor: 0xFFFFFF,
            isLightStatusBar: true,
            isLightNavBar: true,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: false
        )
    }
    
    static func getWhiteDark() -> CustomTheme {
        return CustomTheme(
            name: "White Dark",
            isLightTheme: false,
            isDarkTheme: true,
            isAmoledTheme: false,
            colorPrimary: 0x242424,
            colorPrimaryDark: 0x121212,
            colorAccent: 0xFFFFFF,
            colorPrimaryLightTheme: 0x121212,
            primaryTextColor: 0xFFFFFF,
            secondaryTextColor: 0xB3FFFFFF,
            postTitleColor: 0xFFFFFF,
            postContentColor: 0xB3FFFFFF,
            readPostTitleColor: 0x979797,
            readPostContentColor: 0x979797,
            commentColor: 0xFFFFFF,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0x121212,
            cardViewBackgroundColor: 0x242424,
            readPostCardViewBackgroundColor: 0x101010,
            filledCardViewBackgroundColor: 0x242424,
            readPostFilledCardViewBackgroundColor: 0x101010,
            commentBackgroundColor: 0x242424,
            bottomAppBarBackgroundColor: 0x121212,
            primaryIconColor: 0xFFFFFF,
            bottomAppBarIconColor: 0xFFFFFF,
            postIconAndInfoColor: 0xB3FFFFFF,
            commentIconAndInfoColor: 0xB3FFFFFF,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0x242424,
            mediaIndicatorIconColor: 0x000000,
            mediaIndicatorBackgroundColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0x242424,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0x242424,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x0336FF,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x0336FF,
            noPreviewPostTypeIconTint: 0xFFFFFF,
            subscribed: 0xFF1868,
            unsubscribed: 0x0336FF,
            username: 0x1E88E5,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0x123E77,
            unreadMessageBackgroundColor: 0x123E77,
            dividerColor: 0x69666C,
            noPreviewPostTypeBackgroundColor: 0x000000,
            voteAndReplyUnavailableButtonColor: 0x3C3C3C,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xC300B3,
            commentVerticalBarColor3: 0x00B8DA,
            commentVerticalBarColor4: 0xEDCA00,
            commentVerticalBarColor5: 0xEE0219,
            commentVerticalBarColor6: 0x00B925,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0x000000,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x21C561,
            awardedCommentBackgroundColor: 0x242424,
            navBarColor: 0x121212,
            isLightStatusBar: false,
            isLightNavBar: false,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: false
        )
    }
    
    static func getWhiteAmoled() -> CustomTheme {
        let customTheme = CustomTheme(
            name: "White Amoled",
            isLightTheme: false,
            isDarkTheme: false,
            isAmoledTheme: true,
            colorPrimary: 0x000000,
            colorPrimaryDark: 0x000000,
            colorAccent: 0xFFFFFF,
            colorPrimaryLightTheme: 0x000000,
            primaryTextColor: 0xFFFFFF,
            secondaryTextColor: 0xB3FFFFFF,
            postTitleColor: 0xFFFFFF,
            postContentColor: 0xB3FFFFFF,
            readPostTitleColor: 0x979797,
            readPostContentColor: 0x979797,
            commentColor: 0xFFFFFF,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0x000000,
            cardViewBackgroundColor: 0x000000,
            readPostCardViewBackgroundColor: 0x000000,
            filledCardViewBackgroundColor: 0x000000,
            readPostFilledCardViewBackgroundColor: 0x000000,
            commentBackgroundColor: 0x000000,
            bottomAppBarBackgroundColor: 0x000000,
            primaryIconColor: 0xFFFFFF,
            bottomAppBarIconColor: 0xFFFFFF,
            postIconAndInfoColor: 0xB3FFFFFF,
            commentIconAndInfoColor: 0xB3FFFFFF,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0x000000,
            mediaIndicatorIconColor: 0x000000,
            mediaIndicatorBackgroundColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0x000000,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0x000000,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x0336FF,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x0336FF,
            noPreviewPostTypeIconTint: 0xFFFFFF,
            subscribed: 0xFF1868,
            unsubscribed: 0x0336FF,
            username: 0x1E88E5,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0x123E77,
            unreadMessageBackgroundColor: 0x123E77,
            dividerColor: 0x69666C,
            noPreviewPostTypeBackgroundColor: 0x000000,
            voteAndReplyUnavailableButtonColor: 0x3C3C3C,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xC300B3,
            commentVerticalBarColor3: 0x00B8DA,
            commentVerticalBarColor4: 0xEDCA00,
            commentVerticalBarColor5: 0xEE0219,
            commentVerticalBarColor6: 0x00B925,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0x000000,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x21C561,
            awardedCommentBackgroundColor: 0x000000,
            navBarColor: 0x000000,
            isLightStatusBar: false,
            isLightNavBar: false,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: false
        )
        
        return customTheme
    }
    
    private static func getRed() -> CustomTheme {
        let customTheme = CustomTheme(
            name: "Red",
            isLightTheme: true,
            isDarkTheme: false,
            isAmoledTheme: false,
            colorPrimary: 0xEE0270,
            colorPrimaryDark: 0xC60466,
            colorAccent: 0x02EE80,
            colorPrimaryLightTheme: 0xEE0270,
            primaryTextColor: 0x000000,
            secondaryTextColor: 0x8A000000,
            postTitleColor: 0x000000,
            postContentColor: 0x8A000000,
            readPostTitleColor: 0x9D9D9D,
            readPostContentColor: 0x9D9D9D,
            commentColor: 0x000000,
            buttonTextColor: 0xFFFFFF,
            backgroundColor: 0xFFFFFF,
            cardViewBackgroundColor: 0xFFFFFF,
            readPostCardViewBackgroundColor: 0xF5F5F5,
            filledCardViewBackgroundColor: 0xFFE9F3,
            readPostFilledCardViewBackgroundColor: 0xF5F5F5,
            commentBackgroundColor: 0xFFFFFF,
            bottomAppBarBackgroundColor: 0xFFFFFF,
            primaryIconColor: 0x000000,
            bottomAppBarIconColor: 0x000000,
            postIconAndInfoColor: 0x8A000000,
            commentIconAndInfoColor: 0x8A000000,
            toolbarPrimaryTextAndIconColor: 0xFFFFFF,
            toolbarSecondaryTextColor: 0xFFFFFF,
            circularProgressBarBackground: 0xFFFFFF,
            mediaIndicatorIconColor: 0xFFFFFF,
            mediaIndicatorBackgroundColor: 0x000000,
            tabLayoutWithExpandedCollapsingToolbarTabBackground: 0xFFFFFF,
            tabLayoutWithExpandedCollapsingToolbarTextColor: 0xEE0270,
            tabLayoutWithExpandedCollapsingToolbarTabIndicator: 0xEE0270,
            tabLayoutWithCollapsedCollapsingToolbarTabBackground: 0xEE0270,
            tabLayoutWithCollapsedCollapsingToolbarTextColor: 0xFFFFFF,
            tabLayoutWithCollapsedCollapsingToolbarTabIndicator: 0xFFFFFF,
            upvoted: 0xFF1868,
            downvoted: 0x007DDE,
            postTypeBackgroundColor: 0x002BF0,
            postTypeTextColor: 0xFFFFFF,
            spoilerBackgroundColor: 0xEE02EB,
            spoilerTextColor: 0xFFFFFF,
            nsfwBackgroundColor: 0xFF1868,
            nsfwTextColor: 0xFFFFFF,
            flairBackgroundColor: 0x00AA8C,
            flairTextColor: 0xFFFFFF,
            awardsBackgroundColor: 0xEEAB02,
            awardsTextColor: 0xFFFFFF,
            archivedTint: 0xB4009F,
            lockedIconTint: 0xEE7302,
            crosspostIconTint: 0xFF1868,
            upvoteRatioIconTint: 0x0256EE,
            stickiedPostIconTint: 0x002BF0,
            noPreviewPostTypeIconTint: 0x808080,
            subscribed: 0xFF1868,
            unsubscribed: 0x002BF0,
            username: 0x002BF0,
            subreddit: 0xFF1868,
            authorFlairTextColor: 0xEE02C4,
            submitter: 0xEE8A02,
            moderator: 0x00BA81,
            currentUser: 0x00D5EA,
            singleCommentThreadBackgroundColor: 0xB3E5F9,
            unreadMessageBackgroundColor: 0xB3E5F9,
            dividerColor: 0xE0E0E0,
            noPreviewPostTypeBackgroundColor: 0xE0E0E0,
            voteAndReplyUnavailableButtonColor: 0xF0F0F0,
            commentVerticalBarColor1: 0x0336FF,
            commentVerticalBarColor2: 0xEE02BE,
            commentVerticalBarColor3: 0x02DFEE,
            commentVerticalBarColor4: 0xEED502,
            commentVerticalBarColor5: 0xEE0220,
            commentVerticalBarColor6: 0x02EE6E,
            commentVerticalBarColor7: 0xEE4602,
            fabIconColor: 0xFFFFFF,
            chipTextColor: 0xFFFFFF,
            linkColor: 0xFF1868,
            receivedMessageTextColor: 0xFFFFFF,
            sentMessageTextColor: 0xFFFFFF,
            receivedMessageBackgroundColor: 0x4185F4,
            sentMessageBackgroundColor: 0x31BF7D,
            sendMessageIconColor: 0x4185F4,
            fullyCollapsedCommentBackgroundColor: 0x8EDFBA,
            awardedCommentBackgroundColor: 0xFFFFFF,
            navBarColor: 0xFFFFFF,
            isLightStatusBar: false,
            isLightNavBar: true,
            isChangeStatusBarIconColorAfterToolbarCollapsedInImmersiveInterface: true
        )
        
        return customTheme
    }
}
