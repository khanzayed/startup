//
//  GooglePlacesAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class GooglePlacesAPIHandler:AppAPIHandler {
    
    func fetchNearByPlaces(params:[String:Any], completionBlock:@escaping (NearByPlacesDataModal) -> Void) {
        let url = URLBuilder().buildURL("https://maps.googleapis.com/maps/api/place/nearbysearch/json", withParams: params)
        
        Alamofire.request(url).responseJSON { (response) in
            let nearByPlacesDataModal = NearByPlacesDataModal(jsonResponse: response)
            completionBlock(nearByPlacesDataModal)
        }
    }
    
}
