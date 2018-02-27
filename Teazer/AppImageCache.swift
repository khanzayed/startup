//
//  AppImageCache.swift
//  Teazer
//
//  Created by Faraz Habib on 27/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import AlamofireImage

final class AppImageCache {
    
    private static var imageCacheDict = [String:UIImage]()
    
    //MARK:- Post images
    static internal func savePostImage(image:UIImage?, postId:Int) {
        guard let image = image else {
            return
        }
        imageCacheDict["PostImage_\(postId)"] = image
    }
    
    static internal func fetchPostImage(postId:Int) -> UIImage? {
        return imageCacheDict["PostImage_\(postId)"]
    }
    
    //MARK:- Reaction images
    static internal func saveReactionImage(image:UIImage?, reactionId:Int) {
        guard let image = image else {
            return
        }
        imageCacheDict["ReactionImage_\(reactionId)"] = image
    }
    
    static internal func fetchReactionImage(reactionId:Int) -> UIImage? {
        return imageCacheDict["ReactionImage_\(reactionId)"]
    }
    
    //MARK:- Notification post images
    static internal func saveNotificationPostImage(image:UIImage?, notificationId:Int) {
        guard let image = image else {
            return
        }
        imageCacheDict["NotificationPostImage_\(notificationId)"] = image
    }
    
    static internal func fetchNotificationPostImage(notificationId:Int) -> UIImage? {
        return imageCacheDict["NotificationPostImage_\(notificationId)"]
    }
    
    //MARK:- My profile images
    static internal func saveMyProfileImage(image:UIImage?) {
        guard let image = image else {
            return
        }
        imageCacheDict["MyProfileImage"] = image
    }
    
    static internal func fetchMyProfileImage() -> UIImage? {
        return imageCacheDict["MyProfileImage"]
    }
    
    static internal func saveMyCoverImage(image:UIImage?) {
        guard let image = image else {
            return
        }
        imageCacheDict["MyCoverImage"] = image
    }
    
    static internal func fetchMyCoverImage() -> UIImage? {
        return imageCacheDict["MyCoverImage"]
    }
    
    static internal func removeProfileImage() {
        imageCacheDict["MyCoverImage"] = nil
        imageCacheDict["MyProfileImage"] = nil
    }
    
    //MARK:- Others profile images
    static internal func saveOthersProfileImage(image:UIImage?, userId:Int) {
        guard let image = image else {
            return
        }
        imageCacheDict["OthersProfileImage_\(userId)"] = image
    }
    
    static internal func fetchOthersProfileImage(userId:Int) -> UIImage? {
        return imageCacheDict["OthersProfileImage_\(userId)"]
    }
    
    static internal func saveOthersCoverImage(image:UIImage?, userId:Int) -> UIImage? {
        return imageCacheDict["OthersCoverImage_\(userId)"]
    }
    
    static internal func fetchOthersCoverImage(userId:Int) -> UIImage? {
        return imageCacheDict["OthersCoverImage_\(userId)"]
    }
    
    //MARK:- Remove all images
    static internal func removeAllImages() {
        imageCacheDict = [String:UIImage]()
    }
    
}
