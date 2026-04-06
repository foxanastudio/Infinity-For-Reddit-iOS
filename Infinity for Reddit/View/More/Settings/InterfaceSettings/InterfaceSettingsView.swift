//
// InterfaceSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct InterfaceSettingsView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @AppStorage(InterfaceUserDefaultsUtils.homeTabPostFeedTypeKey, store: .interface) private var homeTabPostFeedType: Int = HomeTabPostFeedType.frontPage.rawValue
    @AppStorage(InterfaceUserDefaultsUtils.nameOfHomeTabPostFeedKey, store: .interface) private var nameOfHomeTabPostFeed: String = ""
    @AppStorage(InterfaceUserDefaultsUtils.defaultSearchResultTabKey, store: .interface) private var defaultSearchResultTab: Int = 0
    @AppStorage(InterfaceUserDefaultsUtils.voteButtonsOnTheRightKey, store: .interface) private var voteButtonsOnTheRight: Bool = false
    @AppStorage(InterfaceUserDefaultsUtils.lazyModeIntervalKey, store: .interface) private var lazyModeInterval: Double = 2.5
    @AppStorage(InterfaceUserDefaultsUtils.showAbsoluteNumberOfVotesKey, store: .interface) private var showAbsoluteNumberOfVotes: Bool = true
    
    @State private var showHomeTabPostFeedSelectionSheet: Bool = false
    
    var body: some View {
        RootView {
            List {
                PreferenceEntry(
                    title: "Font",
                    icon: "textformat.size"
                ) {
                    navigationManager.append(InterfaceSettingsViewNavigation.font)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntry(
                    title: "Home Tab Post Feed",
                    subtitle: homeTabPostFeed,
                    icon: "house"
                ) {
                    showHomeTabPostFeedSelectionSheet = true
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $defaultSearchResultTab,
                    items: InterfaceUserDefaultsUtils.defaultSearchResultTabs,
                    title: "Default Search Result Tab",
                    icon: "magnifyingglass"
                ) { tab in
                    if InterfaceUserDefaultsUtils.defaultSearchResultTabsText.indices.contains(tab) {
                        InterfaceUserDefaultsUtils.defaultSearchResultTabsText[tab]
                    } else {
                        InterfaceUserDefaultsUtils.defaultSearchResultTabsText[0]
                    }
                }
                .listPlainItemNoInsets()
                
                PreferenceEntry(
                    title: "Time Format",
                    icon: "clock"
                ) {
                    navigationManager.append(InterfaceSettingsViewNavigation.timeFormat)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntry(
                    title: "Post"
                ) {
                    navigationManager.append(InterfaceSettingsViewNavigation.post)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntry(
                    title: "Post Details"
                ) {
                    navigationManager.append(InterfaceSettingsViewNavigation.postDetails)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntry(
                    title: "Comment",
                    icon: "text.bubble"
                ) {
                    navigationManager.append(InterfaceSettingsViewNavigation.comment)
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $lazyModeInterval,
                    items: InterfaceUserDefaultsUtils.lazyModeIntervals,
                    title: "Lazy Mode Interval",
                    icon: "magnifyingglass"
                ) { interval in
                    if let index = InterfaceUserDefaultsUtils.lazyModeIntervals.firstIndex(of: interval) {
                        if InterfaceUserDefaultsUtils.lazyModeIntervals.indices.contains(index) {
                            InterfaceUserDefaultsUtils.lazyModeIntervalsText[index]
                        } else {
                            InterfaceUserDefaultsUtils.lazyModeIntervalsText[2]
                        }
                    } else {
                        InterfaceUserDefaultsUtils.lazyModeIntervalsText[2]
                    }
                }
                .listPlainItemNoInsets()
                
                CustomListSection("Post and Comment") {
                    TogglePreference(isEnabled: $voteButtonsOnTheRight, title: "Vote Buttons on the Right")
                        .listPlainItemNoInsets()
                    
                    TogglePreference(isEnabled: $showAbsoluteNumberOfVotes, title: "Show Absolute Number of Votes")
                        .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Interface")
        .wrapContentSheet(isPresented: $showHomeTabPostFeedSelectionSheet) {
            HomeTabPostFeedSelectionSheet { homeTabPostFeedType, nameOfHomeTabPostFeed in
                InterfaceUserDefaultsUtils.setHomeTabPostFeedType(homeTabPostFeedType)
                InterfaceUserDefaultsUtils.setNameOfHomeTabPostFeed(nameOfHomeTabPostFeed)
            }
        }
    }
    
    var homeTabPostFeed: String {
        switch homeTabPostFeedType {
        case HomeTabPostFeedType.subreddit.rawValue:
            if !nameOfHomeTabPostFeed.isEmpty {
                if nameOfHomeTabPostFeed == "popular" || nameOfHomeTabPostFeed == "all" {
                    return nameOfHomeTabPostFeed.capitalizedFirst
                }
                
                return "r/\(nameOfHomeTabPostFeed)"
            }
            return HomeTabPostFeedType.frontPage.description
        case HomeTabPostFeedType.user.rawValue:
            if !nameOfHomeTabPostFeed.isEmpty {
                return "u/\(nameOfHomeTabPostFeed)"
            }
            return HomeTabPostFeedType.frontPage.description
        case HomeTabPostFeedType.customFeed.rawValue:
            if !nameOfHomeTabPostFeed.isEmpty {
                return "Custom feed: \(nameOfHomeTabPostFeed)"
            }
            return HomeTabPostFeedType.frontPage.description
        default:
            return HomeTabPostFeedType.frontPage.description
        }
    }
}
