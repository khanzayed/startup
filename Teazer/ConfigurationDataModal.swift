//
//  ConfigurationDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 03/03/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Alamofire

class ConfigurationDataModal: AppDataModal {
    
    var isForceUpdate = false
    var isUpdateAvailable = false
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseDict = super.responseDict {
            if let value = responseDict["force_update"] as? Bool {
                self.isForceUpdate = value
            }
            
            if let value = responseDict["update_available"] as? Bool {
                self.isUpdateAvailable = value
            }
        }
    }
    
}
