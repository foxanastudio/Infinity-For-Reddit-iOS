//
// AboutSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct AboutSettingsView: View {
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    PreferenceEntry(title: "Acknowledgement") {
                        
                    }
                    PreferenceEntry(title: "Credits") {
                        
                    }
                    PreferenceEntry(title: "Translation") {
                        
                    }
                    PreferenceEntry(title: "Open Source") {
                        
                    }
                    PreferenceEntry(title: "Rate on App Store") {
                        
                    }
                    PreferenceEntry(title: "Email") {
                        
                    }
                    PreferenceEntry(title: "Reddit Account") {
                        
                    }
                    PreferenceEntry(title: "Subreddit") {
                        
                    }
                    PreferenceEntry(title: "Share") {
                        
                    }
                    PreferenceEntry(title: "Infinity For Reddit") {
                        
                    }
                }
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("About")
    }
}
