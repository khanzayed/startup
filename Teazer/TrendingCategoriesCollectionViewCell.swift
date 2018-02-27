//
//  TrendingCategoriesCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class TrendingCategoriesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        categoryView.layer.cornerRadius = categoryView.bounds.height / 2
        categoryView.layer.borderWidth = 1.0
    }
    
    func setupCell(category:Category) {
        if let colorHexStr = category.categoryColorStr {
            categoryView.layer.borderColor = UIColor(rgba: colorHexStr).cgColor
            titleLbl.textColor = UIColor(rgba: colorHexStr)
        } else {
            categoryView.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
        }
        titleLbl.text = category.categoryName
    }
    
}
