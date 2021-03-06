//
//  CommonAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 25/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire
import AlamofireImage

class CommonAPIHandler:AppAPIHandler {
    
    func getDataFromUrl(imageURL: String, completion: @escaping (UIImage?) -> ()) {
        Alamofire.request(imageURL).responseImage { response in
            completion(response.result.value)
        }
    }
    
    func getDataFromUrlWithId(imageURL: String, imageId:Int, completion: @escaping (UIImage?, Int) -> ()) {
        Alamofire.request(imageURL).responseImage { response in
            completion(response.result.value, imageId)
        }
    }
    
    func getDataFromUrlWithId(imageURL: String, imageId:Int, indexPath:IndexPath, completion: @escaping (UIImage?, IndexPath, Int) -> ()) {
        Alamofire.request(imageURL).responseImage { response in
            completion(response.result.value, indexPath, imageId)
        }
    }
    
    func getReportTypesListForPost(_ completionBlock:@escaping (ReportTypeDataModal) -> Void) {
        let url = baseURL +  "/v1/application/post/report/types"
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReportTypeDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getReportTypesListForProfile(_ completionBlock:@escaping (ReportTypeDataModal) -> Void) {
        let url = baseURL +  "/v1/application/profile/report/types"
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReportTypeDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getReportTypesListForReaction(_ completionBlock:@escaping (ReportTypeDataModal) -> Void) {
        let url = baseURL +  "/v1/application/reaction/report/types"
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ReportTypeDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getDefaultCoverImages(_ page:Int, completionBlock:@escaping (CoverImageDataModal) -> Void) {
        let url = baseURL +  "/v1/application/default/cover/medias/\(page)"
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = CoverImageDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }
    
    func getConfiguration(_ completionBlock:@escaping (ConfigurationDataModal) -> Void) {
        let params:[String:Any] = [
            "platform": 2,
            "version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        ]
        
        let url = baseURL +  "/v1/application/config"
        getCURLRequest(url: url, params: params, method: .post)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let dataModal = ConfigurationDataModal(jsonResponse: response)
            completionBlock(dataModal)
        }
    }

}
