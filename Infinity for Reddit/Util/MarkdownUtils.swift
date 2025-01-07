//
//  MarkdownUtils.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-28.
//

import Foundation

class MarkdownUtils {
    private static let REGEX_PATTERNS = {
        do {
            return try [
                NSRegularExpression(pattern: #"!?\[gif\]\(([^)]+)\)"#, options: []),
                NSRegularExpression(pattern: #"https:\/\/preview\.redd\.it\/[a-zA-Z0-9]+\.(?:jpeg|jpg|png)\?width=\d+&format=\w+&auto=\w+&s=[a-f0-9]+"#, options: [])
            ]
        } catch {
            fatalError("Error creating regular expressions: \(error)")
        }
    }()
    
    static func replaceGifURL(_ comment: Comment) -> String {
        guard let commentBody = comment.body else {
            print("Error: Comment body is nil for comment ID: \(comment.id ?? "unknown").")
            return ""
        }
        var replacedBody = commentBody
        
        
        let gifMatches = MarkdownUtils.REGEX_PATTERNS[0].matches(in: commentBody, options: [], range: NSRange(location: 0, length: commentBody.count))
        guard !gifMatches.isEmpty else {
            return commentBody
        }
        
        for match in gifMatches {
            let rangeOfFirstGroup = Range(match.range(at: 1), in: commentBody)!
            let matchedString = String(commentBody[rangeOfFirstGroup])
//            print("matched \(matchedString)")
            guard let mediaMetadata = comment.mediaMetadata,
                  let mediaData = mediaMetadata[matchedString] as? [String: Any],
                  let sData = mediaData["s"] as? [String: Any],
                  let gifURL = sData["gif"] as? String else {
                continue
            }
            replacedBody = replacedBody.replacingOccurrences(of: matchedString, with: gifURL)
        }

        return replacedBody
    }
    
    static func replaceImageURL(_ comment: Comment) -> String {
        guard let commentBody = comment.body else {
            print("Error: Comment body is nil for comment ID: \(comment.id ?? "unknown").")
            return ""
        }
        var replacedBody = commentBody
        
        let imageMatches = MarkdownUtils.REGEX_PATTERNS[1].matches(in: commentBody, options: [], range: NSRange(location: 0, length: commentBody.count))
        guard !imageMatches.isEmpty else {
            return commentBody
        }
        
        for match in imageMatches {
            let range = Range(match.range, in: commentBody)!
            let matchedString = String(commentBody[range])
//            print("matched \(matchedString)")
            let markdownImage = "![Preview Image](\(matchedString))"
            replacedBody = replacedBody.replacingOccurrences(of: matchedString, with: markdownImage)
        }
        
        return replacedBody
    }
}


