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
                NSRegularExpression(pattern: #"https:\/\/preview\.redd\.it\/[a-zA-Z0-9]+\.(?:jpeg|jpg|png)\?width=\d+&format=\w+&auto=\w+&s=[a-f0-9]+"#, options: []),
                NSRegularExpression(pattern: #"\[(.*?)\]\(https:\/\/preview\.redd\.it\/[a-zA-Z0-9]+\.(?:jpeg|jpg|png)\?width=\d+&format=\w+&auto=\w+&s=[a-f0-9]+\)"#, options: []),
                NSRegularExpression(pattern: #"\|:?|:?\|"#, options: [])
            ]
        } catch {
            fatalError("Error creating regular expressions: \(error)")
        }
    }()
    
    static func replaceImageURL(_ comment: Comment) {
        guard let commentBody = comment.body else {
            print("Error: Comment body is nil for comment ID: \(comment.id ?? "unknown").")
            return
        }
        
        var replacedBody = commentBody
        
        let imageURLMatches = MarkdownUtils.REGEX_PATTERNS[1].matches(in: commentBody, options: [], range: NSRange(location: 0, length: commentBody.count))
        let imageMarkdownMatches = MarkdownUtils.REGEX_PATTERNS[2].matches(in: commentBody, options: [], range: NSRange(location: 0, length: commentBody.count))
        guard !imageURLMatches.isEmpty || !imageMarkdownMatches.isEmpty else {
            return
        }
        
        print(commentBody)
        var excludedRanges = Set<NSRange>()
        for match in imageMarkdownMatches.reversed() {
            if let range = Range(match.range, in: commentBody) {
                let matchedMarkdown = String(commentBody[range])
                if let urlRange = matchedMarkdown.range(of: #"(?<=\()\S+(?=\))"#, options: .regularExpression) {
                    let urlNSRange = NSRange(urlRange, in: commentBody)
                    excludedRanges.insert(urlNSRange)
                }
            }
        }
        
        let previewReddItLength = "https://preview.redd.it/".count;
        
        for match in imageURLMatches.reversed() {
            let matchRange = match.range
            
            // Skip matches that overlap with excluded ranges
            if excludedRanges.contains(where: { $0.intersection(matchRange) != nil }) {
                continue
            }
            
            // Replace the matched URL with markdown image syntax
            if let range = Range(matchRange, in: commentBody) {
                let matchedString = String(commentBody[range])
                // Calculate the starting index after `previewReddItLength` from the match's lower bound
                let startIndex = matchedString.index(range.lowerBound, offsetBy: previewReddItLength)
                // Find the index of the first occurrence of "." after `startIndex`
                if let dotIndex = matchedString[startIndex...].firstIndex(of: ".") {
                    // Extract the substring between `startIndex` and `dotIndex`
                    let id = String(matchedString[startIndex ..< dotIndex])
                    print(id)
                    let markdownImage = "![](\(id))"
                    replacedBody.replaceSubrange(range, with: markdownImage)
                } else {
                    let markdownImage = "![Preview Image](\(matchedString))"
                    replacedBody.replaceSubrange(range, with: markdownImage)
                }
            }
        }
        
        for match in imageMarkdownMatches.reversed() {
            let range = Range(match.range, in: commentBody)!
            let matchedMarkdown = String(commentBody[range])
            let rangeOfCaption = Range(match.range(at: 1), in: commentBody)!
            let matchedCaption = String(commentBody[rangeOfCaption])
            
            // Find the last occurrence of "https://preview.redd.it/" within the matched range
            if let urlStartRange = matchedMarkdown.range(of: "https://preview.redd.it/", options: .backwards, range: range) {
                let urlStartIndex = urlStartRange.lowerBound
                
                // Calculate the start index for the ID extraction
                let idStartIndex = matchedMarkdown.index(urlStartIndex, offsetBy: previewReddItLength)
                
                // Find the end of the ID (index of ".")
                if let dotIndex = matchedMarkdown[idStartIndex...].firstIndex(of: ".") {
                    // Extract the ID
                    let id = String(matchedMarkdown[idStartIndex..<dotIndex])
                    
                    // Calculate the caption substring range
                    let captionStartIndex = matchedMarkdown.index(range.lowerBound, offsetBy: 1) // matcher.start() + 1
                    let captionEndIndex = matchedMarkdown.index(urlStartIndex, offsetBy: -2)     // urlStartIndex - 2
                    let caption = String(matchedMarkdown[captionStartIndex..<captionEndIndex])
                    
                    print("ID: \(id)")
                    print("Caption: \(caption)")
                    
                    let markdownImage = "![](\(id))"
                    replacedBody.replaceSubrange(range, with: markdownImage)
                    
                    if !matchedCaption.isEmpty {
                        comment.mediaMetadata?[id]?.caption = matchedCaption
                    }
                } else {
                    // TODO add caption
                    let markdownImage = "![](\(matchedMarkdown))"
                    replacedBody.replaceSubrange(range, with: markdownImage)
                }
            } else {
                // TODO add caption
                let markdownImage = "![](\(matchedMarkdown))"
                replacedBody.replaceSubrange(range, with: markdownImage)
            }
        }
        print(replacedBody)
        comment.body = replacedBody
    }
    
    static func detectMarkdownTable(_ text: String) -> Bool {
        let markdownTableMatches = MarkdownUtils.REGEX_PATTERNS[3].matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        if markdownTableMatches.count > 0 {
            return true
        }
        return false
    }
}


