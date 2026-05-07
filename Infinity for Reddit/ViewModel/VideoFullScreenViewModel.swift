//
//  VideoFullScreenViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import Foundation
import AVFoundation
import SwiftUI

@MainActor
class VideoFullScreenViewModel: ObservableObject {
    @Published private var isLoading: Bool = false
    @Published private var isLoaded: Bool = false
    @Published var isPlaying: Bool = true
    @Published var userPaused: Bool = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 1
    @Published var isSeekingProgress: Bool = false
    @Published var wasPlayingBeforeSeeking: Bool = false
    @Published var hasAudio: Bool = false
    @Published var isMuted: Bool = false
    @Published var playbackSpeed: Double = 1
    @Published var downloadTask: Task<Void, Never>?
    @Published var downloadProgressTitle: String = ""
    @Published var downloadProgress: Double = 0
    @Published var showDownloadFinishedMessage: Bool = false
    @Published var isShowingController: Bool = false
    @Published var error: Error?
    @Published var downloadError: Error?
    
    private var canPlay: Bool = true
    private var loadedURL: URL?
    private var playbackTimeToSeekToInitially: Double?
    private var timer: Timer?
    
    let id: String = "full_screen_video_player"
    
    enum VideoPlayerError: LocalizedError {
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            }
        }
    }
    
    func loadAndPlay(urlString: String, videoType: VideoType, muteVideo: Bool, playbackTimeToSeekToInitially: Double) async {
        if let existingPlayer = VideoPlayerPool.shared.getPlayer(id: id) {
            existingPlayer.play()
            return
        }
        
        guard !self.isLoaded, !self.isLoading else {
            return
        }
        
        guard let url = URL(string: urlString) else {
            self.error = VideoPlayerError.invalidURL
            printInDebugOnly("invalid url")
            return
        }
        
        self.isLoading = true
        if self.playbackTimeToSeekToInitially != nil {
            self.playbackTimeToSeekToInitially = playbackTimeToSeekToInitially
        }
        
        do {
            var finalURL: URL? = url
            switch videoType {
            case .vReddIt:
                finalURL = try await loadVReddItVideo(url)
            case .redgifs(id: let id):
                finalURL = try await loadRedgifsVideo(id)
            case .streamable(shortCode: let shortCode):
                finalURL = try await loadStreamableVideo(shortCode)
            default:
                break
            }
            if let url = finalURL {
                loadedURL = finalURL
                let proxiedURL = ProxyManager.shared.proxyURL(url)
                let item = loadPlayerItem(url: proxiedURL)
                
                try Task.checkCancellation()
                
                isLoaded = true
                isLoading = false
                
                let player = VideoPlayerPool.shared.setupPlayerAfterLoading(
                    id: id,
                    playerItem: item,
                    muteVideo: false,
                    playbackTimeToSeekToInitially: self.playbackTimeToSeekToInitially ?? currentTime
                ) {
                    self.play()
                    self.isMuted = muteVideo
                    self.playbackSpeed = VideoUserDefaultsUtils.defaultPlaybackSpeed
                    self.playbackTimeToSeekToInitially = nil
                }
                
                VideoPlayerPool.shared.setPlayerObservers(
                    id: id,
                    playerObservers: setUpPlayerObservers(player: player)
                )
            }
        } catch {
            printInDebugOnly(error)
            self.error = error
            self.isLoaded = true
            self.isLoading = false
        }
    }
    
    private func setUpPlayerObservers(player: AVPlayer) -> PlayerObservers {
        let currentItemObserver = observeCurrentItem(player)
        let timeObserverToken = observeTime(player)
        let timeControlStatusObserver = observeTimeControlStatus(player)
        
        let endObserver = NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
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
            endObserver: endObserver,
            timeObserverToken: timeObserverToken,
            timeControlStatusObserver: timeControlStatusObserver
        )
    }
    
