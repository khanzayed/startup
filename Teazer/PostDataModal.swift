//
//  PostDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 25/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class PostDataModal:AppDataModal {
    
    var posts:[Post]?
    var nextPage:Bool? = false
    var postdetails:Post?
    var contentHeightForCustomLayout:CGFloat = 0
    
    override init(jsonResponse: DataResponse<Any>?, calculateContentHeight: Bool) {
        super.init(jsonResponse: jsonResponse, calculateContentHeight: calculateContentHeight)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            nextPage = responseDict["next_page"] as? Bool
            
            if let list = responseDict["posts"] as? [[String:Any]] {
                posts = [Post]()
                
                let cellPadding:CGFloat = 5
                let numberOfColumns = 2
                let columnWidth = UIScreen.main.bounds.width / CGFloat(numberOfColumns)
                var xOffset = [CGFloat]()
                for column in 0 ..< numberOfColumns {
                    xOffset.append(CGFloat(column) * columnWidth)
                }
                var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
                var column = 0
                
                for post in list {
                    let postModal = Post(post: post)
                    posts?.append(postModal)
                    
                    if postModal.canDelete == true {
                        PostCacheData.shared.saveMyProfilePost(post: postModal)
                    } else {
                        PostCacheData.shared.saveOthersProfilePost(post: postModal)
                    }
                    
                    if calculateContentHeight {
                        let width = (UIScreen.main.bounds.width / 2)
                        let photoHeight = postModal.mediaList![0].height! * width / postModal.mediaList![0].width!
                        let tempHeight = (photoHeight > 175.0) ? photoHeight : 175.0
                        let height = cellPadding * 2 + tempHeight
                        let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                        contentHeightForCustomLayout = max(contentHeightForCustomLayout, frame.maxY)
                        yOffset[column] = yOffset[column] + height
                        column = column < (numberOfColumns - 1) ? (column + 1) : 0
                    }                    
                }
            } else if responseDict["post_id"] as? Int != nil {
                postdetails = Post(post: responseDict)
                
                if postdetails!.canDelete == true {
                    PostCacheData.shared.saveMyProfilePost(post: postdetails!)
                } else {
                    PostCacheData.shared.saveOthersProfilePost(post: postdetails!)
                }
            } else if let list = responseDict["videos"] as? [[String:Any]] {
                posts = [Post]()
                for post in list {
                    let postModal = Post(post: post)
                    posts?.append(postModal)
                    
                    if postModal.canDelete == true {
                        PostCacheData.shared.saveMyProfilePost(post: postModal)
                    } else {
                        PostCacheData.shared.saveOthersProfilePost(post: postModal)
                    }
                }
            }
        }
    }
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            nextPage = responseDict["next_page"] as? Bool
            
            if let list = responseDict["posts"] as? [[String:Any]] {
                posts = [Post]()
                for post in list {
                    let postModal = Post(post: post)
                    posts?.append(postModal)
                    
                    if postModal.canDelete == true {
                        PostCacheData.shared.saveMyProfilePost(post: postModal)
                    } else {
                        PostCacheData.shared.saveOthersProfilePost(post: postModal)
                    }
                }
            } else if (responseDict["post_id"] as? Int) != nil {
                postdetails = Post(post: responseDict)
            }
        }
    }
}

class Post {
    
    var index:Int!
    var totalTag:Int!
    var postId:Int?
    var postedBy:Int?
    var likes:Int?
    var isDeleted = false
    var totalReactions:Int?
    var hasCheckedIn:Bool?
    var isHidden = false
    var title:String?
    var canReact:Bool?
    var canLike:Bool?
    var canDelete:Bool?
    var postOwner:PostOwner?
    var createdAt:TimeInterval?
    var checkIn:CheckedIn?
    var mediaList:[Media]?
    var categories:[Category]?
    var reactedUsers:[ReactedUser]?
    var reactions:[Reaction]?
    var taggedUsers:[Friend]?
    var postImage:UIImage?
    var profileImage:UIImage?
    
    init(){
        
    }
    
    init(post:[String:Any]) {
        postId = post["post_id"] as? Int
        postedBy = post["posted_by"] as? Int
        likes = post["likes"] as? Int
        totalReactions = post["total_reactions"] as? Int
        hasCheckedIn = post["has_checkin"] as? Bool
        title = post["title"] as? String
        totalTag = post["total_tags"] as? Int
        canReact = post["can_react"] as? Bool
        canLike = post["can_like"] as? Bool
        canDelete = post["can_delete"] as? Bool
        
        if let postOwnerDetails = post["post_owner"] as? [String:Any] {
            let postOwnerModal = PostOwner()
            postOwnerModal.userId = postOwnerDetails["user_id"] as? Int
            postOwnerModal.userName = postOwnerDetails["user_name"] as? String
            postOwnerModal.firstName = postOwnerDetails["first_name"] as? String
            postOwnerModal.lastName = postOwnerDetails["last_name"] as? String
            postOwnerModal.hasProfileMedia = postOwnerDetails["has_profile_media"] as? Bool
            if let media = postOwnerDetails["profile_media"] as? [String:Any] {
                postOwnerModal.profileMedia = ProfileMedia()
                postOwnerModal.profileMedia?.pictureId = media["picture_id"] as? Int
                postOwnerModal.profileMedia?.mediaUrl = media["media_url"] as? String
                postOwnerModal.profileMedia?.thumbUrl =  media["thumb_url"] as? String
                postOwnerModal.profileMedia?.isImage = media["is_image"] as? Bool
                postOwnerModal.profileMedia?.duration = media["duration"] as? String
                if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                    postOwnerModal.profileMedia?.width = mediaDimensions["width"] as? CGFloat
                    postOwnerModal.profileMedia?.height = mediaDimensions["height"] as? CGFloat
                }
            }
            postOwner = postOwnerModal
        }
        
