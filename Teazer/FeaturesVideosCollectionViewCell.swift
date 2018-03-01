//
//  FeaturesVideosCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class FeaturesVideosCollectionViewCell: UICollectionViewCell {
    
    typealias ProfileTappedBlock = (Int,Bool) -> Void
    var profileTappedBlock:ProfileTappedBlock?
    
    typealias MoreTappedBlock = () -> Void
    var moreTappedBlock:MoreTappedBlock?
    
    typealias HideTappedBlock = () -> Void
    var hideTappedBlock:HideTappedBlock?
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var blankDetailView: UIView!
    @IBOutlet weak var blankProfileImageView: UIView!
    @IBOutlet weak var shadowBottomView: UIImageView!
    @IBOutlet weak var shadowTopView: UIImageView!
    @IBOutlet weak var categoryBackView: UIView!
    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var btnMore: UIButton!
    @IBOutlet weak var viewHide: UIView!
    @IBOutlet weak var lblHide: UILabel!
    @IBOutlet weak var btnUnhide: UIButton!
    
    var userId:Int?
    var isMyself = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        profileImageView.layer.borderWidth = 0.5
        blankProfileImageView.layer.cornerRadius = blankProfileImageView.bounds.height / 2
        
        videoImageView.contentMode = .scaleAspectFill
        self.backgroundColor = UIColor(rgba: "#DDDDDD")
        hideVides(value: true)
        
        if categoryNameLbl != nil {
            categoryNameLbl.textColor = UIColor(rgba: "#FFFFFF")
            categoryNameLbl.text = categoryNameLbl.text?.uppercased()
            categoryBackView.layer.borderColor = UIColor(rgba: "#F48FB1").cgColor
            categoryBackView.layer.borderWidth = 0.5
            categoryBackView.layer.cornerRadius = 2.0
        }
        
        if viewHide != nil {
            lblHide.layer.borderWidth = 1.0
            lblHide.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            lblHide.layer.cornerRadius = 4.0
        }
    }
    
    func hideVides(value:Bool) {
        DispatchQueue.main.async {
            self.blankDetailView.isHidden = !value
            self.detailView.isHidden = value
            self.shadowTopView.isHidden = value
            self.shadowBottomView.isHidden = value
            self.titleLbl.isHidden = value
            if self.categoryNameLbl != nil {
                self.categoryBackView.isHidden = value
            }
        }
    }
    
    func setupCell(post:Post) {
        userId = post.postOwner?.userId
        if let value = post.canDelete {
            isMyself = value
        }
        
        showPostDetails(post: post)
    }
    
    @IBAction func ProfileButtonTapped(_ sender: UIButton) {
        guard let userId = userId else {
            return
        }
        
        profileTappedBlock?(userId, isMyself)
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        moreTappedBlock?()
    }
    
    @IBAction func unhideButtonTapped(_ sender: UIButton) {
        hideTappedBlock?()
    }
    
}

extension FeaturesVideosCollectionViewCell {
    
    func showPostDetails(post: Post) {
        guard let list = post.mediaList else {
            return
        }
        hideVides(value: false)
        if let categoriesList = post.categories, categoriesList.count > 0, categoryNameLbl != nil {
            categoryNameLbl.text = categoriesList[0].categoryName
            categoryNameLbl.text = categoryNameLbl.text?.uppercased()
            if let colorStr = categoriesList[0].categoryColorStr {
                categoryNameLbl.textColor = UIColor(rgba: colorStr)
                categoryBackView.layer.borderColor = UIColor(rgba: colorStr).cgColor
            }
        }
        userNameLbl.text = post.postOwner?.userName ?? ""
        titleLbl.text = post.title?.decode() ?? ""
        viewsLbl.text = "\(list[0].views!)"
        likesLbl.text = "\(post.likes!)"
        
        if viewHide != nil {
            viewHide.isHidden = !post.isHidden
        }
    }
    
    func showReactionOwnerName(userName:String?) {
        userNameLbl.text = userName ?? ""
    }
    
    
    func showReactionDetails(reaction:Reaction) {
        guard let _ = reaction.mediaDetails else {
            return
        }
        hideVides(value: false)
        titleLbl.text = reaction.reactTitle?.decode() ?? ""
        viewsLbl.text = "\(reaction.views!)"
        likesLbl.text = "\(reaction.likes!)"
        
        if viewHide != nil {
            viewHide.isHidden = true
        }

    }
}
