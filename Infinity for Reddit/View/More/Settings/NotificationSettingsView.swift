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
    @StateObject private var notificationSettingsViewModel = NotificationSettingsViewModel()

    var body: some View {
        Form {
            Section {
                Toggle("Enable Notifications", systemImage: "bell.fill", isOn: $notificationSettingsViewModel.enableNotifications)
                
                Picker("Check Notifications Interval", systemImage: "clock.fill", selection: $notificationSettingsViewModel.checkNotificationsInterval) {
                    ForEach(0..<notificationSettingsViewModel.notificationsIntervals.count, id: \.self) { index in
                        Text(notificationSettingsViewModel.notificationsIntervals[index]).tag(index)
                        }
                }
            }
        }
        .navigationTitle("Notification")
    }
}

