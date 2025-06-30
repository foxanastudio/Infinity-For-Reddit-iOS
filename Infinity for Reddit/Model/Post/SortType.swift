//
//  SortType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-12.
//

import Foundation

struct SortType {
    enum Kind: String {
        case best = "best"
        case hot = "hot"
        case new = "new"
        case rising = "rising"
        case top = "top"
        case controversial = "controversial"
        case relevance = "relevance"
        case comments = "comments"
        case activity = "activity"
        case qa = "qa"
        case live = "live"

        var fullName: String {
            switch self {
            case .best: return "Best"
            case .hot: return "Hot"
            case .new: return "New"
            case .rising: return "Rising"
            case .top: return "Top"
            case .controversial: return "Controversial"
            case .relevance: return "Relevance"
            case .comments: return "Comments"
            case .activity: return "Activity"
            case .qa: return "QA"
            case .live: return "Live"
            }
        }
        
        var icon: String {
            switch self {
            case .best: return "sort_best"
            case .hot: return "sort_hot"
            case .new: return "sort_new"
            case .rising: return "sort_rising"
            case .top: return "sort_top"
            case .controversial: return "sort_controversial"
            case .relevance: return "sort_relevance"
            case .comments: return "sort_comments"
            case .activity: return "sort_activity"
            case .qa: return "sort_qa"
            case .live: return "sort_live"
            }
        }
    }

    enum Time: String {
        case hour = "hour"
        case day = "day"
        case week = "week"
        case month = "month"
        case year = "year"
        case all = "all"

        var fullName: String {
            switch self {
            case .hour: return "Hour"
            case .day: return "Day"
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            case .all: return "All Time"
            }
        }
    }

    let type: Kind
    let time: Time?

    init(type: Kind, time: Time? = nil) {
        self.type = type
        self.time = time
    }
}
