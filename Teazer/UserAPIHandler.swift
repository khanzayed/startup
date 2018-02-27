//
//  UserAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 03/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class UserAPIHandler:AppAPIHandler {
    
    func registerUser(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/signup"
        
        super.getCURLRequest(url: url, params: user.getParameters(), method: .post)
        Alamofire.request(url, method: .post, parameters: user.getParameters(), encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func registrationVerify(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/signup/verify"
        
        super.getCURLRequest(url: url, params: user.getParameters(), method: .post)
        Alamofire.request(url, method: .post, parameters: user.getParameters(), encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func verifyOTPForEditProfile(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/change/phonenumber/verify/otp"
        
        super.getCURLRequest(url: url, params: user.getParameters(), method: .put)
        Alamofire.request(url, method: .put, parameters: user.getParameters(), encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    
    func signIn(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/signin/with/password"
        
        super.getCURLRequest(url: url, params: user.getParameters(), method: .post)
        Alamofire.request(url, method: .post, parameters: user.getParameters(), encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func checkUserNameAvailability(_ userName:String, completionBlock:@escaping (Bool?, APIErrorModal?) -> Void) {
        let url = super.baseURL + "/v1/authentication/check/username/\(userName)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            guard let isAvailable = dataModal.status else {
                completionBlock(false, dataModal.errorObject)
                return
            }
            completionBlock(!isAvailable, dataModal.errorObject)
        }
    }
    
    func checkEmailAvailability(_ email:String, completionBlock:@escaping (Bool?, APIErrorModal?) -> Void) {
        let url = super.baseURL + "/v1/authentication/check/email/\(email)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            guard let isAvailable = dataModal.status else {
                completionBlock(false, dataModal.errorObject)
                return
            }
            completionBlock(!isAvailable, dataModal.errorObject)
        }
    }
    
    func checkPhoneNumberAvailability(_ params:[String:Any], completionBlock:@escaping (Bool?, APIErrorModal?) -> Void) {
        let url = super.baseURL + URLBuilder().buildURL("/v1/authentication/check/phonenumber", withParams: params) //{ "phonenumber" : "", "countryCode" : ""}
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            guard let isAvailable = dataModal.status else {
                completionBlock(false, dataModal.errorObject)
                return
            }
            completionBlock(!isAvailable, dataModal.errorObject)
        }
    }
    
    func getOTPToLoginThroughMobile(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/signin/with/otp"
        
        super.getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func loginVerifyThroughMobileOTP(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/signin/with/otp/verify"
        
        super.getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func updatePhoneNumberThroughOTP(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/change/phonenumber/verify/otp"
        
        super.getCURLRequest(url: url, params: params, method: .put)
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getOTPToResetPasswordByEmail(_ email:String, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/reset/password/by/\(email)"
        
        super.getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getOTPToResetPasswordByMobile(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/reset/password/by/phonenumber"
        
        super.getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func authenticateForgotPasswordOTP(_ otp:String, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/reset/password/verify/otp/\(otp)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func resetPassword(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/password/reset"
        
        super.getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func registerDeviceToken(_ deivceToken:String) {
        let url = super.baseURL + "/v1/user/update/fcm/\(deivceToken)"
        
        super.getCURLRequest(url: url, params: nil, method: .put)
        Alamofire.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            
        }
    }
    
    func getListOfCategories(completionBlock:@escaping (CategoryDataModal) -> Void) {
        let url = super.baseURL + "/v1/application/categories"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url).responseJSON { (response) in
            let categoryModal = CategoryDataModal(jsonResponse: response)
            completionBlock(categoryModal)
        }
    }
    func updateCategories(params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url = super.baseURL + "/v1/user/update/categories"
        
        super.getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func socialLogin(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/authentication/social/signup"
        
        super.getCURLRequest(url: url, params: user.getParametersForSocialLogin(), method: .post)
        Alamofire.request(url, method: .post, parameters: user.getParametersForSocialLogin(), encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func sendJoinRequestbyUserName(_ userName:String, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/friend/join/request/by/username/\(userName)"
        
        super.getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters:nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func sendJoinRequestbyUserID(_ userId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/friend/join/request/by/userid/\(userId)"
        
        super.getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters:nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func acceptJoinRequest(_ notificationId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/friend/join/request/accept/\(notificationId)"
        
        super.getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func listAllUsers(_ page:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/friend/application/users/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func invalidateAuthToken() {
        let url =  baseURL + "/v1/user/logout"
        
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            
        }
    }
    
}

