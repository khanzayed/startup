//
//  DiscoverLandingDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 26/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class DiscoverLandingDataModal: AppDataModal {
    
    var mostPopularVideos:[Post]?
    var userInterest:[Category]?
    var trendingCategories:[Category]?
    var myInterests:[MyInterestDataModal]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            if let mostPopularList = responseDict["most_popular"] as? [[String:Any]] {
                mostPopularVideos = [Post]()
                for video in mostPopularList {
                    let post = Post(post: video)
                    mostPopularVideos?.append(post)
                }
            }
            
            if let categroryList = responseDict["user_interests"] as? [[String:Any]] {
                userInterest = [Category]()
                for category in categroryList {
                    let cat = Category(params: category)
                    userInterest?.append(cat)
                }
            }
            
            if let categroryList = responseDict["trending_categories"] as? [[String:Any]] {
                trendingCategories = [Category]()
                let font = UIFont(name: Constants.kProximaNovaSemibold, size: 14.0)!
                for category in categroryList {
                    let cat = Category(params: category, font: font)
                    trendingCategories?.append(cat)
                }
            }
            
            if let myInterestList = responseDict["my_interests"] as? [String:Any] {
                myInterests = [MyInterestDataModal]()
                for (key,value) in myInterestList {
                    var myInterest = MyInterestDataModal()
                    myInterest.titleStr = key
                    if let videos = value as? [[String:Any]] {
                        myInterest.post = [Post]()
                        for video in videos {
                            myInterest.post?.append(Post(post: video))
                        }
                    }
                    myInterests?.append(myInterest)
                }
            }
        }
    }
}


struct MyInterestDataModal {
    
    var titleStr:String?
    var post:[Post]?
    
}