//    private func loadPlayerItem(from url: URL) async throws -> AVPlayerItem {
//        let asset = AVURLAsset(url: url)
//        let playable = try await asset.load(.isPlayable)
//        guard playable else {
//            throw NSError(domain: "VideoLoadingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Asset is not playable."])
//        }
//        return AVPlayerItem(asset: asset)
//    }
    
    private func loadPlayerItem(url: URL) -> AVPlayerItem {
        return AVPlayerItem(asset: AVURLAsset(url: url))
    }
    
    private func loadRedgifsVideo(_ id: String) async throws -> URL? {
        return try await VideoFetcher.shared.fetchRedgifsVideo(id: id)
    }
    
    private func loadStreamableVideo(_ shortCode: String) async throws -> URL? {
        return try await VideoFetcher.shared.fetchStreamableVideo(shortCode: shortCode)
    }
    
    private func loadVReddItVideo(_ url: URL) async throws -> URL? {
        return try await VideoFetcher.shared.fetchVReddItVideo(url: url)
    }
    
    func setCanPlay(to value: Bool) {
        self.canPlay = value
    }
    
    func play(respectUserPaused: Bool = false) {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        guard canPlay && !(userPaused && respectUserPaused) else {
            return
        }
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        player.play()
        player.rate = Float(playbackSpeed)
        
        userPaused = false
        
        Task {
            await ScreenWakeManager.shared.videoDidPlay(player)
        }
    }
    
    func pause(userPaused: Bool = false) {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.pause()
        
        if userPaused {
            self.userPaused = true
        }
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
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
                        guard let self = self, !self.isSeekingProgress else { return }
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
    
    func downloadMedia(urlString: String, post: Post?, videoType: VideoType) {
        guard downloadTask == nil else {
            return
        }
        
        downloadTask = Task {
            await self.downloadMediaAsync(urlString: urlString, post: post, videoType: videoType)
        }
    }
    
    private func downloadMediaAsync(urlString: String, post: Post?, videoType: VideoType) async {
        do {
            let downloadMediaType: DownloadMediaType
            
            switch videoType {
            case .reddit:
                if let post {
                    if post.postType == .gif {
                        downloadMediaType = .gif(downloadUrlString: post.url, fileName: "\(post.fileNameWithoutExtension).gif")
                    } else {
                        downloadMediaType = .redditVideo(post: post)
                    }
                } else {
                    downloadMediaType = .video(downloadUrlString: urlString, fileName: "\(Utils.randomString()).mp4")
                }
            case .direct:
                downloadMediaType = .video(downloadUrlString: urlString, fileName: post == nil ? "\(Utils.randomString()).mp4" : "\(post!.fileNameWithoutExtension).mp4")
            case .vReddIt:
                downloadMediaType = .vReddIt(urlString: urlString, downloadUrlString: nil)
            case .redgifs(let id):
                downloadMediaType = .redgifs(redgifsId: id, downloadUrlString: nil)
            case .streamable(let shortCode):
                downloadMediaType = .streamable(shortCode: shortCode, downloadUrlString: nil)
            }
            
            try await MediaDownloader.shared.download(
                downloadMediaType: downloadMediaType,
                onProgressWithTitle: { title, progress in
                    await MainActor.run {
                        self.downloadProgressTitle = title
                        self.downloadProgress = progress
                    }
                })
        } catch {
            printInDebugOnly(error)
            await MainActor.run {
                self.downloadError = error
            }
        }
        await MainActor.run {
            self.downloadProgress = 0
            self.showDownloadFinishedMessage = downloadError == nil
        }
        
        try? await Task.sleep(for: .seconds(1))
        
        await MainActor.run {
            self.downloadError = nil
            self.showDownloadFinishedMessage = false
            self.downloadTask = nil
        }
    }
    
    func setMute() {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.isMuted = isMuted
    }
    
    func setPlaybackSpeed() {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.rate = Float(playbackSpeed)
    }
    
    func seek(to time: Double) {
        guard let player = VideoPlayerPool.shared.getPlayer(id: id) else {
            return
        }
        
        player.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    func toggleController() {
        isShowingController.toggle()
        if isShowingController {
            resetControllerTimer()
        }
    }
    
    func resetControllerTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                withAnimation {
                    self?.isShowingController = false
                }
            }
        }
    }
    
    func removeControllerTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetState() {
        pause()
        
        removeControllerTimer()
        
        canPlay = true
        isPlaying = false
        userPaused = false
        loadedURL = nil
        isLoaded = false
        isLoading = false
        error = nil
        downloadError = nil
        
        VideoPlayerPool.shared.resetState(id: id)
    }
}
