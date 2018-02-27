//
//  CameraControllerAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 21/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import Alamofire

class CameraControllerAPIHandler: AppAPIHandler {
    
    var requestPostUpload:UploadRequest?
    var requestReactionUpload:UploadRequest?
    
    func uploadUserVideo(title:String?, fileURL:URL, place:GooglePlace?, taggedFriends:String, taggedCategories:String, completionHandler: @escaping (VideoResponseDataModal) -> Void, uploadProgressHandler:@escaping (Float) -> Void) {
        let url = baseURL + "/v1/post/create"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileURL, withName: "video")
            
            if title?.count != 0 {
                multipartFormData.append(title!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "title")
            }
            
            if place != nil {
                multipartFormData.append(place!.latitude!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "latitude")
                multipartFormData.append(place!.longitude!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "longitude")
                multipartFormData.append(place!.title!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "location")
            }
            
            if taggedFriends.count > 0 {
                multipartFormData.append(taggedFriends.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "tags")
            }
            
            if taggedCategories.count > 0 {
                multipartFormData.append(taggedCategories.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "categories")
            }
        }, to: url, method: .post, headers: headersForVideoUpload) { [weak self] (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                self?.requestPostUpload = upload
                upload.responseJSON { response in
                    let videoResponseDataModal = VideoResponseDataModal(jsonResponse: response)
                    completionHandler(videoResponseDataModal)
                }
                upload.uploadProgress { progress in
                    uploadProgressHandler(Float(progress.fractionCompleted))
                }
            case .failure(_):
                let videoResponseDataModal = VideoResponseDataModal()
                completionHandler(videoResponseDataModal)
            }
        }
    }
    
    func cancelUploadPost() {
        requestPostUpload?.cancel()
        requestPostUpload = nil
    }
    
    func uploadReactionVideo(title:String?, postId:Int, fileURL:URL, completionHandler: @escaping (VideoResponseDataModal) -> Void, uploadProgressHandler:@escaping (Float) -> Void) {
        let url = baseURL + "/v1/react/create"
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(fileURL, withName: "video")
            multipartFormData.append("\(postId)".data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "post_id")
            if title?.count != 0 {
                multipartFormData.append(title!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "title")
            }
        }, to: url, method: .post, headers: headersForVideoUpload) { [weak self] (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                self?.requestReactionUpload = upload
                upload.responseJSON { response in
                    let videoResponseDataModal = VideoResponseDataModal(jsonResponse: response)
                    completionHandler(videoResponseDataModal)
                }
                upload.uploadProgress { progress in
                    uploadProgressHandler(Float(progress.fractionCompleted))
                }
            case .failure(_):
                let videoResponseDataModal = VideoResponseDataModal()
                completionHandler(videoResponseDataModal)
            }
        }
    }
    
    func cancelUploadReaction() {
        requestReactionUpload?.cancel()
        requestReactionUpload = nil
    }
    
    func fetchFriendsList(page:Int, completionHandler: @escaping (FriendsListDataModal) -> Void) {
        let url = super.baseURL + "/v1/friend/my/circle/\(page)"
        
        getCURLRequest(url: url, params: nil, method: .get)
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let friendListDataModal = FriendsListDataModal(jsonResponse: response)
            completionHandler(friendListDataModal)
        }
    }
    
    func updatePostDetails(params:[String:Any], completionBlock:@escaping(PostDataModal) -> Void) {
        let url = baseURL + "/v1/post/update"
        
        getCURLRequest(url: url, params: params, method: .put)
        Alamofire.request(url, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) in
            let postDataModal = PostDataModal(jsonResponse: response)
            completionBlock(postDataModal)
        }
    }
    
}
