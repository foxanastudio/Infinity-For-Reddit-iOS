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
            Text("Notification")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.notification)
                    //navigationManager.path.append(AppNavigation.userDetails(username: "Hostilenemy"))
                }
            
            Text("Interface")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.interface)
                }
            
            Text("Theme")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.theme)
                }
            
            Text("Gesture & Buttons")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.gestureAndButtons)
                }
            
            Text("Video")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.video)
                }
            
            Text("Lazy Mode Interval")
                .primaryText()
                .listPlainItem()
            
            Text("Download Location")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.downloadLocation)
                }
            
            Text("Security")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.security)
                }
            
            Text("Content Sensitivity Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.contentSensitivityFilter)
                }
            
            Text("Post History")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postHistory)
                }
            
            Text("Post Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postFilter)
                }
            
            Text("Comment Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.commentFilter)
                }
            
            Text("Miscellaneous")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.miscellaneous)
                }
            
            Text("Advanced")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.advanced)
                }
            
            Text("Manage Subscription")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.manageSubscription)
                }
            
            Text("About")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.about)
                }
            
            Text("Privacy Policy")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.privacyPolicy)
                }
            
            Text("Reddit User Agreement")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.redditUserAgreement)
                }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Settings")
    }
}
