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
    @EnvironmentObject private var networkManager: NetworkManager

    @StateObject private var galleryScrollState = GalleryScrollState(scrollId: 0)
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(DataSavingModeUserDefaultsUtils.dataSavingModeKey, store: .dataSavingMode) private var dataSavingMode: Int = 0
    @AppStorage(DataSavingModeUserDefaultsUtils.disableImagePreviewKey, store: .dataSavingMode) private var disableImagePreview: Bool = false

    let post: Post
    let items: [GalleryItem]
    let onImageTap: (() -> Void)?
    
    private var isDataSavingModeActive: Bool {
        return DataSavingModeUserDefaultsUtils.isDataSavingModeActive(dataSavingMode: dataSavingMode, isWifiConnected: networkManager.isWifiConnected)
    }
    
    init(post: Post, onImageTap: (() -> Void)? = nil) {
        self.post = post
        self.items = post.galleryData!.items
        self.onImageTap = onImageTap
    }
    
    var body: some View {
        if isDataSavingModeActive && disableImagePreview {
            ZStack(alignment: .center) {
                SwiftUI.Image(systemName: "square.stack")
                    .noPreviewPostTypeIndicator()
            }
            .noPreviewPostTypeIndicatorBackground()
            .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
            .mediaTapGesture(post: post, aspectRatio: nil, matchedGeometryEffectId: nil)
        } else {
            ZStack(alignment: .topLeading) {
                TabView(selection: $galleryScrollState.scrollId) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        CustomWebImage(
                            getImageUrl(item),
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

                Text("\(galleryScrollState.scrollId + 1)/\(items.count)")
                    .padding(4)
                    .galleryIndexIndicator()
                    .cornerRadius(8)
                    .padding(12)
            }
        }
    }

    private func getImageUrl(_ item: GalleryItem) -> String {
        guard isDataSavingModeActive,
              let mediaMetadata = post.mediaMetadata?[item.mediaId],
              !mediaMetadata.p.isEmpty,
              let previewUrl = mediaMetadata.p.first?.u else {
            return item.urlString
        }
        
        return previewUrl
    }
}
