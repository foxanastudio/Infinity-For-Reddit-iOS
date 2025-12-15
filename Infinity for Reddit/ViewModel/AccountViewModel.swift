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
    
    private let accountDao: AccountDao
    private var cancellables: Set<AnyCancellable> = []
    
    enum AccountError: LocalizedError {
        case failedToUnmarkCurrentAccount
        case failedToMarkNewAccountCurrent
        case failedToObserveCurrentAccount
        
        var errorDescription: String? {
            switch self {
            case .failedToUnmarkCurrentAccount:
                return "Failed to remove the current account."
            case .failedToMarkNewAccountCurrent:
                return "Failed to switch to new account."
            case .failedToObserveCurrentAccount:
                return "Failed to observe the current account."
            }
        }
    }
    
    private init(dbPool: DatabasePool) {
        self.accountDao = AccountDao(dbPool: dbPool)
        do {
            if let account = try accountDao.getCurrentAccount() {
                self.account = account
            } else {
                account = Account.ANONYMOUS_ACCOUNT
            }
        } catch {
            account = Account.ANONYMOUS_ACCOUNT
            print(error.localizedDescription)
        }
        
        subscribeToCurrentAccount()
    }
    
    public func switchAccount(newAccount: Account) {
        if !account.isAnonymous() {
            do {
                try accountDao.unmarkAccountCurrent(username: account.username)
            } catch {
                print("Failed to unmark account as current: \(error)")
                self.error = AccountError.failedToUnmarkCurrentAccount
                return
            }
        }
        do {
            try accountDao.markAccountCurrent(username: newAccount.username)
        } catch {
            print("Failed to mark account as current: \(error)")
            self.error = AccountError.failedToMarkNewAccountCurrent
        }
    }
    
    public func switchToAnonymous() throws {
        try accountDao.markAllAccountsNonCurrent()
    }
    
    public func logout() throws {
        try accountDao.deleteCurrentAccount()
    }
    
    public func updateTokens(accessToken: String, refreshToken: String?) throws {
        account.accessToken = accessToken
        print("Access Token: \(accessToken)")
        if let validRefreshToken = refreshToken, !validRefreshToken.isEmpty {
            account.refreshToken = validRefreshToken
            try accountDao.updateAccessTokenAndRefreshToken(username: account.username, accessToken: accessToken, refreshToken: validRefreshToken)
        } else {
            try accountDao.updateAccessToken(username: account.username, accessToken: accessToken)
        }
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

    private func subscribeToCurrentAccount() {
        do {
            try accountDao.getCurrentAccountObservation()
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error observing current account: \(error)")
                    }
                }, receiveValue: { [weak self] updatedAccount in
                    self?.account = updatedAccount ?? Account.ANONYMOUS_ACCOUNT
                })
                .store(in: &cancellables)
        } catch {
            print("Cannot observe current account: \(error)")
            self.error = AccountError.failedToObserveCurrentAccount
        }
    }
    
    public static func initializeShared(using container: Container) {
        guard _shared == nil else {
            fatalError("AccountViewModel.shared has already been initialized.")
        }
        
        guard let resolvedDBPool = container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve AccountViewModel in AccountViewModel")
        }
        
        _shared = AccountViewModel(dbPool: resolvedDBPool)
        print("Access Token: \(_shared?.account.accessToken ?? "")")
    }
    
    @MainActor
    func switchToAccountIfNeeded(_ username: String) async {
        guard account.username.caseInsensitiveCompare(username) != .orderedSame else { return }
        if let account = try? accountDao.getAccount(username: username) {
            self.switchAccount(newAccount: account)
        }
    }
}
