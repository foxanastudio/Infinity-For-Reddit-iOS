//
//  AccountViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import Foundation
import GRDB

public class AccountViewModel: ObservableObject {
    @Published var account: Account
    let accountDao: AccountDao
    
    init(dbPool: DatabasePool) {
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
    }
}
