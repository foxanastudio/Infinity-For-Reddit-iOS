//
//  CustomThemeViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-10.
//

import Foundation
import Combine
import GRDB
import SwiftUI

public class CustomThemeViewModel: ObservableObject {
    @Published var allCustomThemes: [CustomTheme] = []
    @Published var currentLightCustomTheme: CustomTheme?
    @Published var currentDarkCustomTheme: CustomTheme?
    @Published var currentAmoledCustomTheme: CustomTheme?
    @Published var appColorScheme: ColorScheme = .light
    @Published var themeType: Int
    @Published var amoledDark: Bool
    
    private let customThemeDao: CustomThemeDao
    private var cancellables = Set<AnyCancellable>()
    
    let allCustomThemesPublisher: AnyPublisher<[CustomTheme], Error>
    let currentLightCustomThemePublisher: AnyPublisher<CustomTheme?, Error>
    let currentDarkCustomThemePublisher: AnyPublisher<CustomTheme?, Error>
    let currentAmoledCustomThemePublisher: AnyPublisher<CustomTheme?, Error>
    
    var currentCustomTheme: CustomTheme {
        if themeType == CustomThemeUserDefaultsUtils.themeDeviceDefault {
            if appColorScheme == .light {
                return self.currentLightCustomTheme ?? CustomTheme.getIndigo()
            } else {
                if self.amoledDark {
                    return self.currentAmoledCustomTheme ?? CustomTheme.getIndigoAmoled()
                }
                return self.currentDarkCustomTheme ?? CustomTheme.getIndigoDark()
            }
        } else if themeType == CustomThemeUserDefaultsUtils.themeLight {
            return self.currentLightCustomTheme ?? CustomTheme.getIndigo()
        } else if themeType == CustomThemeUserDefaultsUtils.themeDark {
            if self.amoledDark {
                return self.currentAmoledCustomTheme ?? CustomTheme.getIndigoAmoled()
            }
            return self.currentDarkCustomTheme ?? CustomTheme.getIndigoDark()
        }
        
        // Really shouldn't happen
        return CustomTheme.getIndigo()
    }
    
    var isCurrentThemeLight: Bool {
        if themeType == CustomThemeUserDefaultsUtils.themeDeviceDefault {
            return appColorScheme == .light
        } else if themeType == CustomThemeUserDefaultsUtils.themeLight {
            return true
        } else if themeType == CustomThemeUserDefaultsUtils.themeDark {
            return false
        }
        
        // Really shouldn't happen
        return true
    }
    
    init() {
        guard let resolvedDatabasePool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Could not resolve DatabasePool")
        }
        
        self.customThemeDao = CustomThemeDao(dbPool: resolvedDatabasePool)
        
        self.allCustomThemesPublisher = customThemeDao.getAllCustomThemesPublisher()
        self.currentLightCustomThemePublisher = customThemeDao.getLightCustomThemePublisher()
        self.currentDarkCustomThemePublisher = customThemeDao.getDarkCustomThemePublisher()
        self.currentAmoledCustomThemePublisher = customThemeDao.getAmoledCustomThemePublisher()
        
        self.themeType = CustomThemeUserDefaultsUtils.theme
        self.amoledDark = CustomThemeUserDefaultsUtils.amoledDark
        
        allCustomThemesPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] themes in
                self?.allCustomThemes = themes
            })
            .store(in: &cancellables)
        
        currentLightCustomThemePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] theme in
                self?.currentLightCustomTheme = theme
            })
            .store(in: &cancellables)
        
        currentDarkCustomThemePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] theme in
                self?.currentDarkCustomTheme = theme
            })
            .store(in: &cancellables)
        
        currentAmoledCustomThemePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] theme in
                self?.currentAmoledCustomTheme = theme
            })
            .store(in: &cancellables)
    }
    
    func setAppColorScheme(_ colorScheme: ColorScheme) {
        self.appColorScheme = colorScheme
    }
    
    func setThemeType(_ themeType: Int) {
        self.themeType = themeType
    }
    
    func setAmoledDark(_ amoledDark: Bool) {
        self.amoledDark = amoledDark
    }
}
