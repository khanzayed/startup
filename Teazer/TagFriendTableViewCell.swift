//
//  TagFriendTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class TagFriendTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
    }
    
    func setupCell(friend:Friend, imageKey:String, isSelected:Bool) {
        if isSelected {
            checkImageView.image = UIImage(named: "ic_select_tick_icon")
            checkImageView.tintColor = ColorConstants.kAppGreenColor
        }
        name.text = friend.userName
        fullNameLbl.text = (friend.firstName ?? "") + " " + (friend.lastName ?? "")
    }

}
