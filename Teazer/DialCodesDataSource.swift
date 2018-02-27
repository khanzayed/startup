//
//  CountriesList.swift
//  Teazer
//
//  Created by Faraz Habib on 09/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation

struct DialCodesDataSource {
    var countriesList = [Country]()
    
    mutating func parseJSON() {
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let json =  try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                if let list = json as? [[String:Any]] {
                    for country in list {
                        let code = country["code"] as? String
                        let name = country["name"] as? String
                        let dialCode = country["dial_code"] as? String
                        let countryObj = Country(code: code, name: name, dialCode: dialCode)
                        countriesList.append(countryObj)
                    }
                }
            } catch _ {
                print("Parsing error")
            }
        } else {
            print("FILE NOT FOUND")
        }
    }
    
}

struct Country {
    var code: String?
    var name: String?
    var dialCode: String?
    
    init(code: String?, name: String?, dialCode: String?) {
        self.code = code
        self.name = name
        self.dialCode = dialCode
    }

}
