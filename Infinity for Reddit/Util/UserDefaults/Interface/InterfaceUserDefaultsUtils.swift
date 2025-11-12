//
//  InterfaceUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-11.
//

import Foundation

class InterfaceUserDefaultsUtils {
    static let defaultSearchResultTabKey = "default_search_result_tab"
    static var defaultSearchResultTab: Int {
        return UserDefaults.video.integer(forKey: defaultSearchResultTabKey)
    }
    static let defaultSearchResultTabs: [Int] = [0, 1, 2]
    static let defaultSearchResultTabsText: [String] = ["Posts", "Subreddits", "Users"]
    
    static let voteButtonsOnTheRightKey = "vote_buttons_on_the_right"
    static var voteButtonsOnTheRight: Bool {
        return UserDefaults.video.bool(forKey: voteButtonsOnTheRightKey)
    }
    
    static let showAbsoluteNumberOfVotesKey = "show_absolute_number_of_votes"
    static var showAbsoluteNumberOfVotes: Bool {
        return UserDefaults.video.bool(forKey: showAbsoluteNumberOfVotesKey, true)
    }
}
