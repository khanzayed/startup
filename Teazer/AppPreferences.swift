//
//  AppPreferences.swift
//  Teazer
//
//  Created by Ankita Satpathy on 12/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation

class AppPreferences {
    
    internal static func setIsPrivateAccount(isPrivateAccount:Bool) {
        UserDefaults.standard.set(isPrivateAccount, forKey: "isPrivateAccount")
    }
    
    internal static func getIsPrivateAccount() -> Bool {
        let isPrivateAccount = UserDefaults.standard.value(forKey: "isPrivateAccount") as? Bool
        return (isPrivateAccount != nil) ? isPrivateAccount! : false
    }
    
    internal static func setIsVideoAutoPlay(autoplay: Bool) {
        UserDefaults.standard.set(autoplay, forKey: "isVideoAutoPlay")
    }
    
    internal static func getIsVideoAutoPlay() -> Bool {
        let isVideoAutoPlay = UserDefaults.standard.value(forKey: "isVideoAutoPlay") as? Bool
        return (isVideoAutoPlay != nil) ? isVideoAutoPlay! : true
    }
    
    internal static func setIsAudioAutoPlay(autoplay: Bool) {
        UserDefaults.standard.set(autoplay, forKey: "isAudioAutoPlay")
    }
    
    internal static func getIsAudioAutoPlay() -> Bool {
        let isAudioAutoPlay = UserDefaults.standard.value(forKey: "isAudioAutoPlay") as? Bool
        return (isAudioAutoPlay != nil) ? isAudioAutoPlay! : true
    }
    
}
