//
//  FullScreenMediaViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-04.
//

import Foundation

enum FullScreenMediaType {
    case image(urlString: String, aspectRatio: CGSize? = nil, post: Post? = nil, fileName: String, matchedGeometryEffectId: String? = nil)
    case gif(urlString: String, post: Post? = nil, fileName: String)
    case video(urlString: String, post: Post? = nil, videoType: VideoType = .reddit, canDownload: Bool = true)
    case gallery(currentUrlString: String, post: Post? = nil, items: [GalleryItem], galleryScrollState: GalleryScrollState)
    case imgurGallery(imgurId: String, post: Post? = nil)
    case imgurAlbum(imgurId: String, post: Post? = nil)
    case imgurImage(imgurId: String, post: Post? = nil)
    
//    func getDownloadMediaType(fullScreenMediaType: FullScreenMediaType, loadedVideoURL: URL?) throws -> DownloadMediaType {
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
//        case .video(let urlString, let post, let videoType):
//            switch videoType {
//            case .reddit:
//                if let post {
//                    return DownloadMediaType.redditVideo(post: post)
//                } else {
//                    // Really should not happen
//                    return DownloadMediaType.video(downloadUrlString: urlString, fileName: "\(Utils.randomString()).mp4")
//                }
//            case .direct:
//                return DownloadMediaType.video(downloadUrlString: urlString, fileName: "\(post?.fileNameWithoutExtension ?? Utils.randomString()).mp4")
//            case .vReddIt:
//                return DownloadMediaType.vReddIt(urlString: urlString, downloadUrlString: loadedVideoURL?.absoluteString)
//            case .redgifs(id: let id):
//                return DownloadMediaType.redgifs(redgifsId: id, downloadUrlString: loadedVideoURL?.absoluteString)
//            case .streamable(shortCode: let shortCode):
//                return DownloadMediaType.streamable(shortCode: shortCode, downloadUrlString: loadedVideoURL?.absoluteString)
//            }
//        case .gallery(let currentUrlString, let post, let galleryItems, let galleryScrollState):
//            if let post {
//                switch galleryItems[galleryScrollState.scrollId].mediaType {
//                case .image:
//                    return DownloadMediaType.image(downloadUrlString: currentUrlString, fileName: "\(post.fileNameWithoutExtension).jpg")
//                case .gif:
//                    return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: "\(post.fileNameWithoutExtension).gif")
//                case .video:
//                    return DownloadMediaType.video(downloadUrlString: currentUrlString, fileName: "\(post.fileNameWithoutExtension).mp4")
//                }
//            } else {
//                let url = URL(string: currentUrlString)
//                if let url = url {
//                    switch galleryItems[galleryScrollState.scrollId].mediaType {
//                    case .image:
//                        return DownloadMediaType.image(downloadUrlString: currentUrlString, fileName: url.lastPathComponent)
//                    case .gif:
//                        return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: url.lastPathComponent)
//                    case .video:
//                        return DownloadMediaType.video(downloadUrlString: currentUrlString, fileName: url.lastPathComponent)
//                    }
//                }
//                switch galleryItems[galleryScrollState.scrollId].mediaType {
//                case .image:
//                    return DownloadMediaType.image(downloadUrlString: currentUrlString, fileName: "\(Utils.randomString()).jpg")
//                case .gif:
//                    return DownloadMediaType.gif(downloadUrlString: currentUrlString, fileName: "\(Utils.randomString()).gif")
//                case .video:
//                    return DownloadMediaType.video(downloadUrlString: currentUrlString, fileName: "\(Utils.randomString()).mp4")
//                }
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

enum DownloadMediaTypeError: LocalizedError {
    case getDownloadMediaTypeFailed
    
    var errorDescription: String? {
        switch self {
        case .getDownloadMediaTypeFailed:
            return "Failed to get download media type."
        }
    }
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
        case .image(_, _, _, _, let matchedGeometryEffectId):
            self.matchedGeometryEffectId = matchedGeometryEffectId
        case .gif:
            break
        case .video:
            break
        case .gallery:
            break
        case .imgurGallery:
            break
        case .imgurAlbum:
            break
        case .imgurImage:
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
