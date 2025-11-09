//
//  RedditOAuthAPI.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import Alamofire
import Foundation

enum RedditOAuthAPI: URLRequestConvertible {
    case getMyInfo(headers: HTTPHeaders)
    case getFrontPagePosts(pathComponents: [String: String], queries: [String: String])
    case getUserData(username: String)
    case getSubredditData(subredditName: String)
    case getSubredditPosts(pathComponents: [String: String], queries: [String: String])
    case getUserPosts(pathComponents: [String: String], queries: [String: String])
    case getSearchPosts(queries: [String: String])
    case getSearchPostsInSpecificThing(pathComponents: [String: String], queries: [String: String])
    case getCustomFeedPosts(pathComponents: [String: String], queries: [String: String])
    case getSubredditConcatPosts(pathComponents: [String: String], queries: [String: String])
    case vote(params: [String: String])
    case getSubscribedThings(queries: [String: String])
    case getMyCustomFeeds
    case getUserComments(pathComponents: [String: String], queries: [String: String])
    case getUserSavedComments(pathComponents: [String: String], queries: [String: String])
    case subsrcribeToSubreddit(params: [String: String])
    case getPostAndCommentsById(postId: String, queries: [String: String])
    case getPostAndCommentsSingleThreadById(postId: String, commentId: String, queries: [String: String])
    case searchSubreddits(queries: [String: String])
    case searchUsers(queries: [String: String])
    case getInbox(pathComponents: [String: String], queries: [String: String], headers: HTTPHeaders?)
    case saveThing(params: [String: String])
    case unsaveThing(params: [String: String])
    case getMoreCommentsForCommentMore(params: [String: String])
    case sendCommentOrReplyToMessage(params: [String: String])
    case favoriteThing(params: [String: String])
    case favoriteCustomFeed(params: [String: String])
    case getRules(subredditName: String)
    case getFlairs(subredditName: String)
    case submitPost(params: [String: String])
    case uploadMediaMetadata(params: [String: String])
    case submitGalleryPost(body: String)
    case submitPollPost(body: String)
    case editPostOrComment(params: [String: String])
    case deletePostOrComment(params: [String: String])
    case getInfo(queries: [String: String])
    case hidePost(params: [String: String])
    case unhidePost(params: [String: String])
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getSearchPostsInSpecificThing, .getCustomFeedPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getUserSavedComments, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox, .getRules, .getFlairs, .getInfo:
            return .get
        case .vote, .subsrcribeToSubreddit, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage, .favoriteThing, .favoriteCustomFeed, .submitPost, .uploadMediaMetadata, .submitGalleryPost, .submitPollPost, .editPostOrComment, .deletePostOrComment, .hidePost, .unhidePost:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .getMyInfo:
            return "/api/v1/me"
        case .getUserData(let username):
            return "/user/\(username)/about.json"
        case .getSubredditData(let subredditName):
            return "r/\(subredditName)/about.json"
        case .getFrontPagePosts(let pathComponents, _):
            return "/\(pathComponents["sortType"] ?? "best").json"
        case .vote:
            return "/api/vote"
        case .getSubredditPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getUserPosts(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "")/\(pathComponents["where"] ?? "submitted").json"
        case .getSearchPosts:
            return "/search.json"
        case .getSearchPostsInSpecificThing(let pathComponents, _):
            return "\(pathComponents["name"] ?? "")/search.json"
        case .getCustomFeedPosts(let pathComponents, _):
            return "\(pathComponents["multipath"] ?? "").json"
        case .getSubredditConcatPosts(let pathComponents, _):
            return "/r/\(pathComponents["subreddit"] ?? "popular")/\(pathComponents["sortType"] ?? "hot").json"
        case .getSubscribedThings:
            return "/subreddits/mine/subscriber"
        case .getMyCustomFeeds:
            return "/api/multi/mine"
        case .getUserComments(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "infinityAN")/comments.json"
        case .getUserSavedComments(let pathComponents, _):
            return "/user/\(pathComponents["username"] ?? "")/saved.json"
        case .subsrcribeToSubreddit:
            return "/api/subscribe"
        case .getPostAndCommentsById(let postId, _):
            return "/comments/\(postId).json"
        case .getPostAndCommentsSingleThreadById(let postId, let commentId, _):
            return "/comments/\(postId)/placeholder/\(commentId).json"
        case .searchSubreddits:
            return "/subreddits/search.json"
        case .searchUsers:
            return "/search.json"
        case .getInbox(let pathComponents, _, _):
            return "/message/\(pathComponents["where"] ?? MessageWhere.inbox.rawValue).json"
        case .saveThing:
            return "/api/save"
        case .unsaveThing:
            return "/api/unsave"
        case .getMoreCommentsForCommentMore:
            return "/api/morechildren.json"
        case .sendCommentOrReplyToMessage:
            return "/api/comment"
        case .favoriteThing:
            return "/api/favorite"
        case .favoriteCustomFeed:
            return "/api/multi/favorite"
        case .getRules(let subredditName):
            return "/r/\(subredditName)/about/rules.json"
        case .getFlairs(let subredditName):
            return "/r/\(subredditName)/api/link_flair.json"
        case .submitPost:
            return "/api/submit"
        case .uploadMediaMetadata:
            return "/api/media/asset.json"
        case .submitGalleryPost:
            return "/api/submit_gallery_post.json"
        case .submitPollPost:
            return "/api/submit_poll_post.json"
        case .editPostOrComment:
            return "/api/editusertext"
        case .deletePostOrComment:
            return "/api/del"
        case .getInfo:
            return "/api/info.json"
        case .hidePost:
            return "/api/hide"
        case .unhidePost:
            return "/api/unhide"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getSearchPostsInSpecificThing, .getCustomFeedPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getUserSavedComments, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox, .getRules, .getFlairs, .submitGalleryPost, .submitPollPost, .getInfo:
            return nil
        case .vote(let params), .subsrcribeToSubreddit(let params), .saveThing(let params), .unsaveThing(let params), .getMoreCommentsForCommentMore(let params), .sendCommentOrReplyToMessage(let params), .favoriteThing(let params), .favoriteCustomFeed(let params), .submitPost(let params), .uploadMediaMetadata(let params), .editPostOrComment(let params), .deletePostOrComment(let params), .hidePost(let params), .unhidePost(let params):
            return params
        }
    }
    
    var queries: [String: String]? {
        switch self {
        case .getMyInfo:
            return ["raw_json": "1"]
        case .getFrontPagePosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserData:
            return ["raw_json": "1"]
        case .getSubredditData:
            return ["raw_json": "1"]
        case .vote, .getMyCustomFeeds, .saveThing, .unsaveThing, .subsrcribeToSubreddit, .sendCommentOrReplyToMessage, .favoriteThing:
            return nil
        case .getSubredditPosts(_, let queries):
            return ["raw_json": "1", "always_show_media": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserPosts(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSearchPosts(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSearchPostsInSpecificThing(_, let queries):
            return ["raw_json": "1", "restrict_sr": "on", "sr_detail": "true", "always_show_media": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getCustomFeedPosts(_, let queries):
            return ["raw_json": "1", "always_show_media": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSubredditConcatPosts(_, let queries):
            return ["raw_json": "1", "always_show_media": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getSubscribedThings(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserComments(_, let queries):
            return ["raw_json": "1", "sort": "best"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getUserSavedComments(_, let queries):
            return ["type": "comments", "raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getPostAndCommentsById(_, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getPostAndCommentsSingleThreadById(_, _, let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .searchSubreddits(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .searchUsers(let queries):
            return ["raw_json": "1", "type": "user"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getInbox(_, let queries, _):
            return ["raw_json": "1", "limit": "100"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getMoreCommentsForCommentMore:
            return ["raw_json": "1", "api_type": "json"]
        case .favoriteCustomFeed:
            return ["raw_json": "1", "gilding_detail": "1"]
        case .getRules:
            return ["raw_json": "1"]
        case .getFlairs:
            return ["raw_json": "1"]
        case .submitPost:
            return nil
        case .uploadMediaMetadata:
            return ["raw_json": "1", "gilding_detail": "1"]
        case .submitGalleryPost:
            return ["raw_json": "1", "resubmit": "true"]
        case .submitPollPost:
            return ["raw_json": "1", "resubmit": "true", "gilding_detail": "1"]
        case .editPostOrComment:
            return nil
        case .deletePostOrComment:
            return nil
        case .getInfo(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .hidePost:
            return nil
        case .unhidePost:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo(let headers):
            return headers
        case .getInbox(_, _, let headers):
            return headers
        case .getFrontPagePosts, .getUserData, .getSubredditData, .vote, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getSearchPostsInSpecificThing, .getCustomFeedPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getUserSavedComments, .subsrcribeToSubreddit, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage, .favoriteThing, .favoriteCustomFeed, .getRules, .getFlairs, .submitPost, .uploadMediaMetadata, .submitGalleryPost, .submitPollPost, .editPostOrComment, .deletePostOrComment, .getInfo, .hidePost, .unhidePost:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        default:
            return URLEncoding.default
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        var url = try baseURL.asURL().appendingPathComponent(path)
        //Setup query params
        if let queries = queries {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            urlComponents.queryItems = queries.map { key, value in
                URLQueryItem(name: key, value: value)
            }
            if let updatedURL = urlComponents.url {
                url = updatedURL
            }
        }
        //Set up method and headers
        var request = URLRequest(url: url)
        request.method = method
        request.headers = headers ?? HTTPHeaders()
        
        switch self {
        case .submitGalleryPost(let body), .submitPollPost(let body):
            request.httpBody = body.data(using: .utf8)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        default:
            //Setup URL encoded form data
            let formEncodedData = parameters?.map { key, value in
                "\(key)=\(value)"
            }.joined(separator: "&")
            request.httpBody = formEncodedData?.data(using: .utf8)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        return request
    }
}
