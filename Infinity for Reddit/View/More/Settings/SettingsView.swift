//
// SettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct SettingsView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    var body: some View {
        List {
            NavigationLink(destination: NotificationSettingsView()) {
                Text("Notification")
            }
            NavigationLink(destination: InterfaceSettingsView()) {
                Text("Interface")
            }
            NavigationLink(destination: CustomThemeSettingsView()) {
                Text("Theme")
            }
            NavigationLink(destination: GestureButtonsSettingsView()) {
                Text("Gesture & Buttons")
            }
            NavigationLink(destination: VideoSettingsView()) {
                Text("Video")
            }
            NavigationLink(destination: LazyModeIntervalSettingsView()) {
                Text("Lazy Mode Interval")
            }
            NavigationLink(destination: DownloadLocationSettingsView()) {
                Text("Download Location")
            }
            NavigationLink(destination: SecuritySettingsView()) {
                Text("Security")
            }
            NavigationLink(destination: ContentSensitivityFilterSettingsView()) {
                Text("Content Sensitivity Filter")
            }
            NavigationLink(destination: PostHistorySettingsView()) {
                Text("Post History")
            }
            NavigationLink(destination: PostFilterSettingsView()) {
                Text("Post Filter")
            }
            NavigationLink(destination: CommentFilterSettingsView()) {
                Text("Comment Filter")
            }
            NavigationLink(destination: MiscellaneousSettingsView()) {
                Text("Miscellaneous")
            }
            NavigationLink(destination: AdvancedSettingsView()) {
                Text("Advanced")
            }
            NavigationLink(destination: ManageSubscriptionSettingsView()) {
                Text("Manage Subscription")
            }
            NavigationLink(destination: AboutSettingsView()) {
                Text("About")
            }
            NavigationLink(destination: PrivacyPolicySettingsView()) {
                Text("Privacy Policy")
            }
            NavigationLink(destination: RedditUserAgreementSettingsView()) {
                Text("Reddit User Agreement")
            }
        }
        .navigationTitle("Settings")
    }
}
