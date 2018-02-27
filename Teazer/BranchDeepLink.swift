    //
//  BranchDeepLink.swift
//  Teazer
//
//  Created by Faraz Habib on 07/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Branch
import UIKit

class BranchDeepLink {
    
    var linkTitle:String!
    var description:String?
    var imageUrl:String?
    var channel:String!
    
    init() {
        
    }
    
    init(title:String, description:String?, imageUrl:String?, channel:String) {
        self.linkTitle = title
        self.description = description
        self.imageUrl = imageUrl
        self.channel = channel
    }
    
    func createDeepLinks(params:[String:String]?, viewController:UIViewController) { // post_id, user_id
        let buo = BranchUniversalObject(canonicalIdentifier: "teazerapp/378286372")
        buo.canonicalUrl = "https://teazer.online"
        buo.title = linkTitle
        if description != nil {
            buo.contentDescription = description
        }
        if imageUrl != nil {
            buo.imageUrl = imageUrl
        }
        buo.publiclyIndex = true
        buo.locallyIndex = true
        if let listDict = params {
            for (key,value) in listDict {
                buo.contentMetadata.customMetadata[key] = value
            }
        }
        
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = self.channel
        lp.feature = "sharing"
        
        buo.getShortUrl(with: lp) { [weak self] (url, error) in
            let message = (self?.description != nil) ? self!.description! : "Download Teazer App"
            buo.showShareSheet(with: lp, andShareText: message, from: viewController) { (activityType, completed) in
                print(activityType ?? "")
            }
        }
    }

}
