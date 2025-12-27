//
//  ScreenWakeManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-26.
//

import AVFoundation
import UIKit

actor ScreenWakeManager {
    static let shared = ScreenWakeManager()
    
    private var activeVideoPlayers: Set<ObjectIdentifier> = []
    
    private init() {}
    
    func videoDidPlay(_ player: AVPlayer) async {
        activeVideoPlayers.insert(ObjectIdentifier(player))
        await updateScreenWake(!activeVideoPlayers.isEmpty)
    }
    
    func videoDidPause(_ player: AVPlayer) async {
        activeVideoPlayers.remove(ObjectIdentifier(player))
        await updateScreenWake(!activeVideoPlayers.isEmpty)
    }
    
    @MainActor
    private func updateScreenWake(_ disableWake: Bool) {
        UIApplication.shared.isIdleTimerDisabled = disableWake
    }
}
