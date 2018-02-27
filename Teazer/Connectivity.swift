//
//  Connectivity.swift
//  Teazer
//
//  Created by Faraz Habib on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class Connectivity {
    
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
}
