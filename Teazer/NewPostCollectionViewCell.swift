//
//  NewPostCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 26/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation

class NewPostTableViewCell: UITableViewCell {
    
    typealias ProfileButtonTappedBlock = (Int, Bool) -> Void
    var profileButtonTappedBlock:ProfileButtonTappedBlock?
    
    typealias PostDetailsButtonTappedBlock = (Int) -> Void
    var postDetailsButtonTappedBlock:PostDetailsButtonTappedBlock?
    
    typealias ReactButtonTappedBlock = () -> Void
    var reactButtonTappedBlock:ReactButtonTappedBlock?
    
    @IBOutlet weak var postTitleView: UIView!
    @IBOutlet weak var postImageView: UIView!
    @IBOutlet weak var reactionsView: UIView!
    
    @IBOutlet weak var imageShadowTop: UIImageView!
    @IBOutlet weak var defaultTitleView: UIView!
    @IBOutlet weak var defaultLocationView: UIView!
    @IBOutlet weak var defaultCategoryView: UIView!
    @IBOutlet weak var defaultProfileView: UIView!
    @IBOutlet weak var defaultDetailsView: UIView!
    @IBOutlet weak var defaultNameView: UIView!
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var reactionsCollectionView: UICollectionView!
    
    @IBOutlet weak var viewVideoContainer: UIView!
    @IBOutlet weak var viewTopCategory: UIView!
    @IBOutlet weak var lblPostTitle: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var lblTopCategory: UILabel!
    @IBOutlet weak var lblCategoryCount: UILabel!
    @IBOutlet weak var imageLocation: UIImageView!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var lblPostOwnerName: UILabel!
    @IBOutlet weak var imageShadow: UIImageView!
    @IBOutlet weak var imageLikes: UIImageView!
    @IBOutlet weak var imageViews: UIImageView!
    @IBOutlet weak var imageReactions: UIImageView!
    @IBOutlet weak var lblLikes: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblReactions: UILabel!
    
    @IBOutlet weak var viewColoredReactionBackground: UIView!
    @IBOutlet weak var viewBlackReactionBackground: UIView!
    @IBOutlet weak var btnReaction: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnVolume: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var btnPostOwnerName: UIButton!
    @IBOutlet weak var btnPostDetails: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var btnCategory: UIButton!
    
    var reactionsList = [Reaction]()
    private var areReactionsPresent = false
    private var avPlayer:AVPlayer?
    private var avPlayerItem:AVPlayerItem?
    private var avPlayerLayer: AVPlayerLayer?
    
    private var postId:Int?
    private var postOwnerId:Int?
    private var isMyself:Bool?
    private var canReact:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        defaultTitleView.layer.cornerRadius = 2.0
        defaultLocationView.layer.cornerRadius = 2.0
        defaultCategoryView.layer.cornerRadius = 2.0
        defaultProfileView.layer.cornerRadius = defaultProfileView.bounds.height / 2
        defaultDetailsView.layer.cornerRadius = 2.0
        defaultNameView.layer.cornerRadius = 2.0
        
        imageProfile.layer.cornerRadius = imageProfile.bounds.height / 2
        imageProfile.layer.borderWidth = 0.5
        imageProfile.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
        imageProfile.clipsToBounds = true
        
        videoImageView.clipsToBounds = true
        
        viewTopCategory.layer.borderWidth = 1.0
        viewTopCategory.layer.cornerRadius = 3.0
        
        viewColoredReactionBackground.layer.cornerRadius = viewColoredReactionBackground.bounds.height / 2
        viewBlackReactionBackground.layer.cornerRadius = viewBlackReactionBackground.bounds.height / 2
        
        let separatorView = UIView(frame: CGRect(x: 0, y: self.bounds.height - 0.5, width: self.bounds.width, height: 0.5))
        separatorView.backgroundColor = UIColor(rgba: "#EEEEEE")
        self.addSubview(separatorView)
        imageShadow.applyGradientForBottom()
        imageShadowTop.applyGradientForTop()
        reactionsCollectionView.dataSource = self
        reactionsCollectionView.delegate = self
        btnVolume.isHidden = true
        btnPlay.isHidden = true
        
