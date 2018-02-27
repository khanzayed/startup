//
//  AppAPIParser.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class AppAPIParser: NSObject {
    
    func getNumberOfLinesForFullAddress(text:String, fontSize:CGFloat) -> Int {
        let font = UIFont.systemFont(ofSize: fontSize)
        let size = (text as NSString).size(withAttributes: [NSAttributedStringKey.font: font])
        
        if size.width > UIScreen.main.bounds.width - 20 {
            return 2
        }
        return 1
    }
    
}
