//
//  VideoPlayerPool.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-28.
//

import AVFoundation
import SwiftUI

@MainActor
final class VideoPlayerPool: ObservableObject {
    static let shared = VideoPlayerPool()
    
    @Published private(set) var playerDict: [String: AVPlayer] = [:]

    private let maxConcurrentPlayback = 3

    private var pool: [AVPlayer] = []
    private var available: [AVPlayer] = []
    private var usageOrder: [String] = []
    private var observers: [AVPlayer: PlayerObservers] = [:]

    private init() {
        for _ in 0..<maxConcurrentPlayback {
            let player = AVPlayer()
            pool.append(player)
            available.append(player)
        }
    }
    
    func setupPlayerAfterLoading(
        id: String,
        playerItem: AVPlayerItem,
        muteVideo: Bool,
        playbackTimeToSeekToInitially: Double?,
        onPlay: () -> Void
    ) -> AVPlayer {
        if let existingPlayer = playerDict[id] {
            updateUsage(id)
            return existingPlayer
        }
        
        let player = acquirePlayer()
        playerDict[id] = player
        updateUsage(id)
        
        player.replaceCurrentItem(with: playerItem)

        player.isMuted = muteVideo
        
        onPlay()
        
        if let playbackTimeToSeekToInitially {
            player.seek(
                to: CMTime(seconds: playbackTimeToSeekToInitially, preferredTimescale: 600)
            )
        }
        
        return player
    }
    
    func setPlayerObservers(id: String, playerObservers: PlayerObservers) {
        if let player = playerDict[id] {
            observers[player] = playerObservers
        }
    }
    
    func setStatusAndAudioTrackObserver(id: String, statusObserver: NSKeyValueObservation, audioTrackObserver: NSKeyValueObservation) {
        if let player = playerDict[id], let playerObservers = observers[player] {
            playerObservers.statusObserver = statusObserver
            playerObservers.audioTrackObserver = audioTrackObserver
        }
    }
    
    func getPlayer(id: String) -> AVPlayer? {
        return playerDict[id]
    }
    
    func resetState(id: String) {
        guard let player = playerDict[id], let playerObservers = observers[player] else {
            return
        }
        
        playerObservers.currentItemObserver.invalidate()
        
        playerObservers.statusObserver?.invalidate()
        
        playerObservers.audioTrackObserver?.invalidate()
        
        playerObservers.timeControlStatusObserver.invalidate()
        
        player.removeTimeObserver(playerObservers.timeObserverToken)
        
        player.pause()
        player.replaceCurrentItem(with: nil)
        
        let objectIdentifier = ObjectIdentifier(player)
        
        playerDict.removeValue(forKey: id)
        usageOrder.removeAll { $0 == id }
        observers.removeValue(forKey: player)

        available.append(player)
        
        Task {
            await ScreenWakeManager.shared.videoDidPause(objectIdentifier)
        }
    }

    private func acquirePlayer() -> AVPlayer {
        if let free = available.first {
            available.removeFirst()
            return free
        }

        if let evictID = usageOrder.first {
            usageOrder.removeFirst()

            guard let player = playerDict[evictID] else {
                return AVPlayer()
            }

            player.pause()
            player.replaceCurrentItem(with: nil)

            playerDict.removeValue(forKey: evictID)
            observers.removeValue(forKey: player)
        }

        // Really shouldn't happen
        return AVPlayer()
    }

    private func updateUsage(_ id: String) {
        usageOrder.removeAll { $0 == id }
        usageOrder.append(id)
    }
}

class PlayerObservers {
    var currentItemObserver: NSKeyValueObservation
    var statusObserver: NSKeyValueObservation?
    var audioTrackObserver: NSKeyValueObservation?
    var timeObserverToken: Any
    var timeControlStatusObserver: NSKeyValueObservation
    
    init(
        currentItemObserver: NSKeyValueObservation,
        timeObserverToken: Any,
        timeControlStatusObserver: NSKeyValueObservation
    ) {
        self.currentItemObserver = currentItemObserver
        self.timeObserverToken = timeObserverToken
        self.timeControlStatusObserver = timeControlStatusObserver
    }
}
