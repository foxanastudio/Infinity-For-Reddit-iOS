//
// BackgroundTaskManager.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-06

import Foundation
import BackgroundTasks
import UserNotifications
import GRDB
import Alamofire

class BackgroundTasksManager {
    
    // MARK: - Properties
    let taskIdentifier = "com.docilealligator.infinityforreddit.bg.refresh.inbox"
    private let userDefaults: UserDefaults
    private let dbPool: DatabasePool
    
    private var pullNotificationTimeKey: String { "PULL_NOTIFICATION_TIME" }
    
    // MARK: - Singleton
    static let shared = BackgroundTasksManager()
    
    init () {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.dbPool = resolvedDatabasePool
    }
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            let backgroundTask = Task {
                await self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            task.expirationHandler = {
                print("Background Task: Task is expiring, attempting to cancel.")
                backgroundTask.cancel()
            }
        }
        
        scheduleAppRefresh()
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background Task Manager: Successfully scheduled app refresh task.")
        } catch {
            let nsError = error as NSError
            if nsError.domain == "BGTaskSchedulerErrorDomain" {
                print("Background Task Manager: App refresh task is already scheduled.")
            } else {
                print("Background Task Manager: Could not schedule app refresh task: \(error)")
            }
        }
    }
    
    @discardableResult
    public func refreshAndNotifyAllAccounts() async -> Bool {
        return await pullUnreadAndNotifyAllAccounts()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) async {
        let success = await refreshAndNotifyAllAccounts()
        task.setTaskCompleted(success: success)
        scheduleAppRefresh()
    }
    
    private func loadAllAccounts() async -> [Account] {
        let accountDao = AccountDao(dbPool: dbPool)
        do {
            return try accountDao.getAllAccounts()
                .filter { ($0.accessToken?.isEmpty == false) }
        } catch {
            print("Load accounts failed: \(error)")
            return []
        }
    }
    
    @discardableResult
    private func pullUnreadAndNotifyAllAccounts() async -> Bool {
        let accounts = await loadAllAccounts()
        guard !accounts.isEmpty else {
            return false
        }
        
        let userNotificationCenter = UNUserNotificationCenter.current()
        var anySent = false
        
        let lastTime = self.userDefaults.double(forKey: pullNotificationTimeKey)
        var maxDelivered = lastTime
        
        for (accIndex, account) in accounts.enumerated() {
            let username = account.username
            let provider = TokenCenter.shared
//            let accessToken = account.accessToken ?? ""
//            let refreshToken = account.refreshToken ?? ""
            let perAccountAccessTokenInterceptor = RedditPerAccountAccessTokenInterceptor(
                getToken: { await provider.currentAccessToken(for: username) },
                refreshToken: { try await provider.forceRefresh(for: username) }
            )
            
            guard let unreadListing = try? await fetchUnreadListingForAccount(account, interceptor: perAccountAccessTokenInterceptor) else {
                continue
            }
            
            let messages = (unreadListing.inboxes ?? [])
                .sorted { ($0.createdDate ?? .distantPast) < ($1.createdDate ?? .distantPast)}
                .suffix(20)
            
            for (msgIndex, inbox) in messages.enumerated().reversed() {
                let created = inbox.createdDate?.timeIntervalSince1970 ?? 0
                guard created > lastTime else { continue }
                
                anySent = true
                maxDelivered = max(maxDelivered, created)
                
                let (title, subtitle) = NotificationFormatter.titleSubtitle(for: inbox)
                
//                let content  = UNMutableNotificationContent()
//                content.title = title
//                content.subtitle = subtitle
//                content.body = inbox.body ?? "You've got a new message"
//                content.sound = .default
//                content.threadIdentifier = "inbox.\(account.username.lowercased())"
//                
//                var info: [String: Any] = [
//                    "accountName": account.username,
//                    "kind": inbox.messageKind.rawValue
//                ]
//                if let fullname = inbox.name { info["messageFullname"] = fullname }
//                if let ctx = inbox.context { info["context"] = ctx }
//                content.userInfo = info
//                
//                let stableId = "msg.\(account.username.lowercased()).\(inbox.id ?? "\(accIndex).\(msgIndex)")"
//                try? await userNotificationCenter.add(
//                    UNNotificationRequest(identifier: stableId, content: content, trigger: nil)
//                )
                
                let stableId = "msg.\(account.username.lowercased()).\(inbox.id ?? "\(accIndex).\(msgIndex)")"
                let threadId = "inbox.\(account.username.lowercased())"
                
                var info: [String: Any] = [
                    "accountName": account.username,
                    "kind": inbox.messageKind.rawValue
                ]
                if let fullname = inbox.name { info["messageFullname"] = fullname }
                if let ctx = inbox.context { info["context"] = ctx }
                
                try? await NotificationDelegate.shared.postInboxNotification(
                    stableId: stableId,
                    threadId: threadId,
                    title: title,
                    subtitle: subtitle,
                    body: inbox.body ?? "You've got a new message",
                    userInfo: info
                )
            }
        }
        
        if maxDelivered > lastTime {
            userDefaults.set(maxDelivered, forKey: pullNotificationTimeKey)
        }
        return anySent
    }
    
    private func fetchUnreadListingForAccount(_ account: Account, interceptor: RequestInterceptor? = nil) async throws -> InboxListing {
        let inboxListingRepository = InboxListingRepository(sessionName: "plain")
        do {
            return try await inboxListingRepository.fetchInboxListing(
                messageWhere: .unread,
                pathComponents: [:],
                queries: ["limit": "50"],
                interceptor: interceptor
            )
        } catch {
            throw error
        }
    }
    
    private func refreshAccessTokenIfPossible(account: Account) async throws -> String {
        guard let refreshToken = account.refreshToken, !refreshToken.isEmpty else {
            throw NSError(domain: "BG", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing refresh token"])
        }
        let headers = APIUtils.getHttpBasicAuthHeader()
        let params = ["grant_type": "refresh_token", "refresh_token": refreshToken]
        
        struct AccessTokenResponse: Decodable {
            let accessToken: String
            let refreshToken: String?
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case refreshToken = "refresh_token"
            }
        }
        
        let refreshSession = Session(configuration: .af.default)
        let result = await refreshSession.request(
            "https://www.reddit.com/api/v1/access_token",
            method: .post,
            parameters: params,
            encoding: URLEncoding.default,
            headers: headers
        ).validate().serializingDecodable(AccessTokenResponse.self).result
        
        switch result {
        case .success(let tokenResponse):
            let accountDao = AccountDao(dbPool: dbPool)
            if let newRefreshToken = tokenResponse.refreshToken {
                try? accountDao.updateAccessTokenAndRefreshToken(username: account.username, accessToken: tokenResponse.accessToken, refreshToken: newRefreshToken)
            } else {
                try? accountDao.updateAccessToken(username: account.username, accessToken: tokenResponse.accessToken)
            }
            if AccountViewModel.shared.account.username.caseInsensitiveCompare(account.username) == .orderedSame {
                try? AccountViewModel.shared.updateTokens(accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)
            }
            return tokenResponse.accessToken
        case .failure(let refreshError):
            throw refreshError
        }
    }
    
    // MARK: - Helper Methods
    private func shouldSendNotification(for listing: InboxListing) -> Bool {
        return !(listing.inboxes?.isEmpty ?? true)
    }
}

private extension String {
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }
}
