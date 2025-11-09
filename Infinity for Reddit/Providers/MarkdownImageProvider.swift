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

struct WebImageProvider: ImageProvider {
    var mediaMetadata: [String: MediaMetadata]?
    
    init(mediaMetadata: [String: MediaMetadata]?) {
        self.mediaMetadata = mediaMetadata
    }
    
    func makeImage(url: URL?) -> some View {
        if let unescapedUrl = url?.absoluteString.removingPercentEncoding, let media = mediaMetadata?[unescapedUrl] {
            if media.e == MediaMetadata.gifType {
                VStack {
                    CustomWebImage(
                        media.s.gif,
                        width: 140,
                        aspectRatio: media.s.aspectRatio
                    )
                    .onTapGesture{
                        if let url = url {
                            handleImageTap(url: url)
                        }
                    }
                    
                    if media.caption != nil {
                        // TODO make sure the text style is correct
                        Text(media.caption!)
                            .font(.system(size: 18))
                    }
                }
            } else if media.e == MediaMetadata.imageType {
                VStack {
                    CustomWebImage(
                        media.s.u,
                        aspectRatio: media.s.aspectRatio
                    )
                    .onTapGesture{
                        if let url = url {
                            handleImageTap(url: url)
                        }
                    }
                    
                    if media.caption != nil {
                        // TODO make sure the text style is correct
                        Text(media.caption!)
                            .font(.system(size: 18))
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
                            .font(.system(size: 18))
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
    
    private func handleImageTap(url: URL) {
        print("Image tapped: \(url)")
    }
}
