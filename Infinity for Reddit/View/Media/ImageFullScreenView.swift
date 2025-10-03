//
//  ImageFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageFullScreenView: View {
    @State private var isToolbarVisible: Bool = true
    
    let urlString: String
    let matchedGeometryEffectId: String?
    let onDismiss: () -> Void
    
    init(urlString: String, matchedGeometryEffectId: String? = nil, onDismiss: @escaping () -> Void) {
        self.urlString = urlString
        self.matchedGeometryEffectId = matchedGeometryEffectId
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            CustomWebImage(
                urlString,
                handleImageTapGesture: false,
                matchedGeometryEffectId: matchedGeometryEffectId
            )
            .mediaGesture(
                outOfBoundsColor: .black,
                onDragEnded: { transform in
                    if transform.scaleX == 1 && transform.scaleY == 1 && abs(transform.ty) > 100 {
                        return true
                    }
                    return false
                },
                onDismiss: onDismiss
            )
            .onTapGesture {
                withAnimation {
                    isToolbarVisible.toggle()
                }
            }
            
            ImageFullScreenToolbar(
                downloadMediaType: DownloadMediaType.image(downloadUrlString: urlString, fileName: "test.jpg"),
                isVisible: $isToolbarVisible,
                onClose: {
                    withAnimation {
                        onDismiss()
                    }
                }
            )
            .zIndex(1)
        }
    }
}
