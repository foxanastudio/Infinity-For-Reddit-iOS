//
//  PlayerManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-20.
//

import SwiftUI
import AVKit

class PlayerManager : ObservableObject {
    let player = AVPlayer(url: URL(string: "https://media.w3.org/2010/05/sintel/trailer.mp4")!)
    @Published private var playing = false
    
    func play() {
        player.play()
        playing = true
    }
    
    func playPause() {
        if playing {
            player.pause()
        } else {
            player.play()
        }
        playing.toggle()
    }
}

struct AVPlayerControllerRepresented : UIViewControllerRepresentable {
    var player : AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
