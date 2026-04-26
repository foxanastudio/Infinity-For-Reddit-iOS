//
//  GalleryFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-05.
//

import SwiftUI

struct GalleryFullScreenView: View {
    @StateObject private var tabViewDismissalViewModel: TabViewDismissalViewModel
    
    @ObservedObject private var galleryScrollState: GalleryScrollState
    @State private var sheetGalleryItem: GalleryItem?
    @State private var dismissStarted: Bool = false
    @State private var childViewHasZoomed: Bool = false
    
    let post: Post?
    var items: [GalleryItem]
    let onDismiss: () -> Void
    
    init(post: Post?, items: [GalleryItem], galleryScrollState: GalleryScrollState, onDismiss: @escaping () -> Void) {
        self.post = post
        self.items = items
        self.galleryScrollState = galleryScrollState
        self._tabViewDismissalViewModel = StateObject(wrappedValue: .init())
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        TabView(selection: $galleryScrollState.scrollId) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                if item.mediaType != .video {
                    GalleryImageView(
                        childViewHasZoomed: $childViewHasZoomed,
                        index: index,
                        item: item,
                        items: items,
                        post: post,
                        dismissStarted: dismissStarted,
                        onShowDescription: {
                            sheetGalleryItem = item
                        }
                    ) {
                        tabViewDismissalViewModel.isDismissed = true
                        onDismiss()
                    }
                    .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                    .tag(index)
                } else {
                    TabVideoView(
                        urlString: item.urlString,
                        galleryItems: items,
                        post: nil,
                        videoType: .direct,
                        downloadMediaType: item.toDownloadMediaType(post: post),
                        isSelected: galleryScrollState.scrollId == index,
                        tabViewDismissalViewModel: tabViewDismissalViewModel,
                        hasDescription: !item.caption.isEmpty || !item.captionUrl.isEmpty,
                        childViewHasZoomed: $childViewHasZoomed,
                        onShowDescription: {
                            sheetGalleryItem = item
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
        .sheet(item: $sheetGalleryItem) { item in
            GalleryOrImgurDescriptionSheet(title: nil, description: item.caption, link: item.captionUrl)
                .presentationDetents([.medium, .large])
        }
    }
}

struct GalleryImageView: View {
    @State private var isToolbarVisible: Bool = true
    
    @Binding var childViewHasZoomed: Bool
    
    let index: Int
    let item: GalleryItem
    let items: [GalleryItem]
    let post: Post?
    let dismissStarted: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            CustomWebImage(
                item.urlString,
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
            
            GalleryImageToolbar(
                downloadMediaType: item.toDownloadMediaType(post: post),
                isVisible: $isToolbarVisible,
                index: index,
                items: items,
                post: post,
                hasDescription: !item.caption.isEmpty || !item.captionUrl.isEmpty,
                onShowDescription: onShowDescription,
                onDismiss: onDismiss
            )
        }
    }
}

struct GalleryImageToolbar: View {
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @Binding var isVisible: Bool
    
    let index: Int
    let items: [GalleryItem]
    let post: Post?
    let hasDescription: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 18
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
         index: Int,
         items: [GalleryItem],
         post: Post?,
         hasDescription: Bool,
         onShowDescription: @escaping () -> Void,
         onDismiss: @escaping () -> Void
    ) {
        _fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self._isVisible = isVisible
        self.index = index
        self.items = items
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
                    
                    Text("\(index + 1)/\(items.count)")
                        .padding(10)
                        .foregroundColor(Color.white)
                        .customFont()
                        .background(
                            Capsule()
                                .fill(Color(hex: "#2E2E2E"))
                        )
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
                                fullScreenMediaToolbarViewModel.downloadAllGalleryMedia(items: items, post: post)
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
                            
                            ProgressView(value: fullScreenMediaToolbarViewModel.downloadGalleryAllMediaProgress)
                                .tint(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.downloadGalleryAllMediaProgress == 0 ? 0 : 1)
                        
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
