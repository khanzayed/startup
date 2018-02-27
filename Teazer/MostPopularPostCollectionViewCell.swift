    //
//  MostPopularPostCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class MostPopularPostCollectionViewCell: UICollectionViewCell {
    
    typealias ProfileTappedBlock = (Int,Bool) -> Void
    var profileTappedBlock:ProfileTappedBlock?

    @IBOutlet weak var blankDetailView: UIView!
    @IBOutlet weak var blankProfileView: UIView!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var reactionsLbl: UILabel!
    @IBOutlet weak var firstReactionImageView: UIImageView!
    @IBOutlet weak var secondReactionImageView: UIImageView!
    @IBOutlet weak var thirdReactionImageView: UIImageView!
    @IBOutlet weak var shadowUpImageView: UIImageView!
    @IBOutlet weak var shadowDownImageView: UIImageView!
    
    var userId:Int?
    var isMyself:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let gradient = CAGradientLayer()
        gradient.frame = shadowUpImageView.bounds
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let endColor = UIColor.black.withAlphaComponent(0.7)
        gradient.colors = [endColor.cgColor,startColor.cgColor]
        shadowUpImageView.layer.insertSublayer(gradient, at: 0)
        
        let gradientDown = CAGradientLayer()
        let endColorDown = UIColor.black.withAlphaComponent(0.3)
        gradientDown.frame = shadowDownImageView.bounds
        gradientDown.colors = [startColor.cgColor,endColorDown.cgColor]
        shadowDownImageView.layer.insertSublayer(gradientDown, at: 0)
        
        
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
        profileImageView.layer.borderWidth = 0.5
        firstReactionImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
        firstReactionImageView.layer.borderWidth = 0.5
        secondReactionImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
        secondReactionImageView.layer.borderWidth = 0.5
        thirdReactionImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
        thirdReactionImageView.layer.borderWidth = 0.5
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        firstReactionImageView.layer.cornerRadius = firstReactionImageView.bounds.height / 2
        secondReactionImageView.layer.cornerRadius = secondReactionImageView.bounds.height / 2
        thirdReactionImageView.layer.cornerRadius = thirdReactionImageView.bounds.height / 2
        
        blankProfileView.layer.cornerRadius = blankProfileView.bounds.height / 2
        
        videoImageView.layer.cornerRadius = 4.0
        videoImageView.clipsToBounds = true
        
        videoImageView.contentMode = .scaleAspectFill
        
        self.layer.cornerRadius = 4.0
        self.backgroundColor = UIColor(rgba: "#DDDDDD")
        
        hideVides(value: true)
    }
    
    func hideVides(value:Bool) {
        blankDetailView.isHidden = !value
        topView.isHidden = value
        detailView.isHidden = value
    }
    
    
    func setupCell(post:Post) {
        userId = post.postOwner?.userId
        isMyself = post.canDelete
        
        showPostDetails(post: post)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        guard let userId = userId, let isMyself = isMyself else {
            return
        }
        profileTappedBlock?(userId, isMyself)
    }
}
    
extension MostPopularPostCollectionViewCell {
    
    func showPostDetails(post: Post) {
        guard let list = post.mediaList else {
            return
        }
        
        userNameLbl.text = post.postOwner?.userName ?? ""
        titleLbl.text = post.title?.decode() ?? ""
        durationLbl.text = list[0].duration
        viewsLbl.text = "\(list[0].views!)"
        likesLbl.text = "\(post.likes!)"
        
        if let noOfReactions = post.totalReactions, noOfReactions > 0 {
            if noOfReactions < 4 {
                firstReactionImageView.isHidden = true
                secondReactionImageView.isHidden = true
                thirdReactionImageView.isHidden = true
                reactionsLbl.text = "\(post.totalReactions!) Reactions"
            } else {
                reactionsLbl.text = "+ \(post.totalReactions!) R"
            }
        } else {
            firstReactionImageView.isHidden = true
            secondReactionImageView.isHidden = true
            thirdReactionImageView.isHidden = true
            reactionsLbl.text = ""
        }
    }
}
