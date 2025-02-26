//
//  UserDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-02-11.
//

import Foundation
import GRDB
import Combine
import Swinject
import Alamofire
import SwiftUI
import SwiftyJSON

class UserDetailsViewModel: ObservableObject {
    let session: Session
    @Published var isSubscribed: Bool = false
    @EnvironmentObject var accountViewModel: AccountViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
        self.isSubscribed = isSubscribed
    }
    
    func formattedCakeDay(_ timestamp: TimeInterval?) -> String {
        guard let timestamp = timestamp else {
            return "Unknown"
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    
    func toggleSubscription(username: String) {
        let action = isSubscribed ? "unsub" : "sub"
        subscribe(username: username, action: action)
    }
    
    private func subscribe(username: String, action: String){
        
        let params = ["action": action, "sr_name": "u_\(username)"]
        session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let _):
                    self.isSubscribed = action == "sub"
                    self.objectWillChange.send()
                case .failure(let error):
                    print("Error \(action == "sub" ? "following to" : "unfollowing from") \(username): \(error)")
                    self.objectWillChange.send()
                }
            }
    }
    
    func fetchUserDetails(username: String, completion: @escaping (Result<UserData, Error>) -> Void) {
        self.session.request(RedditAPI.getUserData(username: username, queries: ["raw_json" : "1"]))
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let userDataResponse):
                    guard !userDataResponse.isEmpty else {
                        print("Error: Empty response from Reddit")
                        completion(.failure(NSError(domain: "RedditAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty response from Reddit"])))
                        return
                    }
                    
                    if let myInfoData = userDataResponse.data(using: .utf8) {
                        do {
                            let jsonResponse = try JSON(data: myInfoData)["data"]
                            
                            let name = jsonResponse[JSONUtils.NAME_KEY].stringValue
                            let iconUrl = jsonResponse[JSONUtils.ICON_IMG_KEY].stringValue
                            let bannerImageUrl = jsonResponse[JSONUtils.SUBREDDIT_KEY][JSONUtils.BANNER_IMG_KEY].string
                            let commentKarma = jsonResponse[JSONUtils.COMMENT_KARMA_KEY].intValue
                            let linkKarma = jsonResponse[JSONUtils.LINK_KARMA_KEY].intValue
                            let awarderKarma = jsonResponse[JSONUtils.AWARDER_KARMA_KEY].intValue
                            let awardeeKarma = jsonResponse[JSONUtils.AWARDEE_KARMA_KEY].intValue
                            let totalKarma = jsonResponse[JSONUtils.TOTAL_KARMA_KEY].intValue
                            let cakeday = jsonResponse[JSONUtils.CREATED_UTC_KEY].doubleValue
                            let isGold = jsonResponse[JSONUtils.IS_GOLD_KEY].boolValue
                            let isFriend = jsonResponse[JSONUtils.IS_FRIEND_KEY].boolValue
                            let canBeFollowed = jsonResponse[JSONUtils.CAN_BE_FOLLOWED_KEY].boolValue
                            let isNSFW = jsonResponse[JSONUtils.OVER_18_KEY].boolValue
                            let description = jsonResponse[JSONUtils.SUBREDDIT_KEY][JSONUtils.ACTIVE_CHATTERS_KEY].stringValue
                            let title = jsonResponse[JSONUtils.SUBREDDIT_KEY][JSONUtils.TITLE_KEY].stringValue
                            
                            let userData = UserData(
                                name: name,
                                iconUrl: iconUrl,
                                banner: bannerImageUrl,
                                commentKarma: commentKarma,
                                linkKarma: linkKarma,
                                awarderKarma: awarderKarma,
                                awardeeKarma: awardeeKarma,
                                totalKarma: totalKarma,
                                cakeday: cakeday,
                                isGold: isGold,
                                isFriend: isFriend,
                                canBeFollowed: canBeFollowed,
                                isNSFW: isNSFW,
                                description: description,
                                title: title
                            )
                            
                            completion(.success(userData))
                            
                        } catch {
                            print("Error: Failed to parse account JSON - \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }
    
}


