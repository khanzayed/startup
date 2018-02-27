//
//  DiscoverControllerAPIsHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class DiscoverControllerAPIsHandler:AppAPIHandler {
    
    func getFeaturedVideos(_ page: Int, completionBlock:@escaping (PostDataModal) -> Void) {
        let url = baseURL + "/v1/discover/featured/videos/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response, calculateContentHeight: true)
            completionBlock(dataModal)
        }
    }
    
    func getPopularVideos(_ page: Int, completionBlock:@escaping (PostDataModal) -> Void) {
        let url = baseURL + "/v1/discover/most/popular/videos/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response, calculateContentHeight: true)
            completionBlock(dataModal)
        }
    }
    
    func getLandingPageVideos(_ page: Int, completionBlock:@escaping (DiscoverLandingDataModal) -> Void) {
        let url = baseURL + "/v1/discover/landing"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = DiscoverLandingDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getCategoryVideos(_ categoryId:Int, page: Int, completionBlock:@escaping (PostDataModal) -> Void) {
        let url = baseURL + "/v1/discover/interested/category/videos/\(categoryId)/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = PostDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getSearchVideoResult(_ params: [String:Any], completionBlock:@escaping (SearchVideoResultDataModal) -> Void) {
        let url = baseURL + URLBuilder().buildURL("/v1/discover/videos", withParams: params)
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = SearchVideoResultDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }

    func getSearchUserResult(_ params: [String:Any], completionBlock:@escaping (SearchUserResultDataModal) -> Void) {
        let url = baseURL + URLBuilder().buildURL("/v2/discover/users", withParams: params)
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = SearchUserResultDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
}
