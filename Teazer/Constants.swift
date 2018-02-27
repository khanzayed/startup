//
//  AppConstants.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

enum TabbarControllerIndex:Int {
    case kHomeVCIndex = 0
    case kSearchVCIndex = 1
    case kCameraVCIndex = 2
    case kNotificationVCIndex = 3
    case kMyActivitiesVCIndex = 4
}

enum StoryboardOptions:String {
    case Main = "Main"
    case Profile = "Profile"
    case Search = "Search"
    case Settings = "Settings"
    case Discover = "Discover"
}

class Constants {
    
    // User details
    class var kSocialLoginTypeKey:String {return "teazer_social_login_type"}
    class var kCountryDialCodeKey:String {return "teazer_country_dial_code"}
    class var kDeviceIdKey:String {return "teazer_device_id"}
    class var kCountryCodeKey:String {return "teazer_country_code"}
    class var kAuthTokenKey:String {return "teaser_authToken"}
    class var kDeviceTokenKey:String {return "teazer_deviceToken"}
    class var kPasswordKey:String {return "teaser_password"}
    class var kUserIdKey:String {return "teaser_user_id"}
    
    
    // Alert or error messages
    class var kInternetMessage:String {return "Internet connection is unavailable. Please try again later"}
    class var kGenericErrorMessage:String {return "Oops! Something went wrong. Please try again later"}
    class var kRupeeSymbol: String {return "\u{20B9}"}
    
    
    // Font names
    class var kProximaNovaRegular:String {return "ProximaNova-Regular"}
    class var kProximaNovaSemibold:String {return "ProximaNova-Semibold"}
    class var kProximaNovaBold:String {return "ProximaNova-Bold"}
    
    // Login screens
    class var kWelcomeVideo:String {return "welcome_video"}
    
    // User profile
    class var kUserProfileImageKey:String {return "user_profile_image"}
    class var kUserProfileThumbnailImageKey:String {return "user_profile_thumb_image"}
    
    class var kDeepLinkPostIdKey:String {return "post_id"}
    class var kDeepLinkUserIdKey:String {return "user_id"}
    class var kDeepLinkReactionIdKey:String {return "react_id"}
    
    class var minVideoHeight:CGFloat { return 400.0 }
    class var maxVideoHeight:CGFloat { return UIScreen.main.bounds.height - 67.0 }
    
}
