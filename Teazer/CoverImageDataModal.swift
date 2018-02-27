//
//  CoverImageDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 25/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Alamofire

class CoverImageDataModal: AppDataModal {
    
    var coverImagesList:[CoverImage]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            coverImagesList = [CoverImage]()
            if let list = responseDict["default_cover_medias"] as? [[String:Any]] {
                for image in list {
                    let coverImage = CoverImage(params: image)
                    coverImagesList?.append(coverImage)
                }
            }
        }
    }
    
}


struct CoverImage {
    
    var coverId: Int?
    var thumbUrl: String?
    var mediaUrl: String?
    var dimension: String?
    var height: CGFloat?
    var width: CGFloat?
    
    init(params:[String:Any]) {
        self.coverId = params["default_cover_id"] as? Int
        self.thumbUrl = params["thumb_url"] as? String
        self.mediaUrl = params["media_url"] as? String
        self.dimension = params["dimension"] as? String
        if let mediaDimensions = params["media_dimension"] as? [String:Any] {
            self.height = mediaDimensions["height"] as? CGFloat
            self.width = mediaDimensions["width"] as? CGFloat
        }
    }
    
}
