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
                NSRegularExpression(pattern: #"((?:\[(?:(?!(?:(?<!\\)\[)).)*?]\()?https://preview\.redd\.it/\w+\.(?:jpg|png|jpeg)(?:(?:\?+[-a-zA-Z0-9()@:%_+.~#?&/=]*)|))|((?:\[(?:(?!(?:(?<!\\)\[)).)*?]\()?https://i\.redd\.it/\w+\.(?:jpg|png|jpeg|gif))"#, options: []),
                NSRegularExpression(pattern: #"(?:\[(.*?)\]\()?(https:\/\/reddit\.com\/link\/([^\/]+)\/video\/([^\/]+)\/player)(?:\))?"#, options: []),
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
        
        processProcessingImgText(markdownString: &markdownString, mediaMetadataMap: mediaMetadataMap)
        
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
        guard var markdownString = post.selftext, !markdownString.isEmpty else {
            return
        }
        
        guard let mediaMetadataMap = post.mediaMetadata else {
            return
        }
        
        let previewRedditLength = "https://preview.redd.it/".count
        let iRedditLength = "https://i.redd.it/".count
        let redditVideoLength = "https://reddit.com/link/".count

        var startIndex = 0
        
        processProcessingImgText(markdownString: &markdownString, mediaMetadataMap: mediaMetadataMap)
        
        while true {
            // Apply regex starting from the current index
            let rangeToSearch = NSRange(location: startIndex, length: markdownString.count - startIndex)
            if let match = REGEX_PATTERNS[3].firstMatch(in: markdownString, options: [], range: rangeToSearch) {
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
            } else if let videoMatch = REGEX_PATTERNS[4].firstMatch(in: markdownString, options: [], range: rangeToSearch) {
                if let matchRange = Range(videoMatch.range, in: markdownString) {
                    let videoID = (markdownString as NSString).substring(with: videoMatch.range(at: 4))
                    
                    guard let mediaMetadata = mediaMetadataMap[videoID] else {
                        startIndex = matchRange.upperBound.utf16Offset(in: markdownString)
                        continue
                    }
                    
                    let linkID = (markdownString as NSString).substring(with: videoMatch.range(at: 3))
                    mediaMetadata.caption = videoMatch.range(at: 1).location != NSNotFound ? (markdownString as NSString).substring(with: videoMatch.range(at: 1)) : nil
                    var videoLinkMarkdown = (markdownString as NSString).substring(with: videoMatch.range)
                    if videoLinkMarkdown.hasPrefix("[") {
                        if let range = videoLinkMarkdown.range(of: "https://", options: .backwards) {
                            videoLinkMarkdown = String(videoLinkMarkdown[range.lowerBound..<videoLinkMarkdown.index(videoLinkMarkdown.endIndex, offsetBy: -1)])
                        }
                    }
                    mediaMetadata.videoLinkMarkdown = videoLinkMarkdown
                    printInDebugOnly(mediaMetadata.videoLinkMarkdown)
                    
                    let replacingText = "![](\(videoID))"
                    markdownString.replaceSubrange(matchRange, with: replacingText)
                    printInDebugOnly(replacingText)
                    startIndex = matchRange.lowerBound.utf16Offset(in: markdownString) + replacingText.count
                    
                    printInDebugOnly("Link ID: \(linkID)")
                    printInDebugOnly("Video ID: \(videoID)")
                }
            } else {
                break
            }
            
            post.selftext = markdownString
        }
    }
    
    private static func processProcessingImgText(markdownString: inout String, mediaMetadataMap: [String: MediaMetadata]) {
        if let processingImgPattern = try? NSRegularExpression(pattern: "\\*?Processing img (\\w+)\\.{3}\\*?", options: []) {
            let matches = processingImgPattern.matches(in: markdownString, range: NSRange(location: 0, length: markdownString.count))
            for match in matches.reversed() {
                guard let range = Range(match.range, in: markdownString) else {
                    continue
                }
                
                if let group1Range = Range(match.range(at: 1), in: markdownString) {
                    printInDebugOnly("processing id: \(markdownString[group1Range.lowerBound..<group1Range.upperBound])")
                    let id = String(markdownString[group1Range.lowerBound..<group1Range.upperBound])
                    if let media = mediaMetadataMap[id] {
                        if media.e == MediaMetadata.gifType {
                            if let replacingText = media.s?.gif {
                                markdownString.replaceSubrange(range, with: replacingText)
                            }
                        } else if media.e == MediaMetadata.imageType {
                            if let replacingText = media.s?.u {
                                markdownString.replaceSubrange(range, with: replacingText)
                            }
                        } else if media.e == MediaMetadata.redditVideoType {
                            if let replacingText = media.hlsUrl {
                                markdownString.replaceSubrange(range, with: replacingText)
                            }
                        }
                    }
                }
            }
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
            if let urlRange = markdownString[matchRange].range(of: "https://", options: .backwards) {
                let urlStartIndex = urlRange.lowerBound
                let idStartIndex = markdownString.index(urlStartIndex, offsetBy: baseURLLength)
                let idEndIndex = markdownString[idStartIndex...].firstIndex(of: ".")!
                id = String(markdownString[idStartIndex..<idEndIndex])
                
                let captionStartIndex = markdownString.index(matchRange.lowerBound, offsetBy: 1)
                let captionEndIndex = markdownString.index(urlStartIndex, offsetBy: -2)
                if captionEndIndex >= captionStartIndex {
                    caption = String(markdownString[captionStartIndex..<captionEndIndex])
                }
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
        printInDebugOnly(replacingText)
        return matchRange.lowerBound.utf16Offset(in: markdownString) + replacingText.count
    }
    
    static func insertImageOrGifIntoMarkdownString(
        content: inout String,
        selectedRange: inout NSRange,
        caption: String,
        imageOrGifId: String
    ) {
        guard let range = Range(selectedRange, in: content) else {
            return
        }
        
        let beforeRange = content[..<range.lowerBound]
        let afterRange = content[range.upperBound...]

        let leftCount = min(2, beforeRange.count)
        let leftStart = beforeRange.index(beforeRange.endIndex, offsetBy: -leftCount)
        let leftSlice = beforeRange[leftStart..<beforeRange.endIndex]

        let leftNewlines: Int
        if leftSlice.allSatisfy({ $0 == "\n" || $0.isWhitespace }) {
            leftNewlines = leftSlice.isEmpty ? 2 : leftSlice.filter { $0 == "\n" }.count
        } else if leftSlice.hasSuffix("\n") {
            leftNewlines = 1
        } else {
            leftNewlines = 0
        }

        let rightCount = min(2, afterRange.count)
        let rightEnd = afterRange.index(afterRange.startIndex, offsetBy: rightCount)
        let rightSlice = afterRange[afterRange.startIndex..<rightEnd]

        let rightNewlines: Int
        if rightSlice.allSatisfy({ $0 == "\n" || $0.isWhitespace }) {
            rightNewlines = rightSlice.isEmpty ? 2 : rightSlice.filter { $0 == "\n" }.count
        } else if rightSlice.hasPrefix("\n") {
            rightNewlines = 1
        } else {
            rightNewlines = 0
        }
        
        let imageSyntax = "\(String(repeating: "\n", count: max(0, 2 - leftNewlines)))![\(caption)](\(imageOrGifId))\(String(repeating: "\n", count: max(0, 2 - rightNewlines)))"
        
        let newText: String
        if selectedRange.length > 0 {
            newText = content.replacingCharacters(in: range, with: imageSyntax)
            selectedRange = NSRange(location: selectedRange.location,
                                    length: imageSyntax.count)
        } else {
            newText = content.inserting(imageSyntax, at: selectedRange.location)
            selectedRange = NSRange(location: selectedRange.location + imageSyntax.count,
                                    length: 0)
        }
        content = newText
    }
}
