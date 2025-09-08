//
//  PostVideoView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-08.
//

import SwiftUI

struct PostVideoView: View {
    let post: Post
    let videoUrl: String
    var videoAutoplay: Bool = true
    @Binding var blurSensitiveImages: Bool
    @Binding var blurSpoilerImages: Bool
    let onReadPost: () -> Void
    
    var body: some View {
        if videoAutoplay {
            if let preview = post.preview, preview.images.count > 0 {
                MarkdownVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: preview.images[0].source.aspectRatio)
            } else {
                MarkdownVideoPlayer(videoURL: URL(string: videoUrl)!, aspectRatio: nil)
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
