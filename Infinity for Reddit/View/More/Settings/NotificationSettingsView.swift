//
// NotificationSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import Foundation
import SwiftUI
import Swinject
import GRDB

struct NotificationSettingsView: View {
    @AppStorage(NotificationUserDefaultsUtils.enableNotificationKey, store: .notification) private var enableNotification: Bool = true
    @AppStorage(NotificationUserDefaultsUtils.notificationIntervalKey, store: .notification) private var notificationInterval: Int = 60
    
    private let notificationSettingsViewModel = NotificationSettingsViewModel()
    
    var body: some View {
        List {
            TogglePreference(isEnabled: $enableNotification, title: "Enable Notification")
                .listPlainItemNoInsets()
            
            if enableNotification {
                BarebonePickerPreference(
                    selected: $notificationInterval,
                    items: NotificationUserDefaultsUtils.notificationIntervalOptions,
                    title: "Check Notification Interval"
                ) { interval in
                    NotificationUserDefaultsUtils.notificationIntervalOptionsText[NotificationUserDefaultsUtils.notificationIntervalOptions.firstIndex(of: interval) ?? 2]
                }
                .listPlainItemNoInsets()
                .animation(.easeInOut, value: enableNotification)
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Notification")
        .onChange(of: enableNotification) { _, newValue in
            notificationSettingsViewModel.enableNotification(enable: newValue)
        }
        .onChange(of: notificationInterval) { _, newValue in
            notificationSettingsViewModel.updateNotificationInterval()
        }
    }
}

