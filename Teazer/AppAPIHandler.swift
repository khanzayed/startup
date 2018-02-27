//
//  AppAPIHandler.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Alamofire
import SwiftKeychainWrapper

class AppAPIHandler: NSObject {
    
    var apiURL:String?
    
    private struct Static {
        static var baseURL:String?
    }
    
    
    // This parameter would provide the baseURL to which the subclasses have to append their endpoints
    var baseURL:String {
        if Static.baseURL != nil {
            return Static.baseURL!
        } else {
            let targetName = Bundle.main.infoDictionary!["Target Name"] as! String
            let environmentListPath = Bundle.main.path(forResource: "Environment", ofType: "plist")
            let environmentList = NSDictionary(contentsOfFile:environmentListPath!) as! [String:Any]
            let environment = environmentList[targetName] as! [String:Any]
            Static.baseURL = environment["myAPIURL"] as? String
            
            return Static.baseURL!
        }
    }
    
    var headers:HTTPHeaders {
        get {
            if let authToken = KeychainWrapper.standard.string(forKey: "teaser_authToken")  {
                return [
                    "Content-Type"       :     "application/json",
                    "Accept"             :     "application/json",
                    "Authorization"      :     authToken
                ]
            } else {
                return [
                    "Content-Type"       :     "application/json",
                    "Accept"             :     "application/json",
                ]
            }
        }
    }
    
    var headersForVideoUpload:HTTPHeaders {
        get {
            if let authToken = KeychainWrapper.standard.string(forKey: "teaser_authToken")  {
                return [
                    "Content-Type"       :     "multipart/form-data",
                    "Accept"             :     "application/json",
                    "Authorization"      :     authToken
                ]
            } else {
                return [
                    "Content-Type"       :     "multipart/form-data",
                    "Accept"             :     "application/json",
                ]
            }
        }
    }
    
    func getCURLRequest(url:String, params:[String:Any]?, method:HTTPMethod) {
        var curlString = "THE CURL REQUEST: curl -k -X \(method) --dump-header"
        
        for (key,value) in self.headers {
            let headerKey = self.escapeQuotesInString(str: key)
            let headerValue = self.escapeQuotesInString(str: value)
            
            curlString += " -H \"\(headerKey): \(headerValue)\""
        }
        
        if let body = params {
            do {
                let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    let bodyDataString = self.escapeQuotesInString(str: str)
                    curlString += " -d \"\(bodyDataString)\""
                }
            } catch _ {
                print("cURL Params Parsing Exception")
            }
        }
        curlString += " \"\(url)\""
        
        print(curlString)
    }
    
    private func escapeQuotesInString(str:String) -> String {
        return str.replacingOccurrences(of: "\"", with: "\\\"")
    }
    
}

