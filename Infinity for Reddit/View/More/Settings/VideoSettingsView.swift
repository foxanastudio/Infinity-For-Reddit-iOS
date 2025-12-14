//
// VideoSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct VideoSettingsView: View {
    @AppStorage(VideoUserDefaultsUtils.muteVideoKey, store: .video) private var muteVideo: Bool = false
    @AppStorage(VideoUserDefaultsUtils.muteSensitiveVideoKey, store: .video) private var muteSensitiveVideo: Bool = false
    //@AppStorage(VideoUserDefaultsUtils.switchToLandscapeInVideoPlayerKey, store: .video) private var switchToLandscapeInVideoPlayer: Bool = false
    @AppStorage(VideoUserDefaultsUtils.loopVideoKey, store: .video) private var loopVideo: Bool = true
    @AppStorage(VideoUserDefaultsUtils.defaultPlaybackSpeedKey, store: .video) private var defaultPlaybackSpeed: Double = 1.0
    //@AppStorage(VideoUserDefaultsUtils.redditVideoDefaultResolutionKey, store: .video) private var redditVideoDefaultResolution: Int = 0
    @AppStorage(VideoUserDefaultsUtils.videoAutoplayKey, store: .video) private var videoAutoplay: Int = 0
    @AppStorage(VideoUserDefaultsUtils.muteAutoplayingVideoKey, store: .video) private var muteAutoplayingVideo: Bool = false
    @AppStorage(VideoUserDefaultsUtils.syncMuteAcrossFeedKey, store: .video) private var syncMuteAcrossFeed: Bool = false
    @AppStorage(VideoUserDefaultsUtils.autoplaySensitiveVideoKey, store: .video) private var autoplaySensitiveVideo: Bool = true
    
    var body: some View {
        RootView {
            List {
                TogglePreference(isEnabled: $muteVideo, title: "Mute Video")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $muteSensitiveVideo, title: "Mute Sensitive Video")
                    .listPlainItemNoInsets()
                
//                TogglePreference(isEnabled: $switchToLandscapeInVideoPlayer, title: "Switch to Landscape in Video Player")
//                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $loopVideo, title: "Loop Video")
                    .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $defaultPlaybackSpeed,
                    items: VideoUserDefaultsUtils.playbackSpeeds,
                    title: "Default Playback Speed"
                ) { speed in
                    "\(speed)x"
                }
                .listPlainItemNoInsets()
                
//                BarebonePickerPreference(
//                    selected: $redditVideoDefaultResolution,
//                    items: VideoUserDefaultsUtils.redditVideoDefaultResolutions,
//                    title: "Reddit Video Default Resolution"
//                ) { resolution in
//                    if resolution == 0 {
//                        "Auto"
//                    } else {
//                        "\(resolution)p"
//                    }
//                }
//                .listPlainItemNoInsets()
                
                CustomListSection("Video Autoplay") {
                    BarebonePickerPreference(
                        selected: $videoAutoplay,
                        items: VideoUserDefaultsUtils.videoAutoplayOptions,
                        title: "Video Autoplay"
                    ) { option in
                        VideoUserDefaultsUtils.videoAutoplayOptionsText[option]
                    }
                    .listPlainItemNoInsets()
                    
                    TogglePreference(isEnabled: $muteAutoplayingVideo, title: "Mute Autoplaying Video")
                        .listPlainItemNoInsets()
                    
                    TogglePreference(isEnabled: $syncMuteAcrossFeed, title: "Sync Mute Across Feed")
                        .listPlainItemNoInsets()
                    
                    TogglePreference(isEnabled: $autoplaySensitiveVideo, title: "Autoplay Sensitive Video")
                        .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Video")
    }
}
