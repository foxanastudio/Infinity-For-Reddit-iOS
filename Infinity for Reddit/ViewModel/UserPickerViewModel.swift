//
//  UserPickerViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-18.
//

import Foundation
import Combine
import GRDB

class UserPickerViewModel: ObservableObject {
    @Published var selectedAccount: Account
    @Published var allAccounts: [Account] = []
    
    private let accountDao: AccountDao
    private let accountsPublisher: AnyPublisher<[Account], Error>
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        self.selectedAccount = AccountViewModel.shared.account
        self.accountDao = AccountDao(dbPool: resolvedDBPool)
        self.accountsPublisher = accountDao.getAllAccountsLiveData()
        
        self.accountsPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] accounts in
                self?.allAccounts = accounts
            })
            .store(in: &cancellables)
    }
}
