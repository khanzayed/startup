//
//  BlockListCell.swift
//  Teazer
//
//  Created by Ankita Satpathy on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class BlockListCell: UITableViewCell {
    
    typealias UnblockTappedBlock =  () -> Void
    var unblockTappedBlock : UnblockTappedBlock?
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var unblockBtn: UIButton!

    @IBOutlet weak var fullNameLabel: UILabel!
    
    func setupCell() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
        unblockBtn.layer.cornerRadius = unblockBtn.frame.size.height / 2
        unblockBtn.clipsToBounds = true
        unblockBtn.layer.borderWidth = 1.0
        unblockBtn.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
    }

    @IBAction func unblockTapped(_ sender: Any) {
        unblockTappedBlock!()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
