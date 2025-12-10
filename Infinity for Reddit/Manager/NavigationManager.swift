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
    var viewShouldHideNavigationBarOnScroll: [Bool] = []
    
    var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    private var firstViewShouldHideNavigationBarOnScrollDown: Bool
    
    var rootTabLabelVisibility: Visibility {
        if viewShouldHideRootTabLabels.isEmpty {
            return .visible
        } else {
            return viewShouldHideRootTabLabels.last! ? .hidden : .visible
        }
    }
    
    var hideNavigationBarOnScrollDown: Bool {
        if viewShouldHideNavigationBarOnScroll.isEmpty {
            return firstViewShouldHideNavigationBarOnScrollDown
        } else {
            return viewShouldHideNavigationBarOnScroll.last!
        }
    }
    
    init(fullScreenMediaViewModel: FullScreenMediaViewModel, firstViewShouldHideNavigationBarOnScrollDown: Bool) {
        self.fullScreenMediaViewModel = fullScreenMediaViewModel
        self.firstViewShouldHideNavigationBarOnScrollDown = firstViewShouldHideNavigationBarOnScrollDown
    }
    
    func append(_ destination: any Hashable) {
        switch destination {
        case AppNavigation.userDetails:
            viewShouldHideRootTabLabels.append(true)
        default:
            viewShouldHideRootTabLabels.append(false)
        }
        
        switch destination {
        case AppNavigation.postDetails,
            AppNavigation.postDetailsWithId,
            AppNavigation.subredditDetails,
            AppNavigation.userDetails,
            AppNavigation.searchResults,
            AppNavigation.customFeed,
            AppNavigation.filteredPosts,
            AppNavigation.filteredHistoryPosts,
            MoreViewNavigation.popular,
            MoreViewNavigation.all,
            MoreViewNavigation.history,
            MoreViewNavigation.upvoted,
            MoreViewNavigation.downvoted,
            MoreViewNavigation.hidden,
            MoreViewNavigation.saved:
            viewShouldHideNavigationBarOnScroll.append(true)
        default:
            viewShouldHideNavigationBarOnScroll.append(false)
        }
        
        switch destination {
        case MoreViewNavigation.settings,
            MoreViewNavigation.test:
            viewShouldHideNavigationBarOnScroll.append(false)
        default:
            viewShouldHideNavigationBarOnScroll.append(false)
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
            fullScreenMediaViewModel.show(fullScreenMediaType)
        }
    }
    
    func replaceCurrentScreen(_ destination: any Hashable) {
        viewShouldHideRootTabLabels.removeLast()
        viewShouldHideNavigationBarOnScroll.removeLast()
        path.removeLast()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.append(destination)
        }
    }
    
    func replaceCurrentScreen(_ urlString: String) {
        viewShouldHideRootTabLabels.removeLast()
        viewShouldHideNavigationBarOnScroll.removeLast()
        path.removeLast()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.openLink(urlString)
        }
    }
}
