//
//  CustomThemeDao.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-24.
//

import GRDB
import Combine

class CustomThemeDao {
    private let dbPool: DatabasePool

    init(dbPool: DatabasePool) {
        self.dbPool = dbPool
    }

    // MARK: - Insert Operations

    func insert(customTheme: CustomTheme) throws {
        try dbPool.write { db in
            try customTheme.insert(db, onConflict: .replace)
        }
    }

    func insertAll(customThemes: [CustomTheme]) throws {
        try dbPool.write { db in
            for theme in customThemes {
                try theme.insert(db, onConflict: .replace)
            }
        }
    }

    // MARK: - Query All Themes

    func getAllCustomThemes() throws -> [CustomTheme] {
        try dbPool.read { db in
            try CustomTheme.fetchAll(db)
        }
    }

    func getAllCustomThemesPublisher() -> AnyPublisher<[CustomTheme], Error> {
        ValueObservation
            .tracking { db in
                try CustomTheme.fetchAll(db)
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }

    // MARK: - Fetch Single Themes by ID

    func getCustomTheme(byId id: Int64) throws -> CustomTheme? {
        try dbPool.read { db in
            try CustomTheme
                .filter(Column("id") == id)
                .fetchOne(db)
        }
    }

    func getCustomThemePublisher(byId id: Int64) -> AnyPublisher<CustomTheme?, Error> {
        ValueObservation
            .tracking { db in
                try CustomTheme
                    .filter(Column("id") == id)
                    .fetchOne(db)
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }

    func getLightCustomThemePublisher() -> AnyPublisher<CustomTheme?, Error> {
        ValueObservation
            .tracking { db in
                try CustomTheme
                    .filter(Column("isLightTheme") == true)
                    .limit(1)
                    .fetchOne(db)
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }

    func getDarkCustomThemePublisher() -> AnyPublisher<CustomTheme?, Error> {
        ValueObservation
            .tracking { db in
                try CustomTheme
                    .filter(Column("isDarkTheme") == true)
                    .limit(1)
                    .fetchOne(db)
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }

    func getAmoledCustomThemePublisher() -> AnyPublisher<CustomTheme?, Error> {
        ValueObservation
            .tracking { db in
                try CustomTheme
                    .filter(Column("isAmoledTheme") == true)
                    .limit(1)
                    .fetchOne(db)
            }
            .publisher(in: dbPool)
            .eraseToAnyPublisher()
    }

    // MARK: - Update Operations

    func unsetLightTheme() throws {
        try dbPool.write { db in
            try db.execute(sql: "UPDATE custom_themes SET is_light_theme = 0 WHERE is_light_theme = 1")
        }
    }

    func unsetDarkTheme() throws {
        try dbPool.write { db in
            try db.execute(sql: "UPDATE custom_themes SET is_dark_theme = 0 WHERE is_dark_theme = 1")
        }
    }

    func unsetAmoledTheme() throws {
        try dbPool.write { db in
            try db.execute(sql: "UPDATE custom_themes SET is_amoled_theme = 0 WHERE is_amoled_theme = 1")
        }
    }

    func updateThemeName(byId id: Int64, newName: String) throws {
        try dbPool.write { db in
            try db.execute(sql: "UPDATE custom_themes SET name = ? WHERE id = ?", arguments: [newName, id])
        }
    }

    // MARK: - Delete Operations

    func deleteCustomTheme(byId id: Int64) throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM custom_themes WHERE id = ?", arguments: [id])
        }
    }

    func deleteAllCustomThemes() throws {
        try dbPool.write { db in
            try db.execute(sql: "DELETE FROM custom_themes")
        }
    }
}
