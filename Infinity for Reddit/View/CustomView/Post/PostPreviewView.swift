//
//  PostPreviewView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-13.
//

import SwiftUI

struct PostPreviewView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    let post: Post
    var inPostListing: Bool = false
    var compactMode: Bool = false
    var onReadPost: (() -> Void)? = nil
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    
    var body: some View {
        if let url = resolvedPreviewImageURL {
            ZStack(alignment: compactMode ? .center : .topLeading) {
                CustomWebImage(
                    url,
                    height: limitMediaHeight && inPostListing ? 200 : nil,
                    aspectRatio: limitMediaHeight && inPostListing ? nil : resolvedAspect,
                    handleImageTapGesture: !(compactMode && post.postType == .gallery),
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
                .applyIf(compactMode && inPostListing && post.postType == .gallery) {
                    $0.onTapGesture {
                        if let url = resolvedPreviewImageURL {
                            fullScreenMediaViewModel.show(
                                .gallery(
                                    currentUrlString: url,
                                    post: post,
                                    items: post.galleryData?.items ?? [],
                                    galleryScrollState: GalleryScrollState(scrollId: 0)
                                )
                            )
                            onReadPost?()
                        }
                    }
                }
                
                switch post.postType {
                case .redditVideo, .video, .imgurVideo, .redgifs, .streamable, .gif:
                    if compactMode {
                        SwiftUI.Image(systemName: "play.circle")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .mediaIndicator()
                            .padding(16)
                    } else {
                        SwiftUI.Image(systemName: "play.circle")
                            .resizable()
                            .mediaIndicator()
                            .padding(12)
                            .frame(width: 64, height: 64)
                    }
                case .link:
                    if compactMode {
                        SwiftUI.Image(systemName: "link.circle")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .mediaIndicator()
                            .padding(16)
                    } else {
                        SwiftUI.Image(systemName: "link.circle")
                            .resizable()
                            .mediaIndicator()
                            .padding(12)
                            .frame(width: 64, height: 64)
                    }
                case .gallery:
                    if compactMode {
                        SwiftUI.Image(systemName: "square.stack")
                            .resizable()
                            .scaledToFit()
                            .padding(2)
                            .mediaIndicator()
                            .padding(16)
                    }
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity)
            .applyIf(!limitMediaHeight || !inPostListing) {
                $0.modify { content in
                    if let size = resolvedAspect {
                        content.aspectRatio(size, contentMode: .fit)
                    } else {
                        content
                    }
                }
            }
            .applyIf(limitMediaHeight && inPostListing) {
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
    
    private var resolvedPreviewImageURL: String? {
        if let preview = post.preview, preview.images.count > 0, let url = preview.images[0].source.url {
            return url
        }
        
        if compactMode, let first = post.galleryData?.items.first,
           let url = first.urlString {
            return url
        }
        
        return nil
    }
    
    private var resolvedAspect: CGSize? {
        if let ratio = post.preview?.images.first?.source.aspectRatio {
            return ratio
        }
        if compactMode, post.galleryData != nil {
            return CGSize(width: 1, height: 1)
        }
        return nil
    }
}
