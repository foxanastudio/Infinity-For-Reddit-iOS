//
//  VideoUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-08.
//

import Foundation

class VideoUserDefaultsUtils {
    static let muteVideoKey = "mute_video"
    static var muteVideo: Bool {
        return UserDefaults.video.bool(forKey: muteVideoKey)
    }
    
    static let muteSensitiveVideoKey = "mute_sensitive_video"
    static var muteSensitiveVideo: Bool {
        return UserDefaults.video.bool(forKey: muteSensitiveVideoKey)
    }
    
    static let switchToLandscapeInVideoPlayerKey = "switch_to_landscape_in_video_player"
    static var switchToLandscapeInVideoPlayer: Bool {
        return UserDefaults.video.bool(forKey: switchToLandscapeInVideoPlayerKey)
    }
    
    static let loopVideoKey = "loop_video"
    static var loopVideo: Bool {
        return UserDefaults.video.bool(forKey: loopVideoKey, true)
    }
    
    static let defaultPlaybackSpeedKey = "default_playback_speed"
    static var defaultPlaybackSpeed: Double {
        return UserDefaults.video.double(forKey: defaultPlaybackSpeedKey, 1)
    }
    static let playbackSpeeds: [Double] = [0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2]
    static let playbackSpeedsText: [String] = ["0.25x", "0.5x", "0.75x", "1x", "1.25x", "1.5x", "1.75x", "2x"]
    
    static let redditVideoDefaultResolutionKey = "reddit_video_default_resolution"
    static var redditVideoDefaultResolution: Int {
        return UserDefaults.video.integer(forKey: redditVideoDefaultResolutionKey)
    }
    static let redditVideoDefaultResolutions: [Int] = [0, 1080, 720, 480, 360, 240, 144]
    
    static let videoAutoplayKey = "video_autoplay"
    static var videoAutoplay: Int {
        return UserDefaults.video.integer(forKey: videoAutoplayKey)
    }
    static let videoAutoplayOptions: [Int] = [0, 1, 2]
    static let videoAutoplayOptionsText: [String] = ["Never", "Only on Wi-Fi", "Always On"]
    static func canAutoplayVideo(videoAutoplay: Int, isWifiConnected: Bool) -> Bool {
        if videoAutoplay == 0 {
            return false
        } else if videoAutoplay == 1 {
            return isWifiConnected
        } else {
            return true
        }
    }
    
    static let muteAutoplayingVideoKey = "mute_autoplaying_video"
    static var muteAutoplayingVideo: Bool {
        return UserDefaults.video.bool(forKey: muteAutoplayingVideoKey)
    }
    
    static let syncMuteAcrossFeedKey = "sync_mute_across_feed"
    static var syncMuteAcrossFeed: Bool {
        return UserDefaults.video.bool(forKey: syncMuteAcrossFeedKey)
    }
    
    static let autoplaySensitiveVideoKey = "autoplay_sensitive_video"
    static var autoplaySensitiveVideo: Bool {
        return UserDefaults.video.bool(forKey: autoplaySensitiveVideoKey, true)
    }
}
