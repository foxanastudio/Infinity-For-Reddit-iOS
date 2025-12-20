//
//  NavigationManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

import SwiftUI
import Alamofire

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    var viewShouldHideRootTabLabels: [Bool] = []
    var viewShouldHideNavigationBarOnScroll: [Bool] = []
    
    var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    private var firstViewShouldHideNavigationBarOnScrollDown: Bool
    
    private let session: Session
    
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
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: "plain") else {
            fatalError("Failed to resolve plain Session in NavigationManager")
        }
        self.session = resolvedSession
        
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
        handleLinkDestination(LinkHandler.shared.handle(link: link))
    }

    func openLink(_ url: URL) {
        handleLinkDestination(LinkHandler.shared.handle(url: url))
    }
    
    private func handleLinkDestination(_ linkDestination: LinkDestination) {
        switch linkDestination {
        case .navigation(let destination):
            append(destination)
        case .redditShareLink(let redirectedURL):
            Task {
                let response = await session.request(redirectedURL)
                    .validate()
                    .serializingData()
                    .response
                
                await MainActor.run {
                    if let redirectedURL = response.response?.url {
                        openRedirectedRedditShareLink(redirectedURL)
                    } else {
                        UIApplication.shared.open(redirectedURL)
                    }
                }
            }
        case .fullScreenMedia(let fullScreenMediaType):
            fullScreenMediaViewModel.show(fullScreenMediaType)
        case .openInBrowser(let url):
            UIApplication.shared.open(url)
        case .invalid:
            break
        }
    }
    
    private func openRedirectedRedditShareLink(_ redirectedURL: URL) {
        let linkDestination = LinkHandler.shared.handle(url: redirectedURL, allowRedditShareLink: false)
        switch linkDestination {
        case .navigation(let destination):
            append(destination)
        case .redditShareLink(let redirectedURL):
            break
        case .fullScreenMedia(let fullScreenMediaType):
            fullScreenMediaViewModel.show(fullScreenMediaType)
        case .openInBrowser(let url):
            UIApplication.shared.open(url)
        case .invalid:
            break
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
