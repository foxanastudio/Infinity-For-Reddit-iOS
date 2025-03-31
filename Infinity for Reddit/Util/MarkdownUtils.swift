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
                NSRegularExpression(pattern: #"((?<=[\\s])|^)/[rRuU]/[\\w-]+/{0,1}"#, options: []),
                NSRegularExpression(pattern: #"((?<=[\\s])|^)[rRuU]/[\\w-]+/{0,1}"#, options: []),
                NSRegularExpression(pattern: #"\\^{2,}"#, options: []),
                NSRegularExpression(pattern: #"((?:\[(?:(?!(?:(?<!\\)\[)).)*?]\()?https://preview\.redd\.it/\w+\.(?:jpg|png|jpeg)(?:(?:\?+[-a-zA-Z0-9()@:%_+.~#?&/=]*)|))|((?:\[(?:(?!(?:(?<!\\)\[)).)*?]\()?https://i\.redd\.it/\w+\.(?:jpg|png|jpeg|gif))"#, options: [])
            ]
        } catch {
            fatalError("Error creating regular expressions: \(error)")
        }
    }()
    
    static func parseRedditImagesBlock(_ comment: Comment) {
        guard let mediaMetadataMap = comment.mediaMetadata else {
            return
        }
        
        guard var markdownString = comment.body else {
            return
        }
        
        let previewRedditLength = "https://preview.redd.it/".count
        let iRedditLength = "https://i.redd.it/".count

        var startIndex = 0
        
        while true {
            // Apply regex starting from the current index
            let rangeToSearch = NSRange(location: startIndex, length: markdownString.count - startIndex)
            guard let match = REGEX_PATTERNS[3].firstMatch(in: markdownString, options: [], range: rangeToSearch) else {
                break
            }
            
            if let group1Range = Range(match.range(at: 1), in: markdownString) {
                // Handle preview.redd.it
                startIndex = processMediaMatch(matchRange: group1Range, markdownString: &markdownString, baseURLLength: previewRedditLength, mediaMetadataMap: mediaMetadataMap)
            } else if let group2Range = Range(match.range(at: 2), in: markdownString) {
                // Handle i.redd.it
                startIndex = processMediaMatch(matchRange: group2Range, markdownString: &markdownString, baseURLLength: iRedditLength, mediaMetadataMap: mediaMetadataMap)
            } else {
                // If no groups matched, move the index past this match
                startIndex = match.range.location + match.range.length
            }
            
            comment.body = markdownString
        }
    }
    
    static func parseRedditImagesBlock(_ post: Post) {
        guard let mediaMetadataMap = post.mediaMetadata else {
            return
        }
        
        guard var markdownString = post.selftext else {
            return
        }
        
        let previewRedditLength = "https://preview.redd.it/".count
        let iRedditLength = "https://i.redd.it/".count

        var startIndex = 0
        
        while true {
            // Apply regex starting from the current index
            let rangeToSearch = NSRange(location: startIndex, length: markdownString.count - startIndex)
            guard let match = REGEX_PATTERNS[3].firstMatch(in: markdownString, options: [], range: rangeToSearch) else {
                break
            }
            
            if let group1Range = Range(match.range(at: 1), in: markdownString) {
                // Handle preview.redd.it
                startIndex = processMediaMatch(matchRange: group1Range, markdownString: &markdownString, baseURLLength: previewRedditLength, mediaMetadataMap: mediaMetadataMap)
            } else if let group2Range = Range(match.range(at: 2), in: markdownString) {
                // Handle i.redd.it
                startIndex = processMediaMatch(matchRange: group2Range, markdownString: &markdownString, baseURLLength: iRedditLength, mediaMetadataMap: mediaMetadataMap)
            } else {
                // If no groups matched, move the index past this match
                startIndex = match.range.location + match.range.length
            }
            
            post.selftext = markdownString
        }
    }

    private static func processMediaMatch(
        matchRange: Range<String.Index>,
        markdownString: inout String,
        baseURLLength: Int,
        mediaMetadataMap: [String: MediaMetadata]
    ) -> Int {
        var id: String
        var caption: String? = nil
        
        if markdownString[matchRange.lowerBound] == "[" {
            // Has caption
            if let urlRange = markdownString[matchRange.lowerBound...].range(of: "https://") {
                let urlStartIndex = urlRange.lowerBound
                let idStartIndex = markdownString.index(urlStartIndex, offsetBy: baseURLLength)
                let idEndIndex = markdownString[idStartIndex...].firstIndex(of: ".")!
                id = String(markdownString[idStartIndex..<idEndIndex])
                
                let captionStartIndex = markdownString.index(matchRange.lowerBound, offsetBy: 1)
                caption = String(markdownString[captionStartIndex..<urlStartIndex])
            } else {
                return matchRange.upperBound.utf16Offset(in: markdownString)
            }
        } else {
            let idStartIndex = markdownString.index(matchRange.lowerBound, offsetBy: baseURLLength)
            let idEndIndex = markdownString[idStartIndex...].firstIndex(of: ".")!
            id = String(markdownString[idStartIndex..<idEndIndex])
        }
        
        guard let mediaMetadata = mediaMetadataMap[id] else {
            return matchRange.upperBound.utf16Offset(in: markdownString)
        }
        
        mediaMetadata.caption = caption
        
        let replacingText = "![](\(id))"
        markdownString.replaceSubrange(matchRange, with: replacingText)
        print(replacingText)
        return matchRange.lowerBound.utf16Offset(in: markdownString) + replacingText.count
    }
}


