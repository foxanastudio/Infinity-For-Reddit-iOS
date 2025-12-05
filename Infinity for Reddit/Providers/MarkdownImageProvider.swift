//
//  MarkdownImageProvider.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-27.
//

import MarkdownUI
import SDWebImageSwiftUI
import SwiftUI

// MARK: - WebImageProvider

struct MarkdownImageProvider: ImageProvider {
    let mediaMetadata: [String: MediaMetadata]?
    let fullScreenMediaViewModel: FullScreenMediaViewModel
    
    init(mediaMetadata: [String: MediaMetadata]?, fullScreenMediaViewModel: FullScreenMediaViewModel) {
        self.mediaMetadata = mediaMetadata
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
    }
    
    func makeImage(url: URL?) -> some View {
        if let unescapedUrl = url?.absoluteString.removingPercentEncoding, let media = mediaMetadata?[unescapedUrl] {
            if media.e == MediaMetadata.gifType {
                VStack {
                    CustomWebImage(
                        media.s.gif,
                        width: 140,
                        aspectRatio: media.s.aspectRatio,
                        handleImageTapGesture: false
                    )
                    .highPriorityGesture(TapGesture().onEnded {
                        onMediaTap(urlString: media.s.gif, fileName: "\(Utils.randomString()).gif", isGif: true)
                    })
                    
                    if media.caption != nil {
                        Text(media.caption!)
                            .secondaryText(.f15)
                    }
                }
            } else if media.e == MediaMetadata.imageType {
                VStack {
                    CustomWebImage(
                        media.s.u,
                        aspectRatio: media.s.aspectRatio,
                        handleImageTapGesture: false
                    )
                    .highPriorityGesture(TapGesture().onEnded {
                        onMediaTap(urlString: media.s.u, fileName: "\(Utils.randomString()).jpg", isGif: false)
                    })
                    
                    if media.caption != nil {
                        // TODO make sure the text style is correct
                        Text(media.caption!)
                            .secondaryText(.f15)
                    }
                }
            } else if media.e == MediaMetadata.redditVideoType {
                VStack {
                    if let url = URL(string: media.hlsUrl) {
                        InlineVideoPlayer(videoURL: url, aspectRatio: CGSize(width: media.x, height: media.y))
                            .id(url)
                    }
                    
                    if media.caption != nil {
                        // TODO make sure the text style is correct
                        Text(media.caption!)
                            .secondaryText(.f15)
                    }
                }
            } else {
                EmptyView()
            }
        } else {
            // When there is no MediaMetadata
            EmptyView()
        }
    }
    
    private func onMediaTap(urlString: String?, fileName: String, isGif: Bool) {
        if let urlString {
            if isGif {
                fullScreenMediaViewModel.show(.gif(urlString: urlString, fileName: fileName))
            } else {
                fullScreenMediaViewModel.show(.image(urlString: urlString, fileName: fileName))
            }
        }
    }
}
