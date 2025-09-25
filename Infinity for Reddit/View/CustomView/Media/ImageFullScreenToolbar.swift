//
//  ImageFullScreenToolbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-24.
//

import SwiftUI

struct ImageFullScreenToolbar: View {
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @Binding var isVisible: Bool
    
    //let onDownload: () -> Void
    let onSetAsWallpaper: () -> Void
    let onShare: () -> Void
    let onClose: () -> Void
    
    private let buttonSize: CGFloat = 24
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
         onSetAsWallpaper: @escaping () -> Void,
         onShare: @escaping () -> Void,
         onClose: @escaping () -> Void
    ) {
        _fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self._isVisible = isVisible
        self.onSetAsWallpaper = onSetAsWallpaper
        self.onShare = onShare
        self.onClose = onClose
    }
    
    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    Button {
                        onClose()
                    } label: {
                        SwiftUI.Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .padding(10)
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#08cf75"))
                            )
                    }
                    
                    Spacer()
                }
                .padding(16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            if isVisible {
                HStack {
                    Button {
                        fullScreenMediaToolbarViewModel.downloadMedia()
                    } label: {
                        SwiftUI.Image(systemName: "square.and.arrow.down")
                            .font(.system(size: buttonSize))
                            .padding(.horizontal, 8)
                            .padding(.top, 6)
                            .padding(.bottom, 10)
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#08cf75"))
                            )
                    }
                    
                    Button {
                        onSetAsWallpaper()
                    } label: {
                        SwiftUI.Image(systemName: "photo.on.rectangle")
                            .font(.system(size: buttonSize - 4))
                            .padding(12)
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#08cf75"))
                            )
                    }
                    
                    Button {
                        onShare()
                    } label: {
                        SwiftUI.Image(systemName: "square.and.arrow.up")
                            .font(.system(size: buttonSize))
                            .padding(.horizontal, 8)
                            .padding(.top, 6)
                            .padding(.bottom, 10)
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color(hex: "#08cf75"))
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: "#b6f2d7", opacity: 0.5))
                )
                .padding(.bottom, 64)
                .contentShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
