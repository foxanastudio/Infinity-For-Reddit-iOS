//
//  MarkdownEmbeddedMediaType.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-12.
//

enum MarkdownEmbeddedMediaType: Int {
    case all = 15
    case videoAndImage = 8
    case imageAndGif = 7
    case imageAndEmote = 6
    case gifAndEmote = 5
    case video = 4
    case image = 3
    case gif = 2
    case emote = 1
    case none = 0
    
    var allowVideo: Bool {
        switch self {
        case .all:
            return true
        case .videoAndImage:
            return true
        case .video:
            return true
        default:
            return false
        }
    }
    
    var allowImage: Bool {
        switch self {
        case .all:
            return true
        case .videoAndImage:
            return true
        case .imageAndGif:
            return true
        case .imageAndEmote:
            return true
        case .image:
            return true
        default:
            return false
        }
    }
    
    var allowGif: Bool {
        switch self {
        case .all:
            return true
        case .imageAndGif:
            return true
        case .gifAndEmote:
            return true
        case .gif:
            return true
        default:
            return false
        }
    }
    
    var allowEmote: Bool {
        switch self {
        case .all:
            return true
        case .imageAndEmote:
            return true
        case .gifAndEmote:
            return true
        case .emote:
            return true
        default:
            return false
        }
    }
}
