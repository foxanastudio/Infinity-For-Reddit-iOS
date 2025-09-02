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
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        let item = AVPlayerItem(url: url)
        
        player.replaceCurrentItem(with: item)
        
        await MainActor.run {
            isLoaded = true
            isLoading = true
            
            player.play()
            
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: player.currentItem,
                                                   queue: .main) { _ in
                self.player.seek(to: .zero)
                self.player.play()
            }
        }
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
