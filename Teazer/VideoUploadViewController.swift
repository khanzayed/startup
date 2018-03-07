//
//  VideoUploadViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 21/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import FacebookShare
import Social
import Instructions


class VideoUploadViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var taggedImageView: UIImageView!
    @IBOutlet weak var taggedFriendsLbl: UILabel!
    @IBOutlet weak var noOfTaggedFriends: UILabel!
    @IBOutlet weak var noOfTaggedFriendsView: UIView!
    @IBOutlet weak var selectTaggedFriendsBtn: UIButton!
    @IBOutlet weak var selectedTaggedFriendsView: UIView!
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var locationLbl: UILabel!
    
    @IBOutlet weak var taggedCategoriesImageView: UIImageView!
    @IBOutlet weak var noOfTaggedCategoriesView: UIView!
    @IBOutlet weak var noOfTaggedCategoriesLbl: UILabel!
    @IBOutlet weak var taggedCategoriesLbl: UILabel!
    @IBOutlet weak var selectTaggedCategoriesBtn: UIButton!
    @IBOutlet weak var selectedTaggedCategoriesView: UIView!
    
    @IBOutlet weak var shareOnFbBtn: UIButton!
    @IBOutlet weak var shareOnFbTickView: UIView!
    @IBOutlet weak var shareOnFbTickImageView: UIImageView!
    
    @IBOutlet weak var shareOnInstagramBtn: UIButton!
    @IBOutlet weak var shareOnInstagramTickView: UIView!
    @IBOutlet weak var shareOnInstagramTickImageView: UIImageView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var playVideoBtn: UIButton!
    
    @IBOutlet weak var shadowUpImageView: UIImageView!
    @IBOutlet weak var shareOnSocialPlatformView: UIView!
    @IBOutlet weak var addCategoryLbl: UILabel!
    @IBOutlet weak var videoDurationLbl: UILabel!
    @IBOutlet weak var categoryViewHeightConstraint: NSLayoutConstraint!//58
    @IBOutlet weak var fbShareImageView: UIImageView!
    @IBOutlet weak var heightConstriantTagFriend: NSLayoutConstraint!
    
    var videoURL:URL!
    var compressedVideoURL:URL!
    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    var loaderView:LoaderView?
    var videoPlayerVC:AVPlayerViewController?
    var videoImage:UIImage?
    
    var taggedFriendsIdsList = ""
    var selectedFriends = [Friend]()
    var taggedCategoriesIdsList = ""
    var selectedCategries = [Category]()
    var taggedLocation:GooglePlace?
    var isRecordingReaction = false
    var postDetails:Post?
    var isEditPost = false
    var isFromPhotos = false
    var isCompressionCompeted = false
    var uploadButtonTapped = false
    var isProcessingVideo = false
    var duration:String? = ""
    var progressBar:UIProgressView?
    var exportSession:AVAssetExportSession?
    var exportTimer:Timer?
    var alertView:UIAlertController?
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setUpCoachMarks()
        setDoneOnKeyboard()
        if isEditPost {
            populateFields()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
       
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = true
        tabbarVC.hideCameraButton(value: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if  isEditPost {
            let launchedBefore = UserDefaults.standard.bool(forKey: "isSecondTimeInVideoUpload")
            if launchedBefore  {
                return
            } else {
                self.coachMarksController.start(on: self)
                UserDefaults.standard.set(true, forKey: "isSecondTimeInVideoUpload")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUpCoachMarks() {
        coachMarksController.overlay.allowTap = true
        coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.8)
        self.coachMarksController.dataSource = self
    }
    
    func compressVideo() {
        let pathStr = NSTemporaryDirectory() + (User().deviceId ?? "") + "teazer_temp" + ".mov"
        compressedVideoURL = URL(fileURLWithPath: pathStr)
        
        showProgressAlertBar()
        
        let isFilePresent = FileManager.default.fileExists(atPath: pathStr)
        if isFilePresent {
            try? FileManager.default.removeItem(at: compressedVideoURL)
        }
        
        compressVideo(inputURL: videoURL, outputURL: compressedVideoURL, handler: { [weak self] (session) in
            guard let strongSelf = self else {
                return
            }
            switch session!.status {
            case .completed:
                DispatchQueue.main.async {
                    strongSelf.exportTimer?.invalidate()
                    strongSelf.progressBar?.progress = 1.0
                    strongSelf.alertView?.dismiss(animated: true, completion: {
                        if let tabbarVC = self?.navigationController?.tabBarController as? TabbarViewController {
                            tabbarVC.isVideoReadyToUpload = true
                            tabbarVC.videoTitle = self?.titleTextField.text
                            tabbarVC.compressedVideoURL = self?.compressedVideoURL
                            tabbarVC.isReactionVideo = self!.isRecordingReaction
                            if let postId = self?.postDetails?.postId {
                                tabbarVC.reactionPostId = postId
                            }
                            if let image = self?.videoImageView.image {
                                tabbarVC.uploadViewImage = image.af_imageAspectScaled(toFill: CGSize(width: 60.0, height: 60.0))
                            }
                            tabbarVC.uploadVideo()
                            self?.pushToHomeViewControllerToUploadVideo()
                        }
                    })
                }
                break
            default:
                DispatchQueue.main.async {
                    self?.exportTimer?.invalidate()
                    self?.view.makeToast("Error in processing video")
                    self?.alertView?.dismiss(animated: true, completion: nil)
                }
                break
            }
        })
        
        exportTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let strongSelf = self else {
                return
            }
            
            guard let session = strongSelf.exportSession else {
                return
            }
            
            guard let progressView = strongSelf.progressBar else {
                return
            }
            
            DispatchQueue.main.async  {
                progressView.progress = session.progress
                if progressView.progress > 0.99 {
                    timer.invalidate()
                }
            }
        })
        exportTimer?.fire()
    }
    
    func showProgressAlertBar() {
        alertView = UIAlertController(title: "Please wait", message: "Preparing the video file...", preferredStyle: .alert)
        alertView!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
            self?.exportTimer?.invalidate()
        }))
        
        self.present(alertView!, animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let margin: CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: strongSelf.alertView!.view.frame.width - margin * 2.0, height: 2.0)
            strongSelf.progressBar = UIProgressView(frame: rect)
            strongSelf.progressBar!.progress = 0.0
            strongSelf.progressBar!.tintColor = UIColor.blue
            strongSelf.alertView!.view.addSubview(strongSelf.progressBar!)
        }
    }
    
    func setupView() {
        let gradientUp = CAGradientLayer()
        gradientUp.frame = shadowUpImageView.bounds
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let endColor = UIColor.black.withAlphaComponent(0.8)
        gradientUp.colors = [endColor.cgColor,startColor.cgColor]
        shadowUpImageView.layer.insertSublayer(gradientUp, at: 0)
        

        
        shareOnFbTickView.layer.cornerRadius = shareOnFbTickView.bounds.height / 2
        shareOnInstagramTickView.layer.cornerRadius = shareOnFbTickView.bounds.height / 2
        shareOnFbTickView.layer.borderWidth = 1.0
        shareOnFbTickView.layer.borderColor = ColorConstants.kDisabledGrayColor.cgColor
        shareOnInstagramTickView.layer.borderWidth = 1.0
        shareOnInstagramTickView.layer.borderColor = ColorConstants.kDisabledGrayColor.cgColor
        videoDurationLbl.text = duration
        shareOnFbTickImageView.isHidden = true
        shareOnInstagramTickImageView.isHidden = true
        shareOnInstagramTickImageView.tintColor = ColorConstants.kWhiteColorKey
        shareOnFbTickImageView.tintColor = ColorConstants.kWhiteColorKey
        videoImageView.image = videoImage
        if isRecordingReaction {
            categoryViewHeightConstraint.constant = 0
                heightConstriantTagFriend.constant = 0
        } else {
                heightConstriantTagFriend.constant = 58
            categoryViewHeightConstraint.constant = 58
            addCategoryLbl.text = "Add Categories to your Video*"
        }
        
        noOfTaggedFriendsView.layer.cornerRadius = noOfTaggedFriendsView.bounds.height / 2
        noOfTaggedCategoriesView.layer.cornerRadius = noOfTaggedCategoriesView.bounds.height / 2
        
        if !isEditPost {
            enableUpload()
        } else if isEditPost || isRecordingReaction {
            shareOnSocialPlatformView.isHidden = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 232.0)
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        titleTextField.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    func validateFields() -> Bool {
        selectedTaggedFriendsView.isHidden = (selectedFriends.count == 0)
        selectedTaggedCategoriesView.isHidden = (selectedCategries.count == 0)
        
        if isRecordingReaction {
            if titleTextField.text?.count == 0 {
                return false
            }
            return true
        } else {
            if selectedCategries.count == 0 || titleTextField.text?.count == 0 {
                return false
            }
            return true
        }
    }
    
    func populateFields() {
        guard let post = postDetails else {
            return
        }
        
        let list = post.mediaList
        setupThumbnail(media: list![0])
        if post.hasCheckedIn! {
            locationLbl.text = post.checkIn?.location
        }

        var categoryLblText = ""
        var categoryIdListStr = ""
        for category in post.categories! {
            categoryIdListStr += "\(category.categoryId!)" + ","
            categoryLblText.append("\(category.categoryName!),")
        }
        
        categoryLblText = String(categoryLblText.dropLast())
        categoryIdListStr = String(categoryIdListStr.dropLast())
        
        taggedCategoriesLbl.text = categoryLblText
        noOfTaggedCategoriesLbl.text = "\(post.categories!.count)"
        taggedCategoriesIdsList = categoryIdListStr
        selectedCategries = post.categories!
        
        var friendsNameListStr = ""
        var friendsIdListStr = ""
        if let taggedUserList = post.taggedUsers {
            for friend in taggedUserList {
                friendsNameListStr += friend.firstName! + ","
                friendsIdListStr += "\(friend.userId!)"  + ","
            }
            friendsNameListStr = String(friendsNameListStr.dropLast())
            friendsIdListStr = String(friendsIdListStr.dropLast())
            
            noOfTaggedFriends.text = "\(taggedUserList.count)"
            taggedFriendsLbl.text = friendsNameListStr
            taggedFriendsIdsList = friendsIdListStr
            selectedFriends = taggedUserList
        }
        DispatchQueue.main.async {
            self.titleTextField.text = post.title?.decode()
            self.enableUpload()
        }
        
    }
    
    func setupThumbnail(media:Media) {
        if let thumbnailUrl = media.thumbUrl {
            CommonAPIHandler().getDataFromUrl(imageURL: thumbnailUrl, completion: { [weak self] (image) in
                if image != nil {
                    DispatchQueue.main.async {
                        self?.videoImageView.image = image
                    }
                }
            })
        }
    }

    
    func enableUpload() {
        let areFieldsComplete = validateFields()
        confirmBtn.isEnabled = areFieldsComplete
        confirmBtn.layer.backgroundColor = (areFieldsComplete) ? ColorConstants.kAppGreenColor.cgColor : ColorConstants.kDisabledGrayColor.cgColor
    }
    
    func setupVideoPlayer() {
        DispatchQueue.global().async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.playerLayer?.removeFromSuperlayer()
            strongSelf.playerItem = AVPlayerItem(url: strongSelf.videoURL)
            DispatchQueue.main.async {
                strongSelf.player = AVPlayer(playerItem: strongSelf.playerItem!)
                strongSelf.playerLayer = AVPlayerLayer(player: strongSelf.player!)
                strongSelf.player!.actionAtItemEnd = .none
                strongSelf.playerLayer?.frame = strongSelf.videoPreviewView.bounds
                strongSelf.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                strongSelf.videoPreviewView.layer.addSublayer(strongSelf.playerLayer!)
                strongSelf.player!.volume = 1.0
                strongSelf.videoPreviewView.bringSubview(toFront: strongSelf.playVideoBtn)
            }
        }
    }
    
    
    func removeVideoPlayer() {
        NotificationCenter.default.removeObserver(self)
        
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerItem = nil
        playerLayer = nil
    }
    
    func showSuccessOnVideoUpload() {
        let alertVC = UIAlertController(title: "Video Upload", message: "Video is uploaded successfully.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            
        }
        
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showFailureOnVideoUpload(message:String) {
        let alertVC = UIAlertController(title: "Failed", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func updatePost() {
        guard let postId = postDetails?.postId else {
            return
        }
        
        var params = [String:Any]()
        params["post_id"] = postId
        params["title"] = titleTextField.text?.encode()
        if taggedLocation?.latitude != nil {
            params["location"] = locationLbl.text ?? ""
            params["latitude"] = Double(taggedLocation!.latitude!)!
            params["longitude"] = Double(taggedLocation!.longitude!)!
        }
        if selectedCategries.count > 0 {
            params["categories"] = taggedCategoriesIdsList
        }
        if selectedFriends.count > 0 {
            params["tags"] = taggedFriendsIdsList
        }
        
        CameraControllerAPIHandler().updatePostDetails(params: params) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
                if let postData = responseData.postdetails {
                    let _ = PostCacheData.shared.saveNewOrEditedHomePageVideo(video: postData)
                    ErrorView().showAcknowledgementAlertWithCompletionBlock(title: "Edit Post", message: "The post is updated successfully", forVC: self, completionBlock: { (action) in
                        self?.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self?.view.makeToast("Post update failed")
                }
            }
        }
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
            let urlAsset = AVURLAsset(url: inputURL, options: nil)
            guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset640x480) else {
                handler(nil)
                
                return
            }
        
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mov
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously { () -> Void in
                handler(exportSession)
            }
        }
    
    func shareOnSocialMedia(postIndex:Int) {
        if shareOnFbTickImageView.isHidden == false {
            let post = PostCacheData.shared.posts[postIndex]
            if let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                socialController.title = "Share on Facebook"
                if let list = post.mediaList {
                    if let thumbUrl = list[0].mediaUrl {
                        socialController.add(URL(string: thumbUrl)!)
                    }
                }
                
                DispatchQueue.main.async {
                    self.present(socialController, animated: true, completion: { [weak self] in
                        if self?.shareOnInstagramTickImageView.isHidden == false {
                            if let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter) {
                                vc.title = "Share on Twitter"
                                if let list = post.mediaList {
                                    if let thumbUrl = list[0].mediaUrl {
                                        vc.add(URL(string: thumbUrl)!)
                                    }
                                }
                                
                                DispatchQueue.main.async {
                                    self?.present(vc, animated: true, completion: { [weak self] in
                                        self?.popToHomeViewCntrl()
                                    })
                                }
                            }
                        }
                    })
                }
            }
        } else if shareOnInstagramTickImageView.isHidden == false {
            let post = PostCacheData.shared.posts[postIndex]
            if let vc = SLComposeViewController(forServiceType:SLServiceTypeTwitter) {
                vc.title = "Share on Twitter"
                if let list = post.mediaList {
                    if let thumbUrl = list[0].mediaUrl {
                        vc.add(URL(string: thumbUrl)!)
                    }
                }
                DispatchQueue.main.async {
                    self.present(vc, animated: true, completion: { [weak self] in
                        self?.popToHomeViewCntrl()
                    })
                }
            }
        } else {
            self.popToHomeViewCntrl()
        }
    }
    
    func pushToHomeViewControllerToUploadVideo() {
        defer {
            removeVideoPlayer()
            if let tabbar = tabBarController as? TabbarViewController {
                if isRecordingReaction {
                    let controllers = tabbar.viewControllers!
                    tabbar.reactionPostId = postDetails?.postId
                    tabbar.isReactionVideo = true
                    if let pageDetailVC = controllers[1] as? HomePageDetailViewController {
                        pageDetailVC.removeVideoPlayer()
                    }
                } else {
                    tabbar.isListUpdated = true
                    tabbar.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
                }
            }
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        if videoURL != nil {
            try? FileManager.default.removeItem(at: videoURL)
        }
    }
    
    func popToHomeViewCntrl() {
        if isRecordingReaction {
            if let controllerArr = navigationController?.viewControllers {
                if isFromPhotos{
                    if let controller = controllerArr[controllerArr.count - 4] as? HomePageDetailViewController {
                        controller.reactionRecorded = true
                        removeVideoPlayer()
                        controller.updateReactions()
                        DispatchQueue.main.async {
                            self.navigationController?.popToViewController(controller, animated: true)
                        }
                    }

                } else {
                    if let controller = controllerArr[controllerArr.count - 3] as? HomePageDetailViewController {
                        controller.reactionRecorded = true
                        removeVideoPlayer()
                        controller.updateReactions()
                        DispatchQueue.main.async {
                            self.navigationController?.popToViewController(controller, animated: true)
                        }
                    }

                }
            }
        } else {
            removeVideoPlayer()
            if let tabbar = tabBarController as? TabbarViewController {
                tabbar.isListUpdated = true
                tabbar.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
            }
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        do {
            defer {
                removeVideoPlayer()
                navigationController?.popViewController(animated: true)
            }
            if videoURL != nil {
                try FileManager.default.removeItem(at: videoURL)
            }
            if compressedVideoURL != nil {
                try FileManager.default.removeItem(at: compressedVideoURL)
            }
        } catch _ {
            print("Error deleting local video file")
        }
    }
    
    @IBAction func playVideoButtonTapped(_ sender: UIButton) {
        if let playURL = (isFromPhotos) ? compressedVideoURL : videoURL {
            videoPlayerVC = AVPlayerViewController()
            videoPlayerVC?.player = AVPlayer(url: playURL)
            present(videoPlayerVC!, animated: true) { [weak self] in
                self?.videoPlayerVC?.player?.play()
            }
        }
    }
    
    @IBAction func enterLocationButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func selectFriendsButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func selectCategoriesButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func shareOnFbButtonTapped(_ sender: UIButton) {
        if shareOnFbTickImageView.isHidden {
            shareOnFbTickImageView.isHidden = false
            shareOnFbTickView.backgroundColor = ColorConstants.kAppGreenColor
            shareOnFbTickView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
        } else {
            shareOnFbTickImageView.isHidden = true
            shareOnFbTickView.backgroundColor = ColorConstants.kWhiteColorKey
            shareOnFbTickView.layer.borderColor = ColorConstants.kDisabledGrayColor.cgColor
        }
        
//            let video = Video(url: videoURL)
//            let content = VideoShareContent(video: video)
//            ShareDialog.show(from: self, content: content)
//        
    }
    @IBAction func shareOnTwitterBtnTapped(_ sender: UIButton) {
        if shareOnInstagramTickImageView.isHidden {
            shareOnInstagramTickImageView.isHidden = false
            shareOnInstagramTickView.backgroundColor = ColorConstants.kAppGreenColor
            shareOnInstagramTickView.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            
        } else {
            shareOnInstagramTickImageView.isHidden = true
            shareOnInstagramTickView.backgroundColor = ColorConstants.kWhiteColorKey
            shareOnInstagramTickView.layer.borderColor = ColorConstants.kDisabledGrayColor.cgColor
        }
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        if isFromPhotos {
            guard let titleText = self.titleTextField.text?.encode() else {
                return
            }
            
            if postDetails?.postId == nil && isRecordingReaction {
                ErrorView().showBasicAlertForError(message: "Error trying to upload a video", forVC: self)
                return
            }
            
            if let tabbarVC = self.navigationController?.tabBarController as? TabbarViewController {
                tabbarVC.isVideoReadyToUpload = true
                tabbarVC.videoTitle = titleText
                tabbarVC.compressedVideoURL = compressedVideoURL
                tabbarVC.isReactionVideo = isRecordingReaction
                if let postId = postDetails?.postId {
                    tabbarVC.reactionPostId = postId
                }
                if let image = videoImageView.image {
                    tabbarVC.uploadViewImage = image.af_imageAspectScaled(toFill: CGSize(width: 60.0, height: 60.0))
                }
                tabbarVC.uploadVideo()
                pushToHomeViewControllerToUploadVideo()
            }
        } else if isEditPost {
            updatePost()
            return
        } else {
            guard let titleText = self.titleTextField.text?.encode() else {
                return
            }
            
            if titleText.count == 0 && !isRecordingReaction {
                ErrorView().showBasicAlertForError(title: "Upload Failed", message: "Title field cannot be emplty", forVC: self)
                return
            }
            
            if selectedCategries.count == 0 && !isRecordingReaction {
                ErrorView().showBasicAlertForError(title: "Upload Failed", message: "Please select one or more categories related to the video", forVC: self)
                return
            }
            
            compressVideo()
        }
    }
    
    //MARK:- Navigation method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  let destinationVC = segue.destination as? FriendsListViewController {
            destinationVC.selectedFriends = selectedFriends
            destinationVC.friendsSelectedBlock = { [weak self] (friends) in
                var friendsNameListStr = ""
                var friendsIdListStr = ""
                for friend in friends {
                    friendsNameListStr += friend.firstName! + ","
                    friendsIdListStr += "\(friend.userId!)"  + ","
                }
                friendsNameListStr = String(friendsNameListStr.dropLast())
                friendsIdListStr = String(friendsIdListStr.dropLast())
                
                self?.noOfTaggedFriends.text = "\(friends.count)"
                self?.taggedFriendsLbl.text = friendsNameListStr
                self?.taggedFriendsIdsList = friendsIdListStr
                self?.selectedFriends = friends
                
                let tabbarVC = self?.tabBarController as! TabbarViewController
                tabbarVC.taggedFriendsIdsList = friendsIdListStr
                
                self?.enableUpload()
            }
        } else if let destinationVC = segue.destination as? SearchPlacesViewController {
            destinationVC.locationSelectedBlock = { [weak self] (place) in
                if place != nil {
                    self?.locationLbl.text = place?.title
                    self?.taggedLocation = place
                    
                    let tabbarVC = self?.tabBarController as! TabbarViewController
                    tabbarVC.taggedLocation = place
                } else {
                    self?.locationLbl.text = "Enter Location"
                    self?.taggedLocation = nil
                }
                
                self?.enableUpload()
            }
        } else if let destinationVC = segue.destination as? CategoriesSelectionViewController {
            destinationVC.selectedCategories = selectedCategries
            destinationVC.categoriesSelectedBlock = { [weak self] (categories) in
                var categoryNameListStr = ""
                var categoryIdListStr = ""
                for category in categories {
                    let name = category.categoryName!.index(category.categoryName!.startIndex, offsetBy: 2, limitedBy: category.categoryName!.endIndex)!
                    categoryNameListStr += category.categoryName![name...] + ","
                    categoryIdListStr += "\(category.categoryId!)" + ","
                }
                categoryNameListStr = String(categoryNameListStr.dropLast())
                categoryIdListStr = String(categoryIdListStr.dropLast())
                
                self?.noOfTaggedCategoriesLbl.text = "\(categories.count)"
                self?.taggedCategoriesLbl.text = categoryNameListStr
                self?.taggedCategoriesIdsList = categoryIdListStr
                self?.selectedCategries = categories
                
                let tabbarVC = self?.tabBarController as! TabbarViewController
                tabbarVC.taggedCategoriesIdsList = categoryIdListStr
                
                self?.enableUpload()
            }
        }
    }
    
}

extension VideoUploadViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == titleTextField {
            enableUpload()
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension VideoUploadViewController: CoachMarksControllerDataSource,CoachMarksControllerDelegate {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?)
    {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = "Just click on share & you are ready to share your videos on Facebook and Twitter as well."
        coachViews.bodyView.nextLabel.text = "OKAY!"
        
        UIView.transition(with: coachViews.arrowView!, duration: 1.0, options: [.autoreverse,.repeat], animations: {
            coachViews.arrowView?.frame.origin.y -= 15
        }, completion: nil)
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let coachMark = coachMarksController.helper.makeCoachMark(for: fbShareImageView) {
            (frame: CGRect) -> UIBezierPath in
            
            return UIBezierPath(ovalIn:frame.insetBy(dx: -20, dy: -20))
        }
        return coachMark
    }
    
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }
}

