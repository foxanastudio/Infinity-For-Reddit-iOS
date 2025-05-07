//
//  VideoFullScreenViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import Foundation
import AVFoundation

class VideoFullScreenViewModel: ObservableObject {
    @Published var player: AVPlayer
    
    init(url: URL) {
        self.player = AVPlayer(url: url)
    }
    
    deinit {
        print("Releasing AVPlayer")
        player.replaceCurrentItem(with: nil)
    }
}
