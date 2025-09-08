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
    
    func loadAndPlay(url: URL) async {
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
        } catch {
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
