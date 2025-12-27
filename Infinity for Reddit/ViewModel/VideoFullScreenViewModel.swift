//
//  VideoFullScreenViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import Foundation
import AVFoundation
import SwiftUI

class VideoFullScreenViewModel: ObservableObject {
    @Published var player: AVPlayer = .init()
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
    private var currentItemObserver: NSKeyValueObservation?
    private var timeObserverToken: Any?
    private var statusObserver: NSKeyValueObservation?
    private var audioTrackObserver: NSKeyValueObservation?
    private var timer: Timer?
    
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
        guard !isLoaded, !isLoading else {
            if player.currentItem != nil {
                await MainActor.run {
                    play()
                }
            }
            return
        }
        
        guard let url = URL(string: urlString) else {
            self.error = VideoPlayerError.invalidURL
            print("invalid url")
            return
        }
        
        await MainActor.run {
            isLoading = true
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
                let item = try await loadPlayerItem(from: proxiedURL)
                player.replaceCurrentItem(with: item)
                
                await MainActor.run {
                    isLoaded = true
                    isLoading = false
                    
                    playbackSpeed = VideoUserDefaultsUtils.defaultPlaybackSpeed
                    isMuted = muteVideo
                    play()
                    player.seek(
                        to: CMTime(seconds: playbackTimeToSeekToInitially, preferredTimescale: 600)
                    )
                    
                    observeCurrentItem()
                    observeTime()
                    
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
            }
        } catch {
            print(error)
            await MainActor.run {
                self.error = error
                self.isLoaded = true
                self.isLoading = false
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
        guard canPlay && !(userPaused && respectUserPaused) else {
            return
        }
        
        player.play()
        player.rate = Float(playbackSpeed)
        isPlaying = true
        userPaused = false
        
        Task {
            await ScreenWakeManager.shared.videoDidPlay(player)
        }
    }
    
    func pause(userPaused: Bool = false) {
        player.pause()
        isPlaying = false
        if userPaused {
            self.userPaused = true
        }
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
    }
    
    func resetState() {
        NotificationCenter.default.removeObserver(self)
        self.player.replaceCurrentItem(with: nil)
        
        canPlay = true
        isPlaying = false
        userPaused = false
        loadedURL = nil
        isLoaded = false
        isLoading = false
        error = nil
        downloadError = nil
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(player)
        }
    }
    
    private func observeTime() {
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
        }
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
            print(error)
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
    
    deinit {
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
        self.player.replaceCurrentItem(with: nil)
    }
}
