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
    @EnvironmentObject private var namespaceManager: NamespaceManager
    
    @State private var shouldLoadFallbackImage = false
    
    var urlString: String?
    var width: CGFloat?
    var height: CGFloat?
    var aspectRatio: CGSize?
    var circleClipped: Bool?
    var handleImageTapGesture: Bool
    var centerCrop: Bool
    var enableMatchedGeometryEffect: Bool
    var post: Post?
    var placeholderView: (() -> Content)?
    var fallbackView: (() -> Content)?
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, enableMatchedGeometryEffect: Bool = false, post: Post? = nil) where Content == EmptyView {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.centerCrop = centerCrop
        self.handleImageTapGesture = handleImageTapGesture
        self.enableMatchedGeometryEffect = enableMatchedGeometryEffect
        self.post = post
    }
    

    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, enableMatchedGeometryEffect: Bool = false, post: Post? = nil,
         @ViewBuilder placeholderView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.centerCrop = centerCrop
        self.handleImageTapGesture = handleImageTapGesture
        self.enableMatchedGeometryEffect = enableMatchedGeometryEffect
        self.post = post
        self.placeholderView = placeholderView
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, enableMatchedGeometryEffect: Bool = false, post: Post? = nil,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.centerCrop = centerCrop
        self.handleImageTapGesture = handleImageTapGesture
        self.enableMatchedGeometryEffect = enableMatchedGeometryEffect
        self.post = post
        self.fallbackView = fallbackView
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, enableMatchedGeometryEffect: Bool = false, post: Post? = nil,
         @ViewBuilder placeholderView: @escaping () -> Content,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.enableMatchedGeometryEffect = enableMatchedGeometryEffect
        self.post = post
        self.centerCrop = centerCrop
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
                        .frame(width: width)
                        .frame(height: height)
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
                    .clipShape(circleClipped == true ? AnyShape(Circle()) : AnyShape(Rectangle()))
                    .transition(.fade(duration: 0.5))
                    .frame(width: width)
                    .frame(height: height)
                    .applyIf(centerCrop == true) {
                        $0.scaledToFill()
                            .clipped()
                    }
                    .applyIf(centerCrop == false) {
                        $0.scaledToFit()
                    }
                    .applyIf(enableMatchedGeometryEffect) {
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
                                    if post?.preview.images.isEmpty == false {
                                        if let previewImage = post?.preview.images.first {
                                            if let mp4 = previewImage.mp4Variant {
                                                fullScreenMediaViewModel.show(.video(url: mp4.source.url, post: post))
                                            } else if let gif = previewImage.gifVariant {
                                                fullScreenMediaViewModel.show(.gif(url: gif.source.url, post: post))
                                            }
                                        } else {
                                            fullScreenMediaViewModel.show(.gif(url: post?.url ?? "", post: post))
                                        }
                                    }
                                case .video(let videoUrl, let downloadUrl):
                                    fullScreenMediaViewModel.show(.video(url: videoUrl, post: post))
                                case .link:
                                    if let urlString = post?.url, let url = URL(string: urlString) {
                                        UIApplication.shared.open(url)
                                    } else {
                                        print("Invalid or empty URL")
                                    }
                                    print("link")
                                case .imgurVideo(let url):
                                    print("gif")
                                case .redgifs(let redgifsId):
                                    print("redgifs")
                                case .streamable(let shortCode):
                                    print("streamable")
                                default:
                                    print("other types")
                                }
                            }
                        }
                )
        }
    }
}
