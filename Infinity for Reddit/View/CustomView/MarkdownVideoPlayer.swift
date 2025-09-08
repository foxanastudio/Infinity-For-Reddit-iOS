//
//  MarkdownVideoPlayer.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import SwiftUI
import AVKit

struct MarkdownVideoPlayer: View {
    @State private var showPlayer = false
    
    let videoURL: URL
    let player: AVPlayer
    private let aspectRatio: CGSize?
    
    init(videoURL: URL, aspectRatio: CGSize?) {
        self.videoURL = videoURL
        self.player = AVPlayer(url: videoURL)
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        ZStack {
            if showPlayer {
                MarkdownVideoPlayerWithControls(url: videoURL, aspectRatio: aspectRatio)
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

private struct MarkdownVideoAVPlayer: UIViewControllerRepresentable {
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

private struct MarkdownVideoPlayerWithControls: View {
    @StateObject private var manager: VideoPlayerViewModel
    
    private let aspectRatio: CGSize?

    init(url: URL, aspectRatio: CGSize?) {
        _manager = StateObject(wrappedValue: VideoPlayerViewModel(url: url))
        self.aspectRatio = aspectRatio
    }

    var body: some View {
        ZStack() {
            MarkdownVideoAVPlayer(player: manager.player)
                .contentShape(Rectangle()) // makes the whole area tappable
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
        .onAppear {
            manager.player.play()
        }
    }

    private func formatTime(_ seconds: Double) -> String {
        guard !seconds.isNaN else { return "00:00" }
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
