//
//  CreditsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-18.
//

import SwiftUI

struct CreditsView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    private let credits: [Credit] = [
        Credit(
            name: "App Icon Foreground",
            description: "Technology vector created by freepik - www.freepik.com",
            url: "https://www.freepik.com/free-photos-vectors/technology"
        ),
        Credit(
            name: "App Icon Background",
            description: "Background vector created by freepik - www.freepik.com",
            url: "https://www.freepik.com/free-photos-vectors/background"
        ),
        Credit(
            name: "Rocket Icon",
            description: "Icon made by Freepik from www.flaticon.com",
            url: "https://www.flaticon.com/free-icon/spring-swing-rocket_2929322?term=space%20ship&page=1&position=18"
        ),
        Credit(
            name: "Onboarding Animtaion 1",
            description: "Free Loading #20 Animation",
            url: "https://lottiefiles.com/free-animation/loading-20-UPbevBUQ7N"
        ),
        Credit(
            name: "Onboarding Animtaion 2",
            description: "Free Done Animation",
            url: "https://lottiefiles.com/free-animation/done-mxnPGfBzFJ"
        ),
        Credit(
            name: "Onboarding Animtaion 3",
            description: "Free Globe world map loader searching Animation",
            url: "https://lottiefiles.com/free-animation/globe-world-map-loader-searching-t5OSfEDBpp"
        )
    ]
    
    var body: some View {
        RootView {
            List {
                ForEach(credits, id: \.name) { item in
                    PreferenceEntry(
                        title: item.name,
                        subtitle: item.description
                    ) {
                        navigationManager.openLink(item.url)
                    }
                    .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Credits")
    }
}

struct Credit {
    let name: String
    let description: String
    let url: String
}
