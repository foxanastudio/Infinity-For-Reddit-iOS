//
//  PostPreviewView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-13.
//

import SwiftUI

struct PostPreviewView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var networkManager: NetworkManager
    
    let post: Post
    var inPostListing: Bool = false
    var isInCompactLayout: Bool = false
    var onReadPost: (() -> Void)? = nil
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = true
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    @AppStorage(DataSavingModeUserDefaultsUtils.dataSavingModeKey, store: .dataSavingMode) private var dataSavingMode: Int = 0
    @AppStorage(DataSavingModeUserDefaultsUtils.disableImagePreviewKey, store: .dataSavingMode) private var disableImagePreview: Bool = false
    @AppStorage(DataSavingModeUserDefaultsUtils.onlyDisablePreviewInVideoAndGIFKey, store: .dataSavingMode) private var onlyDisablePreviewInVideoAndGIF: Bool = false
    
    var body: some View {
        if let url = previewUrlString {
            ZStack(alignment: isInCompactLayout ? .center : .topLeading) {
                CustomWebImage(
                    url,
                    width: isInCompactLayout ? 60 : nil,
                    height: limitMediaHeight && inPostListing && !isInCompactLayout ? 200 : (isInCompactLayout ? 60 : nil),
                    aspectRatio: (limitMediaHeight && inPostListing) || isInCompactLayout ? nil : aspectRatio,
                    handleImageTapGesture: !(isInCompactLayout && post.postType == .gallery),
                    centerCrop: true,
                    matchedGeometryEffectId: UUID().uuidString,
                    post: post,
                    blur: (post.over18 && blurSensitiveImages) || (post.spoiler && blurSpoilerImages)
                )
                .applyIf(inPostListing) {
                    $0.simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                onReadPost?()
                            }
                    )
                }
                .applyIf(isInCompactLayout && post.postType == .gallery) {
                    $0.onTapGesture {
                        if let url = previewUrlString {
                            fullScreenMediaViewModel.show(
                                .gallery(
                                    currentUrlString: url,
                                    post: post,
                                    items: post.galleryData?.items ?? [],
                                    galleryScrollState: GalleryScrollState(scrollId: 0)
                                )
                            )
                        }
                    }
                }
                
                switch post.postType {
                case .redditVideo, .video, .imgurVideo, .redgifs, .streamable, .gif:
                    SwiftUI.Image(systemName: "play.circle")
                        .resizable()
                        .mediaIndicator()
                        .applyIf(!isInCompactLayout) {
                            $0.padding(12)
                        }
                        .frame(width: isInCompactLayout ? 24 : 64, height: isInCompactLayout ? 24 : 64)
                case .link:
                    SwiftUI.Image(systemName: "link.circle")
                        .resizable()
                        .mediaIndicator()
                        .applyIf(!isInCompactLayout) {
                            $0.padding(12)
                        }
                        .frame(width: isInCompactLayout ? 24 : 64, height: isInCompactLayout ? 24 : 64)
                case .gallery:
                    if isInCompactLayout {
                        SwiftUI.Image(systemName: "square.stack")
                            .resizable()
                            .mediaIndicator()
                            .frame(width: 24, height: 24)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .applyIf((!limitMediaHeight || !inPostListing) && !isInCompactLayout) {
                $0.aspectRatio(aspectRatio ?? CGSize(width: 0, height: 0), contentMode: .fit)
            }
            .applyIf(limitMediaHeight && inPostListing && !isInCompactLayout) {
                $0.frame(height: 200)
            }
        } else if post.postType.isMedia {
            // No preview media
            ZStack {
                switch post.postType {
                case .redditVideo, .video, .imgurVideo, .redgifs, .streamable:
                    SwiftUI.Image(systemName: "video")
                        .noPreviewPostTypeIndicator()
                case .gallery:
                    SwiftUI.Image(systemName: "square.stack")
                        .noPreviewPostTypeIndicator()
                default:
                    // Image and some weird post types
                    SwiftUI.Image(systemName: "photo")
                        .noPreviewPostTypeIndicator()
                }
            }
            .noPreviewPostTypeIndicatorBackground()
            .mediaTapGesture(post: post, aspectRatio: nil, matchedGeometryEffectId: nil)
        }
    }
    
    private var previewUrlString: String? {
        let isDataSavingModeActive = DataSavingModeUserDefaultsUtils.isDataSavingModeActive(dataSavingMode: dataSavingMode, isWifiConnected: networkManager.isWifiConnected)

        if isDataSavingModeActive && (disableImagePreview || (onlyDisablePreviewInVideoAndGIF && post.postType.isVideoOrGif)){
            return nil
        }

        if isInCompactLayout || isDataSavingModeActive {
            if let url = post.preview?.images.first?.resolutions.first?.url {
                return url
            } else if let url = post.preview?.images.first?.source.url {
                return url
            } else if let url = post.galleryData?.items.first?.urlString {
                return url
            }
        } else {
            if let url = post.preview?.images.first?.source.url {
                return url
            }
        }
        
        return nil
    }
    
    private var aspectRatio: CGSize? {
        if isInCompactLayout {
            if let ratio = post.preview?.images.first?.resolutions.first?.aspectRatio {
                return ratio
            } else if let ratio = post.preview?.images.first?.source.aspectRatio {
                return ratio
            }
        } else {
            if let ratio = post.preview?.images.first?.source.aspectRatio {
                return ratio
            }
        }
        return nil
    }
}
