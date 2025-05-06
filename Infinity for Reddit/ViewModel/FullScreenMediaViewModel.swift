//
//  FullScreenMediaViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-04.
//

import Foundation

enum FullScreenMediaType: Hashable {
    case image(url: String, aspectRatio: CGSize?, post: Post?)
    case gif(url: String, post: Post?)
    case video(url: String, post: Post?)
    case gallery(items: [GalleryItem], mediaMetadata: [String: MediaMetadata])
}

class FullScreenMediaViewModel: ObservableObject {
    @Published var media: FullScreenMediaType?
    @Published var currentId: String?
    
    func show(_ media: FullScreenMediaType) {
        self.media = media
        switch media {
        case .image(let url, _, _):
            self.currentId = url
        case .gif(let url, _):
            self.currentId = url
        case .video(let url, _):
            self.currentId = url
        default:
            self.currentId = nil
        }
    }
    
    func dismiss() {
        self.media = nil
        self.currentId = nil
    }
}
