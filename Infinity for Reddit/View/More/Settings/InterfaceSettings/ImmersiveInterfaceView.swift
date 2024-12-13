//
// ImmersiveInterfaceView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-05
//

import SwiftUI
import Swinject
import GRDB

struct ImmersiveInterfaceView: View {
    @StateObject var immersiveInterfaceViewModel = ImmersiveInterfaceViewModel()
    
    var body: some View {
        List {
            Toggle(isOn: $immersiveInterfaceViewModel.immersiveInterface){
                VStack(alignment: .leading) {
                    Text("Immersive Interface")
                    Text("Does Not Apply to All Pages")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Toggle(isOn: $immersiveInterfaceViewModel.ignoreNavigationBarInImmersiveInterface){
                VStack(alignment: .leading) {
                    Text("Ignore Navigation Bar in Immersive Interface")
                    Text("Prevent the Bottom Navigation Bar Having Extra Padding")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Immersive Interface")
    }
}

