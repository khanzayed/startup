//
//  HomeControllerAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class HomeControllerAPIHandler: AppAPIHandler {
    
    func getHomePageDetails(_ page:Int, completionBlock:@escaping (PostDataModal) -> Void) {
        let url =  super.baseURL + "/v1/post/home/posts/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response, calculateContentHeight: false)
            completionBlock(dataModal)
        }
    }
    func getPostDetails(_ postId:Int, completionBlock:@escaping (PostDataModal) -> Void) {
        let url =  super.baseURL + "/v1/post/video/details/\(postId)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
   
    func getReactionsForPost(_ postId:Int, page:Int, completionBlock:@escaping (ReactionsDataModal) -> Void) {
        let url =  super.baseURL + "/v1/post/video/reactions/\(postId)/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReactionsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func increaseViewsForPost(_ mediaId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/increase/view/\(mediaId)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func increaseViewsForReaction(_ mediaId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/react/increase/view/\(mediaId)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func likeAPost(_ postId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/like/\(postId)/\(1)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func likeAReaction(_ mediaId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/react/like/\(mediaId)/\(1)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }

    func disLikeAPost(_ postId:Int,completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/like/\(postId)/\(2)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func disLikeAReaction(_ mediaId:Int,completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/react/like/\(mediaId)/\(2)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getTaggedFriends(_ postId:Int, pageNo:Int, completionBlock:@escaping (FriendsListDataModal) -> Void) {
        let url = baseURL + "/v2/post/tagged/users/\(postId)/\(pageNo)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = FriendsListDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getLikersList(_ postId:Int, pageNo:Int, completionBlock:@escaping (PeopleDataModel) -> Void) {
        let url = baseURL + "/v2/post/liked/users/\(postId)/\(pageNo)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = PeopleDataModel(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func reportPost(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/report"
        
        getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func reportProfile(_ params:[String:Any], completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/user/report"
        
        getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func hidePost(_ postId: Int ,_ status: Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/hide/\(postId)/\(status)"
        
        getCURLRequest(url: url, params: nil, method: .post)
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func deleteAPost(_ postId:Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/delete/\(postId)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getReactionDetails(_ reactionId :Int,completionBlock:@escaping (ReactionsDataModal) -> Void){
        let url =  super.baseURL + "/v1/react/details/\(reactionId)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReactionsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func untagMyself(_ postId: Int, completionBlock:@escaping (AppDataModal) -> Void) {
        let url = baseURL + "/v1/post/untag/me/\(postId)"
        
        getCURLRequest(url: url, params: nil, method: .delete)
        Alamofire.request(url, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = AppDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
}
