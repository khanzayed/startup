//
//  VideoResponseDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 14/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class VideoResponseDataModal {
    
    var isVideoUploaded:Bool? = false
    var post:Post?
    var reaction:Reaction?
    var message:String? = Constants.kGenericErrorMessage
    
    init() {
        
    }
    
    init(jsonResponse:DataResponse<Any>?) {
        if let responseDict = jsonResponse?.result.value as? [String:Any] {
            isVideoUploaded = responseDict["status"] as? Bool
            message = responseDict["message"] as? String
            if let postDetails = responseDict["post_details"] as? [String:Any] {
                post = Post(post: postDetails)
            }
            if let reactionDetails = responseDict["post_react_detail"] as? [String:Any] {
                reaction = Reaction(reaction: reactionDetails)
            }
        }
    }
    
}