        videoImageView.image = nil
        imageProfile.image = nil
    }
    
    func setupCell(postDetails:Post) {
        postId = postDetails.postId
        postOwnerId = postDetails.postOwner?.userId
        isMyself = postDetails.canDelete
        canReact = postDetails.canReact
        
        btnPlay.isHidden = AppPreferences.getIsVideoAutoPlay()
        showPostDetails(postDetails: postDetails)
        
        pauseVideo()
        removeVideoPlayer()
    }
    
    func updateReaction(reaction:Reaction) {
        DispatchQueue.main.async {
            self.reactionsList.insert(reaction, at: 0)
            self.reactionsCollectionView.reloadData()
            self.viewColoredReactionBackground.isHidden = true
        }
    }
    
    func getProfileImage(urlStr:String?, post:Post) {
        guard let urlStr = urlStr else {
            return
        }
        
        DispatchQueue.main.async {
            self.imageProfile.image = #imageLiteral(resourceName: "ic_male_default")
        }
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr) { (image) in
            DispatchQueue.main.async { [weak self] in
                self?.imageProfile.image = (image != nil) ? image : #imageLiteral(resourceName: "ic_male_default")
                post.profileImage = image
            }
        }
        
//        if let cachedImage = post.profileImage {
//            DispatchQueue.main.async {
//                self.imageProfile.image = cachedImage
//            }
//        }  else {
//            
//        }
    }
    
    func getVideoImage(urlStr:String?, post:Post) {
        guard let urlStr = urlStr else {
            return
        }
        
        DispatchQueue.main.async {
            self.videoImageView.image = post.postImage
        }
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr) { (image) in
            DispatchQueue.main.async { [weak self] in
                if image != nil {
                    self?.unhideDefaultViews()
                    self?.videoImageView.image = image
                    post.postImage = image
                }
            }
        }

//        if let cachedImage = post.postImage {
//            DispatchQueue.main.async {
//                self.videoImageView.image = cachedImage
//            }
//        } else {
//            DispatchQueue.main.async {
//                self.videoImageView.image = nil
//            }
//            CommonAPIHandler().getDataFromUrl(imageURL: urlStr) { (image) in
//                DispatchQueue.main.async { [weak self] in
//                    if image != nil {
//                        self?.unhideDefaultViews()
//                        self?.videoImageView.image = image
//                        post.postImage = image
//                    }
//                }
//            }
//        }
    }
    
    @IBAction func reactionButtonTapped(_ sender: UIButton) {
        guard postId != nil else {
            return
        }
        
        reactButtonTappedBlock?()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        playVideo()
    }
    
    @IBAction func volumeButtonTapped(_ sender: UIButton) {
        let autoPlay = AppPreferences.getIsAudioAutoPlay()
        AppPreferences.setIsAudioAutoPlay(autoplay: !autoPlay)
        
        if autoPlay {
            let image = UIImage(named: "ic_soundOff")
            btnVolume.setImage(image, for: .normal)
            avPlayer?.volume = 0
        } else {
            let image = UIImage(named: "ic_soundOn")
            btnVolume.setImage(image, for: .normal)
            avPlayer?.volume = 1.0
        }
    }
    
    @IBAction func categoryButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        guard let postOwnerId = postOwnerId, let isMyself = isMyself else {
            return
        }
        
        profileButtonTappedBlock?(postOwnerId, isMyself)
    }
    
    @IBAction func postOwnerNameButtonTapped(_ sender: UIButton) {
        guard let postOwnerId = postOwnerId, let isMyself = isMyself else {
            return
        }
        
        profileButtonTappedBlock?(postOwnerId, isMyself)
    }
    
    @IBAction func postDetailsButtonTapped(_ sender: UIButton) {
        guard let postId = postId else {
            return
        }
        
        postDetailsButtonTappedBlock?(postId)
    }
    
}

extension NewPostTableViewCell {
    
