//
//  VideoFullScreenViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import Foundation
import AVFoundation

class VideoFullScreenViewModel: ObservableObject {
    @Published var player: AVPlayer = .init()
    @Published private var isLoading: Bool = false
    @Published private var isLoaded: Bool = false
    @Published private var error: Error?
    
    func loadAndPlay(url: URL, videoType: VideoType) async {
        guard !isLoaded, !isLoading else {
            if player.currentItem != nil {
                player.play()
            }
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            var finalURL: URL? = url
            switch videoType {
            case .vReddIt:
                break
            case .redgifs(id: let id):
                finalURL = try await loadRedgifsVideo(id)
            case .streamable(shortCode: let shortCode):
                finalURL = try await loadStreamableVideo(shortCode)
            default:
                break
            }
            if let url = finalURL {
                let item = try await loadPlayerItem(from: url)
                player.replaceCurrentItem(with: item)
                
                await MainActor.run {
                    isLoaded = true
                    isLoading = false
                    
                    player.play()
                    
                    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                           object: player.currentItem,
                                                           queue: .main) { _ in
                        self.player.seek(to: .zero)
                        self.player.play()
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
        let streamable = try await VideoFetcher.shared.fetchStreamableVideo(shortCode: shortCode)
        if let mp4 = streamable.mp4 {
            return URL(string: mp4.url)
        } else if let mp4Mobile = streamable.mp4mobile {
            return URL(string: mp4Mobile.url)
        }
        
        return nil
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func resetState() {
        NotificationCenter.default.removeObserver(self)
        self.player.replaceCurrentItem(with: nil)
        
        isLoaded = false
        isLoading = false
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        self.player.replaceCurrentItem(with: nil)
    }
}
