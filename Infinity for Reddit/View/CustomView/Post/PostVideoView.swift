//
//  PostVideoView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-08.
//

import SwiftUI

struct PostVideoView: View {
    @EnvironmentObject private var networkManager: NetworkManager
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSensitiveImagesKey, store: .contentSensitivityFilter) private var blurSensitiveImages: Bool = false
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.blurSpoilerImagesKey, store: .contentSensitivityFilter) private var blurSpoilerImages: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.videoAutoplayKey, store: .video) private var videoAutoplay: Int = 0
    @AppStorage(VideoSettingsUserDefaultsUtils.autoplaySensitiveVideoKey, store: .video) private var autoplaySensitiveVideo: Bool = true
    @AppStorage(VideoSettingsUserDefaultsUtils.muteAutoplayingVideoKey, store: .video) private var muteAutoplayingVideo: Bool = true
    @AppStorage(InterfacePostUserDefaultsUtils.limitMediaHeightKey, store: .interfacePost) private var limitMediaHeight: Bool = false
    
    let post: Post
    let videoUrl: String
    var inPostListing: Bool = false
    let onReadPost: () -> Void
    
    var body: some View {
        if VideoSettingsUserDefaultsUtils.canAutoplayVideo(videoAutoplay: videoAutoplay, isWifiConnected: networkManager.isWifiConnected)
            && ((post.over18 && autoplaySensitiveVideo) || !post.over18) {
            if let preview = post.preview, preview.images.count > 0, !(limitMediaHeight && inPostListing) {
                InlineVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: preview.images[0].source.aspectRatio, muteVideo: muteAutoplayingVideo)
            } else {
                InlineVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: nil, muteVideo: muteAutoplayingVideo)
                    .frame(height: 200)
            }
        } else {
            if let preview = post.preview, preview.images.count > 0, let url = post.preview.images[0].source.url {
                ZStack(alignment: .topLeading) {
                    CustomWebImage(
                        url,
                        height: limitMediaHeight && inPostListing ? 200 : nil,
                        aspectRatio: limitMediaHeight && inPostListing ? nil : preview.images[0].source.aspectRatio,
                        centerCrop: true,
                        matchedGeometryEffectId: UUID().uuidString,
                        post: post,
                        blur: (post.over18 && blurSensitiveImages) || (post.spoiler && blurSpoilerImages)
                    )
                    .simultaneousGesture(
                        TapGesture()
                            .onEnded {
                                onReadPost()
                            }
                    )
                    
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
}
