//
//  AccountViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import Foundation
import GRDB
import Combine
import Swinject
import AuthenticationServices

public class AccountViewModel: ObservableObject {
    // Static shared instance
    public static var shared: AccountViewModel {
        guard let instance = _shared else {
            fatalError("AccountViewModel.shared has not been initialized. Call initializeShared(using:) first.")
        }
        return instance
    }
    
    // Private static property for the singleton instance
    private static var _shared: AccountViewModel?
    
    @Published var account: Account
    @Published var error: Error?
    
    @Published var inboxNavigationTarget: InboxNavigationTarget?
    @Published var pendingInboxTabAfterNotificationClicked: Bool = false
    @Published var pendingContextAfterNotificationClicked: String?
    @Published var pendingInboxFullname: String?
    
    @Published var loginFetchAccountDataTask: Task<Void, Never>?
    
    private let accountRepository: AccountRepositoryProtocol
    private let accountDao: AccountDao
    private let contextProvider: AuthPresentationContextProvider
    private var cancellables: Set<AnyCancellable> = []
    
    enum AccountError: LocalizedError {
        case failedToLogin
        case failedToUnmarkCurrentAccount
        case failedToMarkNewAccountCurrent
        case failedToObserveCurrentAccount
        
        var errorDescription: String? {
            switch self {
            case .failedToLogin:
                return "Failed to log in."
            case .failedToUnmarkCurrentAccount:
                return "Failed to remove the current account."
            case .failedToMarkNewAccountCurrent:
                return "Failed to switch to new account."
            case .failedToObserveCurrentAccount:
                return "Failed to observe the current account."
            }
        }
    }
    
    private init(dbPool: DatabasePool, accountRepository: AccountRepositoryProtocol) {
        self.accountRepository = accountRepository
        self.accountDao = AccountDao(dbPool: dbPool)
        do {
            if let account = try accountDao.getCurrentAccount() {
                self.account = account
            } else {
                account = Account.ANONYMOUS_ACCOUNT
            }
        } catch {
            account = Account.ANONYMOUS_ACCOUNT
            printInDebugOnly(error.localizedDescription)
        }
        self.contextProvider = AuthPresentationContextProvider()
        
        subscribeToCurrentAccount()
    }
    
    func startLogin() {
        accountRepository.startRedditLogin(contextProvider: contextProvider) { callbackURL, error in
            if let callbackURL {
                if let code = self.accountRepository.extractCode(callbackURL: callbackURL) {
                    self.loginFetchAccountDataTask?.cancel()
                    self.loginFetchAccountDataTask = Task {
                        do {
                            try await self.accountRepository.setUpAccount(code: code)
                        } catch {
                            await MainActor.run {
                                self.error = error
                            }
                        }
                    }
                }
            } else if let error {
                if let errorCode = (error as? NSError)?.code {
                    if errorCode != ASWebAuthenticationSessionError.Code.canceledLogin.rawValue {
                        printInDebugOnly(error.localizedDescription)
                        self.error = AccountError.failedToLogin
                    }
                }
            }
        }
    }
    
    public func switchAccount(newAccount: Account) {
        if !account.isAnonymous() {
            do {
                try accountDao.unmarkAccountCurrent(username: account.username)
            } catch {
                printInDebugOnly("Failed to unmark account as current: \(error)")
                self.error = AccountError.failedToUnmarkCurrentAccount
                return
            }
        }
        do {
            try accountDao.markAccountCurrent(username: newAccount.username)
            self.error = nil
        } catch {
            printInDebugOnly("Failed to mark account as current: \(error)")
            self.error = AccountError.failedToMarkNewAccountCurrent
        }
    }
    
    public func switchToAnonymous() throws {
        try accountDao.markAllAccountsNonCurrent()
        self.error = nil
    }
    
    public func logout() throws {
        try accountDao.deleteCurrentAccount()
        self.error = nil
    }
    
    public func updateSubscriptionSyncTime() async throws {
        await MainActor.run {
            account.subscriptionSyncTime = Int64(Date().timeIntervalSince1970)
        }
        try accountDao.updateSubscriptionSyncTime(username: account.username, subscriptionSyncTime: account.subscriptionSyncTime)
    }
    
    public func updateCustomFeedSyncTime() async throws {
        await MainActor.run {
            account.customFeedSyncTime = Int64(Date().timeIntervalSince1970)
        }
        try accountDao.updateCustomFeedSyncTime(username: account.username, customFeedSyncTime: account.customFeedSyncTime)
    }
    
    @MainActor
    func setSensitiveContentFromRedditSettings() async {
        do {
            let redditSettings = try await accountRepository.getRedditSettings()
            if account.allowSensitive != redditSettings.over18 {
                try await accountDao.updateAllowSensitive(account: account, allowSensitive: redditSettings.over18)
                
                AccountAllowSensitiveNotification.post(allowSensitive: redditSettings.over18)
            }
        } catch {
            self.error = error
        }
    }

    private func subscribeToCurrentAccount() {
        do {
            try accountDao.getCurrentAccountObservation()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        printInDebugOnly("Error observing current account: \(error)")
                    }
                }, receiveValue: { [weak self] updatedAccount in
                    self?.account = updatedAccount ?? Account.ANONYMOUS_ACCOUNT
                })
                .store(in: &cancellables)
        } catch {
            printInDebugOnly("Cannot observe current account: \(error)")
            self.error = AccountError.failedToObserveCurrentAccount
        }
    }
    
    static func initializeShared(container: Container, accountRepository: AccountRepositoryProtocol) {
        guard _shared == nil else {
            fatalError("AccountViewModel.shared has already been initialized.")
        }
        
        guard let resolvedDBPool = container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve AccountViewModel in AccountViewModel")
        }
        
        _shared = AccountViewModel(dbPool: resolvedDBPool, accountRepository: accountRepository)
    }
    
    @MainActor
    func switchToAccountIfNeeded(_ username: String) async -> Bool {
        guard account.username.caseInsensitiveCompare(username) != .orderedSame else {
            return false
        }
        
        if let account = try? accountDao.getAccount(username: username) {
            self.switchAccount(newAccount: account)
            return true
        }
        
        return false
    }
}

struct InboxNavigationTarget: Equatable {
    let viewMessage: Bool
}

class AuthPresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first!.windows.first!
    }
}
