//
//  ImgurFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-07.
//

import SwiftUI

struct ImgurFullScreenView: View {
    @StateObject private var imgurFullScreenViewModel: ImgurFullScreenViewModel
    @StateObject private var tabViewDismissalViewModel: TabViewDismissalViewModel

    @State private var selectedTab: Int = 0
    @State private var sheetImgurMediaItem: ImgurMediaItem?
    @State private var dismissStarted: Bool = false
    @State private var childViewHasZoomed: Bool = false
    
    let post: Post?
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 18
    
    init(imgurMediaType: ImgurMediaType, post: Post?, onDismiss: @escaping () -> Void) {
        self.post = post
        self._imgurFullScreenViewModel = StateObject(
            wrappedValue: ImgurFullScreenViewModel(imgurMediaType: imgurMediaType)
        )
        self._tabViewDismissalViewModel = StateObject(wrappedValue: .init())
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        Group {
            if let imgurMedia = imgurFullScreenViewModel.imgurMedia {
                TabView(selection: $selectedTab) {
                    ForEach(Array(imgurMedia.images.enumerated()), id: \.offset) { index, item in
                        if item.mediaType != .video {
                            ImgurImageView(
                                childViewHasZoomed: $childViewHasZoomed,
                                imgurMediaItem: item,
                                imgurMedia: imgurMedia,
                                post: post,
                                dismissStarted: dismissStarted,
                                onShowDescription: {
                                    sheetImgurMediaItem = item
                                }
                            ) {
                                tabViewDismissalViewModel.isDismissed = true
                                onDismiss()
                            }
                            .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                            .tag(index)
                        } else {
                            TabVideoView(
                                urlString: item.link,
                                imgurMedia: imgurMedia,
                                post: nil,
                                videoType: .direct,
                                downloadMediaType: item.toDownloadMediaType(post: post),
                                isSelected: selectedTab == index,
                                tabViewDismissalViewModel: tabViewDismissalViewModel,
                                hasDescription: !item.title.isEmpty || !item.description.isEmpty,
                                childViewHasZoomed: $childViewHasZoomed,
                                onShowDescription: {
                                    sheetImgurMediaItem = item
                                }
                            ) {
                                tabViewDismissalViewModel.isDismissed = true
                                onDismiss()
                            }
                            .tag(index)
                        }
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
                .tabViewStyle(.page(indexDisplayMode: .never))
                .tabItemMediaGesture(
                    dismissStarted: $dismissStarted,
                    childViewHasZoomed: childViewHasZoomed,
                    onDismiss: onDismiss
                )
            } else {
                ZStack {
                    Color.clear
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    onDismiss()
                                }
                            } label: {
                                SwiftUI.Image(systemName: "xmark")
                                    .font(.system(size: buttonSize))
                                    .padding(10)
                                    .foregroundColor(Color.white)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "#2E2E2E"))
                                    )
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding(16)
                    
                    if let error = imgurFullScreenViewModel.error {
                        VStack(spacing: 8) {
                            SwiftUI.Image(systemName: "info.circle")
                                .foregroundStyle(.white)
                            
                            Text("Failed to load imgur media. Error: \(error.localizedDescription)")
                                .foregroundStyle(.white)
                                .customFont()
                        }
                        .padding(16)
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
                .contentShape(Rectangle())
                .tabItemMediaGesture(
                    dismissStarted: $dismissStarted,
                    childViewHasZoomed: childViewHasZoomed,
                    onDismiss: onDismiss
                )
            }
        }
        .task {
            await imgurFullScreenViewModel.fetchImgurMedia()
        }
        .sheet(item: $sheetImgurMediaItem) { item in
            GalleryOrImgurDescriptionSheet(title: item.title, description: item.description, link: nil)
                .presentationDetents([.medium, .large])
        }
    }
}

struct ImgurImageView: View {
    @State private var isToolbarVisible: Bool = true
    
    @Binding var childViewHasZoomed: Bool
    
    let imgurMediaItem: ImgurMediaItem
    let imgurMedia: ImgurMedia
    let post: Post?
    let dismissStarted: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            CustomWebImage(
                imgurMediaItem.link,
                handleImageTapGesture: false
            )
            .tabItemMediaGesture(
                childViewHasZoomed: $childViewHasZoomed
            )
            .onTapGesture {
                if !dismissStarted {
                    withAnimation {
                        isToolbarVisible.toggle()
                    }
                }
            }
            
