//
//  NavigationManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

import SwiftUI

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    var viewShouldHideRootTabLabels: [Bool] = []
    
    var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    var rootTabLabelVisibility: Visibility {
        if viewShouldHideRootTabLabels.isEmpty {
            return .visible
        } else {
            return viewShouldHideRootTabLabels.last! ? .hidden : .visible
        }
    }
    
    init(fullScreenMediaViewModel: FullScreenMediaViewModel) {
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
    }
    
    func append(_ destination: any Hashable) {
        switch destination {
        case AppNavigation.userDetails:
            viewShouldHideRootTabLabels.append(true)
        default:
            viewShouldHideRootTabLabels.append(false)
        }
        path.append(destination)
    }
    
    func openLink(_ link: String) {
        let linkDestination = LinkHandler.shared.handle(link: link)
        if case .navigation(let destination) = linkDestination {
            append(destination)
        } else if case .openInBrowser(let url) = linkDestination {
            UIApplication.shared.open(url)
        } else if case .fullScreenMedia(let fullScreenMediaType) = linkDestination {
            print(fullScreenMediaType)
            fullScreenMediaViewModel.show(fullScreenMediaType)
        }
    }
    
    func openLink(_ url: URL) {
        let linkDestination = LinkHandler.shared.handle(url: url)
        if case .navigation(let destination) = linkDestination {
            append(destination)
        } else if case .openInBrowser(let url) = linkDestination {
            UIApplication.shared.open(url)
        } else if case .fullScreenMedia(let fullScreenMediaType) = linkDestination {
            print(fullScreenMediaType)
            fullScreenMediaViewModel.show(fullScreenMediaType)
        }
    }
    
    func replaceCurrentScreen(_ destination: any Hashable) {
        viewShouldHideRootTabLabels.removeLast()
        path.removeLast()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.append(destination)
        }
    }
    
    func replaceCurrentScreen(_ urlString: String) {
        viewShouldHideRootTabLabels.removeLast()
        path.removeLast()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.openLink(urlString)
        }
    }
}
