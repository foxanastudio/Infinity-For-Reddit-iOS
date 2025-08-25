//
// Rule.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24
        
import GRDB

public struct Rule: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "rules"
    
    private let shortName: String
    private let descriptionHtml: String
    
    init(shortName: String, descriptionHtml: String) {
        self.shortName = shortName
        self.descriptionHtml = descriptionHtml
    }
    
    private enum CodingKeys: String, CodingKey, ColumnExpression, CaseIterable {
        case shortName = "short_name"
        case descriptionHtml = "description_html"
    }
}
