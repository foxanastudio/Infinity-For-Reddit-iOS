//
//  PostListingVideoManagerEnvironment.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-09.
//

import SwiftUI

struct PostListingVideoManagerEnvironmentKey: EnvironmentKey {
    static let defaultValue: PostListingVideoManager? = nil
}

extension EnvironmentValues {
    var postListingVideoManager: PostListingVideoManager? {
        get { self[PostListingVideoManagerEnvironmentKey.self] }
        set { self[PostListingVideoManagerEnvironmentKey.self] = newValue }
    }
}
