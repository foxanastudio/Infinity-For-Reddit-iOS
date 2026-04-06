//
//  InterfaceUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-11.
//

import Foundation

class InterfaceUserDefaultsUtils {
    static let homeTabPostFeedTypeKey = "home_tab_post_feed_type"
    static var homeTabPostFeedType: Int {
        return UserDefaults.interface.integer(forKey: homeTabPostFeedTypeKey)
    }
    static func setHomeTabPostFeedType(_ newValue: HomeTabPostFeedType) {
        UserDefaults.interface.set(newValue.rawValue, forKey: homeTabPostFeedTypeKey)
    }
    
    static let nameOfHomeTabPostFeedKey = "name_of_home_tab_post_feed"
    static var nameOfHomeTabPostFeed: String {
        return UserDefaults.interface.string(forKey: nameOfHomeTabPostFeedKey, "")
    }
    static func setNameOfHomeTabPostFeed(_ newValue: String?) {
        UserDefaults.interface.set(newValue, forKey: nameOfHomeTabPostFeedKey)
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
