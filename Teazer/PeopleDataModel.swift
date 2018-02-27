//
//  PeopleDataModel.swift
//  Teazer
//
//  Created by Ankita Satpathy on 09/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class PeopleDataModel: AppDataModal {
    
    var followers: [Friend]?
    var followings: [Friend]?
    var blockedList: [Friend]?
    var likedUserList:[Friend]?
    var nextPage: Bool?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        if super.errorObject == nil, let responseDict = super.responseDict {
            nextPage = responseDict["next_page"] as? Bool
            
            if let followersList = responseDict["followers"] as? [[String:Any]] {
                followers = [Friend]()
                for follower in followersList {
                    let followerModel = Friend(params: follower)
                    UserProfileCache.shared.saveFriendRelation(friend: followerModel)
                    
                    followers?.append(followerModel)
                }
            }
            
            if let followingList = responseDict["followings"] as? [[String:Any]] {
                self.followings = [Friend]()
                for following in followingList {
                    let followingModel = Friend(params: following)
                    UserProfileCache.shared.saveFriendRelation(friend: followingModel)
                    
                    followings?.append(followingModel)
                }
            }
            
            if let blockedUsers = responseDict["blocked_users"] as? [[String:Any]] {
                blockedList = [Friend]()
                for user in blockedUsers {
                    let userModal = Friend(params: user)
                    UserProfileCache.shared.saveFriendRelation(friend: userModal)
                    
                    blockedList?.append(userModal)
                }
            }
            if let likedUsers = responseDict["liked_users"] as? [[String:Any]] {
                likedUserList = [Friend]()
                for user in likedUsers {
                    let userModal = Friend(params: user)
                    UserProfileCache.shared.saveFriendRelation(friend: userModal)
                    
                    likedUserList?.append(userModal)
                }
            }

        }
    }   
}
