//
//  NSMutableAttributesString.swift
//  Teazer
//
//  Created by Faraz Habib on 24/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    
    @discardableResult func bold(_ text:String, fontSize:CGFloat) -> NSMutableAttributedString {
        let attrs:[NSAttributedStringKey:Any] = [NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont(name: Constants.kProximaNovaBold, size: fontSize)!]
        let boldString = NSMutableAttributedString(string: text, attributes:attrs)
        self.append(boldString)
        return self
    }
    
}

