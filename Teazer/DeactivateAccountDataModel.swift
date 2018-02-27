//
//  DeactivateAccountDataModel.swift
//  Teazer
//
//  Created by Mraj singh on 04/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire

class DeactivateAccountDataModal: AppDataModal {
    
    var deactivationReasonList:[DeactivateReason]?
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
    
        if super.errorObject == nil, let responseDict = super.responseArr {
    
            deactivationReasonList = [DeactivateReason]()
            
            for deactivationReason in responseDict {
                
                var deactivateReasonModal = DeactivateReason()
                
                deactivateReasonModal.deactivateId = deactivationReason["deactivate_id"] as? Int
                deactivateReasonModal.title = deactivationReason["title"] as? String
                deactivateReasonModal.hasDescription = deactivationReason["own_reason"] as? Bool
                
                deactivationReasonList?.append(deactivateReasonModal)
            }
            
        }
    }
}

struct DeactivateReason {

    var deactivateId:Int?
    var hasDescription:Bool?
    var title: String?
    var isSelected = false
    
}