    func setupVideoPlayer(urlStr:String?) {
        DispatchQueue.main.async {
            guard let urlStr = urlStr else {
                return
            }
            
            guard let url = URL(string: urlStr) else {
                return
            }
            
            self.avPlayerItem = AVPlayerItem(url: url)
            self.avPlayer = AVPlayer()
            self.avPlayer?.replaceCurrentItem(with: self.avPlayerItem)
            self.avPlayer?.actionAtItemEnd = .none
            self.avPlayer?.volume = AppPreferences.getIsAudioAutoPlay() ? 1.0 : 0.0
            
            self.avPlayerLayer = AVPlayerLayer(player: self.avPlayer!)
            self.avPlayerLayer?.frame = self.viewVideoContainer.bounds
            self.avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            
            self.viewVideoContainer.layer.insertSublayer(self.avPlayerLayer!, at: 0)
            self.viewVideoContainer.layer.masksToBounds = true
            
            self.avPlayer?.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer?.currentItem)
//            try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        
   }
    
    func removeVideoPlayer() {
        DispatchQueue.main.async {
            NotificationCenter.default.removeObserver(self)
            self.avPlayer?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            self.avPlayerLayer?.removeFromSuperlayer()
            
            self.avPlayerLayer = nil
            self.avPlayer = nil
            self.avPlayerItem = nil
        }
        
    }
    
    func playVideo() {
        DispatchQueue.main.async {
            let image = AppPreferences.getIsAudioAutoPlay() ? UIImage(named: "ic_soundOn") : UIImage(named: "ic_soundOff")
            self.btnVolume.setImage(image, for: .normal)
            self.btnVolume.isHidden = false
            self.btnPlay.isHidden = true
            if self.avPlayer?.rate == 0 {
                self.avPlayer?.play()
            }
        }
    }
    
    func pauseVideo() {
        DispatchQueue.main.async {
            self.btnVolume.isHidden = true
            self.btnPlay.isHidden = false
            self.avPlayer?.pause()
        }
    }
    
    func isVideoAlreadyPlaying() -> Bool {
        if avPlayer == nil {
            return false
        } else {
            return true
        }
        
//        return (avPlayer?.rate != 0)
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        pauseVideo()
        avPlayer?.seek(to: kCMTimeZero)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else {
            return
        }
        
        if key == "timeControlStatus" {
            if let timeControlStatusValue = avPlayer?.timeControlStatus.hashValue {
                switch timeControlStatusValue {
                case 1:
                    DispatchQueue.main.async {
                        self.activityIndicator.startAnimating()
                    }
                    break
                default:
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                    }
                    break
                }
            }
        }
    }
    
}

extension NewPostTableViewCell {
    
    func unhideDefaultViews() {
        DispatchQueue.main.async {
            self.defaultTitleView.isHidden = true
            self.defaultLocationView.isHidden = true
            self.defaultCategoryView.isHidden = true
            self.defaultProfileView.isHidden = true
            self.defaultDetailsView.isHidden = true
            self.defaultNameView.isHidden = true
            
            self.imageShadow.isHidden = false
            self.videoImageView.isHidden = false
            self.imageProfile.isHidden = false
            
            self.imageLikes.isHidden = false
            self.imageViews.isHidden = false
            self.imageReactions.isHidden = false
            self.lblLikes.isHidden = false
            self.lblViews.isHidden = false
            self.lblReactions.isHidden = false
            
            self.btnProfile.isEnabled = true
            self.btnPostOwnerName.isEnabled = true
            self.btnPostDetails.isEnabled = true
            self.btnCategory.isHidden = false
        }
    }
    
    func updateCellDetails(postDetails:Post) {
        showPostDetails(postDetails: postDetails)
    }
    