        createdAt = post["has_checkin"] as? TimeInterval
        
        if let checkedInDetails = post["check_in"] as? [String:Any] {
            let checkedInModal = CheckedIn()
            checkedInModal.checkInId = checkedInDetails["checkin_id"] as? Int
            checkedInModal.latitude = checkedInDetails["latitude"] as? Double
            checkedInModal.longitude = checkedInDetails["longitude"] as? Double
            checkedInModal.location = checkedInDetails["location"] as? String
            checkIn = checkedInModal
        }
        
        if let mediaList = post["medias"] as? [[String:Any]] {
            var mediaListModal = [Media]()
            for media in mediaList {
                let mediaModal = Media()
                mediaModal.mediaId = media["media_id"] as? Int
                mediaModal.mediaUrl = media["media_url"] as? String
                mediaModal.thumbUrl = media["thumb_url"] as? String
                mediaModal.duration = media["duration"] as? String
                mediaModal.dimensions = media["dimension"] as? String
                mediaModal.isImage = media["is_image"] as? Bool
                mediaModal.views = media["views"] as? Int
                mediaModal.createdAt = media["created_at"] as? TimeInterval
                if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                    mediaModal.width = mediaDimensions["width"] as? CGFloat
                    mediaModal.height = mediaDimensions["height"] as? CGFloat
                }
                mediaListModal.append(mediaModal)
            }
            self.mediaList = mediaListModal
        }
        
        if let categoriesList = post["categories"] as? [[String:Any]] {
            var categoriesListModal = [Category]()
            for category in categoriesList {
                let categoryModal = Category(params: category)
                categoriesListModal.append(categoryModal)
            }
            categories = categoriesListModal
        }
        
        if let reactedUsers = post["reacted_users"] as? [[String:Any]] {
            self.reactedUsers = [ReactedUser]()
            for user in reactedUsers {
                let reactedUserModal = ReactedUser(params: user)
                self.reactedUsers?.append(reactedUserModal)
            }
        }
        
        if let reactionsList = post["reactions"] as? [[String:Any]] {
            self.reactions = [Reaction]()
            for reaction in reactionsList {
                let reactionModal = Reaction(reaction: reaction)
                self.reactions?.append(reactionModal)
            }
        }
        
        if let taggedUsers = post["reacted_users"] as? [[String:Any]] {
            self.taggedUsers = [Friend]()
            for user in taggedUsers {
                self.taggedUsers?.append(Friend(params: user))
            }
        }
        
    }
    
}

class PostOwner {
    
    var userId:Int?
    var userName:String?
    var firstName:String?
    var lastName:String?
    var hasProfileMedia:Bool?
    var profileMedia:ProfileMedia?
    
}

class CheckedIn {
    
    var checkInId:Int?
    var latitude:Double?
    var longitude:Double?
    var location:String?
    
}

class Media {
    
    var mediaId:Int?
    var mediaUrl:String?
    var thumbUrl:String?
    var duration:String?
    var dimensions:String?
    var width:CGFloat?
    var height:CGFloat?
    var isImage:Bool?
    var views:Int?
    var createdAt:TimeInterval?
    var mediaType:Int?
    var externalMeta:String?
    
}


class ReactedUser {
    
    var userdId:Int?
    var userName:String?
    var firstName:String?
    var lastName:String?
    var hasBlocked:Bool?
    var mySelf:Bool?
    var profileMedia:ProfileMedia?
    
    init() {
        
    }
    
    init(params:[String:Any]) {
        userdId = params["user_id"] as? Int
        userName = params["user_name"] as? String
        firstName = params["first_name"] as? String
        lastName = params["last_name"] as? String
        hasBlocked = params["is_blocked_you"] as? Bool
        mySelf = params["my_self"] as? Bool
        if let media = params["profile_media"] as? [String:Any] {
           let profileMedia = ProfileMedia()
            profileMedia.pictureId = media["picture_id"] as? Int
            profileMedia.mediaUrl = media["media_url"] as? String
            profileMedia.thumbUrl =  media["thumb_url"] as? String
            profileMedia.isImage = media["is_image"] as? Bool
            profileMedia.duration = media["duration"] as? String
            if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                profileMedia.width = mediaDimensions["width"] as? CGFloat
                profileMedia.height = mediaDimensions["height"] as? CGFloat
            }
           self.profileMedia = profileMedia
        }
    }
    
}

