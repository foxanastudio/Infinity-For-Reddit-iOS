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
        List {
            PreferenceEntryWithBackground(title: "Notification", icon: "bell", top: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.notification)
                }
            
            PreferenceEntryWithBackground(title: "Interface", icon: "display")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.interface)
                }
            
            PreferenceEntryWithBackground(title: "Theme", icon: "paintpalette")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.theme)
                }
            
            PreferenceEntryWithBackground(title: "Video", icon: "video")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.video)
                }
            
            PreferenceEntryWithBackground(title: "Gestures & Buttons", icon: "hand.point.up.left", bottom: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.gesturesAndButtons)
                }
            
            PreferenceEntryWithBackground(title: "Security", icon: "lock.shield", top: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.security)
                }
            
            PreferenceEntryWithBackground(title: "Data Saving Mode", icon: "dollarsign.bank.building")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.dataSavingMode)
                }
            
            PreferenceEntryWithBackground(title: "Proxy", icon: "arrow.trianglehead.branch", bottom: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.proxy)
                }
            
            PreferenceEntryWithBackground(title: "Post History", icon: "clock", top: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postHistory)
                }
            
            PreferenceEntryWithBackground(title: "Content Sensitivity Filter", icon: "figure.child.and.lock")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.contentSensitivityFilter)
                }
            
            PreferenceEntryWithBackground(title: "Post Filter", icon: "line.3.horizontal.decrease.circle")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postFilter)
                }
            
            PreferenceEntryWithBackground(title: "Comment Filter", icon: "line.3.horizontal.decrease.circle", bottom: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.commentFilter)
                }
            
            PreferenceEntryWithBackground(title: "Sort Type", icon: "arrow.up.arrow.down.circle", top: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.sortType)
                }
            
            PreferenceEntryWithBackground(title: "Download Location", icon: "square.and.arrow.down")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.downloadLocation)
                }
            
            PreferenceEntryWithBackground(title: "Miscellaneous", icon: "gearshape.2")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.miscellaneous)
                }
            
            PreferenceEntryWithBackground(title: "Advanced", icon: "wrench.and.screwdriver", bottom: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.advanced)
                }
            
            PreferenceEntryWithBackground(title: "Manage Subscription", icon: "crown", top: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.manageSubscription)
                }
            
            PreferenceEntryWithBackground(title: "About", icon: "questionmark.circle")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.about)
                }
            
            PreferenceEntryWithBackground(title: "Privacy Policy", icon: "hand.raised.circle")
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.privacyPolicy)
                }
            
            PreferenceEntryWithBackground(title: "Reddit User Agreement", icon: "text.document", bottom: true)
                .listPlainItemNoInsets()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.redditUserAgreement)
                }
                .padding(.bottom, 16)
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Settings")
    }
}
