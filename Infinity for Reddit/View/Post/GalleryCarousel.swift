//
//  GalleryCarousel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-02.
//

import SwiftUI

struct GalleryCarousel: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @State private var scrollID: Int?
    
    var items: [GalleryItem]
    var mediaMetadata: [String: MediaMetadata]
    
    init(post: Post) {
        self.items = post.galleryData!.items
        self.mediaMetadata = post.mediaMetadata!
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TabView(selection: $scrollID) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if let media = mediaMetadata[item.mediaId], let preview = media.p.last {
                        CustomWebImage(preview.u, handleImageTapGesture: false)
                            .contentShape(Rectangle())
                            .highPriorityGesture(
                                TapGesture()
                                    .onEnded {
                                        withAnimation {
                                            fullScreenMediaViewModel.show(.gallery(items: items, mediaMetadata: mediaMetadata))
                                        }
                                    }
                            )
                            .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                            .tag(index)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            Text("\((scrollID ?? 0) + 1)/\(items.count)")
                .padding(4)
                .mediaIndicator()
                .cornerRadius(8)
                .padding(12)
        }
    }
}
