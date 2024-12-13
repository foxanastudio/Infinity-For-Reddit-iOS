//
//  TimeFormatInterfaceViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-13.
//

import SwiftUI
import Swinject
import GRDB
import Combine

class TimeFormatInterfaceViewModel: ObservableObject {
    // MARK: - Properties
    @Published var showElapsedTime: Bool
    @Published var selectedTimeFormat: Int
    
    let SHOW_ELAPSED_TIME_KEY = UserDefaultsUtils.SHOW_ELAPSED_TIME_KEY
    let TIME_FORMAT_KEY = UserDefaultsUtils.TIME_FORMAT_KEY
    
    let timeFormats = [
        "Jan 23, 2020, 23:45",
        "Jan 23, 2020, 11:45 PM",
        "23 Jan, 2020, 23:45",
        "23 Jan, 2020, 11:45 PM",
        "1/23/2020 23:45",
        "1/23/2020 11:45 PM",
        "23/1/2020 23:45",
        "23/1/2020 11:45 PM",
        "2020/1/23 23:45",
        "2020/1/23 11:45 PM",
        "1-23-2020 23:45",
        "1-23-2020 11:45 PM",
        "23-1-2020 23:45",
        "23-1-2020 11:45 PM",
        "2020/1/23 23:45",
        "2020/1/23 11:45 PM",
        "23.1.2020 23:45",
        "23.1.2020 11:45 PM",
        "2020.1.23 23:45",
        "2020.1.23 11:45 PM"
    ]
    
    private let userDefaults: UserDefaults
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializer
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: SHOW_ELAPSED_TIME_KEY) == nil {
            userDefaults.set(false, forKey: SHOW_ELAPSED_TIME_KEY)
        }
        if userDefaults.object(forKey: TIME_FORMAT_KEY) == nil {
            userDefaults.set(2, forKey: TIME_FORMAT_KEY)
        }
        showElapsedTime = userDefaults.bool(forKey: SHOW_ELAPSED_TIME_KEY)
        selectedTimeFormat = userDefaults.integer(forKey: TIME_FORMAT_KEY)
        
        $showElapsedTime
            .sink { [weak self] newValue in
                self?.saveTimeFormatInterfaceSettings(setting: newValue, forKey: self?.SHOW_ELAPSED_TIME_KEY ?? "")
            }
            .store(in: &cancellables)
        
        $selectedTimeFormat
            .sink { [weak self] newValue in
                self?.saveTimeFormatInterfaceSettings(setting: newValue, forKey: self?.TIME_FORMAT_KEY ?? "")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    func saveTimeFormatInterfaceSettings<T>(setting: T, forKey key: String) {
        userDefaults.set(setting, forKey: key)
    }
}
