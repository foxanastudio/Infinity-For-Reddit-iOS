//
//  AcknowledgementView.swift
//  Infinity for Reddit
//
//  Created by joeylr20242 on 2025-12-11.
//

import SwiftUI

struct AcknowledgementView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    private let acknowledgements: [Acknowledgement] = [
        Acknowledgement(
            name: "Alamofire",
            description: "Elegant HTTP networking for Swift",
            url: "https://github.com/Alamofire/Alamofire"
        ),
        Acknowledgement(
            name: "cmark-gfm",
            description: "CommonMark parsing and rendering library and program in C",
            url: "https://github.com/commonmark/cmark"
        ),
        Acknowledgement(
            name: "Flow",
            description: "Flow Layout implemented in SwiftUI",
            url: "https://github.com/tevelee/SwiftUI-Flow"
        ),
        Acknowledgement(
            name: "GCDWebServer",
            description: "Turned GCDWebServer into a Swift Package",
            url: "https://github.com/yene/GCDWebServer"
        ),
        Acknowledgement(
            name: "GiphyUISDK",
            description: "About Home of the GIPHY SDK iOS example app, along with iOS SDK documentation, issue tracking, & release notes",
            url: "https://github.com/Giphy/giphy-ios-sdk"
        ),
        Acknowledgement(
            name: "GRDB.swift",
            description: "A toolkit for SQLite databases, with a focus on application development",
            url: "https://github.com/groue/GRDB.swift"
        ),
        Acknowledgement(
            name: "Kingfisher",
            description: "A lightweight, pure-Swift library for downloading and caching images from the web",
            url: "https://github.com/onevcat/Kingfisher"
        ),
        Acknowledgement(
            name: "libwebp-Xcode",
            description: "A wrapper for libwebp + Xcode project. Support Carthage && CocoaPods && SwiftPM",
            url: "https://github.com/SDWebImage/libwebp-Xcode"
        ),
        Acknowledgement(
            name: "MijickCamera",
            description: "Camera made simple. The ultimate camera library that significantly reduces implementation time and effort. Written with and for SwiftUI",
            url: "https://github.com/Mijick/Camera.git"
        ),
        Acknowledgement(
            name: "SDWebImage",
            description: "Asynchronous image downloader with cache support as a UIImageView category",
            url: "https://github.com/SDWebImage/SDWebImage"
        ),
        Acknowledgement(
            name: "SDWebImageSwiftUI",
            description: "SwiftUI Image loading and Animation framework powered by SDWebImage",
            url: "https://github.com/SDWebImage/SDWebImageSwiftUI"
        ),
        Acknowledgement(
            name: "swift-collections",
            description: "Commonly used data structures for Swift",
            url: "https://github.com/apple/swift-collections"
        ),
        Acknowledgement(
            name: "swift-identified-collections",
            description: "A library of data structures for working with collections of identifiable elements in an ergonomic, performant way",
            url: "https://github.com/pointfreeco/swift-identified-collections"
        ),
        Acknowledgement(
            name: "swift-markdown-ui",
            description: "Display and customize Markdown text in SwiftUI",
            url: "https://github.com/gonzalezreal/swift-markdown-ui"
        ),
        Acknowledgement(
            name: "SwiftUI-Introspect",
            description: "Introspect underlying UIKit/AppKit components from SwiftUI",
            url: "https://github.com/siteline/SwiftUI-Introspect"
        ),
        Acknowledgement(
            name: "SwiftyJSON",
            description: "The better way to deal with JSON data in Swift",
            url: "https://github.com/SwiftyJSON/SwiftyJSON"
        ),
        Acknowledgement(
            name: "Swinject",
            description: "Dependency injection framework for Swift with iOS/macOS/Linux",
            url: "https://github.com/Swinject/Swinject"
        )
    ]
    
    var body: some View {
        RootView {
            List {
                ForEach(acknowledgements, id: \.name) { item in
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
        .addTitleToInlineNavigationBar("Acknowledgement")
    }
}

struct Acknowledgement {
    let name: String
    let description: String
    let url: String
}
