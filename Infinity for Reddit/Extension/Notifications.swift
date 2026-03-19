//
// Notifications.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-19
        
import Foundation

extension Notification.Name {
    static let inboxDeepLink = Notification.Name("inboxDeepLink")
    static let contextDeepLink = Notification.Name("contextDeepLink")
    static let notificationIntervalChanged = Notification.Name("notificationIntervalChanged")
    static let notificationToggleChanged = Notification.Name("notificationToggleChanged")
    static let accountAllowSensitiveChanged = Notification.Name("accountAllowSensitiveChanged")
}
