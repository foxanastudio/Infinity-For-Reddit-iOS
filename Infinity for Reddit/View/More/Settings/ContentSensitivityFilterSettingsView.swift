//
// ContentSensitivityFilterSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct ContentSensitivityFilterSettingsView: View {
    @EnvironmentObject private var accountViewModel: AccountViewModel
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var snackbarManager: SnackbarManager

    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = true
    //@AppStorage(ContentSensitivityFilterUserDetailsUtils.doNotBlurSensitiveImagesInSensitiveSubredditsKey, store: .contentSensitivityFilter) private var doNotBlurSensitiveImagesInSensitiveSubreddits: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.spoilerContentKey, store: .contentSensitivityFilter) private var spoilerContent: Bool = true
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.disableSensitiveContentForeverKey, store: .contentSensitivityFilter) private var disableSensitiveContentForever: Bool = false
    
    @State private var activeAlert: ActiveAlert?
    
    var body: some View {
        RootView {
            List {
                if !accountViewModel.account.isAnonymous() && !disableSensitiveContentForever {
                    PreferenceEntry(title: "Reddit Settings") {
                        navigationManager.openLink("https://www.reddit.com/settings/preferences")
                    }
                    .listPlainItemNoInsets()
                    
                    TogglePreference(isEnabled: $blurSensitiveImages, title: "Blur Sensitive Images")
                        .listPlainItemNoInsets()
                    
//                    TogglePreference(isEnabled: $doNotBlurSensitiveImagesInSensitiveSubreddits, title: "Don't Blur Senstive Images in Sensitive Subreddits")
//                        .listPlainItemNoInsets()
                }
                
                TogglePreference(isEnabled: $spoilerContent, title: "Spoiler Content")
                    .listPlainItemNoInsets()
                
                if spoilerContent {
                    TogglePreference(isEnabled: $blurSpoilerImages, title: "Blur Spoiler Images")
                        .listPlainItemNoInsets()
                }
                
//                if !accountViewModel.account.isAnonymous() || disableSensitiveContentForever {
//                    CustomDivider()
//                        .listPlainItemNoInsets()
//                    
//                    CustomListSection("Dangerous Action") {
//                        TogglePreference(isEnabled: $disableSensitiveContentForever, title: "Disable Sensitive Content Forever")
//                            .listPlainItemNoInsets()
//                            .disabled(disableSensitiveContentForever)
//                    }
//                    .listPlainItemNoInsets()
//                }
            }
            .animation(.easeInOut, value: spoilerContent)
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Content Sensitivity Filter")
        .task {
            guard !accountViewModel.account.isAnonymous() else {
                return
            }
            
            if await accountViewModel.setSensitiveContentFromRedditSettings() {
                snackbarManager.showSnackbar(.info("Content preferences synced."))
            } else {
                snackbarManager.showSnackbar(.info("Failed to sync content preferences."))
            }
        }
        .appForegroundBackgroundListener(onAppEntersForeground: {
            guard !accountViewModel.account.isAnonymous() else {
                return
            }
            
            Task {
                if await accountViewModel.setSensitiveContentFromRedditSettings() {
                    snackbarManager.showSnackbar(.info("Content preferences synced."))
                } else {
                    snackbarManager.showSnackbar(.info("Failed to sync content preferences."))
                }
            }
        })
        .onChange(of: disableSensitiveContentForever) { _, newValue in
            if newValue {
                withAnimation {
                    activeAlert = .disableSensitiveForever
                }
            }
        }
        .overlay(
            CustomAlert(title: activeAlert?.title ?? "", confirmButtonText: "Confirm", isPresented: Binding(
                get: { activeAlert != nil },
                set: { newValue in
                    if !newValue {
                        activeAlert = nil
                    }
                }
            )) {
                switch activeAlert {
                case .disableSensitiveForever:
                    Text("Once enabled, sensitive content will always be hidden, regardless of the sensitive content setting. This option is irreversible; the only way to re-enable the sensitive content is to clear the app data.\n\nDo you still want to enable it?")
                case nil:
                    EmptyView()
                }
            } onDismiss: {
                disableSensitiveContentForever = false
            } onConfirm: {
                disableSensitiveContentForever = true
            }
        )
    }
    
    private enum ActiveAlert: Identifiable {
        case disableSensitiveForever

        var id: Int {
            hashValue
        }
        
        var title: String {
            switch self {
            case .disableSensitiveForever: return "Warning"
            }
        }
    }
}
