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
    case getInbox(pathComponents: [String: String], queries: [String: String])
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
    case deleteCustomFeed(path: String)
    case readMessage(params: [String: String])
    case readAllMessages
    case markSensitive(params: [String: String])
    case unmarkSensitive(params: [String: String])
    case markSpoiler(params: [String: String])
    case unmarkSpoiler(params: [String: String])
    case selectFlair(subredditName: String, params: [String: String])
    case getUserFlairs(subredditName: String)
    case selectUserFlair(subredditName: String, params: [String: String])
    case composeMessage(params: [String: String])
    case createCustomFeed(params: [String: String])
    case getCustomFeedInfo(queries: [String: String])
    case updateCustomFeed(params: [String: String])
    case copyCustomFeed(params: [String: String])
    case report(params: [String: String])
    case approveThing(params: [String: String])
    case removeThing(params: [String: String])
    case toggleStickyPost(params: [String: String])
    case lockThing(params: [String: String])
    case unlockThing(params: [String: String])
    case toggleDistinguishedThing(params: [String: String])
    case getWikiPage(subredditName: String, wikiPage: String)
    case subredditAutoComplete(queries: [String: String])
    
    private var baseURL: String {
        return "https://oauth.reddit.com"
    }
    
    var method: HTTPMethod {
        switch self {
        case .getMyInfo, .getFrontPagePosts, .getUserData, .getSubredditData, .getSubredditPosts, .getUserPosts, .getSearchPosts, .getSearchPostsInSpecificThing, .getCustomFeedPosts, .getSubredditConcatPosts, .getSubscribedThings, .getMyCustomFeeds, .getUserComments, .getUserSavedComments, .getPostAndCommentsById, .getPostAndCommentsSingleThreadById, .searchSubreddits, .searchUsers, .getInbox, .getRules, .getFlairs, .getInfo, .getUserFlairs, .getCustomFeedInfo, .getWikiPage, .subredditAutoComplete:
            return .get
        case .vote, .subsrcribeToSubreddit, .saveThing, .unsaveThing, .getMoreCommentsForCommentMore, .sendCommentOrReplyToMessage, .favoriteThing, .favoriteCustomFeed, .submitPost, .uploadMediaMetadata, .submitGalleryPost, .submitPollPost, .editPostOrComment, .deletePostOrComment, .hidePost, .unhidePost, .readMessage, .readAllMessages, .markSensitive, .unmarkSensitive, .markSpoiler, .unmarkSpoiler, .selectFlair, .selectUserFlair, .composeMessage, .createCustomFeed, .copyCustomFeed, .report, .approveThing, .removeThing, .toggleStickyPost, .lockThing, .unlockThing, .toggleDistinguishedThing:
            return .post
        case .deleteCustomFeed:
            return .delete
        case .updateCustomFeed:
            return .put
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
        case .getInbox(let pathComponents, _):
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
        case .deleteCustomFeed:
            return "/api/multi/multipath"
        case .readMessage:
            return "/api/read_message"
        case .readAllMessages:
            return "/api/read_all_messages"
        case .markSensitive:
            return "/api/marknsfw"
        case .unmarkSensitive:
            return "/api/unmarknsfw"
        case .markSpoiler:
            return "/api/spoiler"
        case .unmarkSpoiler:
            return "/api/unspoiler"
        case .selectFlair(let subredditName, _):
            return "/r/\(subredditName)/api/selectflair"
        case .getUserFlairs(let subredditName):
            return "r/\(subredditName)/api/user_flair_v2.json"
        case .selectUserFlair(let subredditName, _):
            return "/r/\(subredditName)/api/selectflair"
        case .composeMessage:
            return "/api/compose"
        case .createCustomFeed:
            return "/api/multi/multipath"
        case .getCustomFeedInfo:
            return "/api/multi/multipath"
        case .updateCustomFeed:
            return "/api/multi/multipath"
        case .copyCustomFeed:
            return "/api/multi/copy"
        case .report:
            return "/api/report"
        case .approveThing:
            return "/api/approve"
        case .removeThing:
            return "/api/remove"
        case .toggleStickyPost:
            return "/api/set_subreddit_sticky"
        case .lockThing:
            return "/api/lock"
        case .unlockThing:
            return "/api/unlock"
        case .toggleDistinguishedThing:
            return "/api/distinguish"
        case .getWikiPage(let subredditName, let wikiPage):
            return "/r/\(subredditName)/wiki/\(wikiPage).json"
        case .subredditAutoComplete:
            return "/api/subreddit_autocomplete_v2"
        }
    }
    
    var parameters: [String: String]? {
        switch self {
        case .vote(let params), .subsrcribeToSubreddit(let params), .saveThing(let params), .unsaveThing(let params), .getMoreCommentsForCommentMore(let params), .sendCommentOrReplyToMessage(let params), .favoriteThing(let params), .favoriteCustomFeed(let params), .submitPost(let params), .uploadMediaMetadata(let params), .editPostOrComment(let params), .deletePostOrComment(let params), .hidePost(let params), .unhidePost(let params), .readMessage(let params), .markSensitive(let params), .unmarkSensitive(let params), .markSpoiler(let params), .unmarkSpoiler(let params), .selectFlair(_, let params), .selectUserFlair(_, let params), .composeMessage(let params), .createCustomFeed(let params), .updateCustomFeed(let params), .copyCustomFeed(let params), .report(let params), .approveThing(let params), .removeThing(let params), .toggleStickyPost(let params), .lockThing(let params), .unlockThing(let params), .toggleDistinguishedThing(let params):
            return params
        default:
            return nil
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
        case .getInbox(_, let queries):
            return ["raw_json": "1", "limit": "100"].merging(queries, uniquingKeysWith: { _, new in new })
        case .getMoreCommentsForCommentMore:
            return ["raw_json": "1", "api_type": "json"]
        case .favoriteCustomFeed:
            return ["raw_json": "1", "gilding_detail": "1"]
        case .getRules:
            return ["raw_json": "1"]
        case .getFlairs:
            return ["raw_json": "1"]
        case .uploadMediaMetadata:
            return ["raw_json": "1", "gilding_detail": "1"]
        case .submitGalleryPost:
            return ["raw_json": "1", "resubmit": "true"]
        case .submitPollPost:
            return ["raw_json": "1", "resubmit": "true", "gilding_detail": "1"]
        case .getInfo(let queries):
            return ["raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        case .deleteCustomFeed(let path):
            return ["multipath": path]
        case .getUserFlairs:
            return ["raw_json": "1"]
        case .selectUserFlair:
            return ["raw_json": "1"]
        case .getCustomFeedInfo(let queries):
            return queries
        case .getWikiPage:
            return ["raw_json": "1"]
        case .subredditAutoComplete(let queries):
            return ["typeahead_active": "true", "include_profiles": "false", "raw_json": "1"].merging(queries, uniquingKeysWith: { _, new in new })
        default:
            return nil
        }
    }
    
    var headers: HTTPHeaders? {
        switch self {
        case .getMyInfo(let headers):
            return headers
        default:
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
