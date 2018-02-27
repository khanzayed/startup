
//
//  InterestsCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 25/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class InterestsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var blankImageView: UIView!
    @IBOutlet weak var blankProfileImageView: UIView!
    @IBOutlet weak var strip1View: UIView!
    @IBOutlet weak var strip2View: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var reactionsLbl: UILabel!
    @IBOutlet weak var firstReactionImageView: UIImageView!
    @IBOutlet weak var secondReactionImageView: UIImageView!
    @IBOutlet weak var thirdReactionImageView: UIImageView!
    
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!
    
    var reactedUserImage = UIImage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        videoImageView.layer.cornerRadius = 5.0
        videoImageView.clipsToBounds = true
        
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        firstReactionImageView.layer.cornerRadius = firstReactionImageView.bounds.height / 2
        secondReactionImageView.layer.cornerRadius = secondReactionImageView.bounds.height / 2
        thirdReactionImageView.layer.cornerRadius = thirdReactionImageView.bounds.height / 2
        
        profileImageView.clipsToBounds = true
        
        blankImageView.layer.cornerRadius = 5.0
        blankProfileImageView.layer.cornerRadius = blankProfileImageView.bounds.height / 2
        
        videoImageView.contentMode = .scaleAspectFill
        
        hideVides(value: true)
    }
    
    func hideVides(value:Bool) {
        DispatchQueue.main.async {
            self.blankImageView.isHidden = !value
            self.blankProfileImageView.isHidden = !value
            self.strip1View.isHidden = !value
            self.strip2View.isHidden = !value
            
            self.titleLbl.isHidden = value
            self.userNameLbl.isHidden = value
            self.likesLbl.isHidden = value
            self.viewsLbl.isHidden = value
            self.reactionsLbl.isHidden = value
            self.firstReactionImageView.isHidden = value
            self.secondReactionImageView.isHidden = value
            self.profileImageView.isHidden = value
            self.thirdReactionImageView.isHidden = value
            self.likesImageView.isHidden = value
            self.viewsImageView.isHidden = value
        }
    }
    
    func getProfileImage(_ reactedUser: ReactedUser, imageView:UIImageView) {
        if let profileImage = AppImageCache.fetchOthersProfileImage(userId: reactedUser.userdId!) {
            imageView.image = profileImage
        } else {
            imageView.image = nil
        }
        
        if let urlStr = reactedUser.profileMedia?.thumbUrl {
            CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: reactedUser.userdId!, completion: { (image, key) in
                DispatchQueue.main.async { [weak self] in
                    if self == nil {
                        return
                    }
                    let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                    imageView.image = resizedImage
                    AppImageCache.savePostImage(image: resizedImage, postId: key)
                }
            })
        }
    }
    
    func setupCell(post: Post) {
        showPostDetails(post: post)
    }
    
}


extension InterestsCollectionViewCell {
    
    func showPostDetails(post: Post) {
        guard let list = post.mediaList else {
            return
        }
        reactionsLbl.text = ""
        userNameLbl.text = post.postOwner?.userName ?? ""
        titleLbl.text = post.title?.decode() ?? ""
        viewsLbl.text = "\(list[0].views!)"
        likesLbl.text = "\(post.likes!)"
        
        if let noOfReactions = post.totalReactions, let reactedUsers = post.reactedUsers, noOfReactions > 0, reactedUsers.count > 0 {
            getProfileImage(reactedUsers[0], imageView: firstReactionImageView)
            if reactedUsers.count > 1 {
                getProfileImage(reactedUsers[1], imageView: secondReactionImageView)
            }
            if reactedUsers.count > 2 {
                getProfileImage(reactedUsers[2], imageView: thirdReactionImageView)
            }
            if reactedUsers.count > 3 {
                reactionsLbl.text = "+\(reactedUsers.count - 3) reactions"
            }
        } else {
            firstReactionImageView.isHidden = true
            secondReactionImageView.isHidden = true
            thirdReactionImageView.isHidden = true
            reactionsLbl.text = ""
        }
    }
    
}
