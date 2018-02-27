//
//  ReactionsDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 03/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class ReactionsDataModal:AppDataModal {
    
    var reactions:[Reaction]?
    var reactionStatus:Bool? = false
    var reactionMessage:String?
    var nextPage:Bool? = false
    var reaction:Reaction?
    
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            nextPage = responseDict["next_page"] as? Bool
            reactionStatus = responseDict["status"] as? Bool
            reactionMessage = responseDict["message"] as? String
            if let reactionsList = responseDict["reactions"] as? [[String:Any]] {
                reactions = [Reaction]()
                for reaction in reactionsList {
                    let reactionModal = Reaction(reaction: reaction)
                    reactions?.append(reactionModal)
                }
            }
            if let reactionDetail = responseDict["post_react_detail"] as? [String:Any] {
                reaction = Reaction(reaction: reactionDetail)

            }
        }
    }
}

class Reaction {
    
    var postId:Int?
    var reactId:Int?
    var reactedBy:Int?
    var likes:Int?
    var views:Int?
    var canLike:Bool? = false
    var isMyReaction:Bool? = false
    var reactTitle:String?
    var media:Media?
    var reactionOwner:PostOwner?
    var postOwner:PostOwner?
    var profileMedia:ProfileMedia?
    var mediaDetails:Media?
    var canDelete:Bool? = false
    var reactedAt:TimeInterval?
    var title:String?
    var reactionImage:UIImage?
    
    init() {
        
    }
    
    init(reaction:[String:Any]) {
        self.postId = reaction["post_id"] as? Int
        self.reactId = reaction["react_id"] as? Int
        self.reactedBy = reaction["reacted_by"] as? Int
        self.likes = reaction["likes"] as? Int
        self.views = reaction["views"] as? Int
        self.canLike = reaction["can_like"] as? Bool
        self.reactTitle = reaction["react_title"] as? String
        self.canDelete = reaction["can_delete"] as? Bool
        self.isMyReaction = reaction["my_self"] as? Bool
        self.title = reaction["title"] as? String
        
        if let postOwnerDetails = reaction["react_owner"] as? [String:Any] {
            let postOwnerModal = PostOwner()
            postOwnerModal.userId = postOwnerDetails["user_id"] as? Int
            postOwnerModal.userName = postOwnerDetails["user_name"] as? String
            postOwnerModal.firstName = postOwnerDetails["first_name"] as? String
            postOwnerModal.lastName = postOwnerDetails["last_name"] as? String
            postOwnerModal.hasProfileMedia = postOwnerDetails["has_profile_media"] as? Bool
            if let media = postOwnerDetails["profile_media"] as? [String:Any] {
                let profileMediaModal = ProfileMedia()
                profileMediaModal.mediaUrl = media["media_url"] as? String
                profileMediaModal.thumbUrl = media["thumb_url"] as? String
                profileMediaModal.duration = media["duration"] as? String
                profileMediaModal.isImage = media["is_image"] as? Bool
                if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                    profileMediaModal.width = mediaDimensions["width"] as? CGFloat
                    profileMediaModal.height = mediaDimensions["height"] as? CGFloat
                }
                postOwnerModal.profileMedia = profileMediaModal
            }
            self.reactionOwner = postOwnerModal
        }
        
        if let postOwnerDetails = reaction["post_owner"] as? [String:Any] {
            let postOwnerModal = PostOwner()
            postOwnerModal.userId = postOwnerDetails["user_id"] as? Int
            postOwnerModal.userName = postOwnerDetails["user_name"] as? String
            postOwnerModal.firstName = postOwnerDetails["first_name"] as? String
            postOwnerModal.lastName = postOwnerDetails["last_name"] as? String
            postOwnerModal.hasProfileMedia = postOwnerDetails["has_profile_media"] as? Bool
            if let media = postOwnerDetails["profile_media"] as? [String:Any] {
                let profileMediaModal = ProfileMedia()
                profileMediaModal.mediaUrl = media["media_url"] as? String
                profileMediaModal.thumbUrl = media["thumb_url"] as? String
                profileMediaModal.duration = media["duration"] as? String
                profileMediaModal.isImage = media["is_image"] as? Bool
                if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                    profileMediaModal.width = mediaDimensions["width"] as? CGFloat
                    profileMediaModal.height = mediaDimensions["height"] as? CGFloat
                }
                postOwnerModal.profileMedia = profileMediaModal
            }
            self.postOwner = postOwnerModal
        }
        
        if let mediaDetails = reaction["media_detail"] as? [String:Any] {
            let mediaDetailsModal = Media()
            mediaDetailsModal.mediaId = mediaDetails["media_id"] as? Int
            mediaDetailsModal.mediaUrl = mediaDetails["react_media_url"] as? String
            mediaDetailsModal.thumbUrl = mediaDetails["react_thumb_url"] as? String
            mediaDetailsModal.duration = mediaDetails["react_duration"] as? String
            mediaDetailsModal.dimensions = mediaDetails["react_dimension"] as? String
            mediaDetailsModal.isImage = mediaDetails["react_is_image"] as? Bool
            mediaDetailsModal.mediaType = mediaDetails["media_type"] as? Int
            mediaDetailsModal.externalMeta = mediaDetails["external_meta"] as? String
            if let mediaDimensions = mediaDetails["media_dimension"] as? [String:Any] {
                mediaDetailsModal.width = mediaDimensions["width"] as? CGFloat
                mediaDetailsModal.height = mediaDimensions["height"] as? CGFloat
            }
            self.mediaDetails = mediaDetailsModal
        }
    }
    
}

