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
            RowText("Notification")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.notification)
                    //navigationManager.path.append(AppNavigation.userDetails(username: "Hostilenemy"))
                }
            
            RowText("Interface")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.interface)
                }
            
            RowText("Theme")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.theme)
                }
            
            RowText("Gesture & Buttons")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.gestureAndButtons)
                }
            
            RowText("Video")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.video)
                }
            
            RowText("Lazy Mode Interval")
                .primaryText()
                .listPlainItem()
            
            RowText("Download Location")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.downloadLocation)
                }
            
            RowText("Security")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.security)
                }
            
            RowText("Content Sensitivity Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.contentSensitivityFilter)
                }
            
            RowText("Post History")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postHistory)
                }
            
            RowText("Post Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.postFilter)
                }
            
            RowText("Comment Filter")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.commentFilter)
                }
            
            RowText("Miscellaneous")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.miscellaneous)
                }
            
            RowText("Advanced")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.advanced)
                }
            
            RowText("Manage Subscription")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.manageSubscription)
                }
            
            RowText("About")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.about)
                }
            
            RowText("Privacy Policy")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.privacyPolicy)
                }
            
            RowText("Reddit User Agreement")
                .primaryText()
                .listPlainItem()
                .onTapGesture {
                    navigationManager.path.append(SettingsViewNavigation.redditUserAgreement)
                }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Settings", 1.0)
    }
}
