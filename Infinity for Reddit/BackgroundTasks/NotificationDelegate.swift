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
    
    @discardableResult
    func postInboxNotification(
        stableId: String,
        threadId: String,
        title: String,
        subtitle: String,
        body: String,
        userInfo: [String: Any]
    ) async throws -> String {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = .default
        content.threadIdentifier = threadId
        content.userInfo = userInfo
        
        let req = UNNotificationRequest(identifier: stableId, content: content, trigger: nil)
        try await UNUserNotificationCenter.current().add(req)
        return stableId
    }
    
    func replaceDelivered(id: String, with content: UNMutableNotificationContent) async throws {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [id])
        try await notificationCenter.add(UNNotificationRequest(identifier: id, content: content, trigger: nil))
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
            completion(); return
        }
        
        let userInfo = response.notification.request.content.userInfo
        let account  = (userInfo["accountName"] as? String) ?? ""
        let kindRaw  = (userInfo["kind"] as? String) ?? ""
        let fullname = userInfo["messageFullname"] as? String
        
        switch MsgKind.parse(kindRaw) {
        case .message:
            NotificationRouter.shared.postOpenInbox(account: account, viewMessage: true, fullname: fullname)
        case .comment, .link, .account, .subreddit, .other:
            NotificationRouter.shared.postOpenInbox(account: account, viewMessage: false, fullname: fullname)
        }
        
        completion()
    }
}

private enum MsgKind { case comment, link, message, account, subreddit, other
    static func parse(_ raw: String) -> MsgKind {
        switch raw.lowercased() {
        case "t1": return .comment
        case "t3": return .link
        case "t4": return .message
        case "t2": return .account
        case "t5": return .subreddit
        default:   return .other        
        }
    }
}
