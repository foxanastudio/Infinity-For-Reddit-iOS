//
//  NotificationSettingsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Combine
import GRDB
import Swinject

class NotificationSettingsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var enableNotifications: Bool
    @Published var checkNotificationsInterval: Int
    
    let ENABLE_NOTIFICATION_KEY = UserDefaultsUtils.ENABLE_NOTIFICATION_KEY
    let NOTIFICATION_INTERVAL_KEY = UserDefaultsUtils.NOTIFICATION_INTERVAL_KEY
    
    let notificationsIntervals: [String] = ["15 minutes", "30 minutes", "1 hour", "2 hours", "3 hours", "4 hours", "6 hours", "12 hours", "1 day"]
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: ENABLE_NOTIFICATION_KEY) == nil {
            userDefaults.set(true, forKey: ENABLE_NOTIFICATION_KEY)
        }
        if userDefaults.object(forKey: NOTIFICATION_INTERVAL_KEY) == nil {
            userDefaults.set(2, forKey: NOTIFICATION_INTERVAL_KEY)
        }
        
        self.enableNotifications = userDefaults.bool(forKey: UserDefaultsUtils.ENABLE_NOTIFICATION_KEY)
        self.checkNotificationsInterval = userDefaults.integer(forKey: UserDefaultsUtils.NOTIFICATION_INTERVAL_KEY)
        
        $enableNotifications
            .sink { [weak self] newValue in
                self?.saveNotificationSettings(setting: newValue, forKey: self?.ENABLE_NOTIFICATION_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $checkNotificationsInterval
            .sink { [weak self] newValue in
                self?.saveNotificationSettings(setting: newValue, forKey: self?.NOTIFICATION_INTERVAL_KEY ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func saveNotificationSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
