//
//  StringExtension.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
    
    func isValidMobile() -> Bool {
        //let PHONE_REGEX = "^\\d{10}-\\d{3}-\\d{4}$"
        let PHONE_REGEX = "^\\d{4,13}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        return phoneTest.evaluate(with: self)
    }
    
    func getWidthForText(font:UIFont) -> CGFloat {
        let size = (self as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
        
        return size.width
    }
    //Proxima Nova
    //ProximaNova-Semibold
    //
    func listAllFontFamilies() {
        for family in UIFont.familyNames {
            print(family)
            for name in UIFont.fontNames(forFamilyName: family) {
                print(name)
            }
        }
    }
    
    func encode() -> String? {
        let encodedStr = NSString(cString: self.cString(using: String.Encoding.nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue)
        return encodedStr as String?
    }

    func decode() -> String? {
        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
        if data != nil {

            let valueUniCode = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue) as String?
            if valueUniCode != nil {
                return valueUniCode!
            } else {
                return self
            }
        } else {
            return self
        }
    }
    
    var isNumber: Bool {
            return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    


}
