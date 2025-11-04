//
//  GalleryCarousel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-02.
//

import SwiftUI

struct GalleryCarousel: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var namespaceManager: NamespaceManager
    
    @StateObject private var galleryScrollState = GalleryScrollState(scrollId: 0)
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    
    let post: Post
    let items: [GalleryItem]
    let onImageTap: (() -> Void)?
    let compactMode: Bool
    
    init(post: Post, compactMode: Bool = false, onImageTap: (() -> Void)? = nil) {
        self.post = post
        self.items = post.galleryData!.items
        self.onImageTap = onImageTap
        self.compactMode = compactMode
    }
    
    var body: some View {
        ZStack(alignment: compactMode ? .center : .topLeading) {
            TabView(selection: $galleryScrollState.scrollId) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    CustomWebImage(
                        item.urlString,
                        handleImageTapGesture: false,
                        centerCrop: true,
                        blur: (post.over18 && blurSensitiveImages) || (post.spoiler && blurSpoilerImages),
                        customOnTapGesture: {
                            withAnimation {
                                fullScreenMediaViewModel.show(
                                    .gallery(
                                        currentUrlString: item.urlString,
                                        post: post,
                                        items: items,
                                        galleryScrollState: galleryScrollState
                                    )
                                )
                            }
                            onImageTap?()
                        }
                    )
                    .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if compactMode {
                SwiftUI.Image(systemName: "square.stack")
                    .padding(4)
                    .galleryIndexIndicator()
                    .cornerRadius(8)
                    .padding(12)
            } else {
                Text("\(galleryScrollState.scrollId + 1)/\(items.count)")
                    .padding(4)
                    .galleryIndexIndicator()
                    .cornerRadius(8)
                    .padding(12)
            }
        }
    }
}
