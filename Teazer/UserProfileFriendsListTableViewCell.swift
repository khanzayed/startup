//
//  UserProfileFriendsListTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 19/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class UserProfileFriendsListTableViewCell: UITableViewCell {

    typealias SendRequestButtonTappedBlock = (Int, Bool, FollowInfo) -> Void
    var sendRequestButtonTappedBlock:SendRequestButtonTappedBlock!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var fullNameLbl: UILabel!
    
    var userId:Int?
    var followInfo:FollowInfo?
    var isAccountPrivate = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.borderWidth = 2.0
        profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
        profileImageView.layer.borderColor = ColorConstants.kBackgroundGrayColor.cgColor
        requestBtn.layer.cornerRadius = requestBtn.frame.size.height / 2
        requestBtn.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
        requestBtn.clipsToBounds = true
        requestBtn.layer.borderWidth = 1.0
    }
    
    func setupCell(friend:Friend) {
        nameLabel.text = friend.userName
        fullNameLbl.text = (friend.firstName ?? "") + " " + (friend.lastName ?? "")
        isAccountPrivate = (friend.accountType == 1)
        userId = friend.userId
        
        if friend.isMyself == true {
            requestBtn.isHidden = true
        } else {
            updateActionButton(friendId: friend.userId!)
        }
        
    }
    
    func updateActionButton(friendId:Int) {
        guard let info = UserProfileCache.shared.fetchFriendRelation(friendId: friendId)?.followInfo else {
            requestBtn.isHidden = true
            return
        }
        
        followInfo = info
        requestBtn.isHidden = false
        if info.blocked == true {
            requestBtn.setTitle(RelationTypes.kUnblock.rawValue, for: .normal)
            requestBtn.setImage(nil, for: .normal)
            requestBtn.contentEdgeInsets.left = 0
            requestBtn.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            requestBtn.setTitleColor(ColorConstants.kAppGreenColor, for: .normal)
        } else if info.isRequestReceived == true {
            if info.isFollower == true {
                requestBtn.setTitle(RelationTypes.kFollow.rawValue, for: .normal)
                requestBtn.setImage(nil, for: .normal)
                requestBtn.contentEdgeInsets.left = 0
                requestBtn.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
                requestBtn.setTitleColor(ColorConstants.kAppGreenColor, for: .normal)
            } else {
                requestBtn.setTitle(RelationTypes.kAccept.rawValue, for: .normal)
                requestBtn.setImage(nil, for: .normal)
                requestBtn.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
                requestBtn.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
                requestBtn.contentEdgeInsets.left = 0
            }
        } else if info.isRequestSent == true {
            requestBtn.setTitle(RelationTypes.kRequested.rawValue, for: .normal)
            requestBtn.setImage(nil, for: .normal)
            requestBtn.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
            requestBtn.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
            requestBtn.contentEdgeInsets.left = 0
        } else if info.isFollowing == true {
            requestBtn.setTitle(RelationTypes.kFollowing.rawValue, for: .normal)
            requestBtn.setImage(UIImage(named: "ic_select_tick_icon"), for: .normal)
            requestBtn.contentEdgeInsets.left = -11
            requestBtn.layer.borderColor = ColorConstants.kTextBlackColor.cgColor
            requestBtn.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
        } else {
            requestBtn.setTitle(RelationTypes.kFollow.rawValue, for: .normal)
            requestBtn.setImage(nil, for: .normal)
            requestBtn.contentEdgeInsets.left = 0
            requestBtn.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            requestBtn.setTitleColor(ColorConstants.kAppGreenColor, for: .normal)
        }
    }
    
    @IBAction func requestButtonTapped(_ sender: UIButton) {
        guard let userId = userId, let info = followInfo else {
            return
        }
        sendRequestButtonTappedBlock(userId, isAccountPrivate, info)
    }
}
