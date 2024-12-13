//
//  FontInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Combine
import GRDB
import Swinject

class FontInterfaceViewModel: ObservableObject {
    // MARK: - Properties
    @Published var fontFamily: Int
    @Published var fontSize: Int
    @Published var titleFontFamily: Int
    @Published var titleFontSize: Int
    @Published var contentFontFamily: Int
    @Published var contentFontSize: Int
    
    let FONT_FAMILY_KEY = UserDefaultsUtils.FONT_FAMILY_KEY
    let FONT_SIZE_KEY = UserDefaultsUtils.FONT_SIZE_KEY
    let TITLE_FONT_FAMILY_KEY = UserDefaultsUtils.TITLE_FONT_FAMILY_KEY
    let TITLE_FONT_SIZE_KEY = UserDefaultsUtils.TITLE_FONT_SIZE_KEY
    let CONTENT_FONT_FAMILY_KEY = UserDefaultsUtils.CONTENT_FONT_FAMILY_KEY
    let CONTENT_FONT_SIZE_KEY = UserDefaultsUtils.CONTENT_FONT_SIZE_KEY
    
    let families: [String] = ["Default", "Balsamiq Sans", "Balsamiq Sans Bold", "Noto Sans", "Noto Sans Bold", "Harmonia Sans", "Harmonia Sans Bold (No Italic)", "Roboto Condensed", "Roboto Condensed Bold", "Inter (No Italic)", "Inter Bold (No Italic)", "Manrope (No Italic)", "Manrope Bold (No Italic)", "Sriracha", "Atkinson Hyperlegible", "Atkinson Hyperlegible Bold", "Custom Font Family"]
    let sizes: [String] = ["Extra Small", "Small", "Normal", "Large", "Extra Large"]
    let contentSizes: [String] = ["Extra Small", "Small", "Normal", "Large", "Extra Large", "Enormously Large"]
    
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: FONT_FAMILY_KEY) == nil {
            userDefaults.set(0, forKey: FONT_FAMILY_KEY)
        }
        
        if userDefaults.object(forKey: FONT_SIZE_KEY) == nil {
            userDefaults.set(2, forKey: FONT_SIZE_KEY)
        }
        
        if userDefaults.object(forKey: TITLE_FONT_FAMILY_KEY) == nil {
            userDefaults.set(0, forKey: TITLE_FONT_FAMILY_KEY)
        }
        
        if userDefaults.object(forKey: TITLE_FONT_SIZE_KEY) == nil {
            userDefaults.set(2, forKey: TITLE_FONT_SIZE_KEY)
        }
        
        if userDefaults.object(forKey: CONTENT_FONT_FAMILY_KEY) == nil {
            userDefaults.set(0, forKey: CONTENT_FONT_FAMILY_KEY)
        }
        
        if userDefaults.object(forKey: CONTENT_FONT_SIZE_KEY) == nil {
            userDefaults.set(2, forKey: CONTENT_FONT_SIZE_KEY)
        }
        
        fontFamily = userDefaults.integer(forKey: FONT_FAMILY_KEY)
        fontSize = userDefaults.integer(forKey: FONT_SIZE_KEY)
        titleFontFamily = userDefaults.integer(forKey: TITLE_FONT_FAMILY_KEY)
        titleFontSize = userDefaults.integer(forKey: TITLE_FONT_SIZE_KEY)
        contentFontFamily = userDefaults.integer(forKey: CONTENT_FONT_FAMILY_KEY)
        contentFontSize = userDefaults.integer(forKey: CONTENT_FONT_SIZE_KEY)
        
        $fontFamily
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.FONT_FAMILY_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $fontSize
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.FONT_SIZE_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $titleFontFamily
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.TITLE_FONT_FAMILY_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $titleFontSize
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.TITLE_FONT_SIZE_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $contentFontFamily
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.CONTENT_FONT_FAMILY_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $contentFontSize
            .sink { [weak self] newValue in
                self?.saveInterfaceSettings(setting: newValue, forKey: self?.CONTENT_FONT_SIZE_KEY ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func saveInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
    
}
