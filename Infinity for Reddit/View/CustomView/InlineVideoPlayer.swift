//
//  InlineVideoPlayer.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import SwiftUI
import AVKit

struct InlineVideoPlayer: View {
    @State private var showPlayer = false
    
    let videoURL: URL
    let player: AVPlayer
    private let aspectRatio: CGSize?
    private let muteVideo: Bool
    
    init(videoURL: URL, aspectRatio: CGSize?, muteVideo: Bool = false) {
        self.videoURL = videoURL
        self.player = AVPlayer(url: videoURL)
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
    }

    var body: some View {
        ZStack {
            if showPlayer {
                InlineVideoPlayerWithControls(url: videoURL, aspectRatio: aspectRatio, muteVideo: muteVideo)
            } else {
                // For future video autoplay setting
//                VStack {
//                    Spacer()
//                    
//                    SwiftUI.Image(systemName: "play.circle.fill")
//                        .resizable()
//                        .foregroundColor(.white)
//                        .frame(width: 36, height: 36)
//                    
//                    Spacer()
//                }
//                .frame(maxWidth: .infinity)
//                .background(Color.black)
//                .onTapGesture {
//                    showPlayer = true
//                }
            }
        }
        .applyIf(aspectRatio != nil) {
            $0.aspectRatio(aspectRatio!, contentMode: .fit)
        }
        .onAppear {
            if (!showPlayer) {
                showPlayer = true
            }
        }
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
    
    @StateObject private var manager: VideoPlayerViewModel
    
    private let url: URL
    private let aspectRatio: CGSize?
    private let muteVideo: Bool

    init(url: URL, aspectRatio: CGSize?, muteVideo: Bool = false) {
        _manager = StateObject(wrappedValue: VideoPlayerViewModel())
        self.url = url
        self.aspectRatio = aspectRatio
        self.muteVideo = muteVideo
    }

    var body: some View {
        ZStack {
            InlineVideoAVPlayer(player: manager.player)
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.toggleControls()
                }

            VStack {
                Spacer()
                
                HStack {
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

                    Text(formatTime(manager.currentTime))
                        .foregroundColor(.white)
                        .font(.caption)
                        .frame(width: 50, alignment: .trailing)

                    Slider(value: $manager.currentTime, in: 0...manager.duration, onEditingChanged: { editing in
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
                        .frame(width: 50, alignment: .leading)
                    
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
                    }
                }
                .padding()
                .background(Color.black)
                .opacity(manager.showControls ? 1 : 0)
            }
            .onTapGesture {
                manager.resetControlsTimer()
            }
            .opacity(manager.showControls ? 1 : 0)
            .animation(.easeInOut(duration: 0.3), value: manager.showControls)
        }
        .applyIf(aspectRatio != nil) {
            $0.aspectRatio(aspectRatio!, contentMode: .fit)
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
    }

    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
