//
//  PostView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-11.
//

import Swinject
import GRDB
import SwiftUI

struct PostView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @State private var defaultPostLayout: Int
    @State private var defaultLinkPostLayout: Int
    @State private var hidePostType: Bool
    @State private var hidePostFlair: Bool
    @State private var hideSubredditAndUserPrefix: Bool
    @State private var hideNumberOfVotes: Bool
    @State private var hideNumberOfComments: Bool
    @State private var hideTextPostContent: Bool
    @State private var fixedHeightInCard: Bool
    @State private var showDivider: Bool
    @State private var showThumbnailOnTheLeft: Bool
    @State private var longPressToHideToolbar: Bool
    @State private var hideToolbarByDefault: Bool
    @State private var clickToShowMediaInGalleryLayout: Bool
    
    let DEFAULT_POST_LAYOUT_KEY = UserDefaultsUtils.DEFAULT_POST_LAYOUT_KEY
    let DEFAULT_LINK_POST_LAYOUT_KEY = UserDefaultsUtils.DEFAULT_LINK_POST_LAYOUT_KEY
    let HIDE_POST_TYPE = UserDefaultsUtils.HIDE_POST_TYPE
    let HIDE_POST_FLAIR = UserDefaultsUtils.HIDE_POST_FLAIR
    let HIDE_SUBREDDIT_AND_USER_PREFIX = UserDefaultsUtils.HIDE_SUBREDDIT_AND_USER_PREFIX
    let HIDE_THE_NUMBER_OF_VOTES = UserDefaultsUtils.HIDE_THE_NUMBER_OF_VOTES
    let HIDE_THE_NUMBER_OF_COMMENTS = UserDefaultsUtils.HIDE_THE_NUMBER_OF_COMMENTS
    let HIDE_TEXT_POST_CONTENT = UserDefaultsUtils.HIDE_TEXT_POST_CONTENT
    let FIXED_HEIGHT_PREVIEW_IN_CARD = UserDefaultsUtils.FIXED_HEIGHT_PREVIEW_IN_CARD
    let SHOW_DIVIDER_IN_COMPACT_LAYOUT = UserDefaultsUtils.SHOW_DIVIDER_IN_COMPACT_LAYOUT
    let SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT = UserDefaultsUtils.SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT
    let LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT = UserDefaultsUtils.LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT
    let POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT = UserDefaultsUtils.POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT
    let CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT = UserDefaultsUtils.CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT
    
    
    private let postLayouts: [String] = ["Card Layout", "Card Layout 2", "Card Layout 3", "Compact Layout", "Gallery Layout"]
    private let linkPostLayouts: [String] = ["Auto", "Card Layout", "Card Layout 2", "Card Layout 3", "Compact Layout", "Gallery Layout"]
    private let userDefaults: UserDefaults
    
    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: DEFAULT_POST_LAYOUT_KEY) == nil {
            userDefaults.set(0, forKey: DEFAULT_POST_LAYOUT_KEY)
        }
        
        if userDefaults.object(forKey: DEFAULT_LINK_POST_LAYOUT_KEY) == nil {
            userDefaults.set(0, forKey: DEFAULT_LINK_POST_LAYOUT_KEY)
        }
        
        if userDefaults.object(forKey: HIDE_POST_TYPE) == nil {
            userDefaults.set(false, forKey: HIDE_POST_TYPE)
        }
        
        if userDefaults.object(forKey: HIDE_POST_FLAIR) == nil {
            userDefaults.set(false, forKey: HIDE_POST_FLAIR)
        }
        
        if userDefaults.object(forKey: HIDE_SUBREDDIT_AND_USER_PREFIX) == nil {
            userDefaults.set(false, forKey: HIDE_SUBREDDIT_AND_USER_PREFIX)
        }
        
        if userDefaults.object(forKey: HIDE_THE_NUMBER_OF_VOTES) == nil {
            userDefaults.set(false, forKey: HIDE_THE_NUMBER_OF_VOTES)
        }
        
        if userDefaults.object(forKey: HIDE_THE_NUMBER_OF_COMMENTS) == nil {
            userDefaults.set(true, forKey: HIDE_THE_NUMBER_OF_COMMENTS)
        }
        
        if userDefaults.object(forKey: HIDE_TEXT_POST_CONTENT) == nil {
            userDefaults.set(false, forKey: HIDE_TEXT_POST_CONTENT)
        }
        
        if userDefaults.object(forKey: FIXED_HEIGHT_PREVIEW_IN_CARD) == nil {
            userDefaults.set(false, forKey: FIXED_HEIGHT_PREVIEW_IN_CARD)
        }
        
        if userDefaults.object(forKey: SHOW_DIVIDER_IN_COMPACT_LAYOUT) == nil {
            userDefaults.set(true, forKey: SHOW_DIVIDER_IN_COMPACT_LAYOUT)
        }
        
        if userDefaults.object(forKey: SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT) == nil {
            userDefaults.set(false, forKey: SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT)
        }
        if userDefaults.object(forKey: LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT) == nil {
            userDefaults.set(false, forKey: LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT)
        }
        if userDefaults.object(forKey: POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT) == nil {
            userDefaults.set(false, forKey: POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT)
        }
        if userDefaults.object(forKey: CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT) == nil {
            userDefaults.set(false, forKey: CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT)
        }
        
        
        _defaultPostLayout = State(initialValue: userDefaults.integer(forKey: DEFAULT_POST_LAYOUT_KEY))
        _defaultLinkPostLayout = State(initialValue: userDefaults.integer(forKey: DEFAULT_LINK_POST_LAYOUT_KEY))
        _hidePostType = State(initialValue: userDefaults.bool(forKey: HIDE_POST_TYPE))
        _hidePostFlair = State(initialValue: userDefaults.bool(forKey: HIDE_POST_FLAIR))
        _hideSubredditAndUserPrefix = State(initialValue: userDefaults.bool(forKey: HIDE_SUBREDDIT_AND_USER_PREFIX))
        _hideNumberOfVotes = State(initialValue: userDefaults.bool(forKey: HIDE_THE_NUMBER_OF_VOTES))
        _hideNumberOfComments = State(initialValue: userDefaults.bool(forKey: HIDE_THE_NUMBER_OF_COMMENTS))
        _hideTextPostContent = State(initialValue: userDefaults.bool(forKey: HIDE_TEXT_POST_CONTENT))
        _fixedHeightInCard = State(initialValue: userDefaults.bool(forKey: FIXED_HEIGHT_PREVIEW_IN_CARD))
        _showDivider = State(initialValue: userDefaults.bool(forKey: SHOW_DIVIDER_IN_COMPACT_LAYOUT))
        _showThumbnailOnTheLeft = State(initialValue: userDefaults.bool(forKey: SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT))
        _longPressToHideToolbar = State(initialValue: userDefaults.bool(forKey: LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT))
        _hideToolbarByDefault = State(initialValue: userDefaults.bool(forKey: POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT))
        _clickToShowMediaInGalleryLayout = State(initialValue: userDefaults.bool(forKey: CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT))
    }
    
    var body: some View {
        List {
            Picker("Default Post Layout", selection: $defaultPostLayout) {
                ForEach(0..<postLayouts.count, id: \.self) { index in
                    Text(postLayouts[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            .onChange(of: defaultPostLayout) { _, newValue in
                userDefaults.set(newValue, forKey: DEFAULT_POST_LAYOUT_KEY)
            }
            Picker("Default Link Post Layout", selection: $defaultLinkPostLayout) {
                ForEach(0..<linkPostLayouts.count, id: \.self) { index in
                    Text(linkPostLayouts[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            .onChange(of: defaultLinkPostLayout) { _, newValue in
                userDefaults.set(newValue, forKey: DEFAULT_LINK_POST_LAYOUT_KEY)
            }
            NavigationLink(destination: PostView()) {
                Text("The Number of Columns in Post Feed")
            }.padding(.leading, 44.5)
            Toggle("Hide Post Type", isOn: $hidePostType).padding(.leading, 44.5).onChange(of: hidePostType) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_POST_TYPE)
            }
            Toggle("Hide Post Flair", isOn: $hidePostFlair).padding(.leading, 44.5).onChange(of: hidePostFlair) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_POST_FLAIR)
            }
            Toggle("Hide Subreddit and User Prefix", isOn: $hideSubredditAndUserPrefix).padding(.leading, 44.5).onChange(of: hideSubredditAndUserPrefix) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_SUBREDDIT_AND_USER_PREFIX)
            }
            Toggle("Hide the Number of Votes", isOn: $hideNumberOfVotes).padding(.leading, 44.5).onChange(of: hideNumberOfVotes) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_THE_NUMBER_OF_VOTES)
            }
            Toggle("Hide the Number of Comments", isOn: $hideNumberOfComments).padding(.leading, 44.5).onChange(of: hideNumberOfComments) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_THE_NUMBER_OF_COMMENTS)
            }
            Toggle("Hide Text Post Content", isOn: $hideTextPostContent).padding(.leading, 44.5).onChange(of: hideTextPostContent) {
                _, newValue in userDefaults.set(newValue, forKey: HIDE_TEXT_POST_CONTENT)
            }
            Toggle("Fixed Height in Card", isOn: $fixedHeightInCard).padding(.leading, 44.5).onChange(of: fixedHeightInCard) {
                _, newValue in userDefaults.set(newValue, forKey: FIXED_HEIGHT_PREVIEW_IN_CARD)
            }
            Section(header: Text("Compact Layout")) {
                Toggle("Show Divider", isOn: $showDivider).padding(.leading, 44.5).onChange(of: showDivider) {
                    _, newValue in userDefaults.set(newValue, forKey: SHOW_DIVIDER_IN_COMPACT_LAYOUT)
                }
                Toggle("Show Thumbnail on the Left", isOn: $showThumbnailOnTheLeft).padding(.leading, 44.5).onChange(of: showThumbnailOnTheLeft) {
                    _, newValue in userDefaults.set(newValue, forKey: SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT)
                }
                Toggle("Long Press to Hide Toolbar", isOn: $longPressToHideToolbar).padding(.leading, 44.5).onChange(of: longPressToHideToolbar) {
                    _, newValue in userDefaults.set(newValue, forKey: LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT)
                }
                Toggle("Hide Toolbar by Default", isOn: $hideToolbarByDefault).padding(.leading, 44.5).onChange(of: hideToolbarByDefault) {
                    _, newValue in userDefaults.set(newValue, forKey: POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT)
                }
            }
            Section(header: Text("Gallery Layout")) {
                Toggle("Click to Show Media in Gallery Layout", isOn: $clickToShowMediaInGalleryLayout).padding(.leading, 44.5).onChange(of: clickToShowMediaInGalleryLayout) {
                    _, newValue in userDefaults.set(newValue, forKey: CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT)
                }
            }
            .navigationTitle("Post")
        }
        
    }
}


