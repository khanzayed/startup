//
//  reportDetailTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 29/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class reportDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tickImageVIew: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSelected() {
        DispatchQueue.main.async {
            self.tickImageVIew.isHidden = false
        }
    }
    
    func cellDeselected() {
        DispatchQueue.main.async {
            self.tickImageVIew.isHidden = true
        }
    }


}
