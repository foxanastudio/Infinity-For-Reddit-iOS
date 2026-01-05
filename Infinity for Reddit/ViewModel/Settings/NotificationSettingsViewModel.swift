//
//  NotificationSettingsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import Foundation
import BackgroundTasks

class NotificationSettingsViewModel {
    func enableNotification(enable: Bool) {
        if enable {
            print("Notifications enabled — scheduling background refresh.")
            PullNotificationBackgroundTaskManager.shared.scheduleBackgroundTask()
        } else {
            print("Notifications disabled — cancelling background refresh.")
            PullNotificationBackgroundTaskManager.shared.cancelBackgroundTask()
        }
        
        NotificationCenter.default.post(
            name: .notificationToggleChanged,
            object: nil
        )
    }
    
    func updateNotificationInterval() {
        PullNotificationBackgroundTaskManager.shared.scheduleBackgroundTask()
        NotificationCenter.default.post(name: .notificationIntervalChanged, object: nil)
    }
}
