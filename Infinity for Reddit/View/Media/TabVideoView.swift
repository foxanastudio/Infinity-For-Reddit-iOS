//
//  TabVideoView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-02.
//

import SwiftUI

struct TabVideoView: View {
    @StateObject private var videoFullScreenViewModel: VideoFullScreenViewModel
    @StateObject private var fullScreenMediaToolbarViewModel: FullScreenMediaToolbarViewModel
    
    @ObservedObject var tabViewDismissalViewModel: TabViewDismissalViewModel
    
    @Binding var childViewHasZoomed: Bool
    
    let urlString: String
    
    // The following two are for downloading all media. Null-able
    let imgurMedia: ImgurMedia?
    let galleryItems: [GalleryItem]?
    
    let post: Post?
    let videoType: VideoType
    let isSelected: Bool
    let hasDescription: Bool
    let onShowDescription: () -> Void
    let onDismiss: () -> Void
    
    // downloadMediaType is not used here as the download is handled by VideoFullScreenViewModel.
    // We need FullScreenMediaToolbarViewModel to handle downloading all media.
    init(urlString: String,
         imgurMedia: ImgurMedia? = nil,
         galleryItems: [GalleryItem]? = nil,
         post: Post?,
         videoType: VideoType,
         downloadMediaType: DownloadMediaType,
         isSelected: Bool,
         tabViewDismissalViewModel: TabViewDismissalViewModel,
         hasDescription: Bool,
         childViewHasZoomed: Binding<Bool>,
         onShowDescription: @escaping () -> Void,
         onDismiss: @escaping () -> Void
    ) {
        self.urlString = urlString
        self.imgurMedia = imgurMedia
        self.galleryItems = galleryItems
        self.post = post
        self.videoType = videoType
        self._videoFullScreenViewModel = StateObject(wrappedValue: .init())
        self._fullScreenMediaToolbarViewModel = StateObject(
            wrappedValue: FullScreenMediaToolbarViewModel(downloadMediaType: downloadMediaType)
        )
        self.isSelected = isSelected
        self.hasDescription = hasDescription
        self._childViewHasZoomed = childViewHasZoomed
        self.onShowDescription = onShowDescription
        self.tabViewDismissalViewModel = tabViewDismissalViewModel
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VideoFullScreenView(
            urlString: urlString,
            post: nil,
            videoType: .direct,
            playbackTime: 0,
            videoFullScreenViewModel: videoFullScreenViewModel,
            hasDescription: hasDescription,
            canPlay: isSelected,
            muteVideo: VideoUserDefaultsUtils.muteVideo || ((post?.over18 ?? false) && VideoUserDefaultsUtils.muteSensitiveVideo),
            downloadAllMediaMessageView: {
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
                }
            },
            onShowDescription: onShowDescription,
            onDownloadAllMedia: {
                if let imgurMedia {
                    fullScreenMediaToolbarViewModel.downloadAllImgurMedia(imgurMedia: imgurMedia, post: post)
                } else if let galleryItems {
                    fullScreenMediaToolbarViewModel.downloadAllGalleryMedia(items: galleryItems, post: post)
                }
            }
        ) {
            withAnimation(.easeInOut(duration: 0.15)) {
                onDismiss()
            }
        }
        .tabItemMediaGesture(
            childViewHasZoomed: $childViewHasZoomed
        )
        .onChange(of: isSelected) { _, newValue in
            videoFullScreenViewModel.setCanPlay(to: newValue)
            if newValue {
                videoFullScreenViewModel.play(respectUserPaused: true)
            } else {
                videoFullScreenViewModel.pause()
            }
        }
        .onChange(of: tabViewDismissalViewModel.isDismissed) { _, newValue in
            if newValue {
                videoFullScreenViewModel.resetState()
            }
        }
    }
}
