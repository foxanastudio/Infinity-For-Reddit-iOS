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
    
    let post: Post
    let videoUrl: String
    let onReadPost: () -> Void
    
    var body: some View {
        if VideoSettingsUserDefaultsUtils.canAutoplayVideo(videoAutoplay: videoAutoplay, isWifiConnected: networkManager.isWifiConnected)
            && ((post.over18 && autoplaySensitiveVideo) || !post.over18) {
            if let preview = post.preview, preview.images.count > 0 {
                InlineVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: preview.images[0].source.aspectRatio)
            } else {
                InlineVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: nil)
                    .frame(height: 400)
            }
        } else {
            if let preview = post.preview, preview.images.count > 0, let url = post.preview.images[0].source.url {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        CustomWebImage(
                            url,
                            aspectRatio: preview.images[0].source.aspectRatio,
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
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(preview.images[0].source.aspectRatio, contentMode: .fit)
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
