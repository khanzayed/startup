//
//  CategoryDataModal.swift
//  Teazer
//
//  Created by Faraz Habib on 10/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import Alamofire

class CategoryDataModal: AppDataModal {

    var categoriesList:[Category]?
    var categories : String!
    
    override init(jsonResponse:DataResponse<Any>?) {
        super.init(jsonResponse: jsonResponse)
        
        if super.errorObject == nil, let responseArr = super.responseArr {
            categoriesList = [Category]()
            for cat in responseArr {
                let categoryModal = Category(params: cat)
                categoriesList?.append(categoryModal)
            }
        }
    }
    
}


struct Category {
    
    var categoryId:Int?
    var categoryName:String?
    var categoryColorStr:String?
    var textWidth:CGFloat?
    var categoryColorForHome:String?
    
    init() {
        
    }
    
    init(params:[String:Any]) {
        categoryId = params["category_id"] as? Int
        categoryName = params["category_name"] as? String
        categoryColorStr = params["my_color"] as? String
        categoryColorForHome = params["color"] as? String
    }
    
    init(params:[String:Any], font:UIFont) {
        categoryId = params["category_id"] as? Int
        categoryName = params["category_name"] as? String
        categoryColorStr = params["my_color"] as? String
        categoryColorForHome = params["color"] as? String
        textWidth = categoryName?.getWidthForText(font: font)
    }
    
    init(categoryId: Int, categoryName: String, categoryColorStr:String) {
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryColorStr = categoryColorStr
    }
    
}
