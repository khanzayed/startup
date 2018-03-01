//
//  NewReactionCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 26/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class NewReactionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var defaultImageView: UIView!
    @IBOutlet weak var defaultTitleView: UIView!
    @IBOutlet weak var imageReaction: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        defaultTitleView.layer.cornerRadius = 2.0
        defaultImageView.layer.cornerRadius = 2.0
        
        imageReaction.layer.cornerRadius = 2.0
        imageReaction.image = nil
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        lblTitle.text = ""
        imageReaction.image = nil
        
    }
    
    func setupCell(reation:Reaction) {
        guard let thumbnailUrl = reation.mediaDetails?.thumbUrl else {
            hideReactionDetails()
            return
        }
        showReactionDetails(reaction: reation)
//        getVideoImage(urlStr: thumbnailUrl, reaction: reation)
    }
    
    func getVideoImage(urlStr:String?, reaction:Reaction) {
        guard let urlStr = urlStr else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageReaction.image = reaction.reactionImage
        }
        
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr) { (image) in
            DispatchQueue.main.async { [weak self] in
                self?.showReactionDetails(reaction: reaction)
                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                self?.imageReaction.image = resizedImage
                reaction.reactionImage = resizedImage
            }
        }
    }
    
    func hideReactionDetails() {
        DispatchQueue.main.async {
            self.defaultImageView.isHidden = false
            self.defaultTitleView.isHidden = false
            self.imageReaction.isHidden = true
            self.lblTitle.isHidden = true
        }
    }
    
    func showReactionDetails(reaction: Reaction) {
        DispatchQueue.main.async {
            self.defaultImageView.isHidden = true
            self.defaultTitleView.isHidden = true
            
            self.imageReaction.isHidden = false
            self.lblTitle.isHidden = false
            
            self.lblTitle.text = reaction.reactTitle?.decode()
        }
    }
    
}
