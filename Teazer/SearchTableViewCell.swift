//
//  SearchTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    typealias SendRequestButtonTappedBlock = (Int, Bool, FollowInfo) -> Void
    var sendRequestButtonTappedBlock:SendRequestButtonTappedBlock!
    
    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var trendingLbl: UILabel!
    @IBOutlet weak var subImageView: UIImageView!
    @IBOutlet weak var followingView: UIView!
    @IBOutlet weak var followView: UIView!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var icSelectTick: UIImageView!
    @IBOutlet weak var trendingImageView: UIImageView!
    
    var userId:Int?
    var followInfo:FollowInfo?
    var isAccountPrivate = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        icSelectTick.tintColor = ColorConstants.kTextBlackColor
        followingView.layer.cornerRadius = followingView.bounds.height / 2
        followingView.layer.borderColor = UIColor(rgba: "#333333").cgColor
        followingView.layer.borderWidth = 1.0
        
        followView.layer.cornerRadius = followView.bounds.height / 2
        followView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
        followView.layer.borderWidth = 1.0
        
        followLbl.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func arrangeViewForPeopleSearch() {
        cellImageView.layer.cornerRadius = cellImageView.bounds.height / 2
        cellImageView.clipsToBounds = true
        
        followView.isHidden = false
        followingView.isHidden = false
        userNameLbl.isHidden = false
        fullNameLbl.isHidden = false
        
        titleLbl.isHidden = true
        subImageView.isHidden = true
    }
    
    func arrangeViewForVideoSearch() {
        cellImageView.layer.cornerRadius = 3.0
        cellImageView.clipsToBounds = true
        
        followView.isHidden = true
        followingView.isHidden = true
        userNameLbl.isHidden = true
        fullNameLbl.isHidden = true
        
        trendingImageView.isHidden = false
        titleLbl.isHidden = false
        subImageView.isHidden = false
        trendingImageView.image = #imageLiteral(resourceName: "ic_trending")
    }
    
    func setupCell(withPost:Post, isFirstCell:Bool) {
        trendingLbl.text = "TRENDING"
        trendingLbl.isHidden = !isFirstCell
        
        arrangeViewForVideoSearch()
        guard let list = withPost.mediaList else {
            return
        }
        
        if let urlStr = list[0].thumbUrl {
            CommonAPIHandler().getDataFromUrl(imageURL: urlStr, completion: { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.cellImageView.image = image
                }
            })
        } else {
            DispatchQueue.main.async {
                self.cellImageView.image = nil
            }
        }
        titleLbl.text = withPost.title?.decode()
    }
    
    func setupCell(withUser:Friend, isFirstCell:Bool) {
        isAccountPrivate = (withUser.accountType == 1)
        userId = withUser.userId
        
        trendingLbl.text = "RECENT SEARCHES"
        trendingImageView.image = #imageLiteral(resourceName: "ic_recent")
        trendingLbl.isHidden = !isFirstCell
        arrangeViewForPeopleSearch()
        
        userNameLbl.text = withUser.userName
        fullNameLbl.text = (withUser.firstName ?? "") + " " + (withUser.lastName ?? "")
        
        if withUser.isMyself == true {
            followingView.isHidden = true
            followView.isHidden = true
        } else {
            updateActionButton(friendId: withUser.userId!)
        }
    }
    
    func updateActionButton(friendId:Int) {
        guard let info = UserProfileCache.shared.fetchFriendRelation(friendId: friendId)?.followInfo else {
            followingView.isHidden = true
            followView.isHidden = true
            return
        }
        
        followInfo = info
        if info.blocked == true {
            trendingImageView.isHidden = true
            followingView.isHidden = true
            followView.isHidden = false
            followBtn.isEnabled = true
            followLbl.text = RelationTypes.kUnblock.rawValue
        } else if info.isRequestReceived == true {
            if info.isFollower == true { 
                trendingImageView.isHidden = true
                followingView.isHidden = true
                followView.isHidden = false
                followBtn.isEnabled = true
                followLbl.text = RelationTypes.kFollow.rawValue
            } else {
                trendingImageView.isHidden = true
                followingView.isHidden = true
                followView.isHidden = false
                followBtn.isEnabled = true
                followLbl.text = RelationTypes.kAccept.rawValue
            }
        } else if info.isRequestSent == true {
            trendingImageView.isHidden = true
            followingView.isHidden = true
            followView.isHidden = false
            followBtn.isEnabled = true
            followLbl.text = RelationTypes.kRequested.rawValue
        } else if info.isFollowing == true {
            trendingImageView.isHidden = true
            followingView.isHidden = false
            followView.isHidden = true
            followingBtn.isEnabled = true
        } else {
            trendingImageView.isHidden = true
            followingView.isHidden = true
            followView.isHidden = false
            followBtn.isEnabled = true
            followLbl.text = RelationTypes.kFollow.rawValue
        }
    }

    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let userId = userId, let info = followInfo else {
            return
        }
        sendRequestButtonTappedBlock(userId, isAccountPrivate, info)
    }
    
    @IBAction func followingButtonTapped(_ sender: UIButton) {
        guard let userId = userId, let info = followInfo else {
            return
        }
        sendRequestButtonTappedBlock(userId, isAccountPrivate, info)
    }
    
}
