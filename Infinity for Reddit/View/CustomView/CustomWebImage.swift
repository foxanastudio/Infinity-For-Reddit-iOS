//
//  CustomWebImage.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI
import Kingfisher

struct CustomWebImage<Placeholder: View, Fallback: View>: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var namespaceManager: NamespaceManager

    @State private var shouldLoadFallbackImage = false

    var urlString: String?
    var width: CGFloat?
    var height: CGFloat?
    var imageAspectRatio: CGSize?
    var circleClipped: Bool
    var handleImageTapGesture: Bool
    var centerCrop: Bool
    var matchedGeometryEffectId: String?
    var post: Post?
    var blur: Bool
    var shouldShowRetryView: Bool
    
    // Placeholder may be needed in the future.
    private let customOnTapGesture: (() -> Void)?
    private let placeholderViewBuilder: () -> Placeholder
    private let fallbackViewBuilder: (() -> Fallback)?

    // Primary Initializer: All parameters explicit, with default @ViewBuilder closures
    init(
        _ urlString: String? = nil,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        aspectRatio: CGSize? = nil,
        circleClipped: Bool = false,
        handleImageTapGesture: Bool = true,
        centerCrop: Bool = false,
        matchedGeometryEffectId: String? = nil,
        post: Post? = nil,
        blur: Bool = false,
        shouldShowRetryView: Bool = true,
        customOnTapGesture: (() -> Void)? = nil,
        @ViewBuilder placeholderView: @escaping () -> Placeholder,
        fallbackView: (() -> Fallback)?
    ) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.imageAspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.handleImageTapGesture = handleImageTapGesture
        self.centerCrop = centerCrop
        self.matchedGeometryEffectId = matchedGeometryEffectId
        self.post = post
        self.blur = blur
        self.shouldShowRetryView = shouldShowRetryView
        self.customOnTapGesture = customOnTapGesture
        self.placeholderViewBuilder = placeholderView // Assign the closures
        self.fallbackViewBuilder = fallbackView     // Assign the closures
    }

    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, matchedGeometryEffectId: String? = nil, post: Post? = nil, blur: Bool = false, shouldShowRetryView: Bool = true, customOnTapGesture: (() -> Void)? = nil) where Placeholder == EmptyView, Fallback == EmptyView {
        self.init(urlString, width: width, height: height, aspectRatio: aspectRatio, circleClipped: circleClipped, handleImageTapGesture: handleImageTapGesture, centerCrop: centerCrop, matchedGeometryEffectId: matchedGeometryEffectId, post: post, blur: blur, shouldShowRetryView: shouldShowRetryView, customOnTapGesture: customOnTapGesture,
                  placeholderView: { EmptyView() }, fallbackView: nil)
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, matchedGeometryEffectId: String? = nil, post: Post? = nil, blur: Bool = false, shouldShowRetryView: Bool = true, customOnTapGesture: (() -> Void)? = nil,
         @ViewBuilder placeholderView: @escaping () -> Placeholder) where Fallback == EmptyView {
        self.init(urlString, width: width, height: height, aspectRatio: aspectRatio, circleClipped: circleClipped, handleImageTapGesture: handleImageTapGesture, centerCrop: centerCrop, matchedGeometryEffectId: matchedGeometryEffectId, post: post, blur: blur, shouldShowRetryView: shouldShowRetryView, customOnTapGesture: customOnTapGesture,
                  placeholderView: placeholderView, fallbackView: nil)
    }
    
    init(_ urlString: String? = nil, width: CGFloat? = nil, height: CGFloat? = nil, aspectRatio: CGSize? = nil, circleClipped: Bool = false, handleImageTapGesture: Bool = true, centerCrop: Bool = false, matchedGeometryEffectId: String? = nil, post: Post? = nil, blur: Bool = false, shouldShowRetryView: Bool = true, customOnTapGesture: (() -> Void)? = nil,
         @ViewBuilder fallbackView: @escaping () -> Fallback) where Placeholder == EmptyView {
        self.init(urlString, width: width, height: height, aspectRatio: aspectRatio, circleClipped: circleClipped, handleImageTapGesture: handleImageTapGesture, centerCrop: centerCrop, matchedGeometryEffectId: matchedGeometryEffectId, post: post, blur: blur, shouldShowRetryView: shouldShowRetryView, customOnTapGesture: customOnTapGesture,
                  placeholderView: { EmptyView() },
                  fallbackView: fallbackView)
    }

    var body: some View {
        Group {
            if shouldLoadFallbackImage || urlString == nil {
                if let fallbackViewBuilder = fallbackViewBuilder {
                    fallbackViewBuilder()
                } else if shouldShowRetryView {
                    ZStack {
                        VStack(spacing: 4) {
                            SwiftUI.Image(systemName: "info.circle")
                                .primaryIcon()
                            
                            Text("Failed to load image — tap to retry.")
                                .frame(alignment: .center)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                    }
                    .applyIf(imageAspectRatio != nil) {
                        $0.aspectRatio(imageAspectRatio!.width / imageAspectRatio!.height, contentMode: .fit)
                    }
                    .frame(width: width, height: height)
                    // Using highPriorityGesture here as a workaround to handle tap gesture in a TabView.
                    .highPriorityGesture(TapGesture().onEnded {
                        withAnimation {
                            shouldLoadFallbackImage = false
                        }
                    })
                }
            } else {
                KFAnimatedImage(URL(string: urlString!))
                    .placeholder { progress in
                        ProgressIndicator()
                    }
                    .onSuccess { result in
                        
                    }
                    .onFailure { error in
                        DispatchQueue.main.async {
                            withAnimation {
                                shouldLoadFallbackImage = true
                            }
                        }
                    }
                    .applyIf(width != nil && height != nil) {
                        $0.setProcessor(DownsamplingImageProcessor(size: CGSize(width: width!, height: height!)))
                            .cacheOriginalImage()
                            .scaleFactor(UIScreen.main.scale)
                    }
                    .clipShape(circleClipped ? AnyShape(Circle()) : AnyShape(Rectangle()))
                    .applyIf(imageAspectRatio != nil) {
                        $0.aspectRatio(imageAspectRatio!.width / imageAspectRatio!.height, contentMode: .fit)
                    }
                    .applyIf(centerCrop) {
                        $0.scaledToFill()
                    }
                    .applyIf(!centerCrop) {
                        $0.scaledToFit()
                    }
                    .frame(width: width, height: height)
                    .clipped()
                    .applyIf(handleImageTapGesture) {
                        $0.mediaTapGesture(post: post, aspectRatio: imageAspectRatio, matchedGeometryEffectId: matchedGeometryEffectId)
                    }
                    .applyIf(!handleImageTapGesture && customOnTapGesture != nil) {
                        // Using highPriorityGesture here as a workaround to handle tap gesture in a TabView.
                        $0.highPriorityGesture(TapGesture().onEnded {
                            customOnTapGesture?()
                        })
                    }
            }
        }
        .id(urlString)
//        if let urlString {
//            KFImage(URL(string: urlString))
//                .cacheOriginalImage()
//                .fade(duration: 0)
//                .resizable()
//                .backgroundDecode()
//                .placeholder { progress in
//                    //ProgressIndicator()
//                }
//                .onSuccess { result in
//                    
//                }
//                .onFailure { error in
//                    DispatchQueue.main.async {
//                        shouldLoadFallbackImage = true
//                    }
//                }
//                .applyIf(width != nil || height != nil) {
//                    $0.setProcessor(DownsamplingImageProcessor(size: CGSize(width: width!, height: height!)))
//                }
//                .clipShape(circleClipped ? AnyShape(Circle()) : AnyShape(Rectangle()))
//                .applyIf(imageAspectRatio != nil) {
//                    $0.aspectRatio(imageAspectRatio!.width / imageAspectRatio!.height, contentMode: .fit)
//                }
//                .applyIf(centerCrop) {
//                    $0.scaledToFill()
//                }
//                .applyIf(!centerCrop) {
//                    $0.scaledToFit()
//                }
//                .frame(width: width, height: height)
//                .clipped()
//                .applyIf(handleImageTapGesture) {
//                    $0.mediaTapGesture(post: post, aspectRatio: imageAspectRatio, matchedGeometryEffectId: matchedGeometryEffectId)
//                }
//                .applyIf(!handleImageTapGesture && customOnTapGesture != nil) {
//                    // Using highPriorityGesture here as a workaround to handle tap gesture in a TabView.
//                    $0.highPriorityGesture(TapGesture().onEnded {
//                        customOnTapGesture?()
//                    })
//                }
//                .id(urlString)
//        }
    }
}
