//
//  AccountViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import Foundation
import GRDB

class AccountViewModel: ObservableObject {
    @Published var account: Account?
    let accountDao: AccountDao
    
    init(dbPool: DatabasePool) {
        self.accountDao = AccountDao(dbPool: dbPool)
        loadAccount()
    }
    
    func loadAccount() {
        do {
            account = try accountDao.getCurrentAccount()
            if (account == nil) {
                account = Account.ANONYMOUS_ACCOUNT
            }
        } catch {
            account = Account.ANONYMOUS_ACCOUNT
            print(error.localizedDescription)
        }
    }
    
    func signOut() {
        account = nil
    }
}
