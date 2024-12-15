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
    let accountDao: AccountDao
    private var cancellables: Set<AnyCancellable> = []
    
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
        
        //subscribeToCurrentAccount()
    }
    
    public func updateTokens(accessToken: String, refreshToken: String?) throws {
        account.accessToken = accessToken
        if let validRefreshToken = refreshToken, !validRefreshToken.isEmpty {
            account.refreshToken = validRefreshToken
            try accountDao.updateAccessTokenAndRefreshToken(username: account.username, accessToken: accessToken, refreshToken: validRefreshToken)
        } else {
            try accountDao.updateAccessToken(username: account.username, accessToken: accessToken)
        }
    }
    
    // TODO May not work
    private func subscribeToCurrentAccount() {
        // Subscribe to the getCurrentAccountObservation publisher
        do {
            try accountDao.getCurrentAccountObservation()
                .receive(on: DispatchQueue.main) // Ensure UI updates are done on the main thread
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error observing current account: \(error)")
                    }
                }, receiveValue: { [weak self] updatedAccount in
                    // Update the current account property when the value changes
                    self?.account = updatedAccount ?? Account.ANONYMOUS_ACCOUNT
                })
                .store(in: &cancellables) // Store the subscription to avoid it being deallocated
        } catch {
            print("Cannot observe current account: \(error.localizedDescription)")
        }
    }
    
    public static func initializeShared(using container: Container) {
        guard _shared == nil else {
            fatalError("AccountViewModel.shared has already been initialized.")
        }
        
        guard let resolvedDBPool = container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve AccountViewModel from container")
        }
        
        _shared = AccountViewModel(dbPool: resolvedDBPool)
    }
}
