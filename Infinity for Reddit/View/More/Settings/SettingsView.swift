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
    @EnvironmentObject var navigationManager: NavigationManager
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @State private var selectedItem: Int? = nil
    
    var body: some View {
        RootView {
            List {
                PreferenceEntryWithBackground(title: "Notification", icon: "bell", top: true) {
                    navigationManager.append(SettingsViewNavigation.notification)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Interface", icon: "display") {
                    navigationManager.append(SettingsViewNavigation.interface)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Theme", icon: "paintpalette") {
                    navigationManager.append(SettingsViewNavigation.theme)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Video", icon: "video") {
                    navigationManager.append(SettingsViewNavigation.video)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Gestures & Buttons", icon: "hand.point.up.left", bottom: true) {
                    navigationManager.append(SettingsViewNavigation.gesturesAndButtons)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Security", icon: "lock.shield", top: true) {
                    navigationManager.append(SettingsViewNavigation.security)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Data Saving Mode", icon: "dollarsign.bank.building") {
                    navigationManager.append(SettingsViewNavigation.dataSavingMode)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Proxy", icon: "arrow.trianglehead.branch", bottom: true) {
                    navigationManager.append(SettingsViewNavigation.proxy)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Post History", icon: "clock", top: true) {
                    navigationManager.append(SettingsViewNavigation.postHistory)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Content Sensitivity Filter", icon: "figure.child.and.lock") {
                    navigationManager.append(SettingsViewNavigation.contentSensitivityFilter)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Post Filter", icon: "line.3.horizontal.decrease.circle") {
                    navigationManager.append(SettingsViewNavigation.postFilter())
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Comment Filter", icon: "line.3.horizontal.decrease.circle", bottom: true) {
                    navigationManager.append(SettingsViewNavigation.commentFilter())
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Sort Type", icon: "arrow.up.arrow.down.circle", top: true) {
                    navigationManager.append(SettingsViewNavigation.sortType)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Miscellaneous", icon: "gearshape.2") {
                    navigationManager.append(SettingsViewNavigation.miscellaneous)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Advanced", icon: "wrench.and.screwdriver", bottom: true) {
                    navigationManager.append(SettingsViewNavigation.advanced)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Manage Subscription", icon: "crown", top: true) {
                    navigationManager.append(SettingsViewNavigation.manageSubscription)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "About", icon: "questionmark.circle") {
                    navigationManager.append(SettingsViewNavigation.about)
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Privacy Policy", icon: "hand.raised.circle") {
                    navigationManager.openLink("https://docile-alligator.github.io/")
                }
                .listPlainItemNoInsets()
                
                PreferenceEntryWithBackground(title: "Reddit User Agreement", icon: "text.document", bottom: true) {
                    navigationManager.openLink("https://www.redditinc.com/policies/user-agreement")
                }
                .listPlainItemNoInsets()
                .padding(.bottom, 16)
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Settings")
    }
}
