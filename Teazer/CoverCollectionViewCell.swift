//
//  CoverCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 23/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class CoverCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var viewBlackFront: UIView!
    @IBOutlet weak var imageViewTick: UIImageView!
    @IBOutlet weak var viewAddCustomCover: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 5.0
        
        self.viewAddCustomCover.layer.cornerRadius = 5.0
        self.viewAddCustomCover.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
        self.viewAddCustomCover.layer.borderWidth = 2.0
    }
    
    func setupImageCell(isSelected:Bool) {
        viewBlackFront.isHidden = !isSelected
        imageViewTick.isHidden = !isSelected
        viewAddCustomCover.isHidden = true
    }
    
    func cellSelected() {
        DispatchQueue.main.async {
            self.viewBlackFront.isHidden = false
            self.imageViewTick.isHidden = false
        }
    }
    
    func cellDeselected() {
        DispatchQueue.main.async {
            self.viewBlackFront.isHidden = true
            self.imageViewTick.isHidden = true
        }
    }
    
    func setupButtonCell() {
        imageViewCover.isHidden = true
        viewBlackFront.isHidden = true
        imageViewTick.isHidden = true
        viewAddCustomCover.isHidden = false
    }
    
}
