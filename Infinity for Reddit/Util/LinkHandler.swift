//
//  LinkHandler.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-23.
//

import Foundation
import UIKit

class LinkHandler {
    static let shared = LinkHandler()
    
    private func constructRedditURL(from path: String) -> URL {
        let trimmed = path.trimmingCharacters(in: .whitespacesAndNewlines)
        let full = trimmed.hasPrefix("/") ? "https://www.reddit.com\(trimmed)" : "https://www.reddit.com/\(trimmed)"
        return URL(string: full)!
    }
    
    func handle(link: String) -> LinkDestination {
        guard let url = URL(string: link) else {
            return LinkDestination.invalid
        }
        
        return handle(url: url)
    }
    
    func handle(url: URL) -> LinkDestination {
        let finalURL: URL
        
        if url.scheme == nil && url.host == nil {
            let path = url.absoluteString.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !path.isEmpty else {
                print("Invalid link: \(url)")
                return LinkDestination.invalid
            }
            finalURL = constructRedditURL(from: path)
        } else {
            finalURL = url
        }
        
        guard let host = finalURL.host else {
            print("❌ Missing host in URL: \(finalURL)")
            return LinkDestination.invalid
        }
        
        let path = finalURL.path
        let segments = path.split(separator: "/").map(String.init)
        
        switch host {
        case "v.redd.it":
            openRedditVideo(finalURL)
            return LinkDestination.fullScreenMedia
            
        case "reddit-uploaded-media.s3-accelerate.amazonaws.com":
            openUploadedRedditImage(finalURL)
            return LinkDestination.fullScreenMedia
            
        case _ where host.contains("reddit.com") || host.contains("redd.it") || host.contains("reddit.app"):
            return handleRedditPath(path, segments: segments, url: finalURL)
            
        case _ where host.contains("imgur.com"):
            handleImgurURL(path: path, segments: segments, url: finalURL)
            return LinkDestination.fullScreenMedia
            
        case _ where host.contains("redgifs.com"):
            handleRedgifsURL(path: path)
            return LinkDestination.fullScreenMedia
            
        case _ where host.contains("google.com"):
            return handleGoogleAmp(url: finalURL, path: path)
            
        case "streamable.com":
            handleStreamable(path: path, segments: segments)
            return LinkDestination.fullScreenMedia
            
        case "click.redditmail.com":
            if path.hasPrefix("/CL0/") {
                let newPath = String(path.dropFirst("/CL0/".count))
                if let redirected = URL(string: newPath) {
                    return handle(url: redirected)
                }
            }
            
        default:
            return LinkDestination.openInBrowser(finalURL)
        }
        
        return LinkDestination.openInBrowser(finalURL)
    }
    
    private func handleRedditPath(_ path: String, segments: [String], url: URL) -> LinkDestination {
        if path == "/report" {
            return LinkDestination.openInBrowser(url)
        } else if segments.contains("comments"), let index = segments.lastIndex(of: "comments"), index + 1 < segments.count {
            let postId = segments[index + 1]
            if segments.count > index + 2 {
                let commentId = segments.last!
                openPostWithComment(postId, commentId: commentId)
                return LinkDestination.navigation(AppNavigation.postDetails(postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId, commentId: commentId), isFromSubredditPostListing: false))
            } else {
                openPost(postId)
                return LinkDestination.navigation(AppNavigation.postDetails(postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId), isFromSubredditPostListing: false))
            }
        } else if path == "/media", let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                  let realURLString = query.first(where: { $0.name == "url" })?.value,
                  let realURL = URL(string: realURLString) {
            openImage(realURL)
            return LinkDestination.fullScreenMedia
        } else if let subredditMatch = path.range(of: "/r/[\\w-]+", options: .regularExpression) {
            let subreddit = String(path[subredditMatch]).components(separatedBy: "/")[2]
            openSubreddit(subreddit)
            return LinkDestination.navigation(AppNavigation.subredditDetails(subredditName: subreddit))
        } else if let userMatch = path.range(of: "/(u|user)/[\\w-]+", options: .regularExpression) {
            let username = String(path[userMatch]).components(separatedBy: "/").last!
            openUser(username)
            return LinkDestination.navigation(AppNavigation.userDetails(username: username))
        } else {
            return LinkDestination.openInBrowser(url)
        }
    }
    
    private func handleImgurURL(path: String, segments: [String], url: URL) {
        if path.matches("/gallery/\\w+/?") {
            print("Open Imgur gallery: \(segments[1])")
        } else if path.matches("/(album|a)/\\w+/?") {
            print("Open Imgur album: \(segments[1])")
        } else if path.matches("/\\w+/?") {
            print("Open Imgur image: \(path.dropFirst())")
        } else if path.hasSuffix(".gifv") || path.hasSuffix(".mp4") {
            var videoURL = url.absoluteString
            if path.hasSuffix(".gifv") {
                videoURL = videoURL.replacingOccurrences(of: ".gifv", with: ".mp4")
            }
            openVideo(URL(string: videoURL)!)
        } else {
            openInSafari(url)
        }
    }
    
    private func handleRedgifsURL(path: String) {
        if path.matches("/watch/[\\w-]+$") {
            let id = path.components(separatedBy: "/").last!
            print("Open Redgifs video ID: \(id)")
        } else {
            print("Invalid Redgifs link")
        }
    }
    
    private func handleGoogleAmp(url: URL, path: String) -> LinkDestination {
        if path.matches("/amp/s/amp.reddit.com/.*") {
            let newPath = String(path.dropFirst("/amp/s/".count))
            if let redirected = URL(string: "https://\(newPath)") {
                return handle(url: redirected)
            } else {
                return LinkDestination.invalid
            }
        }
        return LinkDestination.openInBrowser(url)
    }
    
    private func handleStreamable(path: String, segments: [String]) {
        if path.matches("/\\w+/?") {
            let shortCode = segments[0]
            print("Open Streamable video: \(shortCode)")
        } else {
            print("Invalid Streamable link")
        }
    }
    
    private func openImage(_ url: URL) {
        print("Open image: \(url.absoluteString)")
    }
    
    private func openVideo(_ url: URL) {
        print("Open video: \(url.absoluteString)")
    }
    
    private func openUploadedRedditImage(_ url: URL) {
        let unescaped = url.absoluteString.replacingOccurrences(of: "%2F", with: "/")
        if let id = unescaped.components(separatedBy: "/").last {
            print("Uploaded image ID: \(id)")
        }
    }
    
    private func openRedditVideo(_ url: URL) {
        print("Open v.redd.it video: \(url.absoluteString)")
    }
    
    private func openPost(_ id: String) {
        print("Navigate to post: \(id)")
    }
    
    private func openPostWithComment(_ postId: String, commentId: String) {
        print("Navigate to post: \(postId) with comment: \(commentId)")
    }
    
    private func openSubreddit(_ name: String) {
        print("Navigate to subreddit: \(name)")
    }
    
    private func openUser(_ name: String) {
        print("Navigate to user: \(name)")
    }
    
    private func openInSafari(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

enum LinkDestination {
    case navigation(any Hashable)
    case fullScreenMedia
    case openInBrowser(URL)
    case invalid
}
