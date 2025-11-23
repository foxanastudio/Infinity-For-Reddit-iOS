//
// Flair.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-28
        
import Foundation

public struct Flair: Codable, Identifiable, Hashable {
    public let id: String
    let text: String
    let type: String
    let isEditable: Bool
    let richtext: [FlairRichtext]?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case type
        case isEditable = "text_editable"
        case richtext
    }
}
