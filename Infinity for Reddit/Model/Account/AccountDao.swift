//
//  AccountDao.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import GRDB

struct AccountDao {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }

    func insert(_ account: Account) throws {
        try dbPool.write { db in
            try account.insert(db) // Insert or replace
        }
    }

    func isAnonymousAccountInserted() throws -> Bool {
        try dbPool.read { db in
            try Account.fetchOne(db, sql: "SELECT * FROM accounts WHERE username = '-'") != nil
        }
    }

    func getAllAccounts() throws -> [Account] {
        try dbPool.read { db in
            try Account.fetchAll(db, sql: "SELECT * FROM accounts WHERE username != '-'")
        }
    }

    func getAllNonCurrentAccounts() throws -> [Account] {
        try dbPool.read { db in
            try Account.fetchAll(db, sql: "SELECT * FROM accounts WHERE is_current_user = 0 AND username != '-'")
        }
    }

    func markAllAccountsNonCurrent() throws {
        try dbPool.write { db in
            try db.execute(sql: "UPDATE accounts SET is_current_user = 0 WHERE is_current_user = 1 AND username != '-'")
        }
    }

    func deleteCurrentAccount() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM accounts WHERE is_current_user = 1 AND username != '-'")
        }
    }

    func deleteAccount(named accountName: String) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM accounts WHERE username = ?", arguments: [accountName])
        }
    }

    func deleteAllAccounts() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM accounts WHERE username != '-'")
        }
    }

    func getAccountData(username: String) throws -> Account? {
        try dbPool.read { db in
            try Account.fetchOne(db, sql: "SELECT * FROM accounts WHERE username = ? COLLATE NOCASE", arguments: [username])
        }
    }

    func getCurrentAccount() throws -> Account? {
        try dbPool.read { db in
            try Account.fetchOne(db, sql: "SELECT * FROM accounts WHERE is_current_user = 1 AND username != '-'")
        }
    }

    func updateAccountInfo(username: String, profileImageUrl: String?, bannerImageUrl: String?, karma: Int?) throws {
        try dbPool.write { db in
            try db.execute(
                sql: """
                UPDATE accounts 
                SET profile_image_url = ?, banner_image_url = ?, karma = ?
                WHERE username = ?
                """,
                arguments: [profileImageUrl, bannerImageUrl, karma, username]
            )
        }
    }

    func markAccountCurrent(username: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: "UPDATE accounts SET is_current_user = 1 WHERE username = ?",
                arguments: [username]
            )
        }
    }

    func updateAccessToken(username: String, accessToken: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: "UPDATE accounts SET access_token = ? WHERE username = ?",
                arguments: [accessToken, username]
            )
        }
    }

    func updateAccessTokenAndRefreshToken(username: String, accessToken: String, refreshToken: String) throws {
        try dbPool.write { db in
            try db.execute(
                sql: "UPDATE accounts SET access_token = ?, refresh_token = ? WHERE username = ?",
                arguments: [accessToken, refreshToken, username]
            )
        }
    }
}
