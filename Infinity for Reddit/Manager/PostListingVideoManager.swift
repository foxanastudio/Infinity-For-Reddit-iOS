//
//  PostListingVideoManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-09.
//

import Foundation
import Combine

class PostListingVideoManager: ObservableObject {
    @Published var isMuted: Bool = false
    @Published var syncMuteAcrossFeed: Bool
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        syncMuteAcrossFeed = VideoSettingsUserDefaultsUtils.syncMuteAcrossFeed
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.syncMuteAcrossFeed = UserDefaults.video.bool(forKey: VideoSettingsUserDefaultsUtils.syncMuteAcrossFeedKey)
                }
            }
            .store(in: &cancellables)
    }
}
