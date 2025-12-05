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
    let fileName: String
    let matchedGeometryEffectId: String?
    let isGif: Bool
    let onDismiss: () -> Void
    
    init(urlString: String, fileName: String, matchedGeometryEffectId: String? = nil, isGif: Bool, onDismiss: @escaping () -> Void) {
        self.urlString = urlString
        self.fileName = fileName
        self.matchedGeometryEffectId = matchedGeometryEffectId
        self.isGif = isGif
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
                downloadMediaType: DownloadMediaType.image(downloadUrlString: urlString, fileName: fileName),
                isVisible: $isToolbarVisible,
                isGif: isGif,
                onDismiss: {
                    withAnimation {
                        onDismiss()
                    }
                }
            )
            .zIndex(1)
        }
    }
}

struct ImageFullScreenToolbar: View {
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @Binding var isVisible: Bool
    
    let isGif: Bool
    
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 24
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
         isGif: Bool,
         onDismiss: @escaping () -> Void
    ) {
        _fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self._isVisible = isVisible
        self.isGif = isGif
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        SwiftUI.Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#2E2E2E"))
                            )
                    }
                    
                    Spacer()
                }
                .padding(16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            if isVisible {
                VStack(spacing: 0) {
                    HStack(spacing: 8) {
                        Button {
                            fullScreenMediaToolbarViewModel.downloadMedia()
                        } label: {
                            SwiftUI.Image(systemName: "square.and.arrow.down")
                                .font(.system(size: buttonSize))
                                .padding(.horizontal, 10)
                                .padding(.top, 12)
                                .padding(.bottom, 14)
                                .foregroundColor(Color.white)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#2E2E2E"))
                                )
                        }
                        
                        if !isGif {
                            Button {
                                fullScreenMediaToolbarViewModel.shareImage()
                            } label: {
                                SwiftUI.Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: buttonSize))
                                    .padding(.horizontal, 10)
                                    .padding(.top, 12)
                                    .padding(.bottom, 14)
                                    .foregroundColor(Color.white)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "#2E2E2E"))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .contentShape(Capsule())
                    
                    VStack {
                        Text("Downloading...")
                            .foregroundStyle(.white)
                        
                        ProgressView(value: fullScreenMediaToolbarViewModel.downloadProgress)
                            .tint(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .opacity(fullScreenMediaToolbarViewModel.downloadProgress == 0 ? 0 : 1)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
