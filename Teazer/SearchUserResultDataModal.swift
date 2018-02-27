//
//  SearchUserResultDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 29/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class SearchUserResultDataModal: AppDataModal {
    
    var hasNext:Bool?
    var users:[Friend]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            hasNext = responseDict["next_page"] as? Bool
            
            if let list = responseDict["users"] as? [[String:Any]] {
                users = [Friend]()
                for user in list {
                    let friend = Friend(params: user)
                    if let info = user["follow_info"] as? [String:Any] {
                        friend.followInfo = FollowInfo(params: info)
                        UserProfileCache.shared.saveFriendRelation(friend: friend)
                    }
                    users?.append(friend)
                }
            }
        }
    }
}
