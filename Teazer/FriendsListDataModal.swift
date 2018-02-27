//
//  FriendsListDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class FriendsListDataModal:AppDataModal {
    
    var hasNext:Bool? = false
    var friendsList:[Friend]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            hasNext = responseDict["next_page"] as? Bool
            if let circles = responseDict["circles"] as? [[String:Any]] {
                parseResponseArray(circles: circles)
            } else if let users = responseDict["users"] as? [[String:Any]] {
                parseResponseArray(circles: users)
            } else if let users = responseDict["tagged_users"] as? [[String:Any]] {
                parseResponseArray(circles: users)
            }
        }
    }
    
    func parseResponseArray(circles:[[String:Any]]) {
        friendsList = [Friend]()
        for circle in circles {
            let friend = Friend(params: circle)
            UserProfileCache.shared.saveFriendRelation(friend: friend)
            
            friendsList?.append(friend)
        }
    }
}

class FriendProfileDataModal: AppDataModal {
    
    var friend:Friend?
    var followers:Int? = 0
    var following:Int? = 0
    var totalVideo:Int? = 0
    var totalReactions:Int? = 0
    var accountType: Int?
    var canJoin:Bool?
    var hasSentJoinRequest: Bool?
    var joinRequestID: Int?
    var followInfo:FollowInfo?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            if let userDetails = responseDict["user_profile"] as? [String:Any] {
                friend = Friend(params: userDetails)
            } else if let userDetails = responseDict["private_profile"] as? [String:Any] {
                friend = Friend(params: userDetails)
            } else if let userDetails = responseDict["public_profile"] as? [String:Any] {
                friend = Friend(params: userDetails)
            }
            
            accountType = responseDict["account_type"] as? Int
            canJoin = responseDict["can_join"] as? Bool
            hasSentJoinRequest = responseDict["has_send_join_request"] as? Bool
            followers = responseDict["followers"] as? Int
            following = responseDict["followings"] as? Int
            totalVideo = responseDict["total_videos"] as? Int
            totalReactions = responseDict["total_reactions"] as? Int
            if let info = responseDict["follow_info"] as? [String:Any] {
                followInfo = FollowInfo()
                followInfo?.userId = info["user_id"] as? Int
                followInfo?.hasBlockedYou = info["is_blocked_you"] as? Bool
                followInfo?.isFollowing = info["following"] as? Bool
                followInfo?.isFollower = info["follower"] as? Bool
                followInfo?.isRequestSent = info["request_sent"] as? Bool
                followInfo?.isRequestReceived = info["request_received"] as? Bool
                followInfo?.blocked = info["you_blocked"] as? Bool
                followInfo?.requestId = info["request_id"] as? Int
            }
        }
    }
}


class Friend {
    
    var tagId:Int?
    var userId:Int?
    var userName:String?
    var firstName:String?
    var lastName:String?
    var isMyself:Bool? = false
    var accountType:Int?
    var hasProfileMedia:Bool?
    var isActive:Bool?
    var bio:String?
    var blocked:Bool? = false
    var profileMedia:ProfileMedia?
    var coverMedia:CoverMedia?
    var categories:[Category]?
    var followInfo:FollowInfo?
    
    init() {
        
    }
    
    init(params:[String:Any]) {
        tagId = params["tag_id"] as? Int
        userId = params["user_id"] as? Int
        userName = params["user_name"] as? String
        firstName = params["first_name"] as? String
        lastName = params["last_name"] as? String
        isMyself = params["my_self"] as? Bool
        accountType = params["account_type"] as? Int
        hasProfileMedia = params["has_profile_media"] as? Bool
        blocked = params["you_blocked"] as? Bool
        if let profileMedia = params["profile_media"] as? [String:Any] {
            let media = ProfileMedia()
            media.mediaUrl = profileMedia["media_url"] as? String
            media.thumbUrl =  profileMedia["thumb_url"] as? String
            media.isImage = profileMedia["is_image"] as? Bool
            media.duration = profileMedia["duration"] as? String
            if let mediaDimensions = profileMedia["media_dimension"] as? [String:Any] {
                media.width = mediaDimensions["width"] as? CGFloat
                media.height = mediaDimensions["height"] as? CGFloat
            }
            self.profileMedia = media
        }
        
        if let media = params["cover_media"] as? [String:Any] {
            coverMedia = CoverMedia()
            coverMedia?.coverImageId = media["cover_image_id"] as? Int
            coverMedia?.coverType = media["cover_type"] as? Int
            coverMedia?.defaultCoverImageId = media["default_cover_id"] as? Int
            coverMedia?.mediaUrl = media["media_url"] as? String
            coverMedia?.thumbUrl =  media["thumb_url"] as? String
            coverMedia?.isImage = media["is_image"] as? Bool
            coverMedia?.duration = media["duration"] as? String
            if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                coverMedia?.width = mediaDimensions["width"] as? CGFloat
                coverMedia?.height = mediaDimensions["height"] as? CGFloat
            }
        }
        
        if let categoriesList = params["categories"] as? [[String:Any]] {
            categories = [Category]()
            for category in categoriesList {
                let categoryModal = Category(params: category)
                categories?.append(categoryModal)
            }
        }
        if let followInfo = params["follow_info"] as? [String:Any] {
            var info = FollowInfo()
            info.userId = followInfo["user_id"] as? Int
            info.requestId = followInfo["request_id"] as? Int
            info.isFollowing = followInfo["following"] as? Bool
            info.isFollower = followInfo["follower"] as? Bool
            info.isRequestSent = followInfo["request_sent"] as? Bool
            info.isRequestReceived = followInfo["request_received"] as? Bool
            info.hasBlockedYou = followInfo["is_blocked_you"] as? Bool
            info.youBlocked = followInfo["you_blocked"] as? Bool
            self.followInfo = info
    }
  }
}

struct FollowInfo {
    
    var userId:Int?
    var hasBlockedYou:Bool? = false
    var blocked:Bool? = false
    var isFollowing:Bool? = false
    var isFollower:Bool? = false
    var isRequestSent:Bool? = false
    var isRequestReceived:Bool? = false
    var requestId:Int?
    var youBlocked:Bool? = false
    
    init() {
        
    }
    
    init(params:[String:Any]) {
        self.userId = params["user_id"] as? Int
        self.requestId = params["request_id"] as? Int
        self.isFollowing = params["following"] as? Bool
        self.isFollower = params["follower"] as? Bool
        self.isRequestSent = params["request_sent"] as? Bool
        self.isRequestReceived = params["request_received"] as? Bool
        self.hasBlockedYou = params["is_blocked_you"] as? Bool
        self.youBlocked = params["you_blocked"] as? Bool
    }
}
