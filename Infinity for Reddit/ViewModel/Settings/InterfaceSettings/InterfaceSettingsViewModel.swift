//
//  InterfaceSettingsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Combine
import GRDB
import Swinject

class InterfaceSettingsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var hideFABInPostFeed: Bool
    @Published var enableBottomNavigation: Bool
    @Published var hideSubredditDescription: Bool
    @Published var useBottomToolbarInMediaViewer: Bool
    @Published var voteButtonsOnTheRight: Bool
    @Published var showAbsoluteNumberOfVotes: Bool
    @Published var defaultSearchResultTab: Int
    
    let HIDE_FAB_IN_POST_FEED = UserDefaultsUtils.HIDE_FAB_IN_POST_FEED
    let BOTTOM_APP_BAR_KEY = UserDefaultsUtils.BOTTOM_APP_BAR_KEY
    let HIDE_SUBREDDIT_DESCRIPTION = UserDefaultsUtils.HIDE_SUBREDDIT_DESCRIPTION
    let USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER = UserDefaultsUtils.USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER
    let VOTE_BUTTONS_ON_THE_RIGHT_KEY = UserDefaultsUtils.VOTE_BUTTONS_ON_THE_RIGHT_KEY
    let SHOW_ABSOLUTE_NUMBER_OF_VOTES = UserDefaultsUtils.SHOW_ABSOLUTE_NUMBER_OF_VOTES
    let DEFAULT_SEARCH_RESULT_TAB = UserDefaultsUtils.DEFAULT_SEARCH_RESULT_TAB
    
    let searchResultTabs: [String] = ["Posts", "Subreddits", "Users"]
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: HIDE_FAB_IN_POST_FEED) == nil {
            userDefaults.set(false, forKey: HIDE_FAB_IN_POST_FEED)
        }
        
        if userDefaults.object(forKey: BOTTOM_APP_BAR_KEY) == nil {
            userDefaults.set(false, forKey: BOTTOM_APP_BAR_KEY)
        }
        
        if userDefaults.object(forKey: HIDE_SUBREDDIT_DESCRIPTION) == nil {
            userDefaults.set(false, forKey: HIDE_SUBREDDIT_DESCRIPTION)
        }
        
        if userDefaults.object(forKey: USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER) == nil {
            userDefaults.set(false, forKey: USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER)
        }
        
        if userDefaults.object(forKey: VOTE_BUTTONS_ON_THE_RIGHT_KEY) == nil {
            userDefaults.set(false, forKey: VOTE_BUTTONS_ON_THE_RIGHT_KEY)
        }
        
        if userDefaults.object(forKey: SHOW_ABSOLUTE_NUMBER_OF_VOTES) == nil {
            userDefaults.set(true, forKey: SHOW_ABSOLUTE_NUMBER_OF_VOTES)
        }
        
        if userDefaults.object(forKey: DEFAULT_SEARCH_RESULT_TAB) == nil {
            userDefaults.set(0, forKey: DEFAULT_SEARCH_RESULT_TAB)
        }
        
        hideFABInPostFeed = userDefaults.bool(forKey: HIDE_FAB_IN_POST_FEED)
        enableBottomNavigation = userDefaults.bool(forKey: BOTTOM_APP_BAR_KEY)
        hideSubredditDescription = userDefaults.bool(forKey: HIDE_SUBREDDIT_DESCRIPTION)
        useBottomToolbarInMediaViewer = userDefaults.bool(forKey: USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER)
        voteButtonsOnTheRight = userDefaults.bool(forKey: VOTE_BUTTONS_ON_THE_RIGHT_KEY)
        showAbsoluteNumberOfVotes = userDefaults.bool(forKey: SHOW_ABSOLUTE_NUMBER_OF_VOTES)
        defaultSearchResultTab = userDefaults.integer(forKey: DEFAULT_SEARCH_RESULT_TAB)
        
        $hideFABInPostFeed
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.HIDE_FAB_IN_POST_FEED ?? "")
            }
            .store(in: &cancellables)
        
        $enableBottomNavigation
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.BOTTOM_APP_BAR_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $hideSubredditDescription
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.HIDE_SUBREDDIT_DESCRIPTION ?? "")
            }
            .store(in: &cancellables)
        
        $useBottomToolbarInMediaViewer
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER ?? "")
            }
            .store(in: &cancellables)
        
        $voteButtonsOnTheRight
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.VOTE_BUTTONS_ON_THE_RIGHT_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $showAbsoluteNumberOfVotes
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.SHOW_ABSOLUTE_NUMBER_OF_VOTES ?? "")
            }
            .store(in: &cancellables)
        
        $defaultSearchResultTab
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.DEFAULT_SEARCH_RESULT_TAB ?? "")
            }
            .store(in: &cancellables)
        
    }
    
    // MARK: - Methods
    func saveInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
