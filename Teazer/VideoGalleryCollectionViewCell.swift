//
//  VideoGalleryCollectionViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 03/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class VideoGalleryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var lblDuration: UILabel!
    
    
    override func awakeFromNib() {
        self.layer.borderWidth = 0.2
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        
    }
    
}
