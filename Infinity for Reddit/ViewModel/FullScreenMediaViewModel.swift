//
//  FullScreenMediaViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-04.
//

import Foundation

enum FullScreenMediaType {
    case image(urlString: String, aspectRatio: CGSize? = nil, post: Post? = nil, matchedGeometryEffectId: String? = nil)
    case gif(urlString: String, post: Post? = nil)
    case video(urlString: String, post: Post? = nil, videoType: VideoType = .reddit)
    case gallery(currentUrlString: String, post: Post? = nil, items: [GalleryItem], galleryScrollState: GalleryScrollState)
    case imgurGallery(url: URL)
    case imgurAlbum(url: URL)
    case imgurImage(url: URL)
    
//    var downloadMediaType: DownloadMediaType {
//        switch self {
//        case .image(let urlString, _, let post, _):
//            if let post {
//                return DownloadMediaType.image(downloadUrlString: urlString, fileName: "\(post.fileNameWithoutExtension).jpg")
//            } else {
//                let url = URL(string: urlString)
//                if let url = url {
//                    return DownloadMediaType.image(downloadUrlString: urlString, fileName: url.lastPathComponent)
//                }
//                return DownloadMediaType.image(downloadUrlString: urlString, fileName: "\(Utils.randomString()).jpg")
//            }
//        case .gif(let urlString, post: let post):
//            if let post {
//                return DownloadMediaType.gif(downloadUrlString: urlString, fileName: "\(post.fileNameWithoutExtension).gif")
//            } else {
//                let url = URL(string: urlString)
//                if let url = url {
//                    return DownloadMediaType.gif(downloadUrlString: urlString, fileName: url.lastPathComponent)
//                }
//                return DownloadMediaType.gif(downloadUrlString: urlString, fileName: "\(Utils.randomString()).gif")
//            }
//        case .video(url: let urlString, post: let post, videoType: let videoType):
//
//        case .gallery(let currentUrlString, let post, _, _, _):
//            if let post {
//                return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: "\(post.fileNameWithoutExtension).jpg")
//            } else {
//                let url = URL(string: currentUrlString)
//                if let url = url {
//                    return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: url.lastPathComponent)
//                }
//                return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: "\(Utils.randomString()).jpg")
//            }
//        case .imgurGallery(let url):
//            <#code#>
//        case .imgurAlbum(let url):
//            <#code#>
//        case .imgurImage(let url):
//            <#code#>
//        }
//    }
}

enum VideoType {
    case reddit
    case direct
    case vReddIt
    case redgifs(id: String)
    case streamable(shortCode: String)
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
        case .gif:
            break
        case .video:
            break
        case .gallery:
            break
        case .imgurGallery(url: let url):
            break
        case .imgurAlbum(url: let url):
            break
        case .imgurImage(url: let url):
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
