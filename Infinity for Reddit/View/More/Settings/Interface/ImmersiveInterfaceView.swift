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
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @State private var immersiveInterface: Bool
    @State private var ignoreNavigationBarInImmersiveInterface: Bool
    private let userDefaults: UserDefaults
    
    init(){
        guard let resolvedUserDefaults = DependencyManager.shared.container.resolve(UserDefaults.self) else {
            fatalError("Failed to resolve UserDefaults")
        }
        self.userDefaults = resolvedUserDefaults
        
        if userDefaults.object(forKey: "IMMERSIVE_INTERFACE_KEY") == nil {
            userDefaults.set(true, forKey: "IMMERSIVE_INTERFACE_KEY")
        }
        
        if userDefaults.object(forKey: "IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY") == nil {
            userDefaults.set(false, forKey: "IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY")
        }
        
        _immersiveInterface = State(initialValue: userDefaults.bool(forKey: "IMMERSIVE_INTERFACE_KEY"))
        _ignoreNavigationBarInImmersiveInterface = State(initialValue: userDefaults.bool(forKey: "IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY"))
    }
    
    var body: some View {
        List {
            Toggle(isOn: $immersiveInterface){
                VStack(alignment: .leading) {
                    Text("Immersive Interface")
                    Text("Does Not Apply to All Pages")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .onChange(of: immersiveInterface){
                _, newValue in userDefaults.set(newValue, forKey: "IMMERSIVE_INTERFACE_KEY")
            }
            Toggle(isOn: $ignoreNavigationBarInImmersiveInterface){
                VStack(alignment: .leading) {
                    Text("Ignore Navigation Bar in Immersive Interface")
                    Text("Prevent the Bottom Navigation Bar Having Extra Padding")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }.onChange(of: ignoreNavigationBarInImmersiveInterface){
                _, newValue in userDefaults.set(newValue, forKey: "IMMERSIVE_INTERFACE_IGNORE_NAV_BAR_KEY")
            }
        }
        .navigationTitle("Immersive Interface")
    }
}

