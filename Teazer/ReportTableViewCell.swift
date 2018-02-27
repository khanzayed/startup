//
//  ReportTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 29/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {

    @IBOutlet weak var titlelbl: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cellSelected() {
        DispatchQueue.main.async {
            self.tickImage.isHidden = false
        }
    }
    
    func cellDeselected() {
        DispatchQueue.main.async {
            self.tickImage.isHidden = true
        }
    }

}
