//
//  DataSavingModeUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-22.
//

import Foundation

class DataSavingModeUserDefaultsUtils {
    static let dataSavingModeKey = "data_saving_mode"
    static var dataSavingMode: Int {
        return UserDefaults.dataSavingMode.integer(forKey: dataSavingModeKey)
    }
    static let dataSavingModeOptions: [Int] = [0, 1, 2]
    static let dataSavingModeOptionsText: [String] = ["Off", "Only on Cellular Data", "Always"]
    
    static let disableImagePreviewKey = "disable_image_preview"
    static var disableImagePreview: Bool {
        return UserDefaults.dataSavingMode.bool(forKey: disableImagePreviewKey)
    }
    
    static let onlyDisablePreviewInVideoAndGIFKey = "only_disable_preview_in_video_and_gif_posts"
    static var onlyDisablePreviewInVideoAndGIF: Bool {
        return UserDefaults.dataSavingMode.bool(forKey: onlyDisablePreviewInVideoAndGIFKey)
    }
    
    static func isDataSavingModeActive(dataSavingMode: Int, isWifiConnected: Bool) -> Bool {
        return dataSavingMode == 2 || (dataSavingMode == 1 && !isWifiConnected)
    }
}
