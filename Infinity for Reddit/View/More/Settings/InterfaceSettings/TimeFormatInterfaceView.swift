//
//  TimeFormatInterfaceView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-07.
//  

import SwiftUI
import Swinject
import GRDB

struct TimeFormatInterfaceView: View {
    @StateObject var timeFormatInterfaceViewModel = TimeFormatInterfaceViewModel()

    var body: some View {
        List {
            Toggle(isOn: $timeFormatInterfaceViewModel.showElapsedTime) {
                Text("Show Elapsed Time in Posts and Comments")
            }
            
            Picker("Time Format", selection: $timeFormatInterfaceViewModel.selectedTimeFormat) {
                ForEach(0..<timeFormatInterfaceViewModel.timeFormats.count, id: \.self) { index in
                    Text(timeFormatInterfaceViewModel.timeFormats[index]).tag(index)
                }
            }
        }
        .navigationTitle("Time Format")
    }
}
