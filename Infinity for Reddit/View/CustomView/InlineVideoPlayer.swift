//
//  InlineVideoPlayer.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import SwiftUI
import AVKit
import SeekBar

struct InlineVideoPlayer: View {
    @EnvironmentObject private var networkManager: NetworkManager
    
    @ObservedObject private var videoPlayerViewModel: VideoPlayerViewModel
    
    @State private var showPlayer: Bool?
    
    @AppStorage(VideoUserDefaultsUtils.videoAutoplayKey, store: .video) private var videoAutoplay: Int = 0
    @AppStorage(VideoUserDefaultsUtils.autoplaySensitiveVideoKey, store: .video) private var autoplaySensitiveVideo: Bool = true
    @AppStorage(DataSavingModeUserDefaultsUtils.dataSavingModeKey, store: .dataSavingMode) private var dataSavingMode: Int = 0
    
    let videoURL: URL
    let player: AVPlayer
    private let aspectRatio: CGSize?
    private let muteVideo: Bool
    private let canPlay: Bool
    private let isSensitive: Bool
    private let playbackTimeToSeekToInitially: Double
    private let onFullScreen: (() -> Void)?
    
    init(
        videoURL: URL,
        aspectRatio: CGSize?,
        muteVideo: Bool = false,
        canPlay: Bool = true,
        isSensitive: Bool,
        playbackTimeToSeekToInitially: Double = 0,
        videoPlayerViewModel: VideoPlayerViewModel,
        onFullScreen: (() -> Void)? = nil
    ) {
        self.videoURL = videoURL
        self.player = AVPlayer(url: ProxyManager.shared.proxyURL(videoURL))
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
        self.canPlay = canPlay
        self.isSensitive = isSensitive
        self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
        self.videoPlayerViewModel = videoPlayerViewModel
        self.onFullScreen = onFullScreen
        self.showPlayer = false
    }

    var body: some View {
        Group {
            if showPlayer == true {
                InlineVideoPlayerWithControls(
                    url: videoURL,
                    aspectRatio: aspectRatio,
                    muteVideo: muteVideo,
                    canPlay: canPlay,
                    playbackTimeToSeekToInitially: playbackTimeToSeekToInitially,
                    videoPlayerViewModel: videoPlayerViewModel,
                    onFullScreen: onFullScreen
                )
            } else {
                VStack {
                    Spacer()
                    
                    SwiftUI.Image(systemName: "play.circle.fill")
                        .resizable()
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .onTapGesture {
                    showPlayer = true
                }
            }
        }
        .applyIf(aspectRatio != nil) {
            $0.aspectRatio(aspectRatio!, contentMode: .fit)
        }
        .onAppear {
            if showPlayer == nil {
                showPlayer = !isDataSavingModeActive && VideoUserDefaultsUtils.canAutoplayVideo(videoAutoplay: videoAutoplay, isWifiConnected: networkManager.isWifiConnected) && ((isSensitive && autoplaySensitiveVideo) || !isSensitive)
            }
        }
    }
    
    private var isDataSavingModeActive: Bool {
        return DataSavingModeUserDefaultsUtils.isDataSavingModeActive(dataSavingMode: dataSavingMode, isWifiConnected: networkManager.isWifiConnected)
    }
}

struct InlineVideoPlayerWithSelfContainedViewModel: View {
    @StateObject private var videoPlayerViewModel: VideoPlayerViewModel
    
    let videoURL: URL
    private let aspectRatio: CGSize?
    private let muteVideo: Bool
    private let canPlay: Bool
    private let isSensitive: Bool
    private let onFullScreen: (() -> Void)?
    
    init(videoURL: URL, aspectRatio: CGSize?, muteVideo: Bool = false, canPlay: Bool = true, isSensitive: Bool, onFullScreen: (() -> Void)? = nil) {
        self.videoURL = videoURL
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
        self.canPlay = canPlay
        self.isSensitive = isSensitive
        self.onFullScreen = onFullScreen
        self._videoPlayerViewModel = StateObject(wrappedValue: VideoPlayerViewModel())
    }
    
    var body: some View {
        InlineVideoPlayer(
            videoURL: videoURL,
            aspectRatio: aspectRatio,
            muteVideo: VideoUserDefaultsUtils.muteAutoplayingVideo,
            isSensitive: isSensitive,
            videoPlayerViewModel: videoPlayerViewModel,
            onFullScreen: onFullScreen
        )
    }
}

private struct InlineVideoPlayerWithControls: View {
    @Environment(\.postListingVideoManager) private var postListingVideoManager: PostListingVideoManager?
    @EnvironmentObject private var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @ObservedObject private var videoPlayerViewModel: VideoPlayerViewModel
    
