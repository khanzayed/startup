//
//  AppDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class AppDataModal {
    
    var errorObject:APIErrorModal?
    var responseDict:[String:Any]?
    var responseArr:[[String:Any]]?
    var status:Bool?
    var authToken:String?
    var reason:String?
    var message:String?
    var responseCode:Int!
    var followedInfo:FollowInfo?
    
    init(jsonResponse:DataResponse<Any>?, calculateContentHeight:Bool = false) {
        parseResponseData(jsonResponse: jsonResponse)
    }
    
    init(jsonResponse:DataResponse<Any>?) {
        parseResponseData(jsonResponse: jsonResponse)
    }
    
    func parseResponseData(jsonResponse:DataResponse<Any>?) {
        if let statusCode = jsonResponse?.response?.statusCode {
            if statusCode == 401 {
                LogOut().doForceLogOut()
                return
            }
            
            responseCode = statusCode
            if let responseDict = jsonResponse?.result.value as? [String:Any] {
                message = responseDict["message"] as? String
                status = responseDict["status"] as? Bool
                authToken = responseDict["auth_token"] as? String
                if let info = responseDict["follow_info"] as? [String:Any] {
                    followedInfo = FollowInfo()
                    followedInfo?.userId = info["user_id"] as? Int
                    followedInfo?.hasBlockedYou = info["is_blocked_you"] as? Bool
                    followedInfo?.isFollowing = info["following"] as? Bool
                    followedInfo?.isFollower = info["follower"] as? Bool
                    followedInfo?.isRequestSent = info["request_sent"] as? Bool
                    followedInfo?.isRequestReceived = info["request_received"] as? Bool
                    followedInfo?.blocked = info["you_blocked"] as? Bool
                    followedInfo?.requestId = info["request_id"] as? Int
                }
                if statusCode == 201 || statusCode == 200 { // Success
                    self.responseDict = responseDict
                } else if statusCode == 400 || statusCode == 417 || statusCode == 412 {
                    errorObject = APIErrorModal(code: statusCode, message: message, reasonObject: responseDict["reason"])
                } else {
                    errorObject = APIErrorModal(code: 404, message: Constants.kGenericErrorMessage, reasonObject: nil)
                }
            } else if let responseArr = jsonResponse?.result.value as? [[String:Any]] {
                if statusCode == 201 || statusCode == 200 { // Success
                    self.responseArr = responseArr
                } else {
                    errorObject = APIErrorModal(code: 404, message: Constants.kGenericErrorMessage, reasonObject: nil)
                }
            } else {
                errorObject = APIErrorModal(code: 404, message: Constants.kGenericErrorMessage, reasonObject: nil)
            }
        } else {
            responseCode = 417
        }
    }
}

struct APIErrorModal {
    
    var code:Int!
    var message:String?
    var reason:String?
    
    init(code:Int, message:String?, reasonObject:Any?) {
        self.code = code
        self.message = message
        
        if let reason = reasonObject as? String {
            self.reason = reason
        } else if let reasonsArr = reasonObject as? [String] {
            self.reason = reasonsArr[0]
        }
    }
    
}


