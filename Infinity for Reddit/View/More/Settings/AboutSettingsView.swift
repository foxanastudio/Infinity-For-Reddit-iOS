//
// AboutSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct AboutSettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    PreferenceEntry(
                        title: "Acknowledgement"
                    ) {
                        navigationManager.append(AboutSettingsViewNavigation.acknowledgement)
                    }
                    
                    PreferenceEntry(
                        title: "Credits"
                    ) {
                        navigationManager.append(AboutSettingsViewNavigation.credits)
                    }
                    
                    PreferenceEntry(
                        title: "Open Source",
                        subtitle: "Star it on Github if you like this app"
                    ) {
                        
                    }
                    
                    PreferenceEntry(
                        title: "Rate on App Store",
                        subtitle: "Give us a 5-star rating and we will be really happy"
                    ) {
                        
                    }
                    
                    PreferenceEntry(
                        title: "Email",
                        subtitle: "support@foxanastudio.com"
                    ) {
                        if let url = URL(string: "mailto:support@foxanastudio.com") {
                            UIApplication.shared.open(url)
                        }
                    }
                    
                    PreferenceEntry(
                        title: "Developer Reddit Account",
                        subtitle: "u/Hostilenemy"
                    ) {
                        navigationManager.append(AppNavigation.userDetails(username: "Hostilenemy"))
                    }
                    
                    PreferenceEntry(
                        title: "Subreddit",
                        subtitle: "r/Infinity_For_Reddit"
                    ) {
                        navigationManager.append(AppNavigation.subredditDetails(subredditName: "Infinity_For_Reddit"))
                    }
                    
                    ShareLink(
                        item: "Check out Infinity for Reddit for iOS, an awesome Reddit client!\nhttps://github.com/Docile-Alligator/Infinity-For-Reddit-iOS"
                    ) {
                        PreferenceEntry(
                            title: "Share",
                            subtitle: "Share this app to other people if you enjoy it"
                        ) { }
                    }
                    
                    PreferenceEntry(
                        title: "Infinity For Reddit",
                        subtitle: "Version \(Bundle.main.appVersion)"
                    ) { }
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("About")
    }
}
