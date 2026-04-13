//
//  ModMailListingRepositoryProtocol.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-04-08.
//

import Alamofire

public protocol ModMailListingRepositoryProtocol {
    func fetchModMailListing(queries: [String : String], interceptor: RequestInterceptor?) async throws -> ModMailListing
}
