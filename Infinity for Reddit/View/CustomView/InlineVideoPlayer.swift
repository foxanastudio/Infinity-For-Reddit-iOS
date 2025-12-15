//
//  InlineVideoPlayer.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import SwiftUI
import AVKit

struct InlineVideoPlayer: View {
    @EnvironmentObject private var networkManager: NetworkManager
    
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
    private let onFullScreen: (() -> Void)?
    
    init(videoURL: URL, aspectRatio: CGSize?, muteVideo: Bool = false, canPlay: Bool = true, isSensitive: Bool, onFullScreen: (() -> Void)? = nil) {
        self.videoURL = videoURL
        self.player = AVPlayer(url: ProxyManager.shared.proxyURL(videoURL))
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
        self.canPlay = canPlay
        self.isSensitive = isSensitive
        self.onFullScreen = onFullScreen
        self.showPlayer = false
    }

    var body: some View {
        Group {
            if showPlayer == true {
                InlineVideoPlayerWithControls(url: videoURL, aspectRatio: aspectRatio, muteVideo: muteVideo, canPlay: canPlay, onFullScreen: onFullScreen)
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

private struct InlineVideoPlayerWithControls: View {
    @Environment(\.postListingVideoManager) private var postListingVideoManager: PostListingVideoManager?
    @EnvironmentObject private var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @StateObject private var manager: VideoPlayerViewModel
    
    let canPlay: Bool
    
    private let url: URL
    private let aspectRatio: CGSize?
    private let muteVideo: Bool
    private let onFullScreen: (() -> Void)?

    init(url: URL, aspectRatio: CGSize?, muteVideo: Bool = false, canPlay: Bool, onFullScreen: (() -> Void)?) {
        _manager = StateObject(wrappedValue: VideoPlayerViewModel(canPlay: canPlay))
        self.url = url
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
        self.canPlay = canPlay
        self.onFullScreen = onFullScreen
    }

    var body: some View {
        ZStack {
            InlineVideoAVPlayer(player: manager.player)
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.toggleControls()
                }

            ZStack {
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text(formatTime(manager.currentTime))
                            .foregroundColor(.white)
                            .font(.caption)
                            .frame(width: 50)

                        Slider(value: $manager.currentTime, in: 0...manager.duration, onEditingChanged: { editing in
                            print(editing)
                            manager.isDragging = editing
                            if !editing {
                                manager.seek(to: manager.currentTime)
                            }
                        })
                        .accentColor(.white)
                        .onChange(of: manager.currentTime, initial: false) { _, _  in
                            if manager.isDragging {
                                manager.resetControlsTimer()
                            }
                        }

                        Text(formatTime(manager.duration))
                            .foregroundColor(.white)
                            .font(.caption)
                            .frame(width: 50)
                    }
                    .padding(8)
                }
                
                HStack(spacing: 48) {
                    if manager.hasAudio {
                        Button(action: {
                            let isMuted = manager.toggleMute()
                            manager.resetControlsTimer()
                            postListingVideoManager?.isMuted = isMuted
                        }) {
                            SwiftUI.Image(systemName: manager.isMuted ? "speaker.slash" : "speaker.wave.2")
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
                        manager.togglePlayPause()
                        manager.resetControlsTimer()
                    }) {
                        SwiftUI.Image(systemName: manager.isPlaying ? "pause.fill" : "play.fill")
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
            .opacity(manager.showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: manager.showControls)
            .onTapGesture {
                manager.toggleControls()
            }
        }
        .applyIf(aspectRatio != nil) {
            $0.aspectRatio(aspectRatio!, contentMode: .fit)
        }
        .onReceive(fullScreenMediaViewModel.$media) { newValue in
            if newValue != nil {
                manager.pause()
            }
        }
        .onDisappear {
            manager.pause()
        }
        .task {
            await manager.loadAndPlay(url: url, muteVideo: (postListingVideoManager?.syncMuteAcrossFeed ?? false) ? (postListingVideoManager?.isMuted ?? false) : muteVideo)
        }
        .appForegroundBackgroundListener(onAppEntersBackground: {
            manager.pause()
        })
        .onChange(of: canPlay) { _, newValue in
            manager.setCanPlay(newValue)
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
