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
    let mediaMetadata: [String: MediaMetadata]
    let onImageTap: (() -> Void)?
    
    init(post: Post, onImageTap: (() -> Void)? = nil) {
        self.post = post
        self.items = post.galleryData!.items
        self.mediaMetadata = post.mediaMetadata!
        self.onImageTap = onImageTap
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TabView(selection: $galleryScrollState.scrollId) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if let media = mediaMetadata[item.mediaId], let preview = media.p.last {
                        CustomWebImage(
                            preview.u,
                            handleImageTapGesture: false,
                            blur: (post.over18 && blurSensitiveImages) || (post.spoiler && blurSpoilerImages),
                            customOnTapGesture: {
                                withAnimation {
                                    fullScreenMediaViewModel.show(.gallery(currentUrl: preview.u, items: items, mediaMetadata: mediaMetadata, galleryScrollState: galleryScrollState))
                                }
                                onImageTap?()
                            }
                        )
                        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                        .tag(index)
                    } else {
                        Color.clear
                            .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Text("\(galleryScrollState.scrollId + 1)/\(items.count)")
                .padding(4)
                .galleryIndexIndicator()
                .cornerRadius(8)
                .padding(12)
        }
    }
}
