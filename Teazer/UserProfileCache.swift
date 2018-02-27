//
//  UserProfileCache.swift
//  Teazer
//
//  Created by Faraz Habib on 20/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation

class UserProfileCache {
    
    static let shared = UserProfileCache()
    
    private var appUser: UserProfileDataModal?
    private var friendsRelationsList = [FriendRelation]()
    
    
    func saveFriendRelation(friendProfile:FriendProfileDataModal?) {
        guard let profile = friendProfile else {
            return
        }
        
        let index = friendsRelationsList.index { (relation) -> Bool in
            return relation.friendId == profile.friend?.userId
        }
        
        let friendRelation = FriendRelation(friendProfile: profile)
        if index == nil {
            friendsRelationsList.append(friendRelation)
        } else {
            friendsRelationsList.remove(at: index!)
            friendsRelationsList.append(friendRelation)
        }
    }
    
    func updateFollowInfo(friendId:Int, followInfo:FollowInfo?) {
        guard let info = followInfo else {
            return
        }
        
        let index = friendsRelationsList.index { (relation) -> Bool in
            return relation.friendId == friendId
        }
        
        if index == nil {
            let friendRelation = FriendRelation(friendId: friendId, followInfo: info)
            friendsRelationsList.append(friendRelation)
        } else {
            friendsRelationsList[index!].followInfo = info
        }
    }
    
    func saveFriendRelation(friend:Friend?) {
        guard let friend = friend else {
            return
        }
        
        let index = friendsRelationsList.index { (relation) -> Bool in
            return relation.friendId == friend.userId
        }
        
        let friendRelation = FriendRelation(friend: friend)
        if index == nil {
            friendsRelationsList.append(friendRelation)
        } else {
            friendsRelationsList.remove(at: index!)
            friendsRelationsList.append(friendRelation)
        }
    }
    
    func fetchFriendRelation(friendId:Int) -> FriendRelation? {
        let index = friendsRelationsList.index { (relation) -> Bool in
            return relation.friendId == friendId
        }
        
        return (index != nil) ? friendsRelationsList[index!] : nil
    }
    
}


class FriendRelation {
    
    var friendId:Int?
    var followInfo:FollowInfo?
    
    init(friendId:Int, followInfo:FollowInfo) {
        self.friendId = friendId
        self.followInfo = followInfo
    }
    
    init(friendProfile:FriendProfileDataModal) {
        self.friendId = friendProfile.friend?.userId
        self.followInfo = friendProfile.followInfo
    }
    
    init(friend:Friend) {
        self.friendId = friend.userId
        self.followInfo = friend.followInfo
    }
    
}
