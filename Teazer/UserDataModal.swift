//
//  UserDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 03/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import Alamofire

class UserDataModal: AppDataModal {
    
    var user:User?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            user = User(params: responseDict)
        }
        
    }
    
}

class UserProfileDataModal: AppDataModal {
    
    var user:User?
    var followers:Int? = 0
    var following:Int? = 0
    var totalVideo:Int? = 0
    var totalReactions:Int?
    var accountType: Int?
    var canJoin:Bool?
    var hasSentJoinRequest: Bool?
    var joinRequestID: Int?
    var canChangePassword: Bool? = false
    
    
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            if let userDetails = responseDict["user_profile"] as? [String:Any] {
                user = User(params: userDetails)
            } else if let userDetails = responseDict["private_profile"] as? [String:Any] {
                user = User(params: userDetails)
            } else if let userDetails = responseDict["public_profile"] as? [String:Any] {
                user = User(params: userDetails)
            }

            accountType = responseDict["account_type"] as? Int
            canJoin = responseDict["can_join"] as? Bool
            hasSentJoinRequest = responseDict["has_send_join_request"] as? Bool
            followers = responseDict["followers"] as? Int
            following = responseDict["followings"] as? Int
            totalVideo = responseDict["total_videos"] as? Int
            totalReactions = responseDict["total_reactions"] as? Int
            canChangePassword = responseDict["can_change_password"] as? Bool
        }
    }
}

class ProfileMedia {
    
    var pictureId: Int?
    var mediaUrl:String?
    var thumbUrl:String?
    var isImage:Bool?
    var duration:String?
    var height:CGFloat?
    var width:CGFloat?
    
}

class CoverMedia {
    
    var coverImageId: Int?
    var coverType: Int?
    var defaultCoverImageId: Int?
    var mediaUrl:String?
    var thumbUrl:String?
    var isImage:Bool?
    var duration:String?
    var height:CGFloat?
    var width:CGFloat?
    
}

class User {
    
    var userId:Int?
    var userName:String?
    var firstName:String?
    var fullName:String?
    var lastName:String?
    var email:String?
    var socialAccountImageURL:String?
    var isPrivate:Bool? = false
    var socialId:String?
    var profileMedia: ProfileMedia?
    var coverMedia: CoverMedia?
    var hasProfileMedia:Bool?
    var gender: Int?
    var description:String?
    var categories:[Category]?
    var socialLoginType:Int = -1 { // 1 for FB - 2 for Google
        didSet {
            UserDefaults.standard.set(socialLoginType, forKey: Constants.kSocialLoginTypeKey)
        }
    }
    var phoneNumber:String?
    var countryDialCode:String? {
        didSet {
            UserDefaults.standard.set(countryDialCode, forKey: Constants.kCountryDialCodeKey)
        }
    }
    var countryCode:String? {
        didSet {
            UserDefaults.standard.set(countryCode, forKey: Constants.kCountryCodeKey)
        }
    }
    
