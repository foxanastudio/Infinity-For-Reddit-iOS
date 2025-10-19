//
//  UploadedImageExt.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-19.
//

extension UploadedImage {
    func toRedditGalleryPayloadItem() -> RedditGalleryPayload.Item {
        return RedditGalleryPayload.Item(
            caption: self.caption ?? "",
            outboundUrl: self.outboundUrlString ?? "",
            mediaId: self.imageId ?? ""
        )
    }
}
