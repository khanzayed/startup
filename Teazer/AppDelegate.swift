 //
//  AppDelegate.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import FBSDKCoreKit
import GooglePlaces
import GoogleMaps
import GoogleSignIn
import Firebase
import FirebaseMessaging
import UserNotifications
import Fabric
import Crashlytics
import Branch
import AVFoundation

@available(iOS 10.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

   
    var window: UIWindow?
    
    func setCategories(){
        let OpenAppAction = UNNotificationAction(identifier: "openAppIdentifier",title: "Open App", options: UNNotificationActionOptions.foreground)
        let remindMeLaterAction = UNNotificationAction(identifier: "remindMeLaterIdentifier",title: "Remind me later", options: [UNNotificationActionOptions.foreground])
        let category = UNNotificationCategory(identifier: "interactiveNotificationIdentifier",actions: [ OpenAppAction,remindMeLaterAction],intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            self.getNotificationSettings()
        }
    }

    func enableSoundInBackground() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print("Error in playing sound")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setCategories()
        registerForPushNotifications()
        enableSoundInBackground()
        
        DispatchQueue.main.async {
            FIRApp.configure()
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.tokenRefreshNotification(notification:)),
                                                   name: NSNotification.Name.firInstanceIDTokenRefresh,
                                                   object: nil)
        }
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GMSPlacesClient.provideAPIKey("AIzaSyC7qjnyaE6-hFOEMGEA-G5b-u6l_4lflv4")
        GMSServices.provideAPIKey("AIzaSyC7qjnyaE6-hFOEMGEA-G5b-u6l_4lflv4")
        
        Fabric.sharedSDK().debug = true
        Fabric.with([Crashlytics.self])
        
        var style = ToastStyle()
        style.messageFont = UIFont(name: Constants.kProximaNovaSemibold, size: 14.0)!
        
        ToastManager.shared.style = style
        ToastManager.shared.duration = 3.0
        ToastManager.shared.tapToDismissEnabled = true
        ToastManager.shared.queueEnabled = true
        

        if let value = UserDefaults.standard.value(forKey: "isFirstAppLaunch") as? Bool {
            if (value == true) {
                let _ = KeychainWrapper.standard.removeAllKeys()
                UserDefaults.standard.set(false, forKey: "isFirstAppLaunch")
            }
        } else {
            let _ = KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(false, forKey: "isFirstAppLaunch")
        }
        
//        let branch: Branch = Branch.getInstance("key_test_acsIC2SrRt7IzDJtLfklaomeAAeoNqMm")
        let branch: Branch = Branch.getInstance()
        branch.initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: {params, error in
            if error == nil, let paramDict = params as? [String:Any] {
                print(paramDict)
                if let customParams = paramDict["$custom_fields"] as? String {
                    let _ = DeeplinksHandler(queryParams: self.convertToDictionary(text: customParams))
                }
            }
        })
        
        if let notification = launchOptions?[.remoteNotification] as? [String: Any] {
            if let sourceId = notification["source_id"] as? String {
                if let notificationType = notification["notification_type"] as? String {
                    if let intSourceId = Int(sourceId), let intNotificationType = Int(notificationType) {
                        let _ = DeeplinksHandler(intNotificationType, sourceId: intSourceId)
                    }
                }
            }
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func convertToDictionary(text: String) -> [String: Any] {
        if let data = text.data(using: .utf8) {
            do {
                if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    return dict
                }
                return [:]
            } catch {
                print(error.localizedDescription)
            }
        }
        return [:]
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //getNotificationsData()
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        AppImageCache.removeAllImages()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let facebookHandled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let googleHandled = GIDSignIn.sharedInstance().handle(url,sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String,annotation: [:])
        
        return facebookHandled || googleHandled
    }

    // Respond to URI scheme links
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // pass the url to the handle deep link call
        let branchHandled = Branch.getInstance().application(application,
                                                             open: url,
                                                             sourceApplication: sourceApplication,
                                                             annotation: annotation
        )
        if (!branchHandled) {
            // If not handled by Branch, do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        }
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return true
    }
    
    // Respond to Universal Links
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        // pass the url to the handle deep link call
        Branch.getInstance().continue(userActivity)
        
        return true
    }
    
    //MARK: - APNS methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token : \(token)")
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .sandbox)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
        print("FCM Token : \(FIRInstanceID.instanceID().token() ?? "")")
        
        if User().getAuthToken() != nil, let refreshedToken = FIRInstanceID.instanceID().token() {
            UserAPIHandler().registerDeviceToken(refreshedToken)
            connectToFcm()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APNs registration failed: \(error)")
    }
    
    // Push notification received
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        FIRMessaging.messaging().appDidReceiveMessage(userInfo)

    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
        UIApplication.shared.applicationIconBadgeNumber += 1
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let notification = response.notification.request.content.userInfo as? [String:Any] {
            guard let sourceId = notification["source_id"] as? String else {
                return
            }
            
            guard let notificationType = notification["notification_type"] as? String else {
                return
            }
            
            if let intSourceId = Int(sourceId), let intNotificationType = Int(notificationType) {
                let _ = DeeplinksHandler(intNotificationType, sourceId: intSourceId)
            }
        }
        completionHandler()
    }
    
    @objc func tokenRefreshNotification(notification: NSNotification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            if User().getAuthToken() != nil {
                UserAPIHandler().registerDeviceToken(refreshedToken)
                connectToFcm()
            }
        }
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
        }
    }
    
}

@available(iOS 10.0, *)
extension AppDelegate: FIRMessagingDelegate {

    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
    }

    func messaging(_ messaging: FIRMessaging, didReceiveRegistrationToken fcmToken: String) {
//        print("Firebase registration token: \(fcmToken)")
//        KeychainWrapper.standard.set(fcmToken, forKey: Constants.kDeviceTokenKey)

    }

}

