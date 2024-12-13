//
//  ImmersiveInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Combine
import GRDB
import Swinject

class ImmersiveInterfaceViewModel: ObservableObject {
    // MARK: - Properties
    @Published var immersiveInterface: Bool
    @Published var ignoreNavigationBarInImmersiveInterface: Bool
    
    let IMMERSIVE_INTERFACE_KEY = UserDefaultsUtils.IMMERSIVE_INTERFACE_KEY
    let IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY = UserDefaultsUtils.IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY
    
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: IMMERSIVE_INTERFACE_KEY) == nil {
            userDefaults.set(true, forKey: IMMERSIVE_INTERFACE_KEY)
        }
        
        if userDefaults.object(forKey: IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY) == nil {
            userDefaults.set(false, forKey: IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY)
        }
        
        immersiveInterface = userDefaults.bool(forKey: IMMERSIVE_INTERFACE_KEY)
        ignoreNavigationBarInImmersiveInterface = userDefaults.bool(forKey: IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY)
        
        $immersiveInterface
            .sink { [weak self] newValue in
                self?.saveImmersiveInterfaceSettings(setting: newValue, forKey: self?.IMMERSIVE_INTERFACE_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $ignoreNavigationBarInImmersiveInterface
            .sink { [weak self] newValue in
                self?.saveImmersiveInterfaceSettings(setting: newValue, forKey: self?.IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func saveImmersiveInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
    
}
