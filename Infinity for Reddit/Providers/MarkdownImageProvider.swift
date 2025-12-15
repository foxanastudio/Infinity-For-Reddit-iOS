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
    let markdownEmbeddedMediaType: MarkdownEmbeddedMediaType
    let isSensitive: Bool
    let fontSize: AppFontSize
    let linkColor: Color
    let fullScreenMediaViewModel: FullScreenMediaViewModel
    let onLinkTap: ((URL) -> Void)?
    let onFullScreenVideo: ((String) -> Void)?
    
    init(
        mediaMetadata: [String: MediaMetadata]?,
        markdownEmbeddedMediaType: Int = MarkdownEmbeddedMediaType.all.rawValue,
        isSensitive: Bool,
        fontSize: AppFontSize = .f17,
        // We don't care about the linkColor if it is not passed in
        linkColor: Color = .black,
        fullScreenMediaViewModel: FullScreenMediaViewModel,
        onLinkTap: ((URL) -> Void)? = nil,
        onFullScreenVideo: ((String) -> Void)? = nil
    ) {
        self.mediaMetadata = mediaMetadata
        self.markdownEmbeddedMediaType = MarkdownEmbeddedMediaType(rawValue: markdownEmbeddedMediaType) ?? .all
        self.isSensitive = isSensitive
        self.fontSize = fontSize
        self.linkColor = linkColor
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
        self.onLinkTap = onLinkTap
        self.onFullScreenVideo = onFullScreenVideo
    }
    
    func makeImage(url: URL?) -> some View {
        Group {
            if let unescapedUrl = url?.absoluteString.removingPercentEncoding, let media = mediaMetadata?[unescapedUrl] {
                if media.e == MediaMetadata.gifType {
                    if markdownEmbeddedMediaType.allowGif {
                        VStack(spacing: 8) {
                            CustomWebImage(
                                media.s?.gif,
                                width: 140,
                                aspectRatio: media.s?.aspectRatio,
                                handleImageTapGesture: false
                            )
                            .highPriorityGesture(TapGesture().onEnded {
                                if let urlString = media.s?.gif {
                                    onMediaTap(urlString: urlString, fileName: "\(Utils.randomString()).gif", isGif: true)
                                }
                            })
                            
                            if media.caption != nil {
                                Text(media.caption!)
                                    .secondaryText(.f15)
                            }
                        }
                    } else if let urlString = media.s?.gif {
                        VStack(spacing: 8) {
                            Text(getLinkAttributedString(urlString: urlString))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .linkText(.f15)
                            
                            if media.caption != nil {
                                Text(media.caption!)
                                    .secondaryText(.f15)
                            }
                        }
                    }
                } else if media.e == MediaMetadata.imageType {
                    if markdownEmbeddedMediaType.allowImage {
                        VStack(spacing: 8) {
                            CustomWebImage(
                                media.s?.u,
                                aspectRatio: media.s?.aspectRatio,
                                handleImageTapGesture: false
                            )
                            .highPriorityGesture(TapGesture().onEnded {
                                if let urlString = media.s?.u {
                                    onMediaTap(urlString: urlString, fileName: "\(Utils.randomString()).jpg", isGif: false)
                                }
                            })
                            
                            if media.caption != nil {
                                Text(media.caption!)
                                    .secondaryText(.f15)
                            }
                        }
                    } else if let urlString = media.s?.u {
                        VStack(spacing: 8) {
                            Text(getLinkAttributedString(urlString: urlString))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .linkText(.f15)
                            
                            if media.caption != nil {
                                Text(media.caption!)
                                    .secondaryText(.f15)
                            }
                        }
                    }
                } else if media.e == MediaMetadata.redditVideoType {
                    if markdownEmbeddedMediaType.allowVideo {
                        VStack {
                            if let url = URL(string: media.hlsUrl) {
                                InlineVideoPlayer(
                                    videoURL: url,
                                    aspectRatio: CGSize(width: media.x, height: media.y),
                                    muteVideo: VideoUserDefaultsUtils.muteAutoplayingVideo,
                                    isSensitive: isSensitive,
                                    onFullScreen: onFullScreenVideo == nil ? nil : {
                                        onFullScreenVideo?(media.hlsUrl)
                                    }
                                )
                                .id(url)
                            }
                            
                            if media.caption != nil {
                                Text(media.caption!)
                                    .secondaryText(.f15)
                            }
                        }
                    } else if let urlString = media.videoLinkMarkdown {
                        Text(getLinkAttributedString(urlString: urlString, caption: media.caption))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .linkText(.f15)
                    }
                } else {
                    EmptyView()
                }
            } else {
                // When there is no MediaMetadata
                EmptyView()
            }
        }
        .environment(\.openURL, OpenURLAction(handler: { url in
            onLinkTap?(url)
            return .handled
        }))
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
    
    private func getLinkAttributedString(urlString: String, caption: String? = nil) -> AttributedString {
        var attributedString = AttributedString(caption ?? urlString)
        attributedString.link = URL(string: urlString)!
        attributedString.foregroundColor = linkColor
        return attributedString
    }
}
