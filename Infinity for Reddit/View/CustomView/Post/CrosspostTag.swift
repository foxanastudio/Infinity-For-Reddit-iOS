//
//  CrosspostTag.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-15.
//

import SwiftUI

struct CrosspostTag: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let parentPost: Post?
    
    var body: some View {
        SwiftUI.Image(systemName: "arrow.trianglehead.branch")
            .crosspostTag()
            .applyIf(parentPost != nil) {
                $0.onTapGesture {
                    navigationManager.append(AppNavigation.postDetails(postDetailsInput: .post(parentPost!), videoPlaybackTime: 0))
                }
            }
    }
}
