//
//  FullScreenMediaViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-04.
//

import Foundation

enum FullScreenMediaType {
    case image(url: String, aspectRatio: CGSize?, post: Post?, matchedGeometryEffectId: String?)
    case gif(url: String, post: Post?)
    case video(url: String, post: Post?)
    case gallery(currentUrl: String, items: [GalleryItem], mediaMetadata: [String: MediaMetadata], galleryScrollState: GalleryScrollState)
}

class GalleryScrollState: ObservableObject {
    @Published var scrollId: Int = 0
    
    init(scrollId: Int) {
        self.scrollId = scrollId
    }
}

class FullScreenMediaViewModel: ObservableObject {
    @Published var media: FullScreenMediaType?
    @Published var matchedGeometryEffectId: String?
    @Published var isTransitioning: Bool = false
    
    func show(_ media: FullScreenMediaType) {
        isTransitioning = true
        self.media = media
        switch media {
        case .image(_, _, _, let matchedGeometryEffectId):
            self.matchedGeometryEffectId = matchedGeometryEffectId
        case .gif(_, _):
            break
        case .video(_, _):
            break
        case .gallery(_, _, _, _):
            break
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.isTransitioning = false
        }
    }
    
    func dismiss() {
        isTransitioning = true
        
        self.media = nil
        self.matchedGeometryEffectId = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.isTransitioning = false
        }
    }
}