            ImgurImageToolbar(
                downloadMediaType: imgurMediaItem.toDownloadMediaType(post: post),
                isVisible: $isToolbarVisible,
                imgurMediaItem: imgurMediaItem,
                imgurMedia: imgurMedia,
                post: post,
                hasDescription: !imgurMediaItem.title.isEmpty || !imgurMediaItem.description.isEmpty,
                onShowDescription: onShowDescription,
                onDismiss: onDismiss
            )
        }
    }
}

struct ImgurImageToolbar: View {
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @Binding var isVisible: Bool
    
    let imgurMediaItem: ImgurMediaItem
    let imgurMedia: ImgurMedia
    let post: Post?
    let hasDescription: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 18
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
         imgurMediaItem: ImgurMediaItem,
         imgurMedia: ImgurMedia,
         post: Post?,
         hasDescription: Bool,
         onShowDescription: @escaping () -> Void,
         onDismiss: @escaping () -> Void
    ) {
        _fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self._isVisible = isVisible
        self.imgurMediaItem = imgurMediaItem
        self.imgurMedia = imgurMedia
        self.post = post
        self.hasDescription = hasDescription
        self.onShowDescription = onShowDescription
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack {
            if isVisible {
                HStack {
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            onDismiss()
                        }
                    } label: {
                        SwiftUI.Image(systemName: "xmark")
                            .font(.system(size: buttonSize))
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
                VStack(spacing: 16) {
                    HStack {
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
                        
                        if imgurMediaItem.mediaType == .image {
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
                        
                        if hasDescription {
                            Button {
                                onShowDescription()
                            } label: {
                                SwiftUI.Image(systemName: "info.circle")
                                    .font(.system(size: buttonSize))
                                    .padding(10)
                                    .foregroundColor(Color.white)
                                    .background(
                                        Circle()
                                            .fill(Color(hex: "#2E2E2E"))
                                    )
                            }
                        }
                        
                        Menu {
                            Button("Download all media") {
                                fullScreenMediaToolbarViewModel.downloadAllImgurMedia(imgurMedia: imgurMedia, post: post)
                            }
                        } label: {
                            SwiftUI.Image(systemName: "ellipsis.circle")
                                .font(.system(size: buttonSize))
                                .padding(10)
                                .foregroundColor(Color.white)
                                .background(
                                    Circle()
                                        .fill(Color(hex: "#2E2E2E"))
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .contentShape(Capsule())
                    
                    ZStack {
                        VStack {
                            Text("Downloading...")
                                .foregroundStyle(.white)
                                .customFont()
                            
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
                        
                        HStack {
                            SwiftUI.Image(systemName: "checkmark.seal")
                                .foregroundStyle(.white)
                                .customFont(fontSize: .f24)
                            
                            Text("Image downloaded")
                                .foregroundStyle(.white)
                                .customFont()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.showFinishedDownloadMessage ? 1 : 0)
                        
                        HStack {
                            SwiftUI.Image(systemName: "xmark.seal")
                                .foregroundStyle(.white)
                                .customFont(fontSize: .f24)
                            
                            Text("Download failed: \(fullScreenMediaToolbarViewModel.error?.localizedDescription ?? "Unknown error")")
                                .foregroundStyle(.white)
                                .customFont()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.error != nil ? 1 : 0)
                    }

                    ZStack {
                        VStack {
                            Text("Downloading all media...")
                                .foregroundStyle(.white)
                                .customFont()
                            
                            ProgressView(value: fullScreenMediaToolbarViewModel.downloadImgurAllMediaProgress)
                                .tint(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.downloadImgurAllMediaProgress == 0 ? 0 : 1)
                        
                        HStack {
                            SwiftUI.Image(systemName: "checkmark.seal")
                                .foregroundStyle(.white)
                                .customFont(fontSize: .f24)
                            
                            Text("All media downloaded")
                                .foregroundStyle(.white)
                                .customFont()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.showFinishedDownloadAllMediaMessage ? 1 : 0)
                        
                        HStack {
                            SwiftUI.Image(systemName: "xmark.seal")
                                .foregroundStyle(.white)
                                .customFont(fontSize: .f24)
                            
                            Text("Some media couldn’t be downloaded.")
                                .foregroundStyle(.white)
                                .customFont()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.hasErrorWhenDownloadAllMedia ? 1 : 0)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
