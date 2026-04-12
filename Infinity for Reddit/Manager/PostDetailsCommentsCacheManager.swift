//
//  PostDetailsCommentsCacheManager.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-12.
//

import Foundation

class PostDetailsCommentsCacheManager {
    static let shared = PostDetailsCommentsCacheManager()
    
    private var cache: NSCache<NSString, PostDetailsCommentsCache>
    
    private init() {
        cache = NSCache<NSString, PostDetailsCommentsCache>()
        self.cache.countLimit = 25
    }
    
    func getCache(postId: String) -> PostDetailsCommentsCache? {
        cache.object(forKey: postId as NSString)
    }
    
    func setCache(postId: String, cache: PostDetailsCommentsCache) {
        self.cache.setObject(cache, forKey: postId as NSString)
    }
    
    func removeCache(postId: String) {
        self.cache.removeObject(forKey: postId as NSString)
    }
}
