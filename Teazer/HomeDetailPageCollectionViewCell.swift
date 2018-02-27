//
//  HomeDetailPageCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 01/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeDetailPageCollectionViewCell: UICollectionViewCell {
    
    typealias ProfileTappedBlock = () -> Void
    var profileTappedBlock:ProfileTappedBlock?

    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        profileImageView.layer.borderWidth = 0.5
    }
    
    func setupCell(reaction:Reaction) {
        videoTitleLbl.text = reaction.reactTitle?.decode() ?? ""
        
        if let owner = reaction.reactionOwner {
            detailView.isHidden = false
            if owner.hasProfileMedia == true {
                
            }
            userNameLbl.text = owner.userName
            likesLbl.text = "\(reaction.likes!)"
            viewsLbl.text = "\(reaction.views!)"
        } else {
            detailView.isHidden = true
        }
    }
    
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        profileTappedBlock!()
    }
    
}


