//
//  NavigationManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    init(fullScreenMediaViewModel: FullScreenMediaViewModel) {
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
    }
    
    func openLink(_ link: String) {
        let linkDestination = LinkHandler.shared.handle(link: link)
        if case .navigation(let destination) = linkDestination {
            path.append(destination)
        } else if case .openInBrowser(let url) = linkDestination {
            UIApplication.shared.open(url)
        } else if case .fullScreenMedia(let fullScreenMediaType) = linkDestination {
            print(fullScreenMediaType)
        }
    }
    
    func openLink(_ url: URL) {
        let linkDestination = LinkHandler.shared.handle(url: url)
        if case .navigation(let destination) = linkDestination {
            path.append(destination)
        } else if case .openInBrowser(let url) = linkDestination {
            UIApplication.shared.open(url)
        } else if case .fullScreenMedia(let fullScreenMediaType) = linkDestination {
            print(fullScreenMediaType)
        }
    }
}
