//
//  NearByPlacesDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class NearByPlacesDataModal:AppDataModal {
    
    var placesList:[GooglePlace]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            if let results = responseDict["results"] as? [[String:Any]] {
                placesList = [GooglePlace]()
                for result in results {
                    if let title = result["name"] as? String {
                        var nearByPlace = GooglePlace()
                        nearByPlace.title = title
                        nearByPlace.vicinity = result["vicinity"] as? String
                        if let geometry = result["geometry"] as? [String:Any] {
                            if let location = geometry["location"] as? [String:Any] {
                                nearByPlace.latitude = "\(location["lat"] as! Double)"
                                nearByPlace.longitude = "\(location["lng"] as! Double)"
                            }
                        }
                        placesList!.append(nearByPlace)
                        
                    }
                }
            }
        }
    }
    
}

struct GooglePlace {
    
    var title:String?
    var vicinity:String?
    var latitude:String?
    var longitude:String?
    var placeId:String?
    
}
