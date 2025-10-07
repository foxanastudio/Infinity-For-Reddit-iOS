//
//  GalleryFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-05.
//

import SwiftUI

struct GalleryFullScreenView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var namespaceManager: NamespaceManager
    
    @StateObject private var tabViewDismissalViewModel: TabViewDismissalViewModel
    
    @ObservedObject private var galleryScrollState: GalleryScrollState
    @GestureState private var dragOffset: CGSize = .zero
    @State private var currentDragOffset = 0.0
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    
    var items: [GalleryItem]
    let onDismiss: () -> Void
    
    init(items: [GalleryItem], galleryScrollState: GalleryScrollState, onDismiss: @escaping () -> Void) {
        self.items = items
        self.galleryScrollState = galleryScrollState
        self._tabViewDismissalViewModel = StateObject(wrappedValue: .init())
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(opacityForBackground())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            TabView(selection: $galleryScrollState.scrollId) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if item.mediaType != .video {
                        GalleryImageView(urlString: item.urlString) {
                            tabViewDismissalViewModel.isDismissed = true
                            onDismiss()
                        }
                        .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                        .tag(index)
                    } else {
                        TabVideoView(
                            urlString: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
                            post: nil,
                            videoType: .direct,
                            isSelected: galleryScrollState.scrollId == index,
                            tabViewDismissalViewModel: tabViewDismissalViewModel
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
    }
    
    private func opacityForBackground() -> Double {
        let maxOffset: CGFloat = UIScreen.main.bounds.height
        let offset = min(abs(currentDragOffset), maxOffset)
        return Double(1 - (offset / maxOffset))
    }
}

struct GalleryImageView: View {
    @State private var currentImageZoom: CGFloat = 1.0
    @State private var currentDragOffset = 0.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    @State private var isToolbarVisible: Bool = true
    
    let urlString: String
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            ZoomableScrollView(
                content: {
                    CustomWebImage(
                        urlString,
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
            
            GalleryImageToolbar(
                downloadMediaType: .image(downloadUrlString: urlString, fileName: "test.jpg"),
                isVisible: $isToolbarVisible
            ) {
                onDismiss()
            }
        }
    }
}

struct GalleryImageToolbar: View {
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @Binding var isVisible: Bool
    
    let onDismiss: () -> Void
    
    private let buttonSize: CGFloat = 18
    
    init(downloadMediaType: DownloadMediaType,
         isVisible: Binding<Bool>,
         onDismiss: @escaping () -> Void
    ) {
        _fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self._isVisible = isVisible
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
                    
                    Menu {
                        Button("Download all media") {
                            
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
                .padding(.bottom, 64)
                .contentShape(Capsule())
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}
