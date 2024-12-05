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
    private let userDefaults: UserDefaults

    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        if userDefaults.object(forKey: "enableNotifications") == nil {
            userDefaults.set(true, forKey: "enableNotifications")
            }
        if userDefaults.object(forKey: "checkNotificationsInterval") == nil {
            userDefaults.set(60, forKey: "checkNotificationsInterval")
        }

        _enableNotifications = State(initialValue: userDefaults.bool(forKey: "enableNotifications"))
        _checkNotificationsInterval = State(initialValue: userDefaults.integer(forKey: "checkNotificationsInterval"))
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Notifications", systemImage: "bell.fill", isOn: $enableNotifications)
                        .onChange(of: enableNotifications) { _, newValue in
                            userDefaults.set(newValue, forKey: "enableNotifications")
                        }
                    
                    Picker("Check Notifications Interval", systemImage: "clock.fill", selection: $checkNotificationsInterval) {
                        ForEach([15, 30, 60, 120, 180, 240, 360, 720, 1440], id: \.self) { interval in
                                if interval < 60 {
                                    Text("\(interval) minutes")
                                } else if interval < 1440 {
                                    Text("\(interval / 60) hour\(interval >= 120 ? "s" : "")")
                                } else {
                                    Text("1 day")
                                }
                            }
                    }
                    .onChange(of: checkNotificationsInterval) { _, newValue in
                        userDefaults.set(newValue, forKey: "checkNotificationsInterval")
                    }
                }
            }
            .navigationTitle("Notification")
        }
    }
}

