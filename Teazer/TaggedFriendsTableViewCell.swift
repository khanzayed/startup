//
//  TaggedFriendsTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 14/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class TaggedFriendsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    
    @IBOutlet weak var ViewUntag: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor(rgba: "#DDDDDD").cgColor
    }

    func setupCell(friend:Friend) {
        userNameLbl.text = friend.userName
        fullNameLbl.text = (friend.firstName ?? "") + " " + (friend.lastName ?? "")
    }
    
    @IBAction func untagButtonTapped(_ sender: UIButton) {
        
        
    }
}
