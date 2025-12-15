//
//  PostVideoView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-08.
//

import SwiftUI

struct PostVideoView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    @EnvironmentObject private var fullScreenMediaViewModel: FullScreenMediaViewModel

    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(VideoUserDefaultsUtils.videoAutoplayKey, store: .video) private var videoAutoplay: Int = 0
    @AppStorage(VideoUserDefaultsUtils.autoplaySensitiveVideoKey, store: .video) private var autoplaySensitiveVideo: Bool = true
    @AppStorage(VideoUserDefaultsUtils.muteAutoplayingVideoKey, store: .video) private var muteAutoplayingVideo: Bool = true
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    @AppStorage(DataSavingModeUserDefaultsUtils.dataSavingModeKey, store: .dataSavingMode) private var dataSavingMode: Int = 0
    @AppStorage(DataSavingModeUserDefaultsUtils.disableImagePreviewKey, store: .dataSavingMode) private var disableImagePreview: Bool = false
    @AppStorage(DataSavingModeUserDefaultsUtils.onlyDisablePreviewInVideoAndGIFKey, store: .dataSavingMode) private var onlyDisablePreviewInVideoAndGIF: Bool = false

    @State private var canPlay: Bool = false
    
    let post: Post
    let videoUrlString: String
    var inPostListing: Bool = false
    var onReadPost: (() -> Void)? = nil
    
    private var isDataSavingModeActive: Bool {
        return DataSavingModeUserDefaultsUtils.isDataSavingModeActive(dataSavingMode: dataSavingMode, isWifiConnected: networkManager.isWifiConnected)
    }
    
    private var shouldHideVideoPreview: Bool {
        return isDataSavingModeActive && (disableImagePreview || onlyDisablePreviewInVideoAndGIF)
    }
    
    var body: some View {
        Group {
            if !isDataSavingModeActive && VideoUserDefaultsUtils.canAutoplayVideo(videoAutoplay: videoAutoplay, isWifiConnected: networkManager.isWifiConnected) && ((post.over18 && autoplaySensitiveVideo) || !post.over18) {
                if let preview = post.preview, preview.images.count > 0, !(limitMediaHeight && inPostListing) {
                    InlineVideoPlayer(
                        videoURL: URL(string: videoUrlString)!,
                        aspectRatio: preview.images[0].source.aspectRatio,
                        muteVideo: muteAutoplayingVideo,
                        canPlay: canPlay,
                        isSensitive: post.over18
                    ) {
                        showFullScreenVideo()
                        if inPostListing {
                            onReadPost?()
                        }
                    }
                } else {
                    InlineVideoPlayer(
                        videoURL: URL(string: videoUrlString)!,
                        aspectRatio: nil,
                        muteVideo: muteAutoplayingVideo,
                        canPlay: canPlay,
                        isSensitive: post.over18
                    ) {
                        showFullScreenVideo()
                        if inPostListing {
                            onReadPost?()
                        }
                    }
                    .frame(height: 200)
                }
            } else {
                if !shouldHideVideoPreview, let preview = post.preview, preview.images.count > 0 {
                    ZStack(alignment: .topLeading) {
                        CustomWebImage(
                            getPreviewUrl(preview),
                            height: limitMediaHeight && inPostListing ? 200 : nil,
                            aspectRatio: limitMediaHeight && inPostListing ? nil : preview.images[0].source.aspectRatio,
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

                        SwiftUI.Image(systemName: "play.circle")
                            .resizable()
                            .mediaIndicator()
                            .padding(12)
                            .frame(width: 64, height: 64)
                    }
                    .frame(maxWidth: .infinity)
                    .applyIf(!limitMediaHeight || !inPostListing) {
                        $0.aspectRatio(preview.images[0].source.aspectRatio, contentMode: .fit)
                    }
                    .applyIf(limitMediaHeight && inPostListing) {
                        $0.frame(height: 200)
                    }
                } else {
                    ZStack {
                        SwiftUI.Image(systemName: "video")
                            .noPreviewPostTypeIndicator()
                    }
                    .noPreviewPostTypeIndicatorBackground()
                    .mediaTapGesture(post: post, aspectRatio: nil, matchedGeometryEffectId: nil)
                }
            }
        }
        .onVisiblePercentageChange { percent in
            canPlay = percent > 0.5
        }
    }
    
    private func getPreviewUrl(_ preview: Preview) -> String {
        return isDataSavingModeActive
        ? (preview.images[0].resolutions.first?.url ?? preview.images[0].source.url)
        : preview.images[0].source.url
    }
    
    private func showFullScreenVideo() {
        switch post.postType {
        case .redditVideo(let videoUrlString, _):
            fullScreenMediaViewModel.show(.video(urlString: videoUrlString, post: post))
        case .video(let videoUrlString, _):
            fullScreenMediaViewModel.show(.video(urlString: videoUrlString, post: post))
        case .gallery:
            if let items = post.galleryData?.items, let firstGalleryItem = items.first {
                fullScreenMediaViewModel.show(.gallery(currentUrlString: firstGalleryItem.urlString, post: post, items: items, galleryScrollState: GalleryScrollState(scrollId: 0)))
            }
        case .imgurVideo(let urlString):
            fullScreenMediaViewModel.show(.video(urlString: urlString, videoType: .direct))
        case .redgifs(let redgifsId):
            fullScreenMediaViewModel.show(.video(urlString: post.url, videoType: .redgifs(id: redgifsId)))
        case .streamable(let shortCode):
            fullScreenMediaViewModel.show(.video(urlString: post.url, videoType: .streamable(shortCode: shortCode)))
        default:
            break
        }
    }
}
