//
//  VideoFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import SwiftUI
import AVKit
import SeekBar

struct VideoFullScreenView<Content: View>: View {
    @ObservedObject private var videoFullScreenViewModel: VideoFullScreenViewModel

    @State private var dismissStarted: Bool = false
    
    let urlString: String
    let post: Post?
    let videoType: VideoType
    let playbackTimeToSeekToInitially: Double
    let hasDescription: Bool
    // This is for wrapper view to control if the video can be played
    let canPlay: Bool
    let muteVideo: Bool
    let canDownload: Bool
    let downloadAllMediaMessageView: () -> Content
    let onShowDescription: (() -> Void)?
    let onDownloadAllMedia: (() -> Void)?
    let onDismiss: () -> Void
    
    init(
        urlString: String,
        post: Post?,
        videoType: VideoType,
        playbackTime: Double,
        videoFullScreenViewModel: VideoFullScreenViewModel,
        hasDescription: Bool = false,
        canPlay: Bool = true,
        muteVideo: Bool,
        canDownload: Bool = true,
        @ViewBuilder downloadAllMediaMessageView: @escaping () -> Content = { EmptyView() },
        onShowDescription: (() -> Void)? = nil,
        onDownloadAllMedia: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.urlString = urlString
        self.post = post
        self.videoType = videoType
        self.playbackTimeToSeekToInitially = playbackTime
        self.videoFullScreenViewModel = videoFullScreenViewModel
        self.hasDescription = hasDescription
        self.canPlay = canPlay
        self.muteVideo = muteVideo
        self.canDownload = canDownload
        self.downloadAllMediaMessageView = downloadAllMediaMessageView
        self.onShowDescription = onShowDescription
        self.onDownloadAllMedia = onDownloadAllMedia
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            PlayerView(player: videoFullScreenViewModel.player)
                .onTapGesture {
                    if !dismissStarted {
                        withAnimation {
                            videoFullScreenViewModel.toggleController()
                        }
                    }
                }
            
            if let error = videoFullScreenViewModel.error {
                HStack(spacing: 16) {
                    SwiftUI.Image(systemName: "play.slash.fill")
                        .foregroundColor(.white)
                        .customFont(fontSize: .f24)
                    
                    Text(error.localizedDescription)
                        .frame(alignment: .leading)
                        .foregroundStyle(.white)
                        .customFont(fontSize: .f17)
                }
                .padding(32)
            }
            
            if videoFullScreenViewModel.isShowingController {
                VideoController(
                    isPlaying: videoFullScreenViewModel.isPlaying,
                    duration: $videoFullScreenViewModel.duration,
                    currentTime: $videoFullScreenViewModel.currentTime,
                    isSeekingProgress: $videoFullScreenViewModel.isSeekingProgress,
                    hasAudio: $videoFullScreenViewModel.hasAudio,
                    isMuted: $videoFullScreenViewModel.isMuted,
                    playbackSpeed: $videoFullScreenViewModel.playbackSpeed,
                    title: post?.title,
                    downloadProgressTitle: videoFullScreenViewModel.downloadProgressTitle,
                    downloadProgress: videoFullScreenViewModel.downloadProgress,
                    showDownloadFinishedMessage: videoFullScreenViewModel.showDownloadFinishedMessage,
                    downloadError: videoFullScreenViewModel.downloadError,
                    hasDescription: hasDescription,
                    canDownload: canDownload,
                    onTogglePlayPause: {
                        if videoFullScreenViewModel.isPlaying {
                            videoFullScreenViewModel.pause(userPaused: true)
                        } else {
                            videoFullScreenViewModel.play()
                        }
                    },
                    onFastForward: {
                        let newTime = videoFullScreenViewModel.currentTime + 5
                        videoFullScreenViewModel.player.seek(
                            to: CMTime(seconds: min(videoFullScreenViewModel.duration, newTime), preferredTimescale: 600)
                        )
                    },
                    onRewind: {
                        let newTime = videoFullScreenViewModel.currentTime - 5
                        videoFullScreenViewModel.player.seek(
                            to: CMTime(seconds: min(videoFullScreenViewModel.duration, newTime), preferredTimescale: 600)
                        )
                    },
                    onDownload: {
                        videoFullScreenViewModel.downloadMedia(urlString: urlString, post: post, videoType: videoType)
                    },
                    downloadAllMediaMessageView: downloadAllMediaMessageView,
                    onResetControllerTimer: videoFullScreenViewModel.resetControllerTimer,
                    onRemoveControllerTimer: videoFullScreenViewModel.removeControllerTimer,
                    onShowDescription: onShowDescription,
                    onDownloadAllMedia: onDownloadAllMedia,
                    onDismiss: {
                        videoFullScreenViewModel.resetState()
                        withAnimation {
                            onDismiss()
                        }
                    }
                )
                .onTapGesture {
                    if !dismissStarted {
                        withAnimation {
                            videoFullScreenViewModel.toggleController()
                        }
                    }
                }
                .zIndex(1)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
        .applyIf(onDownloadAllMedia == nil) {
            // Not in TabVideoView
            $0.mediaGesture(
                onDragEnded: { transform in
                    if transform.scaleX == 1 && transform.scaleY == 1 && abs(transform.ty) > 100 {
                        return true
                    }
                    return false
                },
                onStartDismiss: {
                    dismissStarted = true
                    
                    withAnimation {
                        videoFullScreenViewModel.isShowingController = false
                    }
                },
                onDismiss: {
                    videoFullScreenViewModel.resetState()
                    videoFullScreenViewModel.removeControllerTimer()
                    onDismiss()
                }
            )
        }
        .appForegroundBackgroundListener(onAppEntersForeground: {
            videoFullScreenViewModel.play(respectUserPaused: true)
        }, onAppEntersBackground: {
            videoFullScreenViewModel.pause()
        })
        .onAppear {
            videoFullScreenViewModel.setCanPlay(to: canPlay)
        }
        .onReceive(videoFullScreenViewModel.$currentTime
            .removeDuplicates()
            .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
        ) { newValue in
            if videoFullScreenViewModel.isSeekingProgress {
                videoFullScreenViewModel.resetControllerTimer()
                videoFullScreenViewModel.player.seek(
                    to: CMTime(seconds: newValue, preferredTimescale: 600)
                )
            }
        }
        .onChange(of: videoFullScreenViewModel.isSeekingProgress) { _, newValue in
            if newValue && videoFullScreenViewModel.isPlaying {
                videoFullScreenViewModel.wasPlayingBeforeSeeking = true
                videoFullScreenViewModel.pause()
            } else if !newValue && videoFullScreenViewModel.wasPlayingBeforeSeeking {
                videoFullScreenViewModel.wasPlayingBeforeSeeking = false
                videoFullScreenViewModel.play()
            }
        }
        .onChange(of: videoFullScreenViewModel.isMuted) { _, newValue in
            videoFullScreenViewModel.player.isMuted = newValue
        }
        .onChange(of: videoFullScreenViewModel.playbackSpeed) { _, newValue in
            videoFullScreenViewModel.player.rate = Float(newValue)
        }
        .task {
            await videoFullScreenViewModel.loadAndPlay(urlString: urlString, videoType: videoType, muteVideo: muteVideo, playbackTimeToSeekToInitially: playbackTimeToSeekToInitially)
        }
    }
}

struct VideoController<Content: View>: View {
    let isPlaying: Bool
    @Binding var duration: Double
    @Binding var currentTime: Double
    @Binding var isSeekingProgress: Bool
    @Binding var hasAudio: Bool
    @Binding var isMuted: Bool
    @Binding var playbackSpeed: Double
    
