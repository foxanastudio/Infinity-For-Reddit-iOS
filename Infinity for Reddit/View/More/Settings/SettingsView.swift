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
            NavigationLink(destination: NotificationView()) {
                Text("Notification")
            }
            NavigationLink(destination: InterfaceView()) {
                Text("Interface")
            }
            NavigationLink(destination: ThemeView()) {
                Text("Theme")
            }
            NavigationLink(destination: GestureButtonsView()) {
                Text("Gesture & Buttons")
            }
            NavigationLink(destination: VideoView()) {
                Text("Video")
            }
            NavigationLink(destination: LazyModeIntervalView()) {
                Text("Lazy Mode Interval")
            }
            NavigationLink(destination: DownloadLocationView()) {
                Text("Download Location")
            }
            NavigationLink(destination: SecurityView()) {
                Text("Security")
            }
            NavigationLink(destination: ContentSensitivityFilterView()) {
                Text("Content Sensitivity Filter")
            }
            NavigationLink(destination: PostHistoryView()) {
                Text("Post History")
            }
            NavigationLink(destination: PostFilterView()) {
                Text("Post Filter")
            }
            NavigationLink(destination: CommentFilterView()) {
                Text("Comment Filter")
            }
            NavigationLink(destination: MiscellaneousView()) {
                Text("Miscellaneous")
            }
            NavigationLink(destination: AdvancedView()) {
                Text("Advanced")
            }
            NavigationLink(destination: ManageSubscriptionView()) {
                Text("Manage Subscription")
            }
            NavigationLink(destination: AboutView()) {
                Text("About")
            }
            NavigationLink(destination: PrivacyPolicyView()) {
                Text("Privacy Policy")
            }
            NavigationLink(destination: RedditUserAgreementView()) {
                Text("Reddit User Agreement")
            }
        }
        .navigationTitle("Settings")
    }
}
