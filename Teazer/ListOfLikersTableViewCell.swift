//
//  ListOfLikersTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 29/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ListOfLikersTableViewCell: UITableViewCell {
    
    typealias FollowButtonTappedBlock = (Bool,Bool) -> Void
    var followButtonTappedBlock:FollowButtonTappedBlock?

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingButtonView: UIView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var followButtonView: UIView!
    @IBOutlet weak var followButtonLbl: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!
    
    var isFollowing = false
    var isRequestSent = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor(rgba: "#DDDDDD").cgColor
        followButtonView.layer.cornerRadius = followButtonView.frame.size.height/2
        followingButtonView.layer.cornerRadius = followingButtonView.frame.size.height/2
        followButtonView.layer.borderWidth = 1
        followButtonView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
        followingButtonView.layer.borderWidth = 1
        followingButtonView.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
        tickImageView.tintColor = ColorConstants.kTextBlackColor

    }
    
    func setUpCell(friend:Friend,imageKey:String) {
        isFollowing = friend.followInfo!.isFollowing!
        isRequestSent = friend.followInfo!.isRequestSent!
        
        userNameLbl.text = friend.userName
        fullNameLbl.text = (friend.firstName ?? "") + " " + (friend.lastName ?? "")
        
        if friend.followInfo!.isFollowing! {
            followButtonView.isHidden = true
            followingButtonView.isHidden = false
        } else if friend.followInfo!.isRequestReceived! {
            followButtonView.isHidden = false
            followingButtonView.isHidden = true
            followButtonView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            followButtonLbl.textColor = ColorConstants.kAppGreenColor
            followButtonLbl.text = "Accept"
        } else if friend.followInfo!.blocked! {
            followButtonView.isHidden = false
            followingButtonView.isHidden = true
            followButtonView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            followButtonLbl.textColor = ColorConstants.kAppGreenColor
            followButtonLbl.text = "Blocked"
        } else if friend.followInfo!.isRequestSent == true && friend.followInfo!.isFollowing == false {
            followButtonView.isHidden = false
            followingButtonView.isHidden = true
            followButtonView.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
            followButtonLbl.textColor = ColorConstants.kTextBlackColor
            followButtonLbl.text = "Requested"
        } else if friend.isMyself == true {
            followButtonView.isHidden = true
            followingButtonView.isHidden = true
        } else {
            followButtonView.isHidden = false
            followingButtonView.isHidden = true
            followButtonView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            followButtonLbl.textColor = ColorConstants.kAppGreenColor
            followButtonLbl.text = "Follow"
        }
    }
    
    @IBAction func followBtnTapped(_ sender: UIButton) {
        followButtonTappedBlock!(isFollowing,isRequestSent)
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
