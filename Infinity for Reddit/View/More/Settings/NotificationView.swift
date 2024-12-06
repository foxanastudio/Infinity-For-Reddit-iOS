//
// NotificationView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import Foundation
import SwiftUI
import Swinject
import GRDB

struct NotificationView: View {
    @Environment(\.dependencyManager) private var container: Container
    @State private var enableNotifications: Bool
    @State private var checkNotificationsInterval: Int
    private let notificationsIntervals: [String] = ["15 minutes", "30 minutes", "1 hour", "2 hours", "3 hours", "4 hours", "6 hours", "12 hours", "1 day"]
    private let userDefaults: UserDefaults

    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        if userDefaults.object(forKey: "ENABLE_NOTIFICATION_KEY") == nil {
            userDefaults.set(true, forKey: "ENABLE_NOTIFICATION_KEY")
            }
        if userDefaults.object(forKey: "NOTIFICATION_INTERVAL_KEY") == nil {
            userDefaults.set(2, forKey: "NOTIFICATION_INTERVAL_KEY")
        }

        _enableNotifications = State(initialValue: userDefaults.bool(forKey: "ENABLE_NOTIFICATION_KEY"))
        _checkNotificationsInterval = State(initialValue: userDefaults.integer(forKey: "NOTIFICATION_INTERVAL_KEY"))
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Notifications", systemImage: "bell.fill", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) { _, newValue in
                            userDefaults.set(newValue, forKey: "ENABLE_NOTIFICATION_KEY")
                        }
                    
                    Picker("Check Notifications Interval", systemImage: "clock.fill", selection: $checkNotificationsInterval) {
                        ForEach(0..<notificationsIntervals.count, id: \.self) { index in
                            Text(notificationsIntervals[index]).tag(index)
                            }
                    }
                    .onChange(of: checkNotificationsInterval) { _, newValue in
                        userDefaults.set(newValue, forKey: "NOTIFICATION_INTERVAL_KEY")
                    }
                }
            }
            .navigationTitle("Notification")
        }
    }
}

