//
//  CustomWebImage.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI
import SDWebImageSwiftUI

struct CustomWebImage<Content: View>: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject() private var namespaceManager: NamespaceManager
    
    @State private var shouldLoadFallbackImage = false
    
    var urlString: String?
    var width: CGFloat?
    var height: CGFloat?
    var aspectRatio: CGSize?
    var circleClipped: Bool?
    var handleImageTapGesture: Bool
    var post: Post?
    var placeholderView: (() -> Content)?
    var fallbackView: (() -> Content)?
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, post: Post? = nil) where Content == EmptyView {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.post = post
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, post: Post? = nil,
         @ViewBuilder placeholderView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.post = post
        self.placeholderView = placeholderView
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, post: Post? = nil,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.post = post
        self.fallbackView = fallbackView
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, post: Post? = nil,
         @ViewBuilder placeholderView: @escaping () -> Content,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.post = post
        self.placeholderView = placeholderView
        self.fallbackView = fallbackView
    }
    
    var body: some View {
        ZStack {
            if shouldLoadFallbackImage || urlString == nil {
                if let fallbackView = fallbackView {
                    fallbackView()
                }
            } else {
                if handleImageTapGesture == true && fullScreenMediaViewModel.currentId == (urlString ?? "") {
                    // Image is now in full screen mode
                    Color.clear
                        .applyIf(width != nil) {
                            $0.frame(width: width!)
                        }
                        .applyIf(height != nil) {
                            $0.frame(height: height!)
                        }
                } else {
                    WebImage(url: URL(string: urlString!)) { image in
                        if let aspectRatio = aspectRatio {
                            image
                                .resizable()
                                .aspectRatio(aspectRatio, contentMode: .fit)
                        } else {
                            image
                                .resizable()
                        }
                    } placeholder: {
                        placeholderView?()
                    }
                    .onSuccess { image, data, cacheType in
                        // Success
                        // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                    }
                    .onFailure { _ in
                        if fallbackView != nil {
                            DispatchQueue.main.async {
                                shouldLoadFallbackImage = true
                            }
                        }
                    }
                    .indicator(.activity)
                    .scaledToFit()
                    .applyIf(circleClipped == true) {
                        $0.clipShape(Circle())
                    }
//                    .applyIf(handleImageTapGesture != true) {
//                        $0.transition(.fade(duration: 0.5))
//                    }
                    .applyIf(width != nil) {
                        $0.frame(width: width!)
                    }
                    .applyIf(height != nil) {
                        $0.frame(height: height!)
                    }
                    .applyIf(handleImageTapGesture == true && fullScreenMediaViewModel.currentId != (urlString ?? "")) {
                        $0.matchedGeometryEffect(id: urlString ?? "", in: namespaceManager.animation)
                    }
                    .applyIf(handleImageTapGesture == false) {
                        $0.matchedGeometryEffect(id: urlString ?? "", in: namespaceManager.animation)
                    }
                }
            }
        }
        .applyIf(handleImageTapGesture == true) {
            $0.contentShape(Rectangle())
                .highPriorityGesture(
                    TapGesture()
                        .onEnded {
                            withAnimation {
                                switch post?.postType {
                                case .image:
                                    fullScreenMediaViewModel.show(.image(url: urlString ?? "", aspectRatio: aspectRatio, post: post))
                                case .imageWithUrlPreview(let urlPreview):
                                    fullScreenMediaViewModel.show(.image(url: urlString ?? "", aspectRatio: aspectRatio, post: post))
                                case .gif:
                                    print("gif")
                                case .video(let videoUrl, let downloadUrl):
                                    fullScreenMediaViewModel.show(.video(url: videoUrl, post: post))
                                case .link:
                                    print("link")
                                case .imgurVideo(let url):
                                    print("gif")
                                case .redgifs(let redgifsId):
                                    print("gif")
                                case .streamable(let shortCode):
                                    print("gif")
                                default:
                                    print("other types")
                                }
                            }
                        }
                )
        }
    }
}
