//
//  ImgurFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-07.
//

import SwiftUI

struct ImgurFullScreenView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var namespaceManager: NamespaceManager
    
    @StateObject private var imgurFullScreenViewModel: ImgurFullScreenViewModel
    @StateObject private var tabViewDismissalViewModel: TabViewDismissalViewModel

    @GestureState private var dragOffset: CGSize = .zero
    @State private var currentDragOffset = 0.0
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    @State private var selectedTab: Int = 0
    @State private var sheetImgurMediaItem: ImgurMediaItem?
    
    let post: Post?
    let onDismiss: () -> Void
    
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
                ZStack {
                    Color.black
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                    
                    TabView(selection: $selectedTab) {
                        ForEach(Array(imgurMedia.images.enumerated()), id: \.offset) { index, item in
                            if item.mediaType != .video {
                                ImgurImageView(
                                    imgurMediaItem: item,
                                    imgurMedia: imgurMedia,
                                    post: post,
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
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            } else {
                ZStack {
                    Color.black
                        .opacity(opacityForBackground)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .edgesIgnoringSafeArea(.all)
                        .ignoresSafeArea()
                    
                    ProgressIndicator()
                        .offset(y: currentDragOffset)
                }
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            // Only allow vertical drag to trigger dismiss
                            if !hasStartedDragging && abs(value.translation.width) < 4 {
                                hasStartedDragging = true
                            }
                            if hasStartedDragging {
                                state = value.translation
                            }
                        }
                        .onChanged { value in
                            // Adjust the scale based on the drag distance
                            if hasStartedDragging {
                                currentDragOffset = value.translation.height
                            }
                        }
                        .onEnded { value in
                            if hasStartedDragging && abs(value.translation.height) > 100 {
                                withAnimation(.linear(duration: 0.25)) {
                                    if value.translation.height < 0 {
                                        // Dragged up
                                        currentDragOffset = -UIScreen.main.bounds.height
                                    } else {
                                        // Dragged down
                                        currentDragOffset = UIScreen.main.bounds.height
                                    }
                                } completion: {
                                    onDismiss()
                                }
                            } else {
                                withAnimation {
                                    currentDragOffset = 0.0
                                }
                            }
                            hasStartedDragging = false
                        }
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
    
    private var opacityForBackground: Double {
        let maxOffset: CGFloat = UIScreen.main.bounds.height
        let offset = min(abs(currentDragOffset), maxOffset)
        return Double(1 - (offset / maxOffset))
    }
}

struct ImgurImageView: View {
    @State private var currentImageZoom: CGFloat = 1.0
    @State private var currentDragOffset = 0.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    @State private var isToolbarVisible: Bool = true
    
    let imgurMediaItem: ImgurMediaItem
    let imgurMedia: ImgurMedia
    let post: Post?
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            ZoomableScrollView(
                content: {
                    CustomWebImage(
                        imgurMediaItem.link,
                        handleImageTapGesture: false
                    )
                    .offset(y: currentDragOffset)
                },
                onSingleTap: {
                    withAnimation {
                        isToolbarVisible.toggle()
                    }
                },
                currentZoomScale: $currentImageZoom
            )
            .simultaneousGesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        // Only allow vertical drag to trigger dismiss
                        if !hasStartedDragging && abs(value.translation.width) < 4 && currentImageZoom == 1.0 {
                            hasStartedDragging = true
                        }
                        if hasStartedDragging {
                            state = value.translation
                        }
                    }
                    .onChanged { value in
                        // Adjust the scale based on the drag distance
                        if hasStartedDragging {
                            currentDragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        if hasStartedDragging && abs(value.translation.height) > 100 {
                            withAnimation(.linear(duration: 0.25)) {
                                if value.translation.height < 0 {
                                    // Dragged up
                                    currentDragOffset = -UIScreen.main.bounds.height
                                } else {
                                    // Dragged down
                                    currentDragOffset = UIScreen.main.bounds.height
                                }
                            } completion: {
                                onDismiss()
                            }
                        } else {
                            withAnimation {
                                currentDragOffset = 0.0
                            }
                        }
                        hasStartedDragging = false
                    }
            )
            
            ImgurImageToolbar(
                downloadMediaType: imgurMediaItem.toDownloadMediaType(post: post),
                isVisible: $isToolbarVisible,
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
    
    let imgurMedia: ImgurMedia
    let post: Post?
    let hasDescription: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 18
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
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
                        onDismiss()
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
                VStack {
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
                            
                            Text("Image downloaded")
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.showFinishedDownloadMessage ? 1 : 0)
                    }

                    ZStack {
                        VStack {
                            Text("Downloading all media...")
                                .foregroundStyle(.white)
                            
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
                            
                            Text("All media downloaded")
                                .foregroundStyle(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                        )
                        .opacity(fullScreenMediaToolbarViewModel.showFinishedDownloadAllMediaMessage ? 1 : 0)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
