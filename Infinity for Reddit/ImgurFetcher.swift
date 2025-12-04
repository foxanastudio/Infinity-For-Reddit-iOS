//
//  ImgurFetcher.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-07.
//

import Alamofire
import SwiftyJSON

class ImgurFetcher {
    static let shared = ImgurFetcher()
    
    private let imgurSession: Session
    
    private init() {
        guard let resolvedImgurSession = DependencyManager.shared.container.resolve(Session.self, name: "imgur") else {
            fatalError("Failed to resolve imgur Session in ImgurFetcher")
        }
        imgurSession = resolvedImgurSession
    }
    
    func fetchImgurMedia(imgurMediaType: ImgurMediaType) async throws -> ImgurMedia {
        var request: DataRequest
        switch imgurMediaType {
        case .imgurGallery(let imgurId):
            request = imgurSession.request(ImgurAPI.getGalleryImages(imgurId: imgurId))
        case .imgurAlbum(imgurId: let imgurId):
            request = imgurSession.request(ImgurAPI.getAlbumImages(imgurId: imgurId))
        case .imgurImage(imgurId: let imgurId):
            request = imgurSession.request(ImgurAPI.getImage(imgurId: imgurId))
        }
        let data = try await request
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return try ImgurMediaRootClass(fromJson: json).imgurMedia
    }
}

enum ImgurMediaType {
    case imgurGallery(imgurId: String)
    case imgurAlbum(imgurId: String)
    case imgurImage(imgurId: String)
}
