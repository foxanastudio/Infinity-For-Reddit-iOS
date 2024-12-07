//
//  TimeFormatView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-07.
//  

import SwiftUI
import Swinject
import GRDB

struct TimeFormatView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @State private var showElapsedTime: Bool
    @State private var selectedTimeFormat: Int

    private let SHOW_ELAPSED_TIME_KEY = UserDefaultsUtils.SHOW_ELAPSED_TIME_KEY
    private let TIME_FORMAT_KEY = UserDefaultsUtils.TIME_FORMAT_KEY

    private let userDefaults: UserDefaults
    
    private let timeFormats = [
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

    init() {
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
        _showElapsedTime = State(initialValue: userDefaults.bool(forKey: SHOW_ELAPSED_TIME_KEY))
        _selectedTimeFormat = State(initialValue: userDefaults.integer(forKey: TIME_FORMAT_KEY))
    }

    var body: some View {
        List {
            Toggle(isOn: $showElapsedTime) {
                Text("Show Elapsed Time in Posts and Comments")
            }
            .onChange(of: showElapsedTime) { _, newValue in
                userDefaults.set(newValue, forKey: SHOW_ELAPSED_TIME_KEY)
            }
            Picker("Time Format", selection: $selectedTimeFormat) {
                ForEach(0..<timeFormats.count, id: \.self) { index in
                    Text(timeFormats[index]).tag(index)
                }
            }
            .onChange(of: selectedTimeFormat) { _, newValue in
                userDefaults.set(newValue, forKey: TIME_FORMAT_KEY)
            }
        }
        .navigationTitle("Time Format")
    }
}
