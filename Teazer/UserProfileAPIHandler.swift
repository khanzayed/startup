//
//  UserProfileViewControllerAPIHandler.swift
//  Teazer
//
//  Created by Ankita Satpathy on 06/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class UserProfileAPIHandler: AppAPIHandler {
    
    func getUserPosts(_ page: Int, completionBlock:@escaping(PostDataModal) -> Void){
        let url =  super.baseURL + "/v1/post/my/videos/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func getOtherPost(_ page: Int, userId:Int, completionBlock:@escaping(PostDataModal) -> Void) {
        let url = baseURL + "/v1/post/friend/videos/\(userId)/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func getUserReactions(_ page:Int, completionBlock:@escaping (ReactionsDataModal) -> Void) {
        let url =  super.baseURL + "/v1/react/my/reactions/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReactionsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getUserProfile(completionBlock:@escaping (UserProfileDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/profile"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = UserProfileDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getUserFollwerDetails(_ page:Int, completionBlock:@escaping (PeopleDataModel) -> Void) {
        let url =  super.baseURL + "/v2/friend/my/followers/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getUserFollowingDetails(_ page:Int, completionBlock:@escaping (PeopleDataModel) -> Void) {
        let url =  super.baseURL + "/v2/friend/my/followings/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func deletePost(_ postID:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/post/delete/\(postID)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func removeProfile(_ completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/remove/profile/media"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func deleteReaction(_ reactID:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/react/delete/\(reactID)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func updateProfileInfo(_ user:User, completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/update/profile"
        
        getCURLRequest(url: url, params: user.getParameters(), method: .put)
        Alamofire.request(url, method: .put, parameters: user.getParameters(), encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func updatePhoneNumber(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/change/phonenumber"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getOtherProfileDetails(_ userID: Int, completionBlock:@escaping(FriendProfileDataModal) -> Void){
        let url =  super.baseURL + "/v1/friend/profile/\(userID)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = FriendProfileDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func sendRequestUsingUserId(_ userID: Int, completionBlock:@escaping(AppDataModal) -> Void){
        let url =  super.baseURL + "/v1/friend/join/request/by/userid/\(userID)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func getFriendsVideos(_ userID: Int, _ pageNo: Int, completionBlock:@escaping(PostDataModal) -> Void){
        let url =  super.baseURL + "/v1/post/friend/videos/\(userID)/\(pageNo)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getFriendsReactions(_ userID: Int, _ pageNo: Int, completionBlock:@escaping(ReactionsDataModal) -> Void){
        let url =  super.baseURL + "/v1/react/friend/reactions/\(userID)/\(pageNo)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReactionsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func blockUser(_ userID: Int, _ status: Int, completionBlock:@escaping(AppDataModal) -> Void){
        let url =  super.baseURL + "/v1/friend/block/\(userID)/\(status)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func reportUser(param: [String:Any], completionBlock:@escaping(AppDataModal) -> Void){
        let url =  super.baseURL + "v1/user/report"
        
        getCURLRequest(url: url, params: param, method: .post)
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    
    func unfollowUser(_ userID: Int, completionBlock:@escaping(AppDataModal) -> Void){
        let url =  super.baseURL + "/v1/friend/unfollow/\(userID)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func cancelJoinRequest(_ userID: Int, completionBlock:@escaping(AppDataModal) -> Void){
        let url =  super.baseURL + "/v1/friend/cancel/join/request/\(userID)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
            
        }
    }
    
    func uploadProfileMedia(imageData:Data, completionHandler: @escaping (VideoResponseDataModal) -> Void) {
        let url = baseURL + "/v1/user/update/profile/media"

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "media", fileName: "profileImage.jpeg", mimeType: "image/jpeg")
        }, to: url, method: .post, headers: headersForVideoUpload) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let videoResponseDataModal = VideoResponseDataModal(jsonResponse: response)
                    completionHandler(videoResponseDataModal)
                }
            case .failure(_):
                let videoResponseDataModal = VideoResponseDataModal()
                completionHandler(videoResponseDataModal)
            }
        }
    }
    
    func uploadCoverMedia(imageData:Data, completionHandler: @escaping (VideoResponseDataModal) -> Void) {
        let url = baseURL + "/v1/user/update/profile/cover/media"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(imageData, withName: "media", fileName: "coverImage.jpeg", mimeType: "image/jpeg")
        }, to: url, method: .post, headers: headersForVideoUpload) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    let videoResponseDataModal = VideoResponseDataModal(jsonResponse: response)
                    completionHandler(videoResponseDataModal)
                }
            case .failure(_):
                let videoResponseDataModal = VideoResponseDataModal()
                completionHandler(videoResponseDataModal)
            }
        }
    }

    func setProfileVisibility(accountType: Int, completionBlock:@escaping(AppDataModal) -> Void){
        let url = super.baseURL + "/v1/user/profile/visibility?accountType=\(accountType)"

        getCURLRequest(url: url, params: nil, method: .put)
        Alamofire.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    
    func getBlockList(pageNo: Int, completionBlock:@escaping(PeopleDataModel) -> Void){
        let url = super.baseURL + "/v1/friend/blocked/users/\(pageNo)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    
    func getFriendsFollowing(_ page:Int, _ userID:Int, completionBlock:@escaping (PeopleDataModel) -> Void) {
        let url =  super.baseURL + "/v2/friend/followings/\(userID)/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getFriendsFollowers(_ page:Int, _ userID:Int, completionBlock:@escaping (PeopleDataModel) -> Void) {
        let url =  super.baseURL + "/v2/friend/followers/\(userID)/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func updatePassword(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/update/password"
        
        getCURLRequest(url: url, params: params, method: .put)
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func setPassword(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/set/new/password"
        
        getCURLRequest(url: url, params: params, method: .put)
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getDeactivationList(_ completionBlock:@escaping (DeactivateAccountDataModal) -> Void) {
        let url = baseURL +  "/v1/application/deactivate/types"
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = DeactivateAccountDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func deactivateAccount(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url =  super.baseURL + "/v1/user/deactivate"
        
        getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post , parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
  
}

