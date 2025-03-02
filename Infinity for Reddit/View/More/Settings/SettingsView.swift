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
    @State private var selectedItem: Int? = nil
    
    var body: some View {
        List {
            CustomNavigationLink("Notification", destination: NotificationSettingsView())
                .listPlainItem()

            CustomNavigationLink("Interface", destination: InterfaceSettingsView())
                .listPlainItem()

            CustomNavigationLink("Theme", destination: CustomThemeSettingsView())
                .listPlainItem()

            CustomNavigationLink("Gesture & Buttons", destination: GestureButtonsSettingsView())
                .listPlainItem()

            CustomNavigationLink("Video", destination: VideoSettingsView())
                .listPlainItem()

            CustomNavigationLink("Lazy Mode Interval", destination: LazyModeIntervalSettingsView())
                .listPlainItem()

            CustomNavigationLink("Download Location", destination: DownloadLocationSettingsView())
                .listPlainItem()

            CustomNavigationLink("Security", destination: SecuritySettingsView())
                .listPlainItem()

            CustomNavigationLink("Content Sensitivity Filter", destination: ContentSensitivityFilterSettingsView())
                .listPlainItem()

            CustomNavigationLink("Post History", destination: PostHistorySettingsView())
                .listPlainItem()

            CustomNavigationLink("Post Filter", destination: PostFilterSettingsView())
                .listPlainItem()

            CustomNavigationLink("Comment Filter", destination: CommentFilterSettingsView())
                .listPlainItem()

            CustomNavigationLink("Miscellaneous", destination: MiscellaneousSettingsView())
                .listPlainItem()

            CustomNavigationLink("Advanced", destination: AdvancedSettingsView())
                .listPlainItem()

            CustomNavigationLink("Manage Subscription", destination: ManageSubscriptionSettingsView())
                .listPlainItem()

            CustomNavigationLink("About", destination: AboutSettingsView())
                .listPlainItem()

            CustomNavigationLink("Privacy Policy", destination: PrivacyPolicySettingsView())
                .listPlainItem()

            CustomNavigationLink("Reddit User Agreement", destination: RedditUserAgreementSettingsView())
                .listPlainItem()
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Settings")
    }
}
