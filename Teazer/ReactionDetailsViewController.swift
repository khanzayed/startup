//
//  ReactionDetailsViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 20/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ReactionDetailsViewController: UIViewController {

    typealias UpdateReactionBlock = (Int?, Int?) -> Void
    var updateReactionBlock: UpdateReactionBlock?
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var likedImageView: UIImageView!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var videoActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var videoPreviewHeightConstraint: NSLayoutConstraint! // 667
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var shareImageView: UIImageView!
    
    @IBOutlet weak var shadowUpImageView: UIImageView!
    
    var reactionId:Int?
    var reaction: Reaction!
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var heightOfVideoCell:CGFloat = 411.0
    var timeObserver:Any?
    var canDeletePost = false
    var userProfile: UserProfileDataModal?
    var myReaction = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlayingVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if reactionId != nil {
            fetchReactionDetailsFromReactionId(reactionId!)
        } else {
            setupView()
            setupDetail()
            setupVideoPlayer()
            increaseViewsForReaction()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        
        let gradient = CAGradientLayer()
        gradient.frame = shadowUpImageView.bounds
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let endColor = UIColor.black
        gradient.colors = [endColor.cgColor,startColor.cgColor]
        shadowUpImageView.layer.insertSublayer(gradient, at: 0)
        
        profileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        profileImageView.layer.borderWidth = 0.5
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        
        
        if var height = reaction.mediaDetails?.height {
            if height > (UIScreen.main.bounds.height - 100.0) {
                height = UIScreen.main.bounds.height
            } else if height < Constants.minVideoHeight {
                height = Constants.minVideoHeight
            }
            videoPreviewHeightConstraint.constant = height
            view.layoutIfNeeded()
        }
        
    }
    
    func setupDetail() {
        guard let media = reaction.mediaDetails else {
            return
        }
        likedImageView.image = (reaction.canLike == false) ? UIImage(named: "ic_liked") : UIImage(named: "ic_like_blank")
        
        videoTitleLbl.text = reaction.reactTitle?.decode() ?? ""
        timerLbl.text = media.duration!
        viewsLbl.text = "\(reaction.views!)"
        likesLbl.text = "\(reaction.likes!)"
        
        userNameLbl.text = reaction.reactionOwner?.userName ?? ""
        
        if reaction.mediaDetails?.mediaType == 4 {
            DispatchQueue.global(qos: .background).async {
                self.loadGif(url: self.reaction.mediaDetails!.externalMeta!, imageView: self.backgroundImageView)
            }
        } else {
            if let imageURL = reaction.media?.thumbUrl {
                setupThumbnail(urlStr: imageURL)
            }
        }
        if let profileImageURL = reaction.reactionOwner?.profileMedia?.thumbUrl {
            setupProfileThumbnail(urlStr: profileImageURL)
        } else if myReaction {
            if let profileImageURL = userProfile?.user?.profileMedia?.thumbUrl {
                setupProfileThumbnail(urlStr: profileImageURL)
            }
        }
    }
    
    func setupVideoPlayer() {
        guard let urlStr = reaction.mediaDetails?.mediaUrl else {
            return
        }
        DispatchQueue.global().async {
            guard let videoURL = URL(string: urlStr) else {
                //debugPrint("URL not found")
                self.view.makeToast("URL not found")
                return
            }
            
            self.playerLayer?.removeFromSuperlayer()
            self.player = nil
            self.playerItem = nil
            
            self.playerItem = AVPlayerItem(url: videoURL)
            self.playerItem!.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
            self.playerItem!.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
            self.playerItem!.addObserver(self, forKeyPath: "playbackBufferFull", options: .new, context: nil)
//            self.playerItem!.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: self.playerItem!)
                self.player!.actionAtItemEnd = .none
                
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.playerLayer?.frame = self.previewView.bounds
                self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                
                self.previewView.layer.addSublayer(self.playerLayer!)
                
                self.player!.volume = 1
                self.player?.isMuted = false
                self.player?.play()
                self.timerLbl.isHidden = false
                
                let interval = CMTime(value: 1, timescale: 1)
                self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] (progressTime) in
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        let finalDuration = CMTimeGetSeconds(strongSelf.playerItem!.duration)
                        let count = CMTimeGetSeconds(strongSelf.playerItem!.currentTime())
                        
                        if !finalDuration.isNaN && !count.isNaN {
                            let reverseCount = Int(finalDuration) - Int(count)
                            if reverseCount > 9 {
                                strongSelf.timerLbl.text = "- 00:\(reverseCount)"
                            } else if reverseCount > 0 {
                                strongSelf.timerLbl.text = "- 00:0\(reverseCount)"
                            } else {
                                strongSelf.timerLbl.text = "00:00"
                            }
                        }
                    }
                })
            }
        }
    }
    
    @objc func finishedPlayingVideo() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object is AVPlayerItem {
            switch keyPath! {
            case "playbackLikelyToKeepUp", "playbackBufferFull":
                DispatchQueue.main.async {
                    self.detailView.isHidden = false
                    self.videoActivityIndicator.stopAnimating()
                }
                break
            default:
                break
            }
        }
    }
    
    
    @IBAction func likeButtonTapped(sender:UIButton) {
        (reaction.canLike == true) ? likeTheReaction() : dislikeTheReaction()
    }
    
    @IBAction func closeButtonTapped(sender:UIButton) {
        removeVideoPlayer()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped(sender:UIButton) {
//        (player?.rate == 0) ? fireTimer() : timerPlayer.invalidate()
        (player?.rate == 0) ? player?.play() : player?.pause()
    }
    
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let reactionID = reaction?.reactId else {
            return
        }
        
        let params:[String:String] = [
            Constants.kDeepLinkReactionIdKey  :   "\(reactionID)"
        ]
        
        let branch = BranchDeepLink(title: "Teazer App", description: "To know more about me follow me on Teazer", imageUrl: reaction.profileMedia?.thumbUrl, channel: "Social")
        branch.createDeepLinks(params: params, viewController: self)
        
    }
    
    
}
extension ReactionDetailsViewController {
    
