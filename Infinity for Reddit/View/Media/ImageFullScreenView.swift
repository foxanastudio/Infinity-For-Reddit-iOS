//
//  ImageFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-03.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageFullScreenView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject var namespaceManager: NamespaceManager
    
    let url: URL?
    let aspectRatio: CGSize?
    let matchedGeometryEffectId: String?
    let onDismiss: () -> Void
    
    var body: some View {
        CustomWebImage(
            url?.absoluteString ?? "",
            aspectRatio: aspectRatio,
            handleImageTapGesture: false,
            matchedGeometryEffectId: matchedGeometryEffectId
        )
        .mediaGesture(
            outOfBoundsColor: .black,
            onDragEnded: { transform in
                if transform.scaleX == 1 && transform.scaleY == 1 && abs(transform.ty) > 100 {
                    onDismiss()
                    return true
                }
                return false
            }
        )
    }
}
