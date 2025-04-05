//
//  CustomWebImage.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI
import SDWebImageSwiftUI

struct CustomWebImage<Content: View>: View {
    var urlString: String?
    var width: CGFloat?
    var height: CGFloat?
    var aspectRatio: CGFloat?
    var circleClipped: Bool?
    var placeholderView: (() -> Content)?
    var fallbackView: (() -> Content)?
    
    @State private var shouldLoadFallbackImage = false
    
    init(_ urlString: String?, circleClipped: Bool = false) where Content == EmptyView {
        self.urlString = urlString
        self.circleClipped = circleClipped
    }
    
    init(_ urlString: String?, circleClipped: Bool = false, @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.circleClipped = circleClipped
        self.fallbackView = fallbackView
    }
    
    init(_ urlString: String?, width: CGFloat, height: CGFloat, circleClipped: Bool = false, @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.circleClipped = circleClipped
        self.fallbackView = fallbackView
    }
    
    init(_ urlString: String?, circleClipped: Bool = false, @ViewBuilder placeholderView: @escaping () -> Content,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.circleClipped = circleClipped
        self.placeholderView = placeholderView
        self.fallbackView = fallbackView
    }
    
    init(_ urlString: String?, width: CGFloat?, height: CGFloat?, aspectRatio: CGFloat?, circleClipped: Bool = false,
         @ViewBuilder placeholderView: @escaping () -> Content, fallbackImage: SwiftUI.Image?) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
        self.placeholderView = placeholderView
    }
    
    init(_ urlString: String?, width: CGFloat?, height: CGFloat?, aspectRatio: CGFloat?, circleClipped: Bool = false,
         @ViewBuilder placeholderView: @escaping () -> Content,
         @ViewBuilder fallbackView: @escaping () -> Content) {
        self.urlString = urlString
        self.width = width
        self.height = height
        self.aspectRatio = aspectRatio
        self.circleClipped = circleClipped
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
                WebImage(url: URL(string: urlString!)) { image in
                    if let aspectRatio = aspectRatio {
                        image
                            .resizable()
                            .aspectRatio(aspectRatio, contentMode: .fit)
                    } else {
                        image
                            .resizable()
                    }
                }  placeholder: {
                    placeholderView?()
                }
                .onSuccess { image, data, cacheType in
                    // Success
                    // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
                }
                .onFailure { _ in
                    if fallbackView != nil {
                        shouldLoadFallbackImage = true
                    }
                }
                .indicator(.activity)
                .applyIf(circleClipped == true) {
                    $0.clipShape(Circle())
                }
                .transition(.fade(duration: 0.5))
                .scaledToFit()
                .frame(width: width, height: height)
            }
        }
    }
}