    var localCountryCode:String? {
        get {
            return (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        }
    }
    var otp:String?
    var isActive:Bool?
    var accountType:Int?
    var creationTime:Date?
    var updateTime:Date?
    var fcmToken:String? {
        get {
            return KeychainWrapper.standard.string(forKey: Constants.kDeviceTokenKey)
        }
    }
    var deviceId:String? {
        get {
            if let uuid = UserDefaults.standard.string(forKey: Constants.kDeviceIdKey) {
                return uuid
            }
            UserDefaults.standard.set(UIDevice.current.identifierForVendor?.uuidString, forKey: Constants.kDeviceIdKey)
            return UIDevice.current.identifierForVendor?.uuidString
        }
    }
    var deviceType = 1
    
    init() {
        
    }
    
    init(params:[String:Any]) {
        
        userId = params["user_id"] as? Int
        UserDefaults.standard.set(userId!, forKey: Constants.kUserIdKey)
        
        userName = params["user_name"] as? String
        firstName = params["first_name"] as? String
        lastName = params["last_name"] as? String
        email = params["email"] as? String
        if let code = params["country_code"] as? Int {
            countryCode = "\(code)"
        } else {
            countryCode = "+91"
        }
        isActive = params["is_active"] as? Bool
        if let cellNumber = params["phone_number"] as? Int {
            phoneNumber = "\(cellNumber)"
        }
        accountType = params["account_type"] as? Int
        gender = params["gender"] as? Int
        description = (params["description"] as? String)?.decode()
        hasProfileMedia = params["has_profile_media"] as? Bool
        
        if let unixTime = params["created_at"] as? Double {
            creationTime = Date(timeIntervalSince1970: unixTime)
        }
        
        if let unixTime = params["updated_at"] as? Double {
            updateTime = Date(timeIntervalSince1970: unixTime)
        }
        if let password = params["phone_number"] as? String {
            setPassword(password: password)
        }
        
        if let authToken = params["auth_token"] as? String {
            setAuthToken(authToken: authToken)
        }
        
        if let categoriesList = params["categories"] as? [[String:Any]] {
            categories = [Category]()
            for category in categoriesList {
                let categoryModal = Category(params: category)
                categories?.append(categoryModal)
            }
        }
        
        if let media = params["profile_media"] as? [String:Any] {
            profileMedia = ProfileMedia()
            profileMedia?.pictureId = media["picture_id"] as? Int
            profileMedia?.mediaUrl = media["media_url"] as? String
            profileMedia?.thumbUrl =  media["thumb_url"] as? String
            profileMedia?.isImage = media["is_image"] as? Bool
            profileMedia?.duration = media["duration"] as? String
            if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                profileMedia?.width = mediaDimensions["width"] as? CGFloat
                profileMedia?.height = mediaDimensions["height"] as? CGFloat
            }
        }
        
        if let media = params["cover_media"] as? [String:Any] {
            coverMedia = CoverMedia()
            coverMedia?.coverImageId = media["cover_image_id"] as? Int
            coverMedia?.coverType = media["cover_type"] as? Int
            coverMedia?.defaultCoverImageId = media["default_cover_id"] as? Int
            coverMedia?.mediaUrl = media["media_url"] as? String
            coverMedia?.thumbUrl =  media["thumb_url"] as? String
            coverMedia?.isImage = media["is_image"] as? Bool
            coverMedia?.duration = media["duration"] as? String
            if let mediaDimensions = media["media_dimension"] as? [String:Any] {
                coverMedia?.width = mediaDimensions["width"] as? CGFloat
                coverMedia?.height = mediaDimensions["height"] as? CGFloat
            }
        }
    }
    
    func getParameters() -> [String:Any] {
        return [
            "user_name"     :   userName ?? "",
            "first_name"    :   firstName ?? "",
            "last_name"     :   lastName ?? "",
            "email"         :   email ?? "",
            "password"      :   getPassword() ?? "",
            "phone_number"  :   phoneNumber ?? "",
            "country_code"  :   countryDialCode ?? "+91",
            "otp"           :   otp ?? "",
            "fcm_token"     :   KeychainWrapper.standard.string(forKey: Constants.kDeviceTokenKey) ?? "",
            "device_id"     :   UIDevice.current.identifierForVendor?.uuidString ?? "",
            "device_type"   :   1,
            "description"   :   description ?? "",
            "gender"        :   gender ?? -1,
        ]
    }
    
    func getParametersForSocialLogin() -> [String:Any] {
        return [
            "user_name"              :   userName ?? "",
            "first_name"             :   firstName ?? "",
            "last_name"              :   lastName ?? "",
            "email"                  :   email ?? "",
            "social_id"              :   socialId ?? "",
            "social_login_type"      :   socialLoginType,
            "fcm_token"              :   KeychainWrapper.standard.string(forKey: Constants.kDeviceTokenKey) ?? "",
            "device_id"              :   UIDevice.current.identifierForVendor?.uuidString ?? "",
            "device_type"            :   1
        ]
    }
    
    internal func setPassword(password: String) {
        KeychainWrapper.standard.set(password, forKey: Constants.kPasswordKey, withAccessibility: .afterFirstUnlock)
    }
    
    internal func getPassword() -> String?  {
        return KeychainWrapper.standard.string(forKey: Constants.kPasswordKey)
    }
    
    internal func setAuthToken(authToken: String) {
        KeychainWrapper.standard.set("Bearer \(authToken)", forKey: Constants.kAuthTokenKey, withAccessibility: .afterFirstUnlock)
    }
    
    internal func removeAuthToken() {
        KeychainWrapper.standard.removeObject(forKey: Constants.kAuthTokenKey)
    }
    
    internal func getAuthToken() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.kAuthTokenKey)
    }
    
    internal func clearUserCredentials() {
        KeychainWrapper.standard.removeObject(forKey: Constants.kAuthTokenKey)
        KeychainWrapper.standard.removeObject(forKey: Constants.kPasswordKey)
        UserDefaults.standard.removeObject(forKey: Constants.kSocialLoginTypeKey)
    }
    
    func getCountryCode() -> (String?,String?) {
        return (UserDefaults.standard.string(forKey: Constants.kCountryDialCodeKey), UserDefaults.standard.string(forKey: Constants.kCountryCodeKey))
    }
    
}

