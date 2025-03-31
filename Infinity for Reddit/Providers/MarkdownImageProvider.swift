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
                    WebImage(url: URL(string: media.s.gif ?? ""))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 140)
                        .aspectRatio(CGFloat(media.s.y) / CGFloat(media.s.x), contentMode: .fill)
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
                
            } else {
                VStack {
                    WebImage(url: URL(string: media.s.u ?? ""))
                        .resizable()
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(CGFloat(media.s.y) / CGFloat(media.s.x), contentMode: .fill)
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
