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
    @Published var showControls = false
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isSeekingProgress = false
    @Published var hasAudio: Bool = false
    @Published var isMuted: Bool = false
    
    let id: String = UUID().uuidString
    
    private var isLoading: Bool = false
    private var playbackSpeed: Double = 1
    private var canPlay: Bool
    private var muteVideo: Bool = true
    private var playbackTimeToSeekToInitially: Double?
    
    private var timer: Timer?
    
    init(canPlay: Bool = true) {
        self.canPlay = canPlay
    }
    
    func loadAndPlay(url: URL, muteVideo: Bool, playbackTimeToSeekToInitially: Double) async {
        if let existingPlayer = VideoPlayerPool.shared.getPlayer(id: id) {
            existingPlayer.play()
            return
        }
        
        self.muteVideo = muteVideo
        self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
        
        guard !isLoading else {
            return
        }
        
        isLoading = true

        do {
            let proxiedURL = ProxyManager.shared.proxyURL(url)
            let item = try await loadPlayerItem(from: proxiedURL)
            
            try Task.checkCancellation()
            
            if canPlay {
                let player = VideoPlayerPool.shared.setupPlayerAfterLoading(
                    id: id,
                    playerItem: item,
                    muteVideo: muteVideo,
                    playbackTimeToSeekToInitially: playbackTimeToSeekToInitially
                ) {
                    self.play()
                }
                
                self.playbackTimeToSeekToInitially = nil
                
                VideoPlayerPool.shared.setPlayerObservers(
                    id: id,
                    playerObservers: setUpPlayerObservers(player: player)
                )
                
                self.isMuted = muteVideo
                self.playbackSpeed = VideoUserDefaultsUtils.defaultPlaybackSpeed
            }
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    private func setUpPlayerObservers(player: AVPlayer) -> PlayerObservers {
        let currentItemObserver = observeCurrentItem(player)
        let timeObserverToken = observeTime(player)
        let timeControlStatusObserver = observeTimeControlStatus(player)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem,
                                               queue: .main) { _ in
            DispatchQueue.main.async {
                if VideoUserDefaultsUtils.loopVideo {
                    player.seek(to: .zero)
                    self.play()
                } else {
                    self.pause()
                }
            }
        }
        
        return PlayerObservers(
            currentItemObserver: currentItemObserver,
            timeObserverToken: timeObserverToken,
            timeControlStatusObserver: timeControlStatusObserver
        )
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
    
    private func observeCurrentItem(_ player: AVPlayer) -> NSKeyValueObservation {
        return player.observe(\.currentItem, options: [.new, .initial]) { [weak self] player, _ in
            DispatchQueue.main.async {
                guard let self = self, let item = player.currentItem else { return }
                
                // When we get a new item, observe its status
                let statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
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
                
                let audioTrackObserver = item.observe(\.tracks, options: [.new]) { [weak self] item, _ in
                    DispatchQueue.main.async {
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
                
                VideoPlayerPool.shared.setStatusAndAudioTrackObserver(
                    id: self.id,
                    statusObserver: statusObserver,
                    audioTrackObserver: audioTrackObserver
                )
            }
        }
    }
    
    private func observeTime(_ player: AVPlayer) -> Any {
        return player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if !self.isSeekingProgress {
                    self.currentTime = time.seconds
                }
            }
        }
    }
    
    private func observeTimeControlStatus(_ player: AVPlayer) -> NSKeyValueObservation {
        return player.observe(\.timeControlStatus, options: [.new, .initial]) { [weak self] player, _ in
            DispatchQueue.main.async {
                self?.isPlaying = (player.timeControlStatus == .playing)
            }
        }
    }
    
    func togglePlayPause() {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        if player.timeControlStatus == .playing {
            player.pause()
            
            Task {
                await ScreenWakeManager.shared.videoDidPause(player)
            }
        } else {
            usePlaybackCategoryAndPlay(player)
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        }
    }
    
    func play() {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        if canPlay {
            usePlaybackCategoryAndPlay(player)
            player.rate = Float(playbackSpeed)
            
            Task {
                await ScreenWakeManager.shared.videoDidPlay(player)
            }
        }
    }
    
    func pause() {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.pause()
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
    }
    
    func setCanPlay(_ value: Bool) {
        self.canPlay = value
    }
    
    private func usePlaybackCategoryAndPlay(_ player: AVPlayer) {
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        player.play()
    }
    
    func toggleMute() -> Bool {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return isMuted
        }
        
        if isMuted {
            player.isMuted = false
        } else {
            player.isMuted = true
        }
        isMuted.toggle()
        return isMuted
    }
    
    func seek(to time: Double) {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
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
        
        isLoading = false
        showControls = false
        isPlaying = false
        isSeekingProgress = false
        canPlay = false
        
        VideoPlayerPool.shared.resetState(id: id)
    }
}