    func showPostDetails(postDetails:Post) {
        guard let list = postDetails.mediaList, list.count > 0 else {
            return
        }
        
        if let title = postDetails.title {
            lblPostTitle.text = title.decode()
            defaultTitleView.isHidden = true
            lblPostTitle.isHidden = false
        } else {
            lblPostTitle.isHidden = true
        }
        
        if let location = postDetails.checkIn?.location {
            lblLocation.text = location
            defaultLocationView.isHidden = true
            lblLocation.isHidden = false
            imageLocation.isHidden = false
        } else {
            lblLocation.isHidden = true
            imageLocation.isHidden = true
        }
        
        if let categoriesList = postDetails.categories, categoriesList.count > 0 {
            lblTopCategory.text = categoriesList[0].categoryName?.uppercased()
            defaultCategoryView.isHidden = true
            lblTopCategory.isHidden = false
            lblCategoryCount.isHidden = true
            lblTopCategory.textColor = UIColor.white
            lblTopCategory.backgroundColor = UIColor.clear
            viewTopCategory.backgroundColor = UIColor(rgba: categoriesList[0].categoryColorStr!)
            viewTopCategory.layer.borderColor = UIColor(rgba: categoriesList[0].categoryColorStr!).cgColor
            viewTopCategory.isHidden = false
            if categoriesList.count > 1 {
                let count = categoriesList.count - 1
                lblCategoryCount.text = "+\(count) Categories"
                lblCategoryCount.isHidden = false
            }
        } else {
            lblTopCategory.isHidden = true
            lblCategoryCount.isHidden = true
            viewTopCategory.isHidden = true
        }
        
        if let postOwnerName = postDetails.postOwner?.userName {
            lblPostOwnerName.text = postOwnerName
            defaultNameView.isHidden = true
            lblPostOwnerName.isHidden = false
        } else {
            lblPostOwnerName.isHidden = true
        }
        
        if let likesCount = postDetails.likes {
            lblLikes.text = "\(likesCount)"
        } else {
            lblLikes.text = "0"
        }
        
        if let viewsCount = list[0].views {
            lblViews.text = "\(viewsCount)"
        } else {
            lblViews.text = "0"
        }
        
        if let reactionsCount = postDetails.totalReactions {
            lblReactions.text = "\(reactionsCount)"
        } else {
            lblReactions.text = "0"
        }
        
        if self.canReact == true {
            self.viewColoredReactionBackground.isHidden = false
        } else {
            self.viewColoredReactionBackground.isHidden = true
        }
    }
    
    func loadGif(url: String , imageView: UIImageView) {
        let dict = convertToDictionary(text: url)
        if let stillDict = dict!["fixed_height_small_still"] as? [String:Any] {
            if (stillDict["url"] as? String) != nil {
                let imageURL = UIImage.gif(url: (stillDict["url"] as? String)!)
                    DispatchQueue.main.async {
                        let imageView1 = UIImageView(image: imageURL)
                        imageView.addSubview(imageView1)
                    }
                } else {
                 return
            }
        }
}
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

}

extension NewPostTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (reactionsList.count != 0) ? reactionsList.count : 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reactionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewReactionCollectionViewCell", for: indexPath) as! NewReactionCollectionViewCell
        if indexPath.row < reactionsList.count {
            let reaction = reactionsList[indexPath.row]
            reactionCell.setupCell(reation: reaction)
            
            if let reactionImage = AppImageCache.fetchReactionImage(reactionId: reaction.reactId!) {
                reactionCell.imageReaction.image = reactionImage
                reactionCell.showReactionDetails(reaction: reaction)
            } else {
                reactionCell.hideReactionDetails()

                if reaction.mediaDetails?.mediaType == 4 {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.loadGif(url: reaction.mediaDetails!.externalMeta!, imageView: reactionCell.imageReaction)
                    }
                } else if let urlStr = reaction.mediaDetails?.thumbUrl {
                    CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: reaction.reactId!, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                        DispatchQueue.main.async { [weak self] in
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                            reaction.reactionImage = resizedImage
                                
                            if let cell = self?.reactionsCollectionView.cellForItem(at: indexPath) as? NewReactionCollectionViewCell {
                                cell.showReactionDetails(reaction: reaction)
                                cell.imageReaction.image = resizedImage
                            }
                        }
                            AppImageCache.saveReactionImage(image: image, reactionId: key)
                        })
                    } else {
                        DispatchQueue.main.async {
                            reactionCell.imageReaction.image = nil

                        }
                    }
            }
        } else {
            reactionCell.hideReactionDetails()
        }
        
        return reactionCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
    }
}
