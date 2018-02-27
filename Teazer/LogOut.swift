//
//  LogOut.swift
//  Teazer
//
//  Created by Faraz Habib on 12/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import GoogleSignIn
import SwiftKeychainWrapper
import AlamofireImage

class LogOut {
    
    init() {
        let _ = KeychainWrapper.standard.removeAllKeys()
        UserDefaults.standard.set(true, forKey: "isFirstAppLaunch")
        AutoPurgingImageCache().removeAllImages()
        AppImageCache.removeAllImages()
        NotificationsCacheData.shared.reset()
        GIDSignIn.sharedInstance().signOut()
        FBSDKLoginManager().logOut()
    }
    
    func doLogOut() {
        DispatchQueue.main.async {
            UserAPIHandler().invalidateAuthToken()
            User().clearUserCredentials()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if let rootVC = appDelegate.window?.rootViewController as? UINavigationController {
                rootVC.popToRootViewController(animated: true)
            }
        }
    }
    
    func doForceLogOut() {
        DispatchQueue.main.async {
            UserAPIHandler().invalidateAuthToken()
            User().clearUserCredentials()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.makeToast("User session expired. Login again")
            if let rootVC = appDelegate.window?.rootViewController as? UINavigationController {
                rootVC.popToRootViewController(animated: true)
            }
        }
    }

}