    func removeVideoPlayer() {
        NotificationCenter.default.removeObserver(self)
        
        self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
        self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferFull")
        
        if timeObserver != nil {
            self.player?.removeTimeObserver(timeObserver!)
        }
        
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
    }
    
    func getFormatedTime(fromTime timeDuration:Int) -> String {
        let minutes = timeDuration / 60 % 60
        let seconds = timeDuration % 60
        let strDuration = String(format:"%02d:%02d", minutes, seconds)
        return strDuration
    }
    
    func updateViewsForReaction() {
        DispatchQueue.main.async {
            var currentViews = Int(self.viewsLbl.text!)!
            currentViews += 1
            self.viewsLbl.text = "\(currentViews)"
        }
    }
    
    func updateLikesForReaction(isIncreased:Bool) {
        DispatchQueue.main.async {
            var currentLikes = Int(self.likesLbl.text!)!
            currentLikes = (isIncreased) ? currentLikes + 1 : currentLikes - 1
            self.likesLbl.text = "\(currentLikes)"
            self.likedImageView.image = (isIncreased) ? UIImage(named: "ic_liked") : UIImage(named: "ic_like_blank")
        }
    }
    
    func setupThumbnail(urlStr: String) {
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr, completion: { [weak self] (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self?.backgroundImageView.image = image
                }
            }
        })
    }
    
    func setupProfileThumbnail(urlStr: String) {
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr, completion: { [weak self] (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self?.profileImageView.image = image
                }
            }
        })
    }
    
    func increaseViewsForReaction() {
        if reaction.isMyReaction == true {
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let mediaId = reaction.mediaDetails?.mediaId else {
            return
        }
        updateViewsForReaction()
        HomeControllerAPIHandler().increaseViewsForReaction(mediaId) { [weak self] (responseData) in
            if let status = responseData.status {
                if status {
                    self?.updateReactionBlock?(1, nil)
                    return
                }
            }
            self?.view.makeToast("Reaction views update failed")
        }
    }
    
    func likeTheReaction() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let mediaId = reaction.mediaDetails?.mediaId else {
            return
        }
        updateLikesForReaction(isIncreased: true)
        likeBtn.isUserInteractionEnabled = false
        HomeControllerAPIHandler().likeAReaction(mediaId) { [weak self] (responseData) in
            if let status = responseData.status {
                if status {
                    self?.reaction.canLike = false
                    self?.updateReactionBlock?(nil, 1)
                    self?.likeBtn.isUserInteractionEnabled = true
                    return
                }
            }
            self?.view.makeToast(responseData.message)
        }
        
    }
    
    func dislikeTheReaction() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let mediaId = reaction.mediaDetails?.mediaId else {
            return
        }
        updateLikesForReaction(isIncreased: false)
        likeBtn.isUserInteractionEnabled = false
        HomeControllerAPIHandler().disLikeAReaction(mediaId) { [weak self] (responseData) in
            if let status = responseData.status {
                if status {
                    self?.reaction.canLike = true
                    self?.updateReactionBlock?(nil, -1)
                    self?.likeBtn.isUserInteractionEnabled = true
                    return
                }
            }
           self?.view.makeToast(responseData.message)
        }
    }
    
    func fetchReactionDetailsFromReactionId(_ reactionId:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        HomeControllerAPIHandler().getReactionDetails(reactionId) { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            if let reactionDetail = responseData.reaction {
                self?.reaction = reactionDetail
                    self?.setupView()
                    self?.setupDetail()
                    self?.setupVideoPlayer()
                    self?.increaseViewsForReaction()
            } else {
                self?.view.makeToast(responseData.message)

                }
            }
        }
    
    func loadGif(url: String , imageView: UIImageView) {
        let dict  = convertToDictionary(text: url)
        let downsizedGif = dict!["downsized"] as? [String:Any]
        let imageURL = UIImage.gif(url: (downsizedGif?["url"] as? String)!)
        DispatchQueue.main.async {
            let imageView1 = UIImageView(image: imageURL)
            imageView1.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: imageView.frame.size.height)
            imageView.addSubview(imageView1)
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
               self.view.makeToast(error.localizedDescription)
            }
        }
        return nil
    }
}
    

