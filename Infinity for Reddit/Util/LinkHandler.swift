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
    
    func handle(link: String, allowRedditShareLink: Bool = true) -> LinkDestination {
        guard let url = URL(string: link) else {
            return LinkDestination.invalid
        }
        
        return handle(url: url, allowRedditShareLink: allowRedditShareLink)
    }
    
    func handle(url: URL, allowRedditShareLink: Bool = true) -> LinkDestination {
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
            print("Missing host in URL: \(finalURL)")
            return LinkDestination.invalid
        }
        
        let path = finalURL.path
        let segments = path.split(separator: "/").map(String.init)
        
        if path.hasSuffix(".mp4") {
            return LinkDestination.fullScreenMedia(FullScreenMediaType.video(urlString: finalURL.absoluteString, videoType: .direct))
        } else if path.hasSuffix(".jpg") || path.hasSuffix(".JPG") || path.hasSuffix(".jpeg") {
            return LinkDestination.fullScreenMedia(FullScreenMediaType.image(urlString: finalURL.absoluteString, fileName: "\(segments[segments.count - 1]).jpg"))
        } else if path.hasSuffix(".png") || path.hasSuffix(".PNG") {
            return LinkDestination.fullScreenMedia(FullScreenMediaType.image(urlString: finalURL.absoluteString, fileName: "\(segments[segments.count - 1]).png"))
        } else if path.hasSuffix(".gif") {
            return LinkDestination.fullScreenMedia(FullScreenMediaType.gif(urlString: finalURL.absoluteString, fileName: "\(segments[segments.count - 1]).gif"))
        }
        
        switch host {
        case "v.redd.it":
            return LinkDestination.fullScreenMedia(FullScreenMediaType.video(urlString: finalURL.absoluteString, videoType: .vReddIt))
            
        case "reddit-uploaded-media.s3-accelerate.amazonaws.com":
            return openUploadedRedditImage(finalURL)
            
        case _ where host.contains("reddit.com") || host.contains("redd.it") || host.contains("reddit.app"):
            return handleRedditPath(path, segments: segments, url: finalURL, allowRedditShareLink: allowRedditShareLink)
            
        case _ where host.contains("imgur.com"):
            return handleImgurURL(path: path, segments: segments, url: finalURL)
            
        case _ where host.contains("redgifs.com"):
            return handleRedgifsURL(path: path, url: finalURL)
            
        case _ where host.contains("google.com"):
            return handleGoogleAmp(url: finalURL, path: path)
            
        case "streamable.com":
            return handleStreamable(path: path, segments: segments, url: finalURL)
            
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
    
    private func handleRedditPath(_ path: String, segments: [String], url: URL, allowRedditShareLink: Bool) -> LinkDestination {
        if path == "/report" {
            return LinkDestination.openInBrowser(url)
        } else if allowRedditShareLink && segments.count == 4 && (segments[0] == "r" || segments[0] == "u"), segments[2] == "s" {
            return LinkDestination.redditShareLink(url)
        } else if segments.count == 4, segments[0] == "r", segments[2] == "wiki" {
            // Wiki
            return LinkDestination.navigation(AppNavigation.wiki(subredditName: segments[1], wikiPath: segments[3]))
        } else if segments.contains("comments"), let index = segments.lastIndex(of: "comments"), index + 1 < segments.count {
            let postId = segments[index + 1]
            if segments.count > index + 3 {
                let commentId = segments.last!
                return LinkDestination.navigation(AppNavigation.postDetails(postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId, commentId: commentId), isFromSubredditPostListing: false))
            } else {
                return LinkDestination.navigation(AppNavigation.postDetails(postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId), isFromSubredditPostListing: false))
            }
        } else if path == "/media", let query = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                  let realURLString = query.first(where: { $0.name == "url" })?.value,
                  let realURL = URL(string: realURLString) {
            return LinkDestination.fullScreenMedia(FullScreenMediaType.image(urlString: realURL.absoluteString, fileName: "\(segments[segments.count - 1]).jpg"))
        } else if segments.count == 4, segments[0] == "user", segments[2] == "m" {
            // Custom Feed
            return LinkDestination.navigation(AppNavigation.customFeed(customFeed: .path(path)))
        } else if let subredditMatch = path.range(of: "/r/[\\w-]+", options: .regularExpression) {
            let subreddit = String(path[subredditMatch]).components(separatedBy: "/")[2]
            return LinkDestination.navigation(AppNavigation.subredditDetails(subredditName: subreddit))
        } else if let userMatch = path.range(of: "/(u|user)/[\\w-]+", options: .regularExpression) {
            let username = String(path[userMatch]).components(separatedBy: "/").last!
            return LinkDestination.navigation(AppNavigation.userDetails(username: username))
        } else {
            return LinkDestination.openInBrowser(url)
        }
    }
    
    private func handleImgurURL(path: String, segments: [String], url: URL) -> LinkDestination {
        if path.matches("/gallery/\\w+/?") {
            print("Open Imgur gallery: \(segments[1])")
            return LinkDestination.fullScreenMedia(FullScreenMediaType.imgurGallery(imgurId: segments[1].components(separatedBy: "-").last ?? segments[1]))
        } else if path.matches("/(album|a)/\\w+/?") {
            print("Open Imgur album: \(segments[1])")
            return LinkDestination.fullScreenMedia(FullScreenMediaType.imgurGallery(imgurId: segments[1].components(separatedBy: "-").last ?? segments[1]))
        } else if path.matches("/\\w+/?") {
            print("Open Imgur image: \(path.dropFirst())")
            let potentialId = path.dropFirst()
            return LinkDestination.fullScreenMedia(FullScreenMediaType.imgurImage(imgurId: String(potentialId.components(separatedBy: "-").last ?? String(potentialId))))
        } else if path.hasSuffix(".gifv") || path.hasSuffix(".mp4") {
            var videoURL = url.absoluteString
            if path.hasSuffix(".gifv") {
                videoURL = videoURL.replacingOccurrences(of: ".gifv", with: ".mp4")
            }
            return LinkDestination.fullScreenMedia(FullScreenMediaType.video(urlString: url.absoluteString, videoType: .direct))
        } else {
            return LinkDestination.openInBrowser(url)
        }
    }
    
    private func handleRedgifsURL(path: String, url: URL) -> LinkDestination {
        if path.matches("/watch/[\\w-]+$") {
            let id = path.components(separatedBy: "/").last!
            print("Open Redgifs video ID: \(id)")
            return LinkDestination.fullScreenMedia(FullScreenMediaType.video(urlString: url.absoluteString, videoType: .redgifs(id: id)))
        } else {
            print("Invalid Redgifs link")
            return LinkDestination.openInBrowser(url)
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
    
    private func handleStreamable(path: String, segments: [String], url: URL) -> LinkDestination {
        if path.matches("/\\w+/?") {
            let shortCode = segments[0]
            print("Open Streamable video: \(shortCode)")
            return LinkDestination.fullScreenMedia(FullScreenMediaType.video(urlString: url.absoluteString, videoType: VideoType.streamable(shortCode: shortCode)))
        } else {
            return LinkDestination.openInBrowser(url)
        }
    }
    
    private func openUploadedRedditImage(_ url: URL) -> LinkDestination {
        let unescaped = url.absoluteString.replacingOccurrences(of: "%2F", with: "/")
        if let id = unescaped.components(separatedBy: "/").last {
            print("Uploaded image ID: \(id)")
            return LinkDestination.fullScreenMedia(.image(urlString: unescaped, fileName: "\(Utils.randomString()).jpg"))
        }
        return LinkDestination.openInBrowser(url)
    }
    
    private func openInSafari(_ url: URL) {
        UIApplication.shared.open(url)
    }
}

enum LinkDestination {
    case navigation(any Hashable)
    case redditShareLink(URL)
    case fullScreenMedia(FullScreenMediaType)
    case openInBrowser(URL)
    case invalid
}
