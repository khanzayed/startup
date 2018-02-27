//
//  NotificationsTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 06/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {
  
    typealias AcceptButtonTappedBlock = () -> Void
    var acceptButtonTappedBlock:AcceptButtonTappedBlock?
    
    typealias ProfileImageButtonTapped = () -> Void
    var profileImageButtonTapped:ProfileImageButtonTapped?
    
    typealias FollowButtonTappedBlock = () -> Void
    var followButtonTappedBlock:FollowButtonTappedBlock?
    
    typealias UnFollowButtonTappedBlock = () -> Void
    var unFollowButtonTappedBlock:UnFollowButtonTappedBlock?
    
    typealias CancelJoinRequestButtonTappedBlock = () -> Void
    var cancelJoinRequestButtonTappedBlock:CancelJoinRequestButtonTappedBlock?
  
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var reactBtn: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var buttonViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageView: UIImageView!
    
    weak var navigationController: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.layer.borderWidth = 1
        profileImageView.layer.borderColor = UIColor(rgba: "#DDDDDD").cgColor
        reactBtn.layer.cornerRadius = reactBtn.frame.size.height/2
        reactBtn.titleLabel?.font = UIFont(name:"ProximaNova-Regular", size: 14)
        reactBtn.layer.borderWidth = 1
        reactBtn.layer.borderColor = UIColor(rgba: "#26C6DA").cgColor
        reactBtn.setTitleColor(UIColor(rgba: "#26C6DA"), for: .normal)
        reactBtn.setImage(nil, for: .normal)
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reactBtn.isHidden = true
        postImageView.isHidden = true
    }

    @IBAction func acceptBtnTapped(_ sender: Any) {
        if reactBtn.titleLabel?.text == "Follow" {
            followButtonTappedBlock!()
           
        } else if reactBtn.titleLabel?.text == "Accept" {
            acceptButtonTappedBlock!()
            
        }else if reactBtn.titleLabel?.text == "Following" {
            
            let alert = UIAlertController(title: "Unfollow", message: "Do you want to unfollow this user?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: { (action) in
                self.unFollowButtonTappedBlock!()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.navigationController?.present(alert, animated: false, completion: nil)

        }else if reactBtn.titleLabel?.text == "Requested" {
            let alert = UIAlertController(title: "Request", message: "Do you want to cancel the follow request ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                self.cancelJoinRequestButtonTappedBlock!()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.navigationController?.present(alert, animated: false, completion: nil)
            
        }
    }
    @IBAction func profileImageBtnTapped(_ sender: Any) {
        profileImageButtonTapped?()
    }
    
    func setUpCell() {
        self.reactBtn.layer.borderColor = UIColor(rgba: "#26C6DA").cgColor
        self.reactBtn.setTitleColor(UIColor(rgba: "#26C6DA"), for: .normal)
        reactBtn.setImage(nil, for: .normal)
        postImageView.isHidden = true
        reactBtn.isHidden = true
        profileImageView.isHidden = true
        messageLbl.isHidden = true
        postImageView.layer.cornerRadius  = 2
        
    }
    
    func boldTheUsername(_ message: String,_ highlights:[String]){
        let attributedString = NSMutableAttributedString(string: message.decode()!)
        let boldFontAttribute = [NSAttributedStringKey.font: UIFont(name: Constants.kProximaNovaSemibold, size: 14.0)!]
        attributedString.addAttributes(boldFontAttribute, range: (message as NSString).range(of: highlights[0]))
        messageLbl.attributedText = attributedString
        
    }
    
    func acceptButttonView() {
        DispatchQueue.main.async {
            self.reactBtn.isHidden = false
            self.reactBtn.setTitle("Accept", for: .normal)
            self.reactBtn.contentEdgeInsets.left = 0
            self.layoutIfNeeded()
        }
    }
    
    func requestedButtonView() {
        DispatchQueue.main.async {
            self.reactBtn.isHidden = false
            self.reactBtn.setTitle("Requested", for: .normal)
            self.reactBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            self.reactBtn.layer.borderColor = UIColor(rgba: "#666666").cgColor
            self.reactBtn.contentEdgeInsets.left = 0
            self.layoutIfNeeded()
        }
    }
    
    func followButtonView() {
        
        DispatchQueue.main.async {
            self.reactBtn.isHidden = false
            self.reactBtn.layer.borderColor = UIColor(rgba: "#26C6DA").cgColor
            self.reactBtn.setTitleColor(UIColor(rgba: "#26C6DA"), for: .normal)
            self.reactBtn.setImage(nil, for: .normal)
            self.reactBtn.setTitle("Follow", for: .normal)
            self.reactBtn.contentEdgeInsets.left = 0
            self.layoutIfNeeded()
        }
    }
    
    func followingButtonView() {
        
        DispatchQueue.main.async {
            self.reactBtn.isHidden = false
            self.reactBtn.layer.borderColor = UIColor(rgba: "#333333").cgColor
            self.reactBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            self.reactBtn.setTitle("Following", for: .normal)
            self.reactBtn.setImage(#imageLiteral(resourceName: "ic_select_tick_icon"), for: .normal)
            self.reactBtn.contentEdgeInsets.left = -11
            self.layoutIfNeeded()
        }
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
