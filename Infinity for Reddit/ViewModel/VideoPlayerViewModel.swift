//
//  VideoPlayerViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-22.
//

import Foundation
import AVFoundation

@MainActor
class VideoPlayerViewModel: NSObject, ObservableObject {
    var player: AVPlayer = AVPlayer()
    
    @Published var showControls = false
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isSeekingProgress = false
    @Published var hasAudio: Bool = false
    @Published var isMuted: Bool = false
    
    private var playerItem: AVPlayerItem?
    private var isLoading: Bool = false
    private var playbackSpeed: Double = 1
    private var canPlay: Bool
    private var muteVideo: Bool = true
    private var playbackTimeToSeekToInitially: Double?
    
    private var timer: Timer?
    private var currentItemObserver: NSKeyValueObservation?
    private var statusObserver: NSKeyValueObservation?
    private var audioTrackObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var timeControlStatusObserver: NSKeyValueObservation?
    
    init(canPlay: Bool = true) {
        self.canPlay = canPlay
    }
    
    func loadAndPlay(url: URL, muteVideo: Bool, playbackTimeToSeekToInitially: Double) async {
        do {
            self.muteVideo = muteVideo
            self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
            
            if let playerItem = playerItem {
                try Task.checkCancellation()
                
                if canPlay {
                    setupPlayerAfterLoading(
                        playerItem: playerItem,
                        playbackTimeToSeekToInitially: currentTime
                    )
                }
                return
            }
            
            guard !isLoading else {
                return
            }
            
            isLoading = true

            do {
                let proxiedURL = ProxyManager.shared.proxyURL(url)
                let item = try await loadPlayerItem(from: proxiedURL)
                playerItem = item
                
                try Task.checkCancellation()
                
                if canPlay {
                    setupPlayerAfterLoading(
                        playerItem: item,
                        playbackTimeToSeekToInitially: playbackTimeToSeekToInitially
                    )
                    self.playbackTimeToSeekToInitially = nil
                }
            } catch {
                isLoading = false
            }
        } catch {
            isLoading = false
        }
    }
    
    private func setupPlayerAfterLoading(
        playerItem: AVPlayerItem,
        playbackTimeToSeekToInitially: Double?
    ) {
        player.replaceCurrentItem(with: playerItem)
        
        isLoading = false
        
        self.player.isMuted = muteVideo
        self.isMuted = muteVideo
        self.playbackSpeed = VideoUserDefaultsUtils.defaultPlaybackSpeed
        self.play()
        if let playbackTimeToSeekToInitially {
            self.player.seek(
                to: CMTime(seconds: playbackTimeToSeekToInitially, preferredTimescale: 600)
            )
        }
        
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
    
    private func loadPlayerItem(from url: URL) async throws -> AVPlayerItem {
        let asset = AVURLAsset(url: url)
        
        try Task.checkCancellation()
        
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
            guard let self = self else {
                return
            }
            if !self.isSeekingProgress {
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
            usePlaybackCategoryAndPlay()
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        }
    }
    
    func play() {
        if canPlay {
            usePlaybackCategoryAndPlay()
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
            if player.currentItem == nil, let playerItem {
                setupPlayerAfterLoading(playerItem: playerItem, playbackTimeToSeekToInitially: playbackTimeToSeekToInitially)
                playbackTimeToSeekToInitially = nil
            } else {
                usePlaybackCategoryAndPlay()
                
                Task {
                    await ScreenWakeManager.shared.videoDidPlay(player)
                }
            }
        } else {
            guard player.currentItem != nil else {
                return
            }
            
            player.pause()
            
            Task {
                await ScreenWakeManager.shared.videoDidPause(player)
            }
        }
    }
    
    private func usePlaybackCategoryAndPlay() {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        player.play()
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
            resetControllerTimer()
        }
    }
    
    func resetControllerTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.showControls = false
            }
        }
    }
    
    func resetState() {
        pause()
        
        NotificationCenter.default.removeObserver(self)
        
        timer?.invalidate()
        timer = nil
        
        currentItemObserver?.invalidate()
        currentItemObserver = nil
        
        statusObserver?.invalidate()
        statusObserver = nil
        
        audioTrackObserver?.invalidate()
        audioTrackObserver = nil
        
        timeControlStatusObserver?.invalidate()
        timeControlStatusObserver = nil
        
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
        
        isLoading = false
        showControls = false
        isPlaying = false
        isSeekingProgress = false
        canPlay = false
        
        self.player.replaceCurrentItem(with: nil)
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
    }
    
//    deinit {
//        printInDebugOnly("asdfasdfd")
//        timer?.invalidate()
//        NotificationCenter.default.removeObserver(self)
//        currentItemObserver?.invalidate()
//        statusObserver?.invalidate()
//        audioTrackObserver?.invalidate()
//        timeControlStatusObserver?.invalidate()
//        if let token = timeObserverToken {
//            player.removeTimeObserver(token)
//        }
//    }
}