    @State var showPlaybackSpeedSheet: Bool = false
    
    let title: String?
    let downloadProgressTitle: String
    let downloadProgress: Double
    let showDownloadFinishedMessage: Bool
    let downloadError: Error?
    let hasDescription: Bool
    let canDownload: Bool
    let onTogglePlayPause: () -> Void
    let onFastForward: () -> Void
    let onRewind: () -> Void
    let onDownload: () -> Void
    let downloadAllMediaMessageView: () -> Content
    let onResetControllerTimer: () -> Void
    let onRemoveControllerTimer: () -> Void
    let onShowDescription: (() -> Void)?
    let onDownloadAllMedia: (() -> Void)?
    let onDismiss: () -> Void
    
    init(
        isPlaying: Bool,
        duration: Binding<Double>,
        currentTime: Binding<Double>,
        isSeekingProgress: Binding<Bool>,
        hasAudio: Binding<Bool>,
        isMuted: Binding<Bool>,
        playbackSpeed: Binding<Double>,
        showPlaybackSpeedSheet: Bool = false,
        title: String? = nil,
        downloadProgressTitle: String,
        downloadProgress: Double,
        showDownloadFinishedMessage: Bool,
        downloadError: Error?,
        hasDescription: Bool,
        canDownload: Bool,
        onTogglePlayPause: @escaping () -> Void,
        onFastForward: @escaping () -> Void,
        onRewind: @escaping () -> Void,
        onDownload: @escaping () -> Void,
        @ViewBuilder downloadAllMediaMessageView: @escaping () -> Content = { EmptyView() },
        onResetControllerTimer: @escaping () -> Void,
        onRemoveControllerTimer: @escaping () -> Void,
        onShowDescription: (() -> Void)? = nil,
        onDownloadAllMedia: (() -> Void)? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.isPlaying = isPlaying
        _duration = duration
        _currentTime = currentTime
        _isSeekingProgress = isSeekingProgress
        _hasAudio = hasAudio
        _isMuted = isMuted
        _playbackSpeed = playbackSpeed
        _showPlaybackSpeedSheet = State(initialValue: showPlaybackSpeedSheet)
        self.title = title
        self.downloadProgressTitle = downloadProgressTitle
        self.downloadProgress = downloadProgress
        self.showDownloadFinishedMessage = showDownloadFinishedMessage
        self.downloadError = downloadError
        self.hasDescription = hasDescription
        self.canDownload = canDownload
        self.onTogglePlayPause = onTogglePlayPause
        self.onFastForward = onFastForward
        self.onRewind = onRewind
        self.onDownload = onDownload
        self.downloadAllMediaMessageView = downloadAllMediaMessageView
        self.onResetControllerTimer = onResetControllerTimer
        self.onRemoveControllerTimer = onRemoveControllerTimer
        self.onShowDescription = onShowDescription
        self.onDownloadAllMedia = onDownloadAllMedia
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack(spacing: 12) {
                    Button {
                        onDismiss()
                    } label: {
                        SwiftUI.Image(systemName: "xmark")
                            .font(.system(size: 24))
                            .foregroundColor(Color.white)
                    }
                    
                    Spacer()
                    
                    if hasAudio {
                        ZStack {
                            SwiftUI.Image(systemName: "speaker.slash")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .opacity(isMuted ? 1 : 0)
                            
                            SwiftUI.Image(systemName: "speaker.wave.2")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .opacity(isMuted ? 0 : 1)
                        }
                        .onTapGesture {
                            isMuted.toggle()
                            onResetControllerTimer()
                        }
                    }
                    
                    if canDownload {
                        Button {
                            onDownload()
                            onResetControllerTimer()
                        } label: {
                            SwiftUI.Image(systemName: "arrow.down.square")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    Button {
                        showPlaybackSpeedSheet.toggle()
                    } label: {
                        SwiftUI.Image(systemName: "gauge.with.dots.needle.67percent")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                    }
                    
                    if hasDescription {
                        Button {
                            onShowDescription?()
                        } label: {
                            SwiftUI.Image(systemName: "info.circle")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                    
                    if let onDownloadAllMedia {
                        Button {
                            onDownloadAllMedia()
                        } label: {
                            SwiftUI.Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(16)
                .transition(.move(edge: .top).combined(with: .opacity))
                
                Spacer()
            }
            .padding(.top, 48)
            
            HStack(spacing: 48) {
                Button {
                    onRewind()
                    onResetControllerTimer()
                } label: {
                    SwiftUI.Image(systemName: "backward.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
                
                Button {
                    onTogglePlayPause()
                    onResetControllerTimer()
                } label: {
                    ZStack {
                        SwiftUI.Image(systemName: "pause.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .opacity(isPlaying ? 1 : 0)
                        
                        SwiftUI.Image(systemName: "play.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .opacity(isPlaying ? 0 : 1)
                    }
                }
                
                Button {
                    onFastForward()
                    onResetControllerTimer()
                } label: {
                    SwiftUI.Image(systemName: "forward.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
            }
            
            VStack(spacing: 16) {
                Spacer()
                
                downloadAllMediaMessageView()
                
                ZStack {
                    VStack {
                        Text(downloadProgressTitle)
                            .foregroundStyle(.white)
                            .customFont(fontSize: .f17)
                        
                        ProgressView(value: downloadProgress)
                            .tint(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .opacity(downloadProgress == 0 ? 0 : 1)
                    
                    HStack {
                        SwiftUI.Image(systemName: "checkmark.seal")
                            .foregroundStyle(.white)
                            .customFont(fontSize: .f24)
                        
                        Text("Video downloaded")
                            .foregroundStyle(.white)
                            .customFont(fontSize: .f17)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .opacity(showDownloadFinishedMessage ? 1 : 0)
                    
                    HStack {
                        SwiftUI.Image(systemName: "xmark.seal")
                            .foregroundStyle(.white)
                            .customFont(fontSize: .f24)
                        
                        Text("Download failed: \(downloadError?.localizedDescription ?? "Unknown error")")
                            .foregroundStyle(.white)
                            .customFont(fontSize: .f17)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#6B6B6B", opacity: 0.5))
                    )
                    .opacity(downloadError != nil ? 1 : 0)
                }
                
                if let title {
                    RowText(title)
                        .foregroundStyle(.white)
                }
                
                ZStack(alignment: .bottom) {
                    HStack(spacing: 0) {
                        Text(formatTime(currentTime))
                            .foregroundStyle(.white)
                            .customFont()
                        
                        Spacer()
                        
                        Text(formatTime(duration))
                            .foregroundStyle(.white)
                            .customFont()
                    }
                    .padding(.bottom, 32)
                    
                    SeekBar(value: $currentTime, in: 0...duration, onEditingChanged: { isEditing in
                        withAnimation {
                            isSeekingProgress = isEditing
                        }
                        onResetControllerTimer()
                    })
                    .seekBarDisplay(with: .trackOnly)
                    .trackDimensions(
                        trackHeight: isSeekingProgress ? 24 : 16,
                        inactiveTrackCornerRadius: 24
                    )
                    .trackColors(activeTrackColor: .white, inactiveTrackColor: .gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .onChange(of: showPlaybackSpeedSheet) { oldValue, newValue in
            if newValue {
                onRemoveControllerTimer()
            } else {
                onResetControllerTimer()
            }
        }
        .wrapContentSheet(isPresented: $showPlaybackSpeedSheet) {
            PlaybackSpeedSheet(playbackSpeed: $playbackSpeed) {
                showPlaybackSpeedSheet = false
            }
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

private struct PlaybackSpeedSheet: View {
    @Binding var playbackSpeed: Double
    
    let onDismiss: () -> Void
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(Array(VideoUserDefaultsUtils.playbackSpeeds.indices), id: \.self) { index in
                    Button {
                        playbackSpeed = VideoUserDefaultsUtils.playbackSpeeds[index]
                        onDismiss()
                    } label: {
                        HStack {
                            Text(VideoUserDefaultsUtils.playbackSpeedsText[index])
                                .primaryText()
                            
                            Spacer()
                            
                            if playbackSpeed == VideoUserDefaultsUtils.playbackSpeeds[index] {
                                SwiftUI.Image(systemName: "checkmark.seal")
                                    .primaryIcon()
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
    }
}
