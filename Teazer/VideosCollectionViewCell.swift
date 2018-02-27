//
//  VideosCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 21/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class VideosCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageVideo: UIImageView!
    
    
    override func awakeFromNib() {
        self.layer.borderWidth = 0.2
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
    }
    
}
