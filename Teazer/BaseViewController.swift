 //
//  BaseViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 14/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class BaseViewController: UIViewController {
    
    var isUpdateAvailable = false
    var isForceUpdateAvailable = false

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CommonAPIHandler().getConfiguration { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            if let error = responseData.errorObject{
                self?.view.makeToast(error.message)
            }
            strongSelf.isUpdateAvailable = responseData.isUpdateAvailable
            strongSelf.isForceUpdateAvailable = responseData.isForceUpdate
            
            strongSelf.getNotificationsData()
            (User().getAuthToken() != nil) ? strongSelf.launchHomePage() : strongSelf.launchBaseLoginPage()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func launchHomePage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
        tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
        tabbarCntrlr.isUpdateAvailable = isUpdateAvailable
        tabbarCntrlr.isForceUpdateAvailable = isForceUpdateAvailable
        self.navigationController?.pushViewController(tabbarCntrlr, animated: true)
    }

    func launchBaseLoginPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let baseLoginVC = storyboard.instantiateViewController(withIdentifier: "BaseLoginViewController") as! BaseLoginViewController
        self.navigationController?.pushViewController(baseLoginVC, animated: true)
    }
    
}
 
 extension BaseViewController {
    
    func getNotificationsData() {
        if KeychainWrapper.standard.string(forKey: Constants.kAuthTokenKey) != nil {
            NotificationsAPIHandler().getFollowingNotificationsList(1) { (responseData) in
                if let list = responseData.notifications {
                    NotificationsCacheData.shared.updateUnreadFollowingCount(count: responseData.unreadCount)
                    NotificationsCacheData.shared.updateFollowingNotifications(list: list, isReset: true, hasNext: responseData.hasNext!)
                }
            }
            
            NotificationsAPIHandler().getRequestNotificationsList(1) { (responseData) in
                if let list = responseData.notifications {
                    NotificationsCacheData.shared.updateUnreadRequestsCount(count: responseData.unreadCount)
                    NotificationsCacheData.shared.updateRequestsNotifications(list: list, isReset: true, hasNext: responseData.hasNext!)
                }
            }
        }
    }
    
 }
