//
// PostLayout.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-10-29
        
import Foundation

enum PostLayout: Int {
    case card = 0
    case compact = 1

    var fullName: String {
        switch self {
        case .card:
            return "Card Layout"
        case .compact:
            return "Compact Layout"
        }
    }

    var icon: String {
        switch self {
        case .card:
            return "rectangle.grid.1x2"
        case .compact:
            return "list.bullet"
        }
    }
}
