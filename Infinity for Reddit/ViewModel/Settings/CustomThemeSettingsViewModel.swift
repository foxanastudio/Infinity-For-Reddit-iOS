//
//  CustomThemeSettingsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-24.
//

import Foundation
import Combine

class CustomThemeSettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var theme: Int // Options: Light, Dark, Device Default
    @Published var amoledDark: Bool // AMOLED Dark Mode Toggle
    
    let THEME_KEY = UserDefaultsUtils.THEME_KEY
    let AMOLED_DARK_KEY = UserDefaultsUtils.AMOLED_DARK_KEY
    
    let themeOptions: [String] = ["Light Theme", "Dark Theme", "Device Default"]
    
    // MARK: - Dependencies
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init() {
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        // Set default values if not already set
        if userDefaults.object(forKey: THEME_KEY) == nil {
            // Device default
            userDefaults.set(2, forKey: THEME_KEY)
        }
        if userDefaults.object(forKey: AMOLED_DARK_KEY) == nil {
            userDefaults.set(false, forKey: AMOLED_DARK_KEY)
        }
        
        // Load initial values from UserDefaults
        self.theme = userDefaults.integer(forKey: THEME_KEY)
        self.amoledDark = userDefaults.bool(forKey: AMOLED_DARK_KEY)
        
        print(theme)
        print(amoledDark)
        
        // React to changes in `theme` and save to UserDefaults
        $theme
            .sink { [weak self] newValue in
                self?.saveSetting(setting: newValue, forKey: self?.THEME_KEY ?? "")
            }
            .store(in: &cancellables)
        
        // React to changes in `amoledDark` and save to UserDefaults
        $amoledDark
            .sink { [weak self] newValue in
                self?.saveSetting(setting: newValue, forKey: self?.AMOLED_DARK_KEY ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    private func saveSetting<T>(setting: T, forKey key: String) {
        print(setting)
        userDefaults.set(setting, forKey: key)
    }
}
