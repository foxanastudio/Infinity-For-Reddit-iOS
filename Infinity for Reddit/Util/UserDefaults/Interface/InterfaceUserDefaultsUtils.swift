//
//  InterfaceUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-11.
//

import Foundation

class InterfaceUserDefaultsUtils {
    static let homeTabPostFeedTypeKeyBase = "home_tab_post_feed_type_"
    static func getHomeTabPostFeedType(account: Account) -> Int {
        return UserDefaults.interface.integer(forKey: homeTabPostFeedTypeKeyBase + account.username)
    }
    static func setHomeTabPostFeedType(account: Account, _ newValue: HomeTabPostFeedType) {
        UserDefaults.interface.set(newValue.rawValue, forKey: homeTabPostFeedTypeKeyBase + account.username)
    }
    
    static let nameOfHomeTabPostFeedKeyBase = "name_of_home_tab_post_feed"
    static func getNameOfHomeTabPostFeed(account: Account) -> String {
        return UserDefaults.interface.string(forKey: nameOfHomeTabPostFeedKeyBase + account.username, "")
    }
    static func setNameOfHomeTabPostFeed(account: Account, _ newValue: String?) {
        UserDefaults.interface.set(newValue, forKey: nameOfHomeTabPostFeedKeyBase + account.username)
    }
    
    static let defaultSearchResultTabKey = "default_search_result_tab"
    static var defaultSearchResultTab: Int {
        return UserDefaults.interface.integer(forKey: defaultSearchResultTabKey)
    }
    static let defaultSearchResultTabs: [Int] = [0, 1, 2]
    static let defaultSearchResultTabsText: [String] = ["Posts", "Subreddits", "Users"]
    
    static let lazyModeIntervalKey = "lazy_mode_interval"
    static var lazyModeInterval: Double {
        return UserDefaults.interface.double(forKey: lazyModeIntervalKey)
    }
    static let lazyModeIntervals: [Double] = [1, 2, 2.5, 3, 5, 7, 10]
    static let lazyModeIntervalsText: [String] = ["1s", "2s", "2.5s", "3s", "5s", "7s", "10s"]
    
    static let voteButtonsOnTheRightKey = "vote_buttons_on_the_right"
    static var voteButtonsOnTheRight: Bool {
        return UserDefaults.interface.bool(forKey: voteButtonsOnTheRightKey)
    }
    
    static let showAbsoluteNumberOfVotesKey = "show_absolute_number_of_votes"
    static var showAbsoluteNumberOfVotes: Bool {
        return UserDefaults.interface.bool(forKey: showAbsoluteNumberOfVotesKey, true)
    }
}
