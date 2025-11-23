//
//  LoadState.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-21.
//

enum LoadState {
    case idle
    case loading
    case loaded
    case failed(Error)
    
    var isLoaded: Bool {
        switch self {
        case .loaded:
            return true
        default:
            return false
        }
    }
    
    var canLoad: Bool {
        switch self {
        case .idle, .failed:
            return true
        default:
            return false
        }
    }
}
