//
//  NotificationsCacheData.swift
//  Teazer
//
//  Created by Faraz Habib on 05/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

class NotificationsCacheData {
    
    static let shared = NotificationsCacheData()
    
    private var requests = [Notification]()
    private var following = [Notification]()
    
    private var newRequestsCount = 0 {
        didSet {
            updateBagdeNoOnTabbar(count: newFollowingCount + newRequestsCount)
        }
    }
    private var newFollowingCount = 0 {
        didSet {
            updateBagdeNoOnTabbar(count: newFollowingCount + newRequestsCount)
        }
    }
    
    var pageNoForRequests = 1
    var pageNoForFollowing = 1
    var followingHasNext = false
    var requestsHasNext = false
    
    func reset() {
        pageNoForRequests = 1
        pageNoForFollowing = 1
        followingHasNext = false
        requestsHasNext = false
        
        requests = [Notification]()
        following = [Notification]()
    }
    
    //MARK:- Save data
    func updateRequestsNotifications(list:[Notification], isReset:Bool = false, hasNext:Bool = false) {
        if isReset {
            requests = [Notification]()
            pageNoForRequests = 1
        }
        requestsHasNext = hasNext
        
        for notification in list {
            _ = requests.index { (oldNotification) -> Bool in
                return oldNotification.notificationId == notification.notificationId
            }
        }
        
        requests.append(contentsOf: list)
    }
    
    func updateFollowingNotifications(list:[Notification], isReset:Bool = false, hasNext:Bool = false) {
        if isReset {
            following = [Notification]()
            pageNoForFollowing = 1
        }
        followingHasNext = hasNext
        
        following.append(contentsOf: list)
    }
    
    func updateUnreadRequestsCount(count:Int?) {
        newRequestsCount = (count != nil) ? count! : 0
    }
    
    func updateUnreadFollowingCount(count:Int?) {
        newFollowingCount = (count != nil) ? count! : 0
    }
    
    func updateRequestsNotifications(notification:Notification, atIndex index:Int) {
        requests[index] = notification
    }
    
    func updateFollowingNotifications(notification:Notification, atIndex index:Int) {
        following[index] = notification
    }
    func fetchFollowingNotficationListFromUserId(_ userId:Int) -> [Notification] {
        let list = following.filter { (notification) -> Bool in
            return notification.sourceId == userId
        }
        return list
    }
    func fetchRequestNotficationListFromUserId(_ userId:Int) -> [Notification] {
        let list = requests.filter { (notification) -> Bool in
            return notification.sourceId == userId
        }
        return list

    }
    
    //MARK:- Fetch data
    func fetchRequestsNotifications() -> [Notification] {
        return requests
    }
    
    func fetchFollowingNotifications() -> [Notification] {
        return following
    }
    
    func getUnReadRequestsCount() -> Int {
        return newRequestsCount
    }
    
    func getUnReadFollowingCount() -> Int {
        return newFollowingCount
    }
    
    func getUnReadTotalCount() -> Int {
        return newFollowingCount + newRequestsCount
    }
    
    func deleteNotificationsByUserId(userId:Int) {
        removeRequestNotificationsByUserId(userId: userId)
        removeFollowingNotificationsByUserId(userId: userId)
    }
    
    func removeRequestNotificationsByUserId(userId:Int) {
        let notificationIndex = requests.index { (notification) -> Bool in
            return notification.metaData?.fromId == userId
        }
        if notificationIndex != nil {
            requests.remove(at: notificationIndex!)
        }
    }
    
    func removeFollowingNotificationsByUserId(userId:Int) {
        let notificationIndex = following.index { (notification) -> Bool in
            return notification.metaData?.fromId  == userId
        }
        if notificationIndex != nil {
            following.remove(at: notificationIndex!)
        }
    }
    
    func updateBagdeNoOnTabbar(count:Int) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            if let rootViewController = appDelegate.window?.rootViewController as? UINavigationController {
                let vcList = rootViewController.viewControllers
                if vcList.count == 0 {
                    return
                }
                
                if let tabbarCntrl = vcList[1] as? TabbarViewController {
                    if let tabbarItems = tabbarCntrl.tabBar.items {
                        let item =  tabbarItems[TabbarControllerIndex.kNotificationVCIndex.rawValue]
                        item.badgeValue = (count == 0) ? nil : "\(count)"
                        item.badgeColor = UIColor(rgba: "#ED3E51")
                    }
                }
            }
        }
    }
    
}
