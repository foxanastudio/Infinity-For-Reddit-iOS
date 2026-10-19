//
//  TabReselectionViewModifier.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-18.
//

import SwiftUI
import SwiftUIIntrospect

struct TabReselectionViewModifier: ViewModifier {
    @State private var delegateProxy = TabReselectionDelegateProxy()
    
    let onReselect: () -> Bool
    
    func body(content: Content) -> some View {
        content
            .introspect(.tabView, on: .iOS(.v18, .v26, .v27)) { tabBarController in
                delegateProxy.onReselect = onReselect
                if tabBarController.delegate !== delegateProxy {
                    delegateProxy.originalDelegate = tabBarController.delegate
                    tabBarController.delegate = delegateProxy
                }
            }
    }
}

final class TabReselectionDelegateProxy: NSObject, UITabBarControllerDelegate {
    weak var originalDelegate: UITabBarControllerDelegate?
    var onReselect: (() -> Bool)?
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController === tabBarController.selectedViewController, onReselect?() == true {
            return false
        }
        return originalDelegate?.tabBarController?(tabBarController, shouldSelect: viewController) ?? true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
        if tab === tabBarController.selectedTab, onReselect?() == true {
            return false
        }
        return originalDelegate?.tabBarController?(tabBarController, shouldSelectTab: tab) ?? true
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        super.responds(to: aSelector) || originalDelegate?.responds(to: aSelector) == true
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        if originalDelegate?.responds(to: aSelector) == true {
            return originalDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }
}
