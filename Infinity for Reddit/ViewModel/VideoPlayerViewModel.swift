//
//  VideoPlayerViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import Foundation
import AVFoundation

class VideoPlayerViewModel: NSObject, ObservableObject {
    lazy var player: AVPlayer = {
        return AVPlayer()
    }()
    @Published private var isLoading: Bool = false
    @Published private var isLoaded: Bool = false
    private var timer: Timer?
    
    private var currentItemObserver: NSKeyValueObservation?
    private var statusObserver: NSKeyValueObservation?
    private var audioTrackObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var timeControlStatusObserver: NSKeyValueObservation?
    
    @Published var showControls = false
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isDragging = false
    @Published var hasAudio: Bool = false
    @Published var isMuted: Bool = false
    @Published var playbackSpeed: Double = 1
    var canPlay: Bool
    
    init(canPlay: Bool = true) {
        self.canPlay = canPlay
    }
    
    func loadAndPlay(url: URL, muteVideo: Bool, playbackTimeToSeekToInitially: Double) async {
        guard !isLoaded, !isLoading else {
            return
        }
        
        await MainActor.run {
            isLoading = true
        }

        do {
            let proxiedURL = ProxyManager.shared.proxyURL(url)
            let item = try await loadPlayerItem(from: proxiedURL)
            player.replaceCurrentItem(with: item)
            
            await MainActor.run {
                isLoaded = true
                isLoading = false
                
                self.player.isMuted = muteVideo
                self.isMuted = muteVideo
                self.playbackSpeed = VideoUserDefaultsUtils.defaultPlaybackSpeed
                self.play()
                self.player.seek(
                    to: CMTime(seconds: playbackTimeToSeekToInitially, preferredTimescale: 600)
                )
                
                observeCurrentItem()
                observeTime()
                observeTimeControlStatus()
                
                NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                       object: player.currentItem,
                                                       queue: .main) { _ in
                    if VideoUserDefaultsUtils.loopVideo {
                        self.player.seek(to: .zero)
                        self.play()
                    } else {
                        self.pause()
                    }
                }
            }
        } catch {
            // Error handling
            await MainActor.run {
                isLoaded = true
                isLoading = false
            }
        }
    }
    
    private func loadPlayerItem(from url: URL) async throws -> AVPlayerItem {
        let asset = AVURLAsset(url: url)
        let playable = try await asset.load(.isPlayable)
        guard playable else {
            throw NSError(domain: "VideoLoadingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Asset is not playable."])
        }
        return AVPlayerItem(asset: asset)
    }
    
    private func observeCurrentItem() {
        currentItemObserver = player.observe(\.currentItem, options: [.new, .initial]) { [weak self] player, _ in
            guard let self = self, let item = player.currentItem else { return }
            
            // When we get a new item, observe its status
            self.statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
                guard let self = self else { return }
                
                if item.status == .readyToPlay {
                    let durationSec = item.duration.seconds
                    if durationSec.isFinite {
                        DispatchQueue.main.async {
                            self.duration = durationSec
                        }
                    }
                }
            }
            
            self.audioTrackObserver = item.observe(\.tracks, options: [.new]) { [weak self] item, _ in
                guard let self = self else { return }
                var hasAudio = false
                for playerItem in item.tracks {
                    hasAudio = playerItem.assetTrack?.mediaType == .audio
                    if hasAudio {
                        break
                    }
                }
                self.hasAudio = hasAudio
            }
        }
    }
    
    private func observeTime() {
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            if !self.isDragging {
                self.currentTime = time.seconds
            }
        }
    }
    
    private func observeTimeControlStatus() {
        timeControlStatusObserver = player.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.isPlaying = (player.timeControlStatus == .playing)
            }
        }
    }
    
    func togglePlayPause() {
        if player.timeControlStatus == .playing {
            player.pause()
            
            Task {
                await ScreenWakeManager.shared.videoDidPause(player)
            }
        } else {
            player.play()
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        }
    }
    
    func play() {
        if canPlay {
            player.play()
            player.rate = Float(playbackSpeed)
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        }
    }
    
    func pause() {
        player.pause()
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
    }
    
    func setCanPlay(_ value: Bool) {
        self.canPlay = value
        if value {
            player.play()
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        } else {
            player.pause()
            
            Task {
                await ScreenWakeManager.shared.videoDidPause(player)
            }
        }
    }
    
    func toggleMute() -> Bool {
        if isMuted {
            player.isMuted = false
        } else {
            player.isMuted = true
        }
        isMuted.toggle()
        return isMuted
    }
    
    func seek(to time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: cmTime)
    }
    
    func toggleControls() {
        showControls.toggle()
        if showControls {
            resetControlsTimer()
        }
    }
    
    func resetControlsTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showControls = false
            }
        }
    }
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        currentItemObserver?.invalidate()
        statusObserver?.invalidate()
        audioTrackObserver?.invalidate()
        timeControlStatusObserver?.invalidate()
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
        }
    }
}
