//
//  HomePageDetailViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 29/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import AlamofireImage
import AVKit
import Instructions

class HomePageDetailViewController: UIViewController {

    typealias UpdatePostBlock = (Int?, Int?, Int?, Bool?) -> Void
    var updatePostBlock: UpdatePostBlock?
    
    typealias ReactionRecordedBlock = () -> Void
    var reactionRecordedBlock: ReactionRecordedBlock?
    
    
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var detailView: UIView!
    @IBOutlet weak var videoTitleLbl: UILabel!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var videoDetailsView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var likesImageView: UIImageView!
    @IBOutlet weak var viewsImageView: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var viewsLbl: UILabel!
    @IBOutlet weak var reactionsCountLbl: UILabel!
    @IBOutlet weak var firstReactionProfileImageView: UIImageView!
    @IBOutlet weak var secondReactionProfileImageView: UIImageView!
    @IBOutlet weak var thirdReactionProfileImageView: UIImageView!
    @IBOutlet weak var categoriesListLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var videoActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var colorBackgroundView: UIView!
    @IBOutlet weak var iconBackgroundView: UIView!
    @IBOutlet weak var reactBtn: UIButton!
    
    @IBOutlet weak var shadowUpImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var shadowDownImageView: UIImageView!
    @IBOutlet weak var videoPreviewHeightConstraint: NSLayoutConstraint! //411
    @IBOutlet weak var reactViewHeightConstraint: NSLayoutConstraint! //76
    @IBOutlet weak var reactionsViewHeightConstraint: NSLayoutConstraint! // 113
    @IBOutlet weak var categoriesViewHeightConstraint: NSLayoutConstraint! // 17
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var likeImageView: UIImageView!
    @IBOutlet weak var tagViewHeightConstraint: NSLayoutConstraint! // 55
    
    @IBOutlet weak var taggedPerson1ImageView: UIImageView!
    @IBOutlet weak var taggedPerson2ImageView: UIImageView!
    @IBOutlet weak var taggedPerson3ImageView: UIImageView!
    @IBOutlet weak var taggedPerson4ImageView: UIImageView!
    @IBOutlet weak var taggedPerson5ImageView: UIImageView!
    @IBOutlet weak var taggedPerson6ImageView: UIImageView!
    @IBOutlet weak var taggedPerson7ImageView: UIImageView!
    @IBOutlet weak var taggedPerson8ImageView: UIImageView!
    @IBOutlet weak var taggedPerson9ImageView: UIImageView!
    @IBOutlet weak var viewAllTaggedPersonImageView: UIImageView!
    @IBOutlet weak var viewAllTaggedPersonsBtn: UIButton!
    @IBOutlet weak var noOfTagsLbl: UILabel!
    @IBOutlet weak var noOfTagsView: UIView!
    @IBOutlet weak var NoreactionLbl: UILabel!
    @IBOutlet weak var reactionOnVideoLbl: UILabel!
    
