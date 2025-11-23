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
        return UserDefaults.standard.integer(forKey: dataSavingModeKey)
    }

    static let dataSavingModeOptions: [Int] = [0, 1, 2]
    static let dataSavingModeOptionsText: [String] = ["Off", "Only on Cellular Data", "Always"]
}
