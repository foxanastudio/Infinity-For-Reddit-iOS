//
// SortTypeSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct SortTypeSettingsView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @AppStorage(SortTypeSettingsUserDefaultsUtils.saveSortTypeKey, store: .sortTypeSettings) private var saveSortType: Bool = true
    @AppStorage(SortTypeSettingsUserDefaultsUtils.subredditDefaultSortTypeKey, store: .sortTypeSettings) private var subredditDefaultSortType: String = SortType.Kind.hot.rawValue
    @AppStorage(SortTypeSettingsUserDefaultsUtils.subredditDefaultSortTimeKey, store: .sortTypeSettings) private var subredditDefaultSortTime: String = SortType.Time.all.rawValue
    @AppStorage(SortTypeSettingsUserDefaultsUtils.userDefaultSortTypeKey, store: .sortTypeSettings) private var userDefaultSortType: String = SortType.Kind.new.rawValue
    @AppStorage(SortTypeSettingsUserDefaultsUtils.userDefaultSortTimeKey, store: .sortTypeSettings) private var userDefaultSortTime: String = SortType.Time.all.rawValue
    @AppStorage(SortTypeSettingsUserDefaultsUtils.respectSubredditRecommendedCommentSortTypeKey, store: .sortTypeSettings) private var respectSubredditRecommendedCommentSortType: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                TogglePreference(isEnabled: $saveSortType, title: "Save Sort Type")
                
                GenericPickerPreference(
                    selected: $subredditDefaultSortType,
                    items: SortTypeSettingsUserDefaultsUtils.subredditSortTypes,
                    title: "Subreddit Default Sort Type"
                )
                
                GenericPickerPreference(
                    selected: $subredditDefaultSortTime,
                    items: SortTypeSettingsUserDefaultsUtils.sortTimes,
                    title: "Subreddit Default Sort Time"
                )
                
                GenericPickerPreference(
                    selected: $userDefaultSortType,
                    items: SortTypeSettingsUserDefaultsUtils.userSortTypes,
                    title: "User Default Sort Type"
                )
                
                GenericPickerPreference(
                    selected: $userDefaultSortTime,
                    items: SortTypeSettingsUserDefaultsUtils.sortTimes,
                    title: "User Default Sort Time"
                )
                
                TogglePreference(isEnabled: $respectSubredditRecommendedCommentSortType,
                                 title: "Respect Subreddit Recommended Comment Sort Type",
                                 subtitle: "Comment sort type will not be saved"
                )
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Sort Type")
    }
}