    let canPlay: Bool
    
    private let url: URL
    private let aspectRatio: CGSize?
    private let muteVideo: Bool
    private let playbackTimeToSeekToInitially: Double
    private let onFullScreen: (() -> Void)?

    init(
        url: URL,
        aspectRatio: CGSize?,
        muteVideo: Bool = false,
        canPlay: Bool,
        playbackTimeToSeekToInitially: Double,
        videoPlayerViewModel: VideoPlayerViewModel,
        onFullScreen: (() -> Void)?
    ) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
        self.canPlay = canPlay
        self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
        self.videoPlayerViewModel = videoPlayerViewModel
        self.onFullScreen = onFullScreen
    }

    var body: some View {
        ZStack {
            InlineVideoAVPlayer(player: videoPlayerViewModel.player)
                .contentShape(Rectangle())
                .onTapGesture {
                    videoPlayerViewModel.toggleControls()
                }

            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    
                    ZStack(alignment: .bottom) {
                        HStack(spacing: 0) {
                            Text(formatTime(videoPlayerViewModel.currentTime))
                                .foregroundColor(.white)
                                .customFont(fontSize: .f11)

                            Spacer()

                            Text(formatTime(videoPlayerViewModel.duration))
                                .foregroundColor(.white)
                                .customFont(fontSize: .f11)
                        }
                        .padding(.bottom, 28)
                        
                        SeekBar(value: $videoPlayerViewModel.currentTime, in: 0...videoPlayerViewModel.duration, onEditingChanged: { editing in
                            withAnimation {
                                videoPlayerViewModel.isDragging = editing
                            }
                            if !editing {
                                videoPlayerViewModel.seek(to: videoPlayerViewModel.currentTime)
                            }
                        })
                        .seekBarDisplay(with: .trackOnly)
                        .trackDimensions(
                            trackHeight: videoPlayerViewModel.isDragging ? 24 : 16,
                            inactiveTrackCornerRadius: 24
                        )
                        .trackColors(activeTrackColor: .white, inactiveTrackColor: .gray)
                        .onChange(of: videoPlayerViewModel.currentTime, initial: false) { _, _  in
                            if videoPlayerViewModel.isDragging {
                                videoPlayerViewModel.resetControlsTimer()
                            }
                        }
                    }
                    .padding(.bottom, 16)
                    .padding(.horizontal, 16)
                }
                
                HStack(spacing: 48) {
                    if videoPlayerViewModel.hasAudio {
                        Button(action: {
                            let isMuted = videoPlayerViewModel.toggleMute()
                            videoPlayerViewModel.resetControlsTimer()
                            postListingVideoManager?.isMuted = isMuted
                        }) {
                            SwiftUI.Image(systemName: videoPlayerViewModel.isMuted ? "speaker.slash" : "speaker.wave.2")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Spacer()
                            .frame(width: 24)
                    }
                    
                    Button(action: {
                        videoPlayerViewModel.togglePlayPause()
                        videoPlayerViewModel.resetControlsTimer()
                    }) {
                        SwiftUI.Image(systemName: videoPlayerViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                    .buttonStyle(.borderless)
                    
                    if let onFullScreen {
                        Button(action: {
                            onFullScreen()
                        }) {
                            SwiftUI.Image(systemName: "arrow.down.left.and.arrow.up.right.rectangle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.borderless)
                    } else {
                        Spacer()
                            .frame(width: 24)
                    }
                }
                .padding(16)
            }
            .background(Color.black.opacity(0.5))
            .opacity(videoPlayerViewModel.showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: videoPlayerViewModel.showControls)
            .onTapGesture {
                videoPlayerViewModel.toggleControls()
            }
        }
        .applyIf(aspectRatio != nil) {
            $0.aspectRatio(aspectRatio!, contentMode: .fit)
        }
        .onReceive(fullScreenMediaViewModel.$media) { newValue in
            if newValue != nil {
                videoPlayerViewModel.pause()
            }
        }
        .onDisappear {
            videoPlayerViewModel.pause()
        }
        .task {
            await videoPlayerViewModel.loadAndPlay(
                url: url,
                muteVideo: (postListingVideoManager?.syncMuteAcrossFeed ?? false) ? (postListingVideoManager?.isMuted ?? false) : muteVideo,
                playbackTimeToSeekToInitially: playbackTimeToSeekToInitially
            )
        }
        .appForegroundBackgroundListener(onAppEntersBackground: {
            videoPlayerViewModel.pause()
        })
        .onChange(of: canPlay) { _, newValue in
            videoPlayerViewModel.setCanPlay(newValue)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

private struct InlineVideoAVPlayer: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}
