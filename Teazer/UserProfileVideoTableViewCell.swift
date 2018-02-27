//
//  UserProfileVideoTableViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 05/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class UserProfileVideoTableViewCell: UITableViewCell {
    
    typealias DeleteVideoTappedBlock =  () -> Void
    var deleteVideoTappedBlock : DeleteVideoTappedBlock?
    
    typealias EditPostViewBlock =  () -> Void
    var editPostViewBlock : EditPostViewBlock?
    
    typealias ReportPostBlock = () -> Void
    var reportPostBlock : ReportPostBlock?
    
    typealias MoreButtonBlock = () -> Void
    var moreButtonBlock : MoreButtonBlock?

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var reactionsLabel: UILabel!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var deleteView: UIView!
    @IBOutlet weak var deleteOptionBtn: UIButton!
    @IBOutlet weak var detailsTopView: UIView!
    @IBOutlet weak var detailsBottomView: UIView!
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var reactedLabel: UILabel!
    @IBOutlet weak var postOwnerName: UILabel!
    @IBOutlet weak var deleteViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteViewForReaction: UIView!
    @IBOutlet weak var deleteOptionImage: UIImageView!
    @IBOutlet weak var reportViewOfOtherProfile: UIView!
    @IBOutlet weak var shadowUpImageView: UIImageView!
    
    var post = Post()
    var reaction =  Reaction()
    var isCreation = true
    var canDelete = false
    
    override func awakeFromNib() {
        
        deleteView.isHidden = true
        deleteView.alpha = 0
        deleteView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
    }
    
    func setupCellforPost(post:Post) {
        
        reportViewOfOtherProfile.isHidden = true
        deleteView.isHidden = true
        deleteViewForReaction.isHidden = true
        isCreation = true
        imageView1.isHidden = false
        imageView2.isHidden = false
        imageView3.isHidden = false
        reactionsLabel.isHidden = false
        locationImageView.isHidden = false
        canDelete = post.canDelete!
        reactedLabel.isHidden = true
        postOwnerName.isHidden = true
        locationLabel.isHidden = false
        

        guard let list = post.mediaList else {
            return
         }
        
        setupProfileImageviews(imageview: imageView1)
        setupProfileImageviews(imageview: imageView2)
        setupProfileImageviews(imageview: imageView3)
        
        titleLabel.text = post.title?.decode() ?? " "
        durationLabel.text = list[0].duration
        
        if post.hasCheckedIn! {
            locationLabel.text = post.checkIn!.location
        } else {
            locationLabel.isHidden = true
            locationImageView.isHidden = true
        }
        
        guard let noOflike = post.likes else {
            return
        }
        likesLabel.text = "\(noOflike)"
        
        guard let noOfViews =  list[0].views else {
            return
        }
        viewsLabel.text = "\(noOfViews)"
        
        guard let noOfReactions = post.totalReactions else {
            imageView1.isHidden = true
            imageView2.isHidden = true
            imageView3.isHidden = true
            reactionsLabel.text = "0 Reactions"
            
            return
        }
        if noOfReactions < 1 {
            imageView1.isHidden = true
            imageView2.isHidden = true
            imageView3.isHidden = true
            reactionsLabel.isHidden = true
        }else if noOfReactions < 4 {
            reactionsLabel.isHidden = false
            imageView1.isHidden = true
            imageView2.isHidden = true
            imageView3.isHidden = true
            reactionsLabel.text = (noOfReactions == 1) ? "\(noOfReactions) Reaction" :  "\(noOfReactions) Reaction"
        } else {
            reactionsLabel.isHidden = false
            imageView1.isHidden = false
            imageView2.isHidden = false
            imageView3.isHidden = false
            reactionsLabel.text = "+ \(noOfReactions) R"
        }

    }
    
    func setupCellforReaction(reaction:Reaction) {
        deleteViewForReaction.isHidden = true
        reportViewOfOtherProfile.isHidden = true
        deleteView.isHidden = true
        isCreation = false
        imageView1.isHidden = true
        imageView2.isHidden = true
        imageView3.isHidden = true
        reactionsLabel.isHidden = true
        locationImageView.isHidden = true
        reactedLabel.isHidden = false
        canDelete = reaction.canDelete!
        postOwnerName.isHidden = false
        locationLabel.isHidden = true
        
        guard let list = reaction.mediaDetails else {
            return
        }
        durationLabel.text = list.duration
        titleLabel.text = reaction.reactTitle?.decode() ?? " "
        
        guard let noOflike = reaction.likes else {
            return
        }
        likesLabel.text = "\(noOflike)"
        
        
        guard let noOfViews =  reaction.views else {
            return
        }
        viewsLabel.text = "\(noOfViews)"
        

        guard let reactedToUser =  reaction.postOwner?.userName! else {
            return
        }
        postOwnerName.text = "\(reactedToUser)"
    }
    
    
    func setupProfileImageviews(imageview: UIImageView){
        imageview.clipsToBounds = true
        imageview.layer.cornerRadius = imageview.bounds.height / 2
        imageview.layer.borderWidth = 1.0
        imageview.layer.borderColor = UIColor.white.cgColor
    }
  
    @IBAction func dotsButtonTapped(_ sender: Any) {

        if isCreation && canDelete {
            moreButtonBlock!()
            
        } else if !isCreation && canDelete {
            deleteVideoTappedBlock!()
            
        }
        if canDelete == false {
            reportPostBlock!()

        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
 
    }
    
    @IBAction func editPostButtonTapped(_ sender: Any) {
   
    }
    @IBAction func deleteButtonReactionTapped(_ sender: Any) {

    }
    
    @IBAction func reportPostBUttonTapped(_ sender: UIButton) {
   
    }

}
