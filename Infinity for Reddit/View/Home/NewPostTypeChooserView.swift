//
//  NewPostTypeChooserView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-03.
//

import SwiftUI

struct NewPostTypeChooserView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                SimpleTouchItemRow(text: "Text", icon: "text.page") {
                    navigationManager.path.append(AppNavigation.submitTextPost)
                }
                
                SimpleTouchItemRow(text: "Link", icon: "link") {
                    navigationManager.path.append(AppNavigation.submitLinkPost)
                }
                
                SimpleTouchItemRow(text: "Video", icon: "video") {
                    navigationManager.path.append(AppNavigation.submitVideoPost)
                }
                
                SimpleTouchItemRow(text: "Image", icon: "photo") {
                    navigationManager.path.append(AppNavigation.submitImagePost)
                }
                
                SimpleTouchItemRow(text: "Gallery", icon: "square.stack") {
                    navigationManager.path.append(AppNavigation.submitGalleryPost)
                }
                
                SimpleTouchItemRow(text: "Poll", icon: "chart.bar.xaxis") {
                    navigationManager.path.append(AppNavigation.submitPollPost)
                }
            }
        }
        .rootViewBackground()
    }
}