    var postId:Int?
    var postDetails:Post!
    var loaderView:LoaderView?
    var reactions = [Reaction]()
    var taggedFriends = [Friend]()
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var heightOfVideoCell:CGFloat = 411.0
    var timeObserver:Any?
    var hasNext:Bool = false
    var isPostOwner:Bool? = false
    var pageNo = 1
    var reactionRecorded = false
    let imageCache = AutoPurgingImageCache()
    var swipeFromTheLeftEdge: UIScreenEdgePanGestureRecognizer?
    var openReaction = false
    var reactionId = -1
    let coachMarksController = CoachMarksController()
    var tagsCount:Int? {
        didSet {
            if let count = tagsCount {
                noOfTagsLbl.text = "\(count)"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let layout = self.collectionView?.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlayingVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        
        setupView()
        coachMarksController.overlay.allowTap = true
        coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.8)
        self.coachMarksController.dataSource = self
        
        view.layoutIfNeeded()
        
        fetchPostFromPostId()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = true
        tabbarVC.hideCameraButton(value: true)
        
        if reactionRecorded {
            reactionRecorded = false
            postDetails.canReact = false
            disableReactButton()
            fetchReactions()
            reactionRecordedBlock?()
        }
        
        if postDetails != nil {
            tagsCount = postDetails.totalTag
            fetchTaggedFriendsList()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "isSecondTimeForHomeDetail")
        if launchedBefore  {
            return
        } else {
            self.coachMarksController.start(on: self)
            UserDefaults.standard.set(true, forKey: "isSecondTimeForHomeDetail")
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
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
        
        
        categoriesListLbl.translatesAutoresizingMaskIntoConstraints = false
        timerLbl.isHidden = true
        muteBtn.isHidden = true
        detailView.isHidden = true

        profileImageView.clipsToBounds = true
        profileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        profileImageView.layer.borderWidth = 0.5
        firstReactionProfileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        firstReactionProfileImageView.layer.borderWidth = 0.5
        secondReactionProfileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        secondReactionProfileImageView.layer.borderWidth = 0.5
        thirdReactionProfileImageView.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
        thirdReactionProfileImageView.layer.borderWidth = 0.5
        
        colorBackgroundView.layer.cornerRadius = colorBackgroundView.bounds.height / 2
        iconBackgroundView.layer.cornerRadius = iconBackgroundView.bounds.height / 2
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        firstReactionProfileImageView.layer.cornerRadius = firstReactionProfileImageView.bounds.height / 2
        secondReactionProfileImageView.layer.cornerRadius = secondReactionProfileImageView.bounds.height / 2
        thirdReactionProfileImageView.layer.cornerRadius = thirdReactionProfileImageView.bounds.height / 2
        
        
        noOfTagsLbl.text = "0"
        noOfTagsView.layer.cornerRadius = 7
        tagViewHeightConstraint.constant = 0
        
        disableReactButton()
    }
    
    func setupScrollHeight() {
        videoPreviewHeightConstraint.constant = heightOfVideoCell
        let scrollHeight = videoPreviewHeightConstraint.constant + reactViewHeightConstraint.constant + reactionsViewHeightConstraint.constant + tagViewHeightConstraint.constant
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: scrollHeight)
    }
    
    func setUpPanGesture(){
        swipeFromTheLeftEdge = UIScreenEdgePanGestureRecognizer(target: self,action: #selector(swipeFromEdge))
        swipeFromTheLeftEdge?.edges = .left
        self.view.addGestureRecognizer(swipeFromTheLeftEdge!)
    }
    
    @objc func swipeFromEdge(){
        removeVideoPlayer()
        navigationController?.popViewController(animated: true)
    }
    
    
    func fetchReactions() {
        guard let postId = postId  else {
            return
        }
        
        HomeControllerAPIHandler().getReactionsForPost(postId, page: pageNo) { [weak self] (responseData) in
            if let error = responseData.errorObject {
               self?.view.makeToast(error.message)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.reactions {
                DispatchQueue.main.async {
                    if strongSelf.pageNo == 1 {
                        strongSelf.reactions = Array(list)
                    } else {
                        strongSelf.reactions.append(contentsOf: list)
                    }
                    if list.count == 0 {
                        self?.reactionOnVideoLbl.isHidden = true
                        self?.NoreactionLbl.isHidden = false
                    } else {
                        self?.reactionOnVideoLbl.isHidden = false
                        self?.NoreactionLbl.isHidden = true
                    }
                    strongSelf.collectionView.reloadData()
                    strongSelf.hasNext = responseData.nextPage!
                }
            }
        }
    }
    
    
    //MARK:- Video cell methods
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let key = keyPath else {
            return
        }
        
        if key == "timeControlStatus", player != nil {
            if let timeControlStatusValue = player?.timeControlStatus.hashValue {
                switch timeControlStatusValue {
                case 1:
                    DispatchQueue.main.async {
                        self.videoActivityIndicator.startAnimating()
                    }
                    break
                default:
                    DispatchQueue.main.async {
                        self.videoActivityIndicator.stopAnimating()
                    }
                    break
                }
            }
        }
    }
    
    func setupDetail() {
        guard let list = postDetails.mediaList else {
            return
        }
        
        DispatchQueue.main.async {
            self.videoActivityIndicator.startAnimating()
            self.detailView.isHidden = false
        }
        
        isPostOwner = postDetails.canDelete
        if postDetails.canReact == false {
            disableReactButton()
        } else {
            enableReactButton()
        }
        self.likeImageView.image = (postDetails.canLike == false) ? UIImage(named: "ic_liked") : UIImage(named: "ic_likes")
        
        if let profileImageUrl = postDetails.postOwner?.profileMedia?.thumbUrl, let postOwnerId = postDetails.postOwner?.userId {
            setupProfileThumbnail(imageUrl: profileImageUrl, postOwnerId: postOwnerId)
        } else {
            DispatchQueue.main.async {
                self.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
    
        setupThumbnail(urlStr: list[0].thumbUrl!)
        if player == nil {
            setupVideoPlayer(urlStr: list[0].mediaUrl!)
        } else {
            player?.play()
        }
        
        videoTitleLbl.text = postDetails.title?.decode() ?? ""
        timerLbl.text = list[0].duration
        viewsLbl.text = "\(list[0].views!)"
        
        if postDetails.hasCheckedIn! {
            locationLbl.text = postDetails.checkIn!.location
            locationIconImageView.isHidden = false
        } else {
            locationLbl.isHidden = true
            locationIconImageView.isHidden = true
        }
        
        if postDetails.categories != nil {
            if postDetails.categories!.count > 0 {
                categoriesView.isHidden = false
            }
        }
        
        if let postOwner = postDetails.postOwner {
            userNameLbl.text = postOwner.userName
            if postOwner.hasProfileMedia! {
                // profileImageView.isHidden = false
            } else {
                // profileImageView.isHidden = true
            }
        } else {
            // profileImageView.isHidden = true
        }
        
        likesLbl.text = "\(postDetails.likes!)"
        if let totalTags = postDetails.totalTag {
            tagsCount = totalTags
        }
      
        if postDetails.totalReactions == 0 && postDetails.canDelete == true {
            NoreactionLbl.text = "There's no reaction yet"
            reactionOnVideoLbl.isHidden = true
            NoreactionLbl.isHidden = false
        } else if postDetails.totalReactions == 0 && postDetails.canDelete == false {
            NoreactionLbl.text = "Be the first one to react"
            reactionOnVideoLbl.isHidden = true
            NoreactionLbl.isHidden = false
        } else {
            reactionOnVideoLbl.isHidden = false
            NoreactionLbl.isHidden = true
        }
        
        if let noOfReactions = postDetails.totalReactions {
            if noOfReactions < 4 {
                firstReactionProfileImageView.isHidden = true
                secondReactionProfileImageView.isHidden = true
                thirdReactionProfileImageView.isHidden = true
                reactionsCountLbl.text = "\(postDetails.totalReactions!) Reactions"
            } else {
                reactionsCountLbl.text = "+ \(postDetails.totalReactions! - 3) R"
                firstReactionProfileImageView.isHidden = false
                secondReactionProfileImageView.isHidden = false
                thirdReactionProfileImageView.isHidden = false
                loadReactionsProfileImages()
            }
        } else {
            firstReactionProfileImageView.isHidden = true
            secondReactionProfileImageView.isHidden = true
            thirdReactionProfileImageView.isHidden = true
            reactionsCountLbl.text = "0 Reaction"
        }
        
        if let  categories = postDetails.categories {
            var categoriesStr = ""
            for category in categories {
                if categoriesStr.count != 0 {
                    categoriesStr += "   \(category.categoryName!)"
                } else {
                    categoriesStr += category.categoryName!
                }
            }
//            categoriesStr = categoriesStr.uppercased()
            if categoriesStr.count != 0 {
                categoriesView.isHidden = false
                categoriesListLbl.text = categoriesStr
                
                if let font = UIFont(name: Constants.kProximaNovaBold, size: 10.0) {
                    let width = categoriesStr.getWidthForText(font: font) + 150
//                    categoriesView.frame = CGRect(x: UIScreen.main.bounds.width, y: categoriesView.frame.origin.y, width: width, height: 17)
                    
                    if width  > UIScreen.main.bounds.width  {
                        self.startMarqueeLabelAnimation()
                    }
                }
            } else {
                categoriesView.isHidden = true
                categoriesViewHeightConstraint.constant = 0
            }
        }
    }
    
    func disableReactButton() {
        reactBtn.isEnabled = false
        colorBackgroundView.backgroundColor = UIColor(rgba: "#DDDDDD")
        iconBackgroundView.backgroundColor = UIColor(rgba: "#B3B3B3")
        reactBtn.setTitleColor(UIColor.lightText, for: .normal)
    }
    
    func enableReactButton() {
        reactBtn.isEnabled = true
        colorBackgroundView.backgroundColor = ColorConstants.kAppGreenColor
        iconBackgroundView.backgroundColor = ColorConstants.kTextBlackColor
        reactBtn.setTitleColor(UIColor.lightText, for: .normal)
    }
    
    func setupTaggedFriendsProfileImages() {
        if taggedFriends.count == 0 {
            noOfTagsView.isHidden = true
            return
        }
        
        if taggedFriends.count > 0 {
            noOfTagsView.isHidden = false
            taggedPerson1ImageView.isHidden = false
            taggedPerson1ImageView.clipsToBounds = true
            taggedPerson1ImageView.layer.cornerRadius = 15
            taggedPerson1ImageView.layer.borderWidth = 0.5
            taggedPerson1ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[0].hasProfileMedia == true, let imageStrURL = taggedFriends[0].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson1ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[0].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson1ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
          taggedPerson1ImageView.isHidden = true
        }
        
        if taggedFriends.count > 1 {
            noOfTagsView.isHidden = false
            taggedPerson2ImageView.isHidden = false
            taggedPerson2ImageView.clipsToBounds = true
            taggedPerson2ImageView.layer.cornerRadius = 15
            taggedPerson2ImageView.layer.borderWidth = 0.5
            taggedPerson2ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[1].hasProfileMedia == true, let imageStrURL = taggedFriends[1].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson2ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[1].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson2ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
           taggedPerson2ImageView.isHidden = true
        }
        
        if taggedFriends.count > 2 {
            noOfTagsView.isHidden = false
            taggedPerson3ImageView.isHidden = false
            taggedPerson3ImageView.clipsToBounds = true
            taggedPerson3ImageView.layer.cornerRadius = 15
            taggedPerson3ImageView.layer.borderWidth = 0.5
            taggedPerson3ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[2].hasProfileMedia == true, let imageStrURL = taggedFriends[2].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson3ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[2].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson3ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        }else{
            taggedPerson3ImageView.isHidden = true
        }
        
        if taggedFriends.count > 3 {
            noOfTagsView.isHidden = false
            taggedPerson4ImageView.isHidden = false
            taggedPerson4ImageView.clipsToBounds = true
            taggedPerson4ImageView.layer.cornerRadius = 15
            taggedPerson4ImageView.layer.borderWidth = 0.5
            taggedPerson4ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[3].hasProfileMedia == true, let imageStrURL = taggedFriends[3].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson4ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[3].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson4ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
            taggedPerson4ImageView.isHidden = true
        }
        
        if taggedFriends.count > 4 {
            if taggedFriends[4].hasProfileMedia == true, let imageStrURL = taggedFriends[4].profileMedia?.thumbUrl {
                noOfTagsView.isHidden = false
                taggedPerson5ImageView.isHidden = false
                taggedPerson5ImageView.clipsToBounds = true
                taggedPerson5ImageView.layer.cornerRadius = 15
                taggedPerson5ImageView.layer.borderWidth = 0.5
                taggedPerson5ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
                downloadProfileImage(imageView: taggedPerson5ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[4].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson5ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
             taggedPerson5ImageView.isHidden = true
        }
        
        if taggedFriends.count > 5 {
            noOfTagsView.isHidden = false
            taggedPerson6ImageView.isHidden = false
            taggedPerson6ImageView.clipsToBounds = true
            taggedPerson6ImageView.layer.cornerRadius = 15
            taggedPerson6ImageView.layer.borderWidth = 0.5
            taggedPerson6ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[5].hasProfileMedia == true, let imageStrURL = taggedFriends[5].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson6ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[5].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson6ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        }
        
        if taggedFriends.count > 6 {
            noOfTagsView.isHidden = false
            taggedPerson7ImageView.isHidden = false
            taggedPerson7ImageView.clipsToBounds = true
            taggedPerson7ImageView.layer.cornerRadius = 15
            taggedPerson7ImageView.layer.borderWidth = 0.5
            taggedPerson7ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[6].hasProfileMedia == true, let imageStrURL = taggedFriends[6].profileMedia?.thumbUrl {
                downloadProfileImage(imageView: taggedPerson7ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[6].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson7ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
           taggedPerson7ImageView.isHidden = true
        }
        
        if taggedFriends.count > 7 {
            if taggedFriends[7].hasProfileMedia == true, let imageStrURL = taggedFriends[7].profileMedia?.thumbUrl {
                noOfTagsView.isHidden = false
                taggedPerson8ImageView.isHidden = false
                taggedPerson8ImageView.clipsToBounds = true
                taggedPerson8ImageView.layer.cornerRadius = 15
                taggedPerson8ImageView.layer.borderWidth = 0.5
                taggedPerson8ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
                downloadProfileImage(imageView: taggedPerson8ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[7].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson8ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        } else {
            taggedPerson8ImageView.isHidden = true
        }
        
        if taggedFriends.count > 8 {
            noOfTagsView.isHidden = false
            taggedPerson9ImageView.isHidden = false
            taggedPerson9ImageView.clipsToBounds = true
            taggedPerson9ImageView.layer.cornerRadius = 15
            taggedPerson9ImageView.layer.borderWidth = 0.5
            taggedPerson9ImageView.layer.borderColor = ColorConstants.kWhiteColorKey.cgColor
            
            if taggedFriends[8].hasProfileMedia == true, let imageStrURL = taggedFriends[8].profileMedia?.thumbUrl {   
                downloadProfileImage(imageView: taggedPerson9ImageView, imageURLStr: imageStrURL, imageKey:  taggedFriends[8].userId! )
            } else {
                DispatchQueue.main.async {
                    self.taggedPerson9ImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            viewAllTaggedPersonImageView.image = UIImage(named: "")
        } else {
           taggedPerson9ImageView.isHidden = true
        }

    }
    
    func downloadProfileImage(imageView:UIImageView, imageURLStr:String, imageKey:Int) {
        if let postImage = AppImageCache.fetchOthersProfileImage(userId: imageKey) {
            DispatchQueue.main.async {
                imageView.image = postImage
            }
        } else {
            DispatchQueue.main.async {
                imageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        CommonAPIHandler().getDataFromUrlWithId(imageURL: imageURLStr, imageId: imageKey) { (image, key) in
            DispatchQueue.main.async {
                imageView.image = image
                AppImageCache.saveOthersProfileImage(image: image, userId: key)
                
            }
        }
    }
    
    func startMarqueeLabelAnimation() {
        DispatchQueue.main.async(execute: {
            
            UIView.animate(withDuration: 10.0, delay: 0, options: ([.curveLinear,.repeat]), animations: {() -> Void in
                
                self.categoriesListLbl.center = CGPoint(x:0 - self.categoriesListLbl.bounds.size.width / 2, y: self.categoriesListLbl.center.y)
               
                
            }, completion:  nil)
        })
        categoriesListLbl.leftAnchor.constraint(equalTo: view.rightAnchor).isActive = true

    }
    
    func setupVideoPlayer(urlStr:String) {
        DispatchQueue.global().async {
            guard let videoURL = URL(string: urlStr) else {
                self.view.makeToast("URL not found")
                return
            }
            
            self.playerLayer?.removeFromSuperlayer()
            self.player = nil
            self.playerItem = nil
            
            self.playerItem = AVPlayerItem(url: videoURL)
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: self.playerItem!)
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.player!.actionAtItemEnd = .none
                self.playerLayer?.frame = self.previewView.bounds
                self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.previewView.layer.addSublayer(self.playerLayer!)
                self.player!.volume = 1
                self.player?.isMuted = false
                self.player?.play()
                self.timerLbl.isHidden = false
                self.muteBtn.isHidden = false
                let imageName = "ic_soundOn"
                self.muteBtn.setImage(UIImage(named:imageName), for: .normal)
                
                let interval = CMTime(value: 1, timescale: 1)
                
                self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
                self.timeObserver = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main,
                                                                         using: { [weak self] (progressTime) in
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        if strongSelf.playerItem != nil {
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
                    }
                })
            }
        }
    }
    
    func removeVideoPlayer() {
        NotificationCenter.default.removeObserver(self)
        
        DispatchQueue.main.async {
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            
            if self.timeObserver != nil {
                self.player?.removeTimeObserver(self.timeObserver!)
                self.timeObserver = nil
            }
            
            self.player?.pause()
            self.playerLayer?.removeFromSuperlayer()
            self.player = nil
            self.playerItem = nil
            self.playerLayer = nil
        }
    }
    
    @objc func finishedPlayingVideo() {
        player?.pause()
        player?.seek(to: kCMTimeZero)
       
    }
    
    func getFormatedTime(fromTime timeDuration:Int) -> String {
        let minutes = timeDuration / 60 % 60
        let seconds = timeDuration % 60
        let strDuration = String(format:"%02d:%02d", minutes, seconds)
        return strDuration
    }
    
    func updateLikes(isIncreased:Bool) {
        DispatchQueue.main.async {
            var likes = self.postDetails.likes!
            likes = (isIncreased) ? likes + 1 : likes - 1
            self.postDetails.canLike = !isIncreased
            self.postDetails.likes = likes
            self.likesLbl.text = "\(likes)"
            self.likeImageView.image = (isIncreased) ? UIImage(named: "ic_liked") : UIImage(named: "ic_likes")
        }
    }
    
    func updateViews() {
//        DispatchQueue.main.async {
//            var currentViews = Int(self.viewsLbl.text!)!
//            currentViews += 1
//            self.viewsLbl.text = "\(currentViews)"
//        }
    }
    
    
    func updateReactions() {
        reactionOnVideoLbl.isHidden = false
        NoreactionLbl.isHidden = true
        
        guard var reactionsCount = postDetails.totalReactions else {
            return
        }
        
        DispatchQueue.main.async {
            reactionsCount = reactionsCount + 1
            if reactionsCount < 4 {
                self.firstReactionProfileImageView.isHidden = true
                self.secondReactionProfileImageView.isHidden = true
                self.thirdReactionProfileImageView.isHidden = true
                self.reactionsCountLbl.text = "\(reactionsCount) Reactions"
            } else {
                self.firstReactionProfileImageView.isHidden = false
                self.secondReactionProfileImageView.isHidden = false
                self.thirdReactionProfileImageView.isHidden = false
                self.reactionsCountLbl.text = "+ \(reactionsCount) R"
                self.loadReactionsProfileImages()
            }
        }
    }
    
    func loadReactionsProfileImages() {
        if let list = postDetails.reactedUsers {
            let firstUser = list[0]
            if let thumbUrl = firstUser.profileMedia?.thumbUrl {
                downloadProfileImage(imageView: firstReactionProfileImageView, imageURLStr: thumbUrl, imageKey: firstUser.userdId!)
            } else {
                DispatchQueue.main.async {
                    self.firstReactionProfileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            let secondUser = list[1]
            if let thumbUrl = secondUser.profileMedia?.thumbUrl {
                downloadProfileImage(imageView: secondReactionProfileImageView, imageURLStr: thumbUrl, imageKey: secondUser.userdId!)
            } else {
                DispatchQueue.main.async {
                    self.secondReactionProfileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            let thirdUser = list[2]
            if let thumbUrl = thirdUser.profileMedia?.thumbUrl {
                downloadProfileImage(imageView: thirdReactionProfileImageView, imageURLStr: thumbUrl, imageKey: thirdUser.userdId!)
            } else {
                DispatchQueue.main.async {
                    self.thirdReactionProfileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        }
    }

    func showPopoverReportTypesListViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
            let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
            reportVC.isFromReportPost = true
            reportVC.post = self.postDetails
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
    
    func openProfile( _ userId: Int?) {
        guard let userId = userId else {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        destinationVC.friendUserId = userId
        destinationVC.isFromVideo = true
        destinationVC.isMyProfile = (userId == UserDefaults.standard.value(forKey: Constants.kUserIdKey) as? Int)
        destinationVC.isBasicProfile = false
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func openLikersList( _ postId: Int?) {
        guard let postId = postId else {
            return
        }
        let storyboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let likersListVC = storyboard.instantiateViewController(withIdentifier: "ListOfLikersViewController") as! ListOfLikersViewController
        likersListVC.postId = postId
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(likersListVC, animated: true)
        }
    }
    
    //MARK: - React cell methods
    
    
    //MARK: - Reactions cell methods
    
    
    //MARK: - Button delegates
    
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        guard postDetails.postId != nil else {
            return
        }
        
        guard let videoPlayer = player else {
            return
        }
        videoPlayer.isMuted = !videoPlayer.isMuted
        let imageName = (videoPlayer.isMuted) ? "ic_soundOff" : "ic_soundOn"
        self.muteBtn.setImage(UIImage(named:imageName), for: .normal)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {

        guard postDetails.postId != nil else {
            return
        }
        
        (player?.rate == 0) ? player?.play() : player?.pause()
    }
    
    @IBAction func reactButtonTapped(_ sender: UIButton) {
        guard postDetails.postId != nil else {
            return
        }
        
    }
    
    @IBAction func openProfileButtonTapped(_ sender: UIButton) {
        player?.pause()
        openProfile(postDetails.postOwner?.userId)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        removeVideoPlayer()
        
        if let homeViewController = navigationController?.viewControllers.first as? NewHomeViewController {
            homeViewController.updatedPost = postDetails
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func hideButtonTapped() {
        guard let postId = postDetails.postId else {
            return
        }
        
        player?.pause()
        ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Hide", actionTitle: "Hide", message: "Do you really want to hide the video ?", forVC: self) { [weak self] (action) in
            self?.hidePost(postId: postId, status: 1)
        }
    }

    func deleteButtonTapped() {
        player?.pause()
        
        guard postDetails.postId != nil else {
            return
        }

        if postDetails.canDelete == true {
            let alertVC = UIAlertController(title: "Alert", message: "Do you want to delete the post ?", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Confirm", style: .default) { [weak self] (action) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.deleteThePost()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            
            self.present(alertVC, animated: true, completion: nil)
        } else {
            showPopoverReportTypesListViewController()
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.01, animations: {
            self.likeImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
            self.likeImageView.transform = CGAffineTransform.identity
            }
        })
        
        (postDetails.canLike == true) ? likeThePost() : dislikeThePost()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let postId = postDetails.postId else {
            return
        }
        
        let params:[String:String] = [
            Constants.kDeepLinkPostIdKey  :   "\(postId)"
        ]
        
        let url = postDetails.mediaList![0].mediaUrl
        let branch = BranchDeepLink(title: "Teazer App", description: "See this post", imageUrl: url, channel: "Social")
        branch.createDeepLinks(params: params, viewController: self)
    }

    @IBAction func taggedButtonTapped(_ sender: UIButton) {
        guard let postId = postDetails.postId else {
            return
        }
        
        
        if taggedFriends.count == 0 {
            self.view.makeToast("There are no tagged users")
        } else {
            if (self.tagViewHeightConstraint.constant == 0) {
                UIView.animate(withDuration: 0.3) {
                    self.tagViewHeightConstraint.constant = 55
                    self.setupScrollHeight()
                    self.view.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.tagViewHeightConstraint.constant = 0
                    self.setupScrollHeight()
                    self.view.layoutIfNeeded()
                }
            }
        }    
    }
    
    @IBAction func viewAllTaggedPersonsButtonTapped(_ sender: UIButton) {
        player?.pause()
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "TaggedFriendsViewController") as! TaggedFriendsViewController
        destinationVC.postDetails = postDetails
        self.navigationController?.pushViewController(destinationVC, animated: true)
        
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        guard postDetails.postId != nil else {
            return
        }
        
        if postDetails.canDelete == false {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Hide", style: .default, handler: { _ in
               self.hideButtonTapped()
            }))
            alert.addAction(UIAlertAction(title: "Report", style: .destructive, handler: { _ in
                self.deleteButtonTapped()
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                self.deleteButtonTapped()
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
     
    @IBAction func profileButtonTapped(_ sender: UIButton) {
        guard let postOwnerId = postDetails.postOwner?.userId else {
            return
        }
        player?.pause()
        openProfile(postOwnerId)
    }
    
    @IBAction func likersButtonTapped(_ sender: UIButton) {
        guard let postId = postDetails.postId else {
            return
        }
        
        player?.pause()
        openLikersList(postId)
    }
    
    //MARK:- Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReactionSegueIdentifier" {
            player?.pause()
            let destinationVC = segue.destination as! CameraViewController
            destinationVC.isRecordingReaction = true
            destinationVC.postDetails = postDetails
       }   
    }
}

extension HomePageDetailViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}

extension HomePageDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reactions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if let layout = collectionView.collectionViewLayout as? HomePageLayout {
                reactionsViewHeightConstraint.constant = layout.collectionViewContentSize.height + 41.0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeDetailPageCollectionViewCell", for: indexPath) as! HomeDetailPageCollectionViewCell

        let reaction = reactions[indexPath.row]
        cell.setupCell(reaction: reaction)
//        cell.setupThumbnail(media: reaction.mediaDetails!, imageKey: "HomeDetailPageImage\(indexPath.row)")
        
        
        if let reactionImage = AppImageCache.fetchReactionImage(reactionId: reaction.reactId!) {
            DispatchQueue.main.async {
                cell.imageView.image = reactionImage
            }
        } else {
            DispatchQueue.main.async {
                cell.imageView.image = nil
            }
        }
        if reaction.mediaDetails?.mediaType == 4 {
            DispatchQueue.global(qos: .background).async {
                self.loadGif(url: reaction.mediaDetails!.externalMeta!, imageView: cell.imageView)
            }
        } else {
            if let urlStr = reaction.mediaDetails?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: reaction.reactId!, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                    DispatchQueue.main.async { [weak self] in
                        if image != nil, let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? HomeDetailPageCollectionViewCell {
                            cell.imageView.image = image
                        }
                        AppImageCache.saveReactionImage(image: image, reactionId: key)
                    }
                })
            }
        }
        
        if let postOwnerId = reaction.reactionOwner?.userId {
            if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }

            if let urlStr = reaction.reactionOwner?.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                    DispatchQueue.main.async { [weak self] in
                        if image != nil, let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? HomeDetailPageCollectionViewCell {
                            cell.profileImageView.image = image
                        }
                        AppImageCache.saveOthersProfileImage(image: image, userId: key)
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        cell.profileTappedBlock = {[weak self] in
            self?.player?.pause()
            self?.openProfile(reaction.reactionOwner?.userId)
            
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let reaction = reactions[indexPath.row]
        guard let canDelete = postDetails.canDelete else {
            return
        }
        
        player?.pause()
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ReactionDetailsViewController") as! ReactionDetailsViewController
        destinationVC.reaction = reaction
        destinationVC.canDeletePost = canDelete
        destinationVC.updateReactionBlock = { [weak self] (views, likes) in
            if views != nil {
                self?.reactions[indexPath.row].views! += views!
            } else if likes != nil {
                self?.reactions[indexPath.row].canLike = (likes! > 0) ? false : true
                self?.reactions[indexPath.row].likes! += likes!
            }
            self?.collectionView.reloadItems(at: [indexPath])
        }
        
        navigationController?.present(destinationVC, animated: true, completion: nil)

    }
}
extension HomePageDetailViewController: HomePageLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let reaction = reactions[indexPath.row]
        let height = reaction.mediaDetails!.height! * (UIScreen.main.bounds.width / 2) / reaction.mediaDetails!.width!
        return (height > 175.0)  ? height : 175.0
    }
    
}

extension HomePageDetailViewController {

    func increaseViews() {
        if isPostOwner! {
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let list = postDetails.mediaList else {
            return
        }
        updateViews()
        HomeControllerAPIHandler().increaseViewsForPost(list[0].mediaId!) { [weak self] (responseData) in
            if responseData.status == true, let strongSelf = self {
                return
            }
            self?.view.makeToast("Post views update failed")
        }
    }
    
    func likeThePost() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let postId = postDetails.postId else {
            return
        }
        updateLikes(isIncreased: true)
        HomeControllerAPIHandler().likeAPost(postId) { [weak self] (responseData) in
            if responseData.status == true {
                return
            }
            
           self?.view.makeToast("Post liked failed")
        }
    }
    
    func dislikeThePost() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let postId = postDetails.postId else {
            return
        }
        updateLikes(isIncreased: false)
        HomeControllerAPIHandler().disLikeAPost(postId) { [weak self] (responseData) in
            if responseData.status == true {
                return
            }

            self?.view.makeToast("Post disliked failed")
        }
    }
    
    func hidePost(postId:Int,status:Int){
        HomeControllerAPIHandler().hidePost(postId, status){ [weak self] (responseData) in
            if let error = responseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
            }
            if responseData.status == true {
                self?.view.makeToast("Post Hidden succesfully!")
                DispatchQueue.main.async {
                    self?.removeVideoPlayer()
                    if let homeViewController = self?.navigationController?.viewControllers[0] as? NewHomeViewController {
                        homeViewController.hidePostBlock?()
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.view.makeToast(responseData.message)
            }
        }
    }
        
    func deleteThePost() {
        if !isPostOwner! {
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let postId = postDetails.postId else {
            return
        }
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }

        HomeControllerAPIHandler().deleteAPost(postId) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    self?.removeVideoPlayer()
                    self?.navigationController?.popViewController(animated: true)
                }
            } else {
                self?.view.makeToast("Deletion failed")
            }
        }
    }
    
    func fetchTaggedFriendsList() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let postId = postDetails.postId else {
            return
        }
        
        HomeControllerAPIHandler().getTaggedFriends(postId, pageNo: 1) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            DispatchQueue.main.async {
                if let list = responseData.friendsList {
                    strongSelf.taggedFriends = Array(list)
                    strongSelf.tagsCount = list.count
                    strongSelf.setupTaggedFriendsProfileImages()
                }
            }
        }
    }
    
    func fetchPostFromPostId() {
        guard let postId = postId else {
            return
        }
        
        HomeControllerAPIHandler().getPostDetails(postId) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            if let postDetails = responseData.postdetails {
                strongSelf.postDetails = postDetails
                strongSelf.setupDetail()
                
                if postDetails.mediaList![0].height! > (UIScreen.main.bounds.height - 100.0) {
                    self?.heightOfVideoCell = UIScreen.main.bounds.height - 67.0
                } else if postDetails.mediaList![0].height! < Constants.minVideoHeight {
                    self?.heightOfVideoCell = Constants.minVideoHeight
                } else {
                    self?.heightOfVideoCell = postDetails.mediaList![0].height!
                }
                
                self?.setupScrollHeight()
                self?.increaseViews()
                self?.fetchReactions()
                self?.fetchTaggedFriendsList()
            }
        }
    }
    
}

extension HomePageDetailViewController: CoachMarksControllerDataSource,CoachMarksControllerDelegate {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?)
    {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = "React on Videos via Videos of your own or record a video instantly."
        coachViews.bodyView.nextLabel.text = "OKAY!"
        
        UIView.transition(with: coachViews.arrowView!, duration: 1.0, options: [.autoreverse,.repeat], animations: {
            coachViews.arrowView?.frame.origin.y -= 15
        }, completion: nil)
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let coachMark = coachMarksController.helper.makeCoachMark(for: reactBtn) {
            (frame: CGRect) -> UIBezierPath in
            
            return UIBezierPath(ovalIn:frame.insetBy(dx: -14, dy: -50))
        }
        return coachMark
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
}

extension HomePageDetailViewController {

    func setupProfileThumbnail(imageUrl:String, postOwnerId:Int) {
        if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
            DispatchQueue.main.async {
                self.profileImageView.image = postImage
            }
        } else {
            DispatchQueue.main.async {
                self.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        CommonAPIHandler().getDataFromUrlWithId(imageURL: imageUrl, imageId: postOwnerId, completion: { [weak self] (image, key) in
            DispatchQueue.main.async {
                self?.profileImageView.image = image
                AppImageCache.saveOthersProfileImage(image: image, userId: key)
            }
        })
    }
    
    func setupThumbnail(urlStr: String) {
        CommonAPIHandler().getDataFromUrl(imageURL: urlStr, completion: { [weak self] (image) in
            if image != nil {
                DispatchQueue.main.async {
                    self?.backgroundImageView.image = image
                    self?.backgroundImageView.contentMode = .scaleAspectFill
                }
            }
        })
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
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

