//
//  InternalStateUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-01-02.
//

import Foundation

class InternalStateUserDefaultsUtils {
    static let onboardingFinishedKey = "onboarding_finished"
    static var onboardingFinished: Bool {
        return UserDefaults.internalState?.bool(forKey: onboardingFinishedKey, false) ?? false
    }
    
    static let currentBuildNumberKey = "current_build_number"
    static var currentBuildNumber: Int {
        return UserDefaults.internalState?.integer(forKey: currentBuildNumberKey, 0) ?? 0
    }
    static func setCurrentBuildNumber() {
        UserDefaults.internalState?.set(Bundle.main.buildNumber, forKey: currentBuildNumberKey)
    }
}
