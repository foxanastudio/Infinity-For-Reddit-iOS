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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey, store: .contentSensitivityFilter) private var sensitiveContent: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.doNotBlurSensitiveImagesInSensitiveSubredditsKey, store: .contentSensitivityFilter) private var doNotBlurSensitiveImagesInSensitiveSubreddits: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.spoilerContentKey, store: .contentSensitivityFilter) private var spoilerContent: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.disableSensitiveContentForeverKey, store: .contentSensitivityFilter) private var disableSensitiveContentForever: Bool = false
    
    var body: some View {
        List {
            TogglePreference(isEnabled: $sensitiveContent, title: "Sensitive Content", icon: "figure.child.and.lock")
                .listPlainItemNoInsets()
            
            TogglePreference(isEnabled: $blurSensitiveImages, title: "Blur Sensitive Images")
                .listPlainItemNoInsets()
            
            TogglePreference(isEnabled: $doNotBlurSensitiveImagesInSensitiveSubreddits, title: "Don't Blur Senstive Images in Sensitive Subreddits")
                .listPlainItemNoInsets()
            
            TogglePreference(isEnabled: $spoilerContent, title: "Spoiler Content")
                .listPlainItemNoInsets()
            
            TogglePreference(isEnabled: $blurSpoilerImages, title: "Blur Spoiler Images")
                .listPlainItemNoInsets()
            
            TogglePreference(isEnabled: $disableSensitiveContentForever, title: "Disable Sensitive Content Forever")
                .listPlainItemNoInsets()
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Content Sensitivity Filter")
    }
}
