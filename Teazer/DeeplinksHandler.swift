
//
//  DeeplinksHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 17/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

enum NotificationType:Int {
    case kStartedFollowing = 1
    case kRequestAccepted = 2
    case kRequestSend = 3
    case kReacted = 4
    case KlikedPost = 5
    case kLikedReaction = 6
    case kPostedVideo = 7
    case kReactedOnTag = 8
    case KTaggedYou = 9
    case KAlsoStartedFollowing = 10
    
}

class DeeplinksHandler {
    
    init(_ notificationType:Int, sourceId:Int) {
        if notificationType == NotificationType.kStartedFollowing.rawValue || notificationType == NotificationType.kRequestAccepted.rawValue || notificationType == NotificationType.kRequestSend.rawValue || notificationType == NotificationType.KAlsoStartedFollowing.rawValue  {
            openProfile(sourceId)
            
        } else if notificationType == NotificationType.kPostedVideo.rawValue || notificationType == NotificationType.KlikedPost.rawValue || notificationType == NotificationType.KTaggedYou.rawValue {
            openPost(sourceId)
        }
    }
    
    init(queryParams:[String:Any]) {
        if let value = queryParams[Constants.kDeepLinkPostIdKey] as? String {
            openPost(Int(value)!)
        } else if let value = queryParams[Constants.kDeepLinkUserIdKey] as? String {
            openProfile(Int(value)!)
        } else if let value = queryParams[Constants.kDeepLinkReactionIdKey] as? String {
            
        }
    }
    
    func openProfile(_ sourceId:Int) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootViewController = appDelegate.window?.rootViewController as! UINavigationController
            let vcList = rootViewController.viewControllers
            if vcList.count == 0 {
                return
            }
            if let tabbarCntrl = vcList[1] as? TabbarViewController {
                let index = TabbarControllerIndex.kMyActivitiesVCIndex.rawValue
                tabbarCntrl.selectedIndex = index
                
                let navCntrl = tabbarCntrl.viewControllers![index] as! UINavigationController
                let profileVC = navCntrl.viewControllers[0] as! NewProfileViewController
                profileVC.friendUserId = sourceId
                profileVC.isFromNotification = true
                profileVC.isFromVideo = true
                if let storedId = UserDefaults.standard.value(forKey: Constants.kUserIdKey) as? Int {
                    profileVC.isMyProfile = (storedId == sourceId)
                }
                profileVC.isBasicProfile = false
                navCntrl.pushViewController(profileVC, animated: true)
            }
        }
    }
    
    func openPost(_ postId:Int) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootViewController = appDelegate.window?.rootViewController as! UINavigationController
            let vcList = rootViewController.viewControllers
            if vcList.count == 0 {
                return
            }
            if let tabbarCntrl = vcList[1] as? TabbarViewController {
                let index = TabbarControllerIndex.kHomeVCIndex.rawValue
                let homeVC = tabbarCntrl.viewControllers![index] as? NewHomeViewController
                homeVC?.openPost = true
                homeVC?.openReaction = false
                homeVC?.postId = postId
                tabbarCntrl.selectedIndex = index
                
                let navCntrl = tabbarCntrl.viewControllers![index] as! UINavigationController
                let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
                let postDetailVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
                postDetailVC.postId = postId
                navCntrl.pushViewController(postDetailVC, animated: true)
            }
        }
    }
    
    func openReaction(_ reactionId:Int, postId:Int) {
        DispatchQueue.main.async {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let rootViewController = appDelegate.window?.rootViewController as! UINavigationController
            let vcList = rootViewController.viewControllers
            if vcList.count == 0 {
                return
            }
            if let tabbarCntrl = vcList[1] as? TabbarViewController {
                let index = TabbarControllerIndex.kHomeVCIndex.rawValue
                let homeVC = tabbarCntrl.viewControllers![index] as? NewHomeViewController
                homeVC?.openPost = true
                homeVC?.openReaction = true
                homeVC?.postId = postId
                homeVC?.reactionId = reactionId
                tabbarCntrl.selectedIndex = index
            }
        }
    }
    
}
