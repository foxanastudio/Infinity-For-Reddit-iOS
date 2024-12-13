//
//  NavigationDrawerInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//  

import SwiftUI
import Swinject
import GRDB
import Combine

class NavigationDrawerInterfaceViewModel: ObservableObject{
    // MARK: - Properties
    @Published var showAvatarOnRight: Bool
    @Published var collapseAccountSection: Bool
    @Published var collapseRedditSection: Bool
    @Published var collapsePostSection: Bool
    @Published var collapsePreferencesSection: Bool
    @Published var collapseFavoriteSubredditsSection: Bool
    @Published var collapseSubscribedSubredditsSection: Bool
    @Published var hideFavoriteSubredditsSection: Bool
    @Published var hideSubscribedSubredditsSection: Bool
    @Published var hideAccountKarma: Bool
    
    let SHOW_AVATAR_ON_RIGHT = UserDefaultsUtils.SHOW_AVATAR_ON_RIGHT
    let COLLAPSE_ACCOUNT_SECTION = UserDefaultsUtils.COLLAPSE_ACCOUNT_SECTION
    let COLLAPSE_REDDIT_SECTION = UserDefaultsUtils.COLLAPSE_REDDIT_SECTION
    let COLLAPSE_POST_SECTION = UserDefaultsUtils.COLLAPSE_POST_SECTION
    let COLLAPSE_PREFERENCES_SECTION = UserDefaultsUtils.COLLAPSE_PREFERENCES_SECTION
    let COLLAPSE_FAVORITE_SUBREDDITS_SECTION = UserDefaultsUtils.COLLAPSE_FAVORITE_SUBREDDITS_SECTION
    let COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION = UserDefaultsUtils.COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION
    let HIDE_FAVORITE_SUBREDDITS_SECTION = UserDefaultsUtils.HIDE_FAVORITE_SUBREDDITS_SECTION
    let HIDE_SUBSCRIBED_SUBREDDITS_SECTION = UserDefaultsUtils.HIDE_SUBSCRIBED_SUBREDDITS_SECTION
    let HIDE_ACCOUNT_KARMA = UserDefaultsUtils.HIDE_ACCOUNT_KARMA_NAV_BAR
    
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: SHOW_AVATAR_ON_RIGHT) == nil {
            userDefaults.set(false, forKey: SHOW_AVATAR_ON_RIGHT)
        }
        if userDefaults.object(forKey: COLLAPSE_ACCOUNT_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_ACCOUNT_SECTION)
        }
        if userDefaults.object(forKey: COLLAPSE_REDDIT_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_REDDIT_SECTION)
        }
        if userDefaults.object(forKey: COLLAPSE_POST_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_POST_SECTION)
        }
        if userDefaults.object(forKey: COLLAPSE_PREFERENCES_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_PREFERENCES_SECTION)
        }
        if userDefaults.object(forKey: COLLAPSE_FAVORITE_SUBREDDITS_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_FAVORITE_SUBREDDITS_SECTION)
        }
        if userDefaults.object(forKey: COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION) == nil {
            userDefaults.set(false, forKey: COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION)
        }
        if userDefaults.object(forKey: HIDE_FAVORITE_SUBREDDITS_SECTION) == nil {
            userDefaults.set(false, forKey: HIDE_FAVORITE_SUBREDDITS_SECTION)
        }
        if userDefaults.object(forKey: HIDE_SUBSCRIBED_SUBREDDITS_SECTION) == nil {
            userDefaults.set(false, forKey: HIDE_SUBSCRIBED_SUBREDDITS_SECTION)
        }
        if userDefaults.object(forKey: HIDE_ACCOUNT_KARMA) == nil {
            userDefaults.set(false, forKey: HIDE_ACCOUNT_KARMA)
        }
        
        showAvatarOnRight = userDefaults.bool(forKey: SHOW_AVATAR_ON_RIGHT)
        collapseAccountSection = userDefaults.bool(forKey: COLLAPSE_ACCOUNT_SECTION)
        collapseRedditSection = userDefaults.bool(forKey: COLLAPSE_REDDIT_SECTION)
        collapsePostSection = userDefaults.bool(forKey: COLLAPSE_POST_SECTION)
        collapsePreferencesSection = userDefaults.bool(forKey: COLLAPSE_PREFERENCES_SECTION)
        collapseFavoriteSubredditsSection = userDefaults.bool(forKey: COLLAPSE_FAVORITE_SUBREDDITS_SECTION)
        collapseSubscribedSubredditsSection = userDefaults.bool(forKey: COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION)
        hideFavoriteSubredditsSection = userDefaults.bool(forKey: HIDE_FAVORITE_SUBREDDITS_SECTION)
        hideSubscribedSubredditsSection = userDefaults.bool(forKey: HIDE_SUBSCRIBED_SUBREDDITS_SECTION)
        hideAccountKarma = userDefaults.bool(forKey: HIDE_ACCOUNT_KARMA)
        
        $showAvatarOnRight
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.SHOW_AVATAR_ON_RIGHT ?? "")
            }
            .store(in: &cancellables)
        
        $collapseAccountSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_ACCOUNT_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $collapseRedditSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_REDDIT_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $collapsePostSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_POST_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $collapsePreferencesSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_PREFERENCES_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $collapseFavoriteSubredditsSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_FAVORITE_SUBREDDITS_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $collapseSubscribedSubredditsSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.COLLAPSE_SUBSCRIBED_SUBREDDITS_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $hideFavoriteSubredditsSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.HIDE_FAVORITE_SUBREDDITS_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $hideSubscribedSubredditsSection
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.HIDE_SUBSCRIBED_SUBREDDITS_SECTION ?? "")
            }
            .store(in: &cancellables)
        
        $hideAccountKarma
            .sink { [weak self] newValue in
                self?.saveNavigationDrawerInterfaceSettings(setting: newValue, forKey: self?.HIDE_ACCOUNT_KARMA ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func saveNavigationDrawerInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
