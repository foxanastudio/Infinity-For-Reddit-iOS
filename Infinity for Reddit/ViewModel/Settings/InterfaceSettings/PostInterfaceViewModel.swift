//
//  PostInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Swinject
import GRDB
import Combine

class PostInterfaceViewModel: ObservableObject {
    // MARK: - Properties
    @Published var defaultPostLayout: Int
    @Published var defaultLinkPostLayout: Int
    @Published var hidePostType: Bool
    @Published var hidePostFlair: Bool
    @Published var hideSubredditAndUserPrefix: Bool
    @Published var hideNumberOfVotes: Bool
    @Published var hideNumberOfComments: Bool
    @Published var hideTextPostContent: Bool
    @Published var fixedHeightInCard: Bool
    @Published var showDivider: Bool
    @Published var showThumbnailOnTheLeft: Bool
    @Published var longPressToHideToolbar: Bool
    @Published var hideToolbarByDefault: Bool
    @Published var clickToShowMediaInGalleryLayout: Bool
    
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
    
    let postLayouts: [String] = ["Card Layout", "Card Layout 2", "Card Layout 3", "Compact Layout", "Gallery Layout"]
    let linkPostLayouts: [String] = ["Auto", "Card Layout", "Card Layout 2", "Card Layout 3", "Compact Layout", "Gallery Layout"]
    
    private var userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
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
            userDefaults.set(false, forKey: HIDE_THE_NUMBER_OF_COMMENTS)
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
        
        defaultPostLayout = userDefaults.integer(forKey: DEFAULT_POST_LAYOUT_KEY)
        defaultLinkPostLayout = userDefaults.integer(forKey: DEFAULT_LINK_POST_LAYOUT_KEY)
        hidePostType = userDefaults.bool(forKey: HIDE_POST_TYPE)
        hidePostFlair = userDefaults.bool(forKey: HIDE_POST_FLAIR)
        hideSubredditAndUserPrefix = userDefaults.bool(forKey: HIDE_SUBREDDIT_AND_USER_PREFIX)
        hideNumberOfVotes = userDefaults.bool(forKey: HIDE_THE_NUMBER_OF_VOTES)
        hideNumberOfComments = userDefaults.bool(forKey: HIDE_THE_NUMBER_OF_COMMENTS)
        hideTextPostContent = userDefaults.bool(forKey: HIDE_TEXT_POST_CONTENT)
        fixedHeightInCard = userDefaults.bool(forKey: FIXED_HEIGHT_PREVIEW_IN_CARD)
        showDivider = userDefaults.bool(forKey: SHOW_DIVIDER_IN_COMPACT_LAYOUT)
        showThumbnailOnTheLeft = userDefaults.bool(forKey: SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT)
        longPressToHideToolbar = userDefaults.bool(forKey: LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT)
        hideToolbarByDefault = userDefaults.bool(forKey: POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT)
        clickToShowMediaInGalleryLayout = userDefaults.bool(forKey: CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT)
        
        $defaultPostLayout
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.DEFAULT_POST_LAYOUT_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $defaultLinkPostLayout
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.DEFAULT_LINK_POST_LAYOUT_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $hidePostType
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_POST_TYPE ?? "")
            }
            .store(in: &cancellables)
        
        $hidePostFlair
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_POST_FLAIR ?? "")
            }
            .store(in: &cancellables)
        
        $hideSubredditAndUserPrefix
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_SUBREDDIT_AND_USER_PREFIX ?? "")
            }
            .store(in: &cancellables)
        
        $hideNumberOfVotes
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_THE_NUMBER_OF_VOTES ?? "")
            }
            .store(in: &cancellables)
        
        $hideNumberOfComments
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_THE_NUMBER_OF_COMMENTS ?? "")
            }
            .store(in: &cancellables)
        
        $hideTextPostContent
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.HIDE_TEXT_POST_CONTENT ?? "")
            }
            .store(in: &cancellables)
        
        $fixedHeightInCard
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.FIXED_HEIGHT_PREVIEW_IN_CARD ?? "")
            }
            .store(in: &cancellables)
        
        $showDivider
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.SHOW_DIVIDER_IN_COMPACT_LAYOUT ?? "")
            }
            .store(in: &cancellables)
        
        $showThumbnailOnTheLeft
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.SHOW_THUMBNAIL_ON_THE_LEFT_IN_COMPACT_LAYOUT ?? "")
            }
            .store(in: &cancellables)
        
        $longPressToHideToolbar
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.LONG_PRESS_TO_HIDE_TOOLBAR_IN_COMPACT_LAYOUT ?? "")
            }
            .store(in: &cancellables)
        
        $hideToolbarByDefault
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.POST_COMPACT_LAYOUT_TOOLBAR_HIDDEN_BY_DEFAULT ?? "")
            }
            .store(in: &cancellables)
        
        $clickToShowMediaInGalleryLayout
            .sink { [weak self] newValue in
                self?.savePostInterfaceSettings(setting: newValue, forKey: self?.CLICK_TO_SHOW_MEDIA_IN_GALLERY_LAYOUT ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func savePostInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
