//
//  ContentSensitivityFilterUserDetailsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-16.
//

import Foundation

enum ContentSensitivityFilterUserDetailsUtils {
    static let sensitiveContentKey = "sensitive_content"
    static var sensitiveContent: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: sensitiveContentKey, false)
    }
    
    static let blurSensitiveImagesKey = "blur_sensitive_images"
    static var blurSensitiveImages: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: blurSensitiveImagesKey, true)
    }
    
    static let doNotBlurSensitiveImagesInSensitiveSubredditsKey = "do_not_blur_sensitive_images_in_sensitive_subreddits"
    static var doNotBlurSensitiveImagesInSensitiveSubreddits: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: doNotBlurSensitiveImagesInSensitiveSubredditsKey)
    }
    
    static let spoilerContentKey = "spoiler_content"
    static var spoilerContent: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: spoilerContentKey)
    }
    
    static let blurSpoilerImagesKey = "blur_spoiler_images"
    static var blurSpoilerImages: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: blurSpoilerImagesKey)
    }
    
    static let disableSensitiveContentForeverKey = "disable_sensitive_content_forever"
    static var disableSensitiveContentForever: Bool {
        return UserDefaults.contentSensitivityFilter.bool(forKey: disableSensitiveContentForeverKey, false)
    }
}
