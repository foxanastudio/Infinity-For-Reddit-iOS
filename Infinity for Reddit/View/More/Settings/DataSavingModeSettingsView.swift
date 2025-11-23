//
// DataSavingModeSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI

struct DataSavingModeSettingsView: View {
    @AppStorage(DataSavingModeUserDefaultsUtils.dataSavingModeKey, store: .dataSavingMode) private var dataSavingMode: Int = 0

    var body: some View {
        RootView {
            List {
                PreferenceEntry(
                    title: "",
                    subtitle: "In data saving mode:\nPreview images are in lower resolution.\nReddit videos are in lower resolution.\nVideo autoplay is disabled.",
                    icon: "exclamationmark.circle"
                ) {
                    // Empty action
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $dataSavingMode,
                    items: DataSavingModeUserDefaultsUtils.dataSavingModeOptions,
                    title: "Data Saving Mode"
                ) { mode in
                    DataSavingModeUserDefaultsUtils.dataSavingModeOptionsText[mode]
                }
                .listPlainItemNoInsets()
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Data Saving Mode")
    }
}
