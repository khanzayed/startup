//
//  NotificationsAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 06/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class NotificationsAPIHandler:AppAPIHandler {
    
    func getFollowingNotificationsList(_ page: Int, completionBlock:@escaping (NotificationsDataModal) -> Void) {
        let url = baseURL + "/v1/user/notifications/followings/\(page)"
            
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = NotificationsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
        
    }
    
    func getRequestNotificationsList(_ page: Int, completionBlock:@escaping (NotificationsDataModal) -> Void) {
        let url = baseURL + "/v1/user/notifications/requests/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = NotificationsDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
        
    }
    
    func getUsersList(_ page: Int, completionBlock:@escaping (FriendsListDataModal) -> Void) {
        let url = baseURL + "/v1/friend/application/users/\(page)"
        
        super.getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
            let dataModal = FriendsListDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }

    func resetNotificationsCount(type:Int) {
        let params:[String:Any] = ["type"   :   type]
        let url = baseURL + URLBuilder().buildURL("/v1/user/reset/notification/count", withParams: params)
        
        
        super.getCURLRequest(url: url, params: nil, method: .put)
        Alamofire.request(url, method: .put, parameters: nil, encoding: JSONEncoding.default, headers: super.headers).responseJSON { (response) in
        }
    }
}
