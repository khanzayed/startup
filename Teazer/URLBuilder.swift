//
//  URLBuilder.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation

class URLBuilder: NSObject {
    
    func buildURL(_ url:String, withParams:[String:Any]?) -> String {
        var dictParamsString = ""
        if let isDict: Dictionary = withParams {
            for (key, value) in isDict  {
                dictParamsString = dictParamsString + "\(key)=\(value)&"
            }
            dictParamsString = String(dictParamsString.dropLast())
        } else {
            return url
        }
        
        return "\(url)?\(dictParamsString)"
    }
}
