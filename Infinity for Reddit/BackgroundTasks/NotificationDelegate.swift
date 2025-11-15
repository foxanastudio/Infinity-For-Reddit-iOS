//
// NotificationDelegate.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-07
        
import UserNotifications
import Foundation
import UIKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    private override init() {}
    
    func configure(requestAuthorization: Bool = true) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        if requestAuthorization {
            notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { _, _ in }
        }
    }
    
    func postNotification(
        notificationId: String,
        threadId: String,
        title: String,
        subtitle: String,
        body: String,
        userInfo: [String: Any]
    ) async throws {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default
        content.threadIdentifier = threadId
        content.userInfo = userInfo

        try await UNUserNotificationCenter.current().add(
            UNNotificationRequest(identifier: notificationId, content: content, trigger: nil)
        )
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completion: @escaping () -> Void) {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            completion()
            return
        }
        
        let userInfo = response.notification.request.content.userInfo
        
        guard let accountName = userInfo["accountName"] as? String,
              let inboxKind = userInfo["kind"] as? Inbox.InboxKind else {
            completion()
            return
        }
        
        let fullname = userInfo["messageFullname"] as? String
        
        var deepLinkUrl: URL?
        
        switch inboxKind {
        case .comment, .link:
            if let context = userInfo["context"] as? String,
               let externalUrl = URL(string: context) {
                deepLinkUrl = AppDeepLink.toExternalLink(
                    url: externalUrl,
                    account: accountName,
                    fullname: fullname
                )
            }
            
        case .message, .account, .subreddit, .unknown:
            deepLinkUrl = AppDeepLink.toInbox(
                account: accountName,
                viewMessage: (inboxKind == .message),
                fullname: fullname
            )
        case .award:
            break
        }
        
        if let url = deepLinkUrl {
            Task { @MainActor in
                UIApplication.shared.open(url)
            }
        }
        
        completion()
    }
}
