//
//  SearchVideoResultDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 29/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class SearchVideoResultDataModal: AppDataModal {
    
    var hasNext:Bool?
    var videos:[Post]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            hasNext = responseDict["next_page"] as? Bool
            
            if let list = responseDict["videos"] as? [[String:Any]] {
                videos = [Post]()
                for video in list {
                    let videoModal = Post(post: video)
                    videos?.append(videoModal)
                }
            }
        }
    }
}

struct VideoInfo {
    
    var mediaId:Int?
    var mediaUrl:String?
    var thumbnailUrl:String?
    var duration:String?
    var isImage:Bool?
    var height:CGFloat?
    var width:CGFloat?
    
}
