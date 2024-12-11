//
// InterfaceView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct InterfaceView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @State private var hideFABInPostFeed: Bool
    @State private var enableBottomNavigation: Bool
    @State private var hideSubredditDescription: Bool
    @State private var useBottomToolbarInMediaViewer: Bool
    @State private var voteButtonsOnTheRight: Bool
    @State private var showAbsoluteNumberOfVotes: Bool
    @State private var defaultSearchResultTab: Int
    
    let HIDE_FAB_IN_POST_FEED = UserDefaultsUtils.HIDE_FAB_IN_POST_FEED
    let BOTTOM_APP_BAR_KEY = UserDefaultsUtils.BOTTOM_APP_BAR_KEY
    let HIDE_SUBREDDIT_DESCRIPTION = UserDefaultsUtils.HIDE_SUBREDDIT_DESCRIPTION
    let USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER = UserDefaultsUtils.USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER
    let VOTE_BUTTONS_ON_THE_RIGHT_KEY = UserDefaultsUtils.VOTE_BUTTONS_ON_THE_RIGHT_KEY
    let SHOW_ABSOLUTE_NUMBER_OF_VOTES = UserDefaultsUtils.SHOW_ABSOLUTE_NUMBER_OF_VOTES
    let DEFAULT_SEARCH_RESULT_TAB = UserDefaultsUtils.DEFAULT_SEARCH_RESULT_TAB
    
    private let searchResultTabs: [String] = ["Posts", "Subreddits", "Users"]
    private let userDefaults: UserDefaults
    
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
        _hideFABInPostFeed = State(initialValue: userDefaults.bool(forKey: HIDE_FAB_IN_POST_FEED))
        _enableBottomNavigation = State(initialValue: userDefaults.bool(forKey: BOTTOM_APP_BAR_KEY))
        _hideSubredditDescription = State(initialValue: userDefaults.bool(forKey: HIDE_SUBREDDIT_DESCRIPTION))
        _useBottomToolbarInMediaViewer = State(initialValue: userDefaults.bool(forKey: USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER))
        _voteButtonsOnTheRight = State(initialValue: userDefaults.bool(forKey: VOTE_BUTTONS_ON_THE_RIGHT_KEY))
        _showAbsoluteNumberOfVotes = State(initialValue: userDefaults.bool(forKey: SHOW_ABSOLUTE_NUMBER_OF_VOTES))
        _defaultSearchResultTab = State(initialValue: userDefaults.integer(forKey: DEFAULT_SEARCH_RESULT_TAB))
    }
    
    var body: some View {
        List {
            NavigationLink(destination: FontView()) {
                Label("Font", systemImage: "textformat.size")
            }
            NavigationLink(destination: ImmersiveInterfaceView()) {
                Text("Immersive Interface").padding(.leading, 44.5)
            }
            NavigationLink(destination: NavigationDrawerView()) {
                Text("Navigation Drawer").padding(.leading, 44.5)
            }
            Toggle("Hide FAB in Post Feed", isOn: $hideFABInPostFeed).padding(.leading, 44.5).onChange(of: hideFABInPostFeed){
                _, newValue in userDefaults.set(newValue, forKey: HIDE_FAB_IN_POST_FEED)
            }
            Toggle("Enable Bottom Navigation", isOn: $enableBottomNavigation).padding(.leading, 44.5).onChange(of: enableBottomNavigation){
                _, newValue in userDefaults.set(newValue, forKey: BOTTOM_APP_BAR_KEY)
            }
            Toggle("Hide Subreddit Description", isOn: $hideSubredditDescription).padding(.leading, 44.5).onChange(of: hideSubredditDescription){
                _, newValue in userDefaults.set(newValue, forKey: HIDE_SUBREDDIT_DESCRIPTION)
            }
            Toggle("Use Bottom Toolbar in Media Viewer", isOn: $useBottomToolbarInMediaViewer).padding(.leading, 44.5).onChange(of: useBottomToolbarInMediaViewer){
                _, newValue in userDefaults.set(newValue, forKey: USE_BOTTOM_TOOLBAR_IN_MEDIA_VIEWER)
            }
            Picker("Default Search Result Tab", selection: $defaultSearchResultTab){
                ForEach(0..<searchResultTabs.count, id: \.self) { index in
                    Text(searchResultTabs[index]).tag(index)
                }
            }
            .padding(.leading, 44.5)
            .onChange(of: defaultSearchResultTab) { _, newValue in
                userDefaults.set(newValue, forKey: DEFAULT_SEARCH_RESULT_TAB)
            }
            NavigationLink(destination: TimeFormatView()) {
                Text("Time Format").padding(.leading, 44.5)
            }
            NavigationLink(destination: PostView()) {
                Text("Post").padding(.leading, 44.5)
            }
            NavigationLink(destination: InterfaceView()) {
                Text("Post Details").padding(.leading, 44.5)
            }
            NavigationLink(destination: InterfaceView()) {
                Text("Comment").padding(.leading, 44.5)
            }
            
            Section(header: Text("Post and Comment")){
                Toggle("Vote Buttons on the Right", isOn: $voteButtonsOnTheRight).padding(.leading, 44.5).onChange(of: voteButtonsOnTheRight){
                    _, newValue in userDefaults.set(newValue, forKey: VOTE_BUTTONS_ON_THE_RIGHT_KEY)
                }
                Toggle("Show Absolute Number of Votes", isOn: $showAbsoluteNumberOfVotes).padding(.leading, 44.5).onChange(of: showAbsoluteNumberOfVotes){
                    _, newValue in userDefaults.set(newValue, forKey: SHOW_ABSOLUTE_NUMBER_OF_VOTES)
                }
                
            }
        }
        .navigationTitle("Interface")
    }
}


