//
// UNUserNotificationCenterAsync.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-07
        
import UserNotifications

extension UNUserNotificationCenter {
    enum NotificationAuthError: Error { case authorizationDenied }

    func addRequest(_ request: UNNotificationRequest) async throws {
        var settings = await notificationSettings()

        if settings.authorizationStatus == .notDetermined {
            let granted = try await requestAuthorization(options: [.alert, .sound, .badge])
            guard granted else { throw NotificationAuthError.authorizationDenied }
            settings = await notificationSettings()
        }

        let ok: Set<UNAuthorizationStatus> = [.authorized, .provisional, .ephemeral]
        guard ok.contains(settings.authorizationStatus) else {
            throw NotificationAuthError.authorizationDenied
        }

        try await add(request)
    }
}
