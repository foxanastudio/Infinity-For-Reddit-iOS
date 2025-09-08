//
// VideoSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct VideoSettingsView: View {
    @AppStorage(VideoSettingsUserDefaultsUtils.muteVideoKey, store: .video) private var muteVideo: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.muteSensitiveVideoKey, store: .video) private var muteSensitiveVideo: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.switchToLandscapeInVideoPlayerKey, store: .video) private var switchToLandscapeInVideoPlayer: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.loopVideoKey, store: .video) private var loopVideo: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.defaultPlaybackSpeedKey, store: .video) private var defaultPlaybackSpeed: Double = 1.0
    @AppStorage(VideoSettingsUserDefaultsUtils.redditVideoDefaultResolutionKey, store: .video) private var redditVideoDefaultResolution: Int = 0
    @AppStorage(VideoSettingsUserDefaultsUtils.videoAutoplayKey, store: .video) private var videoAutoplay: Int = 0
    @AppStorage(VideoSettingsUserDefaultsUtils.muteAutoplayingVideoKey, store: .video) private var muteAutoplayingVideo: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.syncMuteAcrossFeedKey, store: .video) private var syncMuteAcrossFeed: Bool = false
    @AppStorage(VideoSettingsUserDefaultsUtils.autoplaySensitiveVideoKey, store: .video) private var autoplaySensitiveVideo: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                TogglePreference(isEnabled: $muteVideo, title: "Mute Video")
                
                TogglePreference(isEnabled: $muteSensitiveVideo, title: "Mute Sensitive Video")
                
                TogglePreference(isEnabled: $switchToLandscapeInVideoPlayer, title: "Switch to Landscape in Video Player")
                
                TogglePreference(isEnabled: $loopVideo, title: "Loop Video")
                
                BarebonePickerPreference(
                    selected: $defaultPlaybackSpeed,
                    items: VideoSettingsUserDefaultsUtils.playbackSpeeds,
                    title: "Default Playback Speed"
                ) { speed in
                    String(speed)
                }
                
                BarebonePickerPreference(
                    selected: $redditVideoDefaultResolution,
                    items: VideoSettingsUserDefaultsUtils.redditVideoDefaultResolutions,
                    title: "Reddit Video Default Resolution"
                ) { resolution in
                    if resolution == 0 {
                        "Auto"
                    } else {
                        String(resolution)
                    }
                }
                
                BarebonePickerPreference(
                    selected: $redditVideoDefaultResolution,
                    items: VideoSettingsUserDefaultsUtils.videoAutoplayOptions,
                    title: "Video Autoplay"
                ) { option in
                    if option == 0 {
                        "Never"
                    } else if option == 1 {
                        "Only on Wi-Fi"
                    } else {
                        "Always On"
                    }
                }
                
                TogglePreference(isEnabled: $muteAutoplayingVideo, title: "Mute Autoplaying Video")
                
                TogglePreference(isEnabled: $syncMuteAcrossFeed, title: "Sync Mute Across Feed")
                
                TogglePreference(isEnabled: $autoplaySensitiveVideo, title: "Autoplay Sensitive Video")
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Video")
    }
}
