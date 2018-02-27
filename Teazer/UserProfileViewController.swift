//
//  UserProfileViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import AlamofireImage

public enum ProfileVideos:Int {
    
    case kMyCreations = 0
    case kMyReactions = 1
    
}

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var blurredImageView: UIImageView!
    @IBOutlet weak var headerImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var profileDetailsView: UIView!
    @IBOutlet weak var creationBtn: UIButton!
    @IBOutlet weak var followingBtn: UIButton!
    @IBOutlet weak var followersBtn: UIButton!
    @IBOutlet weak var editBtnView: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var shareBtnView: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var noReactionMsgLbl: UILabel!
    @IBOutlet weak var noReactionMsgLbl2: UILabel!
    @IBOutlet weak var noPostMsgLbl: UILabel!
    @IBOutlet weak var postVideoBtn: UIButton!
    @IBOutlet weak var privateAccountMsgLbl: UILabel!
    @IBOutlet weak var privateAccountMsgView: UIView!
    @IBOutlet weak var followBtnView: UIView!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var followBtnLbl: UILabel!
    @IBOutlet weak var followBtnImageView: UIImageView!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var reportView: UIView!
    @IBOutlet weak var blockBtn: UIButton!
    @IBOutlet weak var profileContentView: UIView!
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var profileTitleLbl: UILabel!
    @IBOutlet weak var userNameTitleLbl: UILabel!
    @IBOutlet weak var blockLabel: UILabel!
    
    
    var othersUserId:Int?
    var isFromVideo = false
    var isAccountPrivate = false
    var isFollowing:Bool?
    var isRequested:Bool?
    var isBlocked:Bool? = false
    var myReactions = [Reaction]()
    var myPostsList = [Post]()
    var othersPostsList = [Post]()
    var userProfile: UserProfileDataModal?
    var friendProfile: FriendProfileDataModal?
    var isFirstProfile = true
    var hasMoreMyCreations = false
    var isFromNotification = false
    var hasMoreMyReaction = false
    var isMyself = false
    var pageNumberForMyCreations = 1
    var pageNumberForMyReactions = 1
    var isWebserviceCallGoingOn = false
    var refreshControl:UIRefreshControl?
    var loaderView:LoaderView?
    var selectedVideosSection:ProfileVideos = .kMyCreations
    var videoPlayerVC:AVPlayerViewController?
    var updatedThumbnailProfileImage:UIImage?
    var updatedProfileImage:UIImage?
    var isComingFromHomeDetail = false
    var blockTitle = "Block"
    
    var headerBackgroundImage: UIImage? {
        didSet {
            //let blurRadius: CGFloat = 20.0
            headerImageView.image = headerBackgroundImage
//            blurredImageView.image = headerImageView.image?.applyBlurWithRadius(blurRadius: blurRadius, tintColor: nil, saturationDeltaFactor: 1.0, maskImage: nil)
            blurredImageView.image = headerImageView.image
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupSegmentControlView()
        addPullToRefresh()
        loadtableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = isFromVideo
        tabbarVC.hideCameraButton(value: isFromVideo)
        
        if videoPlayerVC?.isBeingDismissed ?? false {
            videoPlayerVC?.player = nil
        }
        if isComingFromHomeDetail {
            loadtableView()
            isComingFromHomeDetail = false
        }
       
        if self.othersUserId == nil || (othersUserId != nil && isMyself == true) {
            if let image = AppImageCache.fetchMyProfileImage() {
                profileImageView.image = image
            } else {
                if let mediaUrl = userProfile?.user?.profileMedia?.thumbUrl {
                    downloadProfileImage(url: mediaUrl, userId: nil)
                } else {
                    profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            if let image = AppImageCache.fetchMyCoverImage() {
                blurredImageView.image = image
            } else {
                if let mediaURL = userProfile?.user?.profileMedia?.mediaUrl {
                    downloadCoverImage(url: mediaURL, userId: nil)
                } else {
                    blurredImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
        }
        
        if othersUserId == nil  || (othersUserId != nil && isMyself == true) {
            if myPostsList.count > 0 {
                hideNoPostsView()
            }
            tableView.reloadData()
            fetchMyProfile()
        } else {
            fetchOthersProfile(userId: othersUserId!)
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isFromNotification { // Reset all the values
            isFirstProfile = true
            hasMoreMyCreations = false
            isFromNotification = false
            hasMoreMyReaction = false
            pageNumberForMyCreations = 1
            pageNumberForMyReactions = 1
            othersUserId = nil
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsetsMake(283, 0.0, 0.0, 0.0)
        tableView.scrollRectToVisible(CGRect(x:0,y:0,width: 1,height: 1), animated: false)
    }
    
    func setupUI() {
        blurredImageView.contentMode = .scaleAspectFill
        blurredImageView.alpha = 1.0
        followBtnImageView.tintColor = ColorConstants.kWhiteColorKey
        profileImageView.layer.borderWidth = 2.0
        profileImageView.layer.borderColor = ColorConstants.kBackgroundGrayColor.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height/2
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        followBtnImageView.tintColor = ColorConstants.kWhiteColorKey
        followBtnImageView.image = #imageLiteral(resourceName: "ic_select_tick_icon")
        userNameTitleLbl.isHidden = true
        
        postVideoBtn.clipsToBounds = true
        postVideoBtn.layer.cornerRadius = postVideoBtn.frame.size.height / 2
        
        self.statsView.isHidden = true
        self.profileDetailsView.isHidden = true
        tableView.isUserInteractionEnabled = true
        
        backBtn.isHidden = isFirstProfile
        
        reportView.isHidden = true
        reportView.alpha = 0
        reportView.dropShadow(color: .gray, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        
        if othersUserId == nil || (othersUserId != nil && isMyself == true) {
            followBtnView.isHidden = true
            
            shareBtnView.layer.borderWidth = 1.0
            shareBtnView.layer.borderColor = UIColor.white.cgColor
            shareBtnView.clipsToBounds = true
            shareBtnView.layer.cornerRadius = shareBtnView.frame.size.height/2
            
            editBtnView.clipsToBounds = true
            editBtnView.layer.cornerRadius = editBtnView.frame.size.height/2
            editBtnView.layer.borderColor = UIColor.white.cgColor
            editBtnView.layer.borderWidth = 1.0
            
            moreBtn.isHidden = true
        } else {
            shareBtnView.isHidden = true
            editBtnView.isHidden = true
            followBtnView.isHidden = false
            followBtnView.clipsToBounds = true
            followBtnView.layer.cornerRadius = editBtnView.frame.size.height/2
            followBtnView.layer.borderColor = UIColor.white.cgColor
            followBtnView.layer.borderWidth = 1.0
           
            settingBtn.isHidden = true
            
            if isFollowing == true {
                followBtnImageView.isHidden = false
                followBtnLbl.text = "Following"
                followBtnImageView.tintColor = ColorConstants.kWhiteColorKey
            } else if isRequested == true {
                followBtnImageView.isHidden = true
                followBtnLbl.text = "Requested"
                followBtnLbl.frame.origin.x = 18

            } else {
                followBtnImageView.isHidden = true
                followBtnImageView.image = UIImage(named: "ic_follow")
                followBtnLbl.text = "Follow"
                followBtnLbl.frame.origin.x = 27
            }
            
            moreBtn.isHidden = true
            blockLabel.text = (friendProfile?.followInfo?.blocked == true) ? "Unblock" : "Block"
            
        }
        
        creationBtn.isEnabled = !isAccountPrivate
        followingBtn.isEnabled = !isAccountPrivate || (isAccountPrivate && isFollowing!)
        followersBtn.isEnabled = !isAccountPrivate || (isAccountPrivate && isFollowing!)
    
    }
    func loadtableView() {
        if othersUserId == nil || (othersUserId != nil && isMyself == true) {
            let pageNo = (selectedVideosSection == .kMyCreations) ? pageNumberForMyCreations : pageNumberForMyReactions
            loadTableView(pageNo: pageNo)
        } else {
            if isBlocked == true {
                isAccountPrivate = true
            }
            
            if !isAccountPrivate {
                loadTableViewForOthers(pageNo: pageNumberForMyCreations, userId: othersUserId!)
            } else if isAccountPrivate == true && isFollowing! == false {
                showPrivateAccountView()
            }else if isAccountPrivate && isFollowing! {
                loadTableViewForOthers(pageNo: pageNumberForMyCreations, userId: othersUserId!)
            }else {
                privateAccountMsgView.isHidden = true
                privateAccountMsgLbl.isHidden = true
            }
        }
        
    }

    func share(message: String, link: String) {
        if let link = NSURL(string: link) {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            self.present(activityVC, animated: true, completion: nil)
        }
    }

    func setupSegmentControlView() {
        if othersUserId == nil || (othersUserId != nil && isMyself == true) {
            let items = ["My Creations","My Reactions"]
            let segmentedControl = UISegmentedControl(items: items)
            segmentedControl.frame = CGRect(x: 15, y: 15.0, width: UIScreen.main.bounds.width - 30, height: 29.0)
            segmentedControl.tintColor = ColorConstants.kAppGreenColor
            segmentedControl.backgroundColor = UIColor.white
            segmentedControl.layer.cornerRadius = 4.0
            segmentedControl.selectedSegmentIndex = selectedVideosSection.rawValue
            
            segmentedControl.addTarget(self, action: #selector(self.segmentedControlChanged(sender:)), for: .valueChanged)
            
            segmentView.addSubview(segmentedControl)
        } else {
            let label = UILabel(frame: CGRect(x: 15, y: 15, width: UIScreen.main.bounds.width - 15.0, height: 17.0))
            label.text = "Creations"
            label.font = UIFont(name: Constants.kProximaNovaBold, size: 14.0)
            label.textColor = ColorConstants.kTextBlackColor
            
            segmentView.addSubview(label)
        }
    }
    
    
    @objc func segmentedControlChanged(sender:UISegmentedControl) {
        selectedVideosSection = ProfileVideos.init(rawValue: sender.selectedSegmentIndex)!
        if selectedVideosSection == .kMyCreations {
            if (othersUserId == nil || (othersUserId != nil && isMyself == true)) {
                hideNoReactionView()
                hideNoPostsView()
                if myPostsList.count > 0 {
                    tableView.reloadData()
                } else {
                    loadTableView(pageNo: pageNumberForMyCreations)
                }
            }
        } else if selectedVideosSection == .kMyReactions && myReactions.count == 0 {
            hideNoReactionView()
            hideNoPostsView()
            loadTableView(pageNo: pageNumberForMyReactions)
        } else {
            hideNoPostsView()
            hideNoReactionView()
            tableView.reloadData()
        }
    }
    
    func loadTableView(pageNo:Int) {
        if othersUserId == nil || (othersUserId != nil && isMyself == true) {
             (selectedVideosSection == ProfileVideos.kMyCreations) ? fetchMyCreations(pageNo: pageNo) : fetchMyReactions(pageNo: pageNo)
        } else {
            fetchOthersCreations(pageNo: pageNo, userId:othersUserId!)
        }
      
    }
    
    func loadTableViewForOthers(pageNo: Int, userId: Int) {
        fetchOthersCreations(pageNo: pageNo, userId: userId)
    }
    
  
    
    func showNoPostsView(forOthers:Bool) {
        errorView.isHidden = false
        noPostMsgLbl.isHidden = false
        if forOthers {
            postVideoBtn.isHidden = true
            noPostMsgLbl.text = "This user has no creation"
        } else {
            postVideoBtn.isHidden = false
        }
    }
    
    func hideNoPostsView() {
        errorView.isHidden = true
        noPostMsgLbl.isHidden = true
        postVideoBtn.isHidden = true
    }
    
    func showNoReactionView(forOthers:Bool) {
        errorView.isHidden = false
        noReactionMsgLbl.isHidden = false
        noReactionMsgLbl2.isHidden = false
        if forOthers {
            noReactionMsgLbl.text = "There are no reactions to show"
        }
    }
    
    func hideNoReactionView() {
        errorView.isHidden = true
        noReactionMsgLbl.isHidden = true
        noReactionMsgLbl2.isHidden = true
    }
    
    func showPrivateAccountView() {
        privateAccountMsgView.isHidden = false
        privateAccountMsgLbl.isHidden = false
    }
    
    func hidePrivateAccountView() {
        privateAccountMsgView.isHidden = true
        privateAccountMsgLbl.isHidden = true
    }
    
    func showPopoverReportTypesListViewController(dataSource:[ReportType]) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
            let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
            reportVC.reportTypesList = dataSource
            reportVC.isFromReportPost = false
            reportVC.userId = self.userProfile?.user?.userId
//            reportVC.reportTypeSelectedBlock = { [weak self] (reportType) in
//
//                let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
//                let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListDetailViewController") as! ReportListDetailViewController
//                self?.navigationController?.pushViewController(reportVC, animated: true)
//               // self?.reportTheProfile(reportType: reportType)
//            }
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
    

    
    @IBAction func settingBtnTapped(_ sender: Any) {
        guard let _ = userProfile?.user else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
        let settingsVC   = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.userProfile = userProfile
        settingsVC.updateUserProfile = { (profile) in
            settingsVC.userProfile = profile
        }
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }

    
    @IBAction func editButtonTapped(_ sender: Any) {
        guard let user = userProfile?.user else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let editVC   = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editVC.user = user
        editVC.updatedProfileImage = updatedProfileImage
        editVC.updatedThumbnailProfileImage = updatedThumbnailProfileImage
//        editVC.updateProfileImageBlock = { [weak self] (imageData) in
//            UserProfileAPIHandler().uploadProfileMedia(imageData: imageData, completionHandler: { [weak self] (responseData) in
//                if responseData.isVideoUploaded == true {
//                    //self?.view.makeToast("Profile picture updated successfully")
//                }
//            })
//        }
        navigationController?.pushViewController(editVC, animated: true)
    }

    
    @IBAction func shareBtnTapped(_ sender: Any) {
        guard let personId = userProfile?.user?.userId else {
            return
        }
        
        let params:[String:String] = [
            Constants.kDeepLinkUserIdKey  :   "\(personId)"
        ]
        
        let branch = BranchDeepLink(title: "Teazer App", description: "To know more about me follow me on Teazer", imageUrl: userProfile?.user?.profileMedia?.mediaUrl, channel: "Social")
        branch.createDeepLinks(params: params, viewController: self)
    }
    
    @IBAction func followBtnTapped(_ sender: Any) {
        guard let isFollowing = friendProfile?.followInfo?.isFollowing, let userId = friendProfile?.friend?.userId, let isPrivate = friendProfile?.friend?.accountType else {
            return
        }
        
        if friendProfile?.followInfo?.blocked == true {
            ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Blocked", actionTitle: "Unblock", message: "This user is blocked. Tap Unblock to unblock the user.", forVC: self, completionBlock: { [weak self] (action) in
                self?.unblockUser()
                self?.followBtnLbl.text = "Follow"
            })
            return
        }
        
        if followBtnLbl.text == "Requested" {
            let alert = UIAlertController(title: "Request", message: "Do you want to cancel the follow request ?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                self.followBtnLbl.frame.origin.x = 27
                self.followBtnLbl.text = "Follow"
                self.cancelSentRequest(userId: userId)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.navigationController?.present(alert, animated: false, completion: nil)
            return
        }
       
        if isFollowing == false && followBtnLbl.text == "Follow" {
            followBtnLbl.text = (isPrivate == 1) ? "Requested" : "Following"
            followBtnLbl.frame.origin.x = (isPrivate == 1) ? 18 : 27
            DispatchQueue.main.async {
                self.followBtnImageView.isHidden = (isPrivate == 1) ? true : false
            }
            followUser(userId: userId, isPrivate: isPrivate)
            
        } else if followBtnLbl.text == "Accept" {
            followBtnLbl.text = (isFollowing) ? "Following" : "Follow"
            DispatchQueue.main.async {
                self.followBtnImageView.isHidden = (self.followBtnLbl.text == "Following") ? false : true
            }
            acceptJoinRequest()
            
        } else {
            let alert = UIAlertController(title: "Unfollow", message: "Do you want to unfollow this user?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Unfollow", style: .default, handler: { (action) in
                self.followBtnLbl.text = "Follow"
                self.followBtnLbl.frame.origin.x = 27
                DispatchQueue.main.async {
                    self.followBtnImageView.isHidden = true
                }
                self.unFollowUser(userId: userId)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            self.navigationController?.present(alert, animated: false, completion: nil)
        }
    }
    
    @IBAction func followingBtnTapped(_ sender: Any) {
        if isBlocked == true {
            return
        }
        if othersUserId != nil {
            if friendProfile?.following == 0 {
                return
            }
        } else {
            if userProfile?.following == 0 {
                return
            }
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let followingVC = storyboard.instantiateViewController(withIdentifier: "FollowingListViewController") as! FollowingListViewController
        followingVC.friendUserId = othersUserId
//        followingVC.isMyProfile = isMyself
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    
    @IBAction func followersBtnTapped(_ sender: Any) {
        if isBlocked == true {
            return
        }
        
        if othersUserId != nil {
            if friendProfile?.followers == 0 {
                return
            }
        } else {
            if userProfile?.followers == 0 {
                return
            }
        }
        
        let storyboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let followersVC = storyboard.instantiateViewController(withIdentifier: "PeopleFollowListViewController") as! PeopleFollowListViewController
//        followersVC.otherUserId = othersUserId
//        followersVC.isMyself = isMyself
        navigationController?.pushViewController(followersVC, animated: true)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func postVideoButtonTapped(_ sender: UIButton) {
        let tabbar = tabBarController as! TabbarViewController
        tabbar.selectedIndex = TabbarControllerIndex.kCameraVCIndex.rawValue
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Report Profile", style: .destructive, handler: { _ in
            guard let userId = self.friendProfile?.friend?.userId else {
                return
            }
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
                let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
                reportVC.isFromReportPost = false
                reportVC.userId = userId
                self.navigationController?.pushViewController(reportVC, animated: true)
            }
        }))
        if blockTitle == "Block" {
            alert.addAction(UIAlertAction(title: blockTitle, style: .destructive, handler: { _ in
                ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Block", actionTitle: "Confirm", message: "Do you want to block the user ?", forVC: self) { [weak self] (action) in
                    self?.blockUser()
                    self?.blockTitle = "Unblock"
                }
            }))
        } else if blockTitle == "Unblock" {
            alert.addAction(UIAlertAction(title: blockTitle, style: .destructive, handler: { _ in
                ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Blocked", actionTitle: "Confirm", message: "Do you want to unblock this user ?", forVC: self) { [weak self] (action) in
                    self?.unblockUser()
                    self?.blockTitle = "Block"
                }
            }))
        }
      
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func blockButtonTapped(_ sender: UIButton) {
        if blockLabel.text == "Block" {
      
        }else{
            ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Blocked", actionTitle: "Do you want to unblock the user ?", message: "", forVC: self) { [weak self] (action) in
                self?.unblockUser()
        }
    }
}
    @IBAction func reportButtonTapped(_ sender: UIButton) {
        
    }
}

    
extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        var numberOfRows: Int = 0
        if self.selectedVideosSection == ProfileVideos.kMyCreations {
            let creationsCount = (othersUserId == nil || (othersUserId != nil && isMyself == true)) ? myPostsList.count : othersPostsList.count
            if creationsCount != 0 {
                tableView.separatorStyle = .singleLine
                numberOfRows = creationsCount
                tableView.backgroundView = nil
            } else {
                tableView.separatorStyle  = .none
            }
        } else {
            if myReactions.count != 0 {
                tableView.separatorStyle = .singleLine
                numberOfRows = myReactions.count
                tableView.backgroundView = nil
            } else {
                tableView.separatorStyle  = .none
            }
        }
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 262.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileVideoTableViewCell") as! UserProfileVideoTableViewCell
        
        cell.deleteView.isHidden = true
        if self.selectedVideosSection == ProfileVideos.kMyCreations {
            let postDetails = (othersUserId == nil || (othersUserId != nil && isMyself == true)) ? myPostsList[indexPath.row] : othersPostsList[indexPath.row]
            cell.moreButtonBlock = { [weak self] in
                let mediaUrl = postDetails.mediaList![0].mediaUrl
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Edit Post", style: .destructive, handler: { _ in
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let videoUploadVC = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
                        videoUploadVC.postDetails = postDetails
                        videoUploadVC.isEditPost = true
                        videoUploadVC.videoURL = NSURL(fileURLWithPath: mediaUrl!) as URL!
                        self?.navigationController?.pushViewController(videoUploadVC, animated: true)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Are you sure you want to delete your post?", actionTitle: "Delete", message: "", forVC: self) { [weak self] (action) in
                        UserProfileAPIHandler().deletePost(postDetails.postId!) {  (responseData) in
                            if let error = responseData.errorObject {
                                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                                return
                            }
                            
                            if let message = responseData.message {
                                self?.view.makeToast("\(message)")
                            }
                            
                            if responseData.status == true {
                                // Delete post
                            }
                        }
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            cell.setupCellforPost(post: postDetails)
            if let postImage = AppImageCache.fetchPostImage(postId: postDetails.postId!) {
                DispatchQueue.main.async {
                    cell.videoImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.videoImageView.image = nil
                }
            }
            if let list = postDetails.mediaList, list.count > 0 {
                if let urlStr = list[0].thumbUrl {
                    CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postDetails.postId!, completion: { (image, key) in
                        DispatchQueue.main.async { [weak self] in
                            if let cell = self?.tableView.cellForRow(at: indexPath) as? UserProfileVideoTableViewCell {
                                cell.videoImageView.image = image
                            }
                            AppImageCache.savePostImage(image: image, postId: key)
                        }
                    })
                }
            }
            
            cell.reportPostBlock = {[weak self] in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { _ in
                    DispatchQueue.main.async {
                        let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
                        let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
                        reportVC.isFromReportPost = true
                        reportVC.isFromProfile = true
                        reportVC.post = postDetails
                        self?.navigationController?.pushViewController(reportVC, animated: true)
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        } else {
            let post = myReactions[indexPath.row]
            cell.deleteVideoTappedBlock = { [weak self] in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Are you sure you want to delete your reaction?", actionTitle: "Delete", message: "", forVC: self) { [weak self] (action) in
                        UserProfileAPIHandler().deleteReaction(post.reactId!) {  (responseData) in
                            
                            if let error = responseData.errorObject {
                                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                                return
                            }
                            if let message = responseData.message {
                                self?.view.makeToast("\(message)")
                            }
                            
                            if responseData.status == true {
                                DispatchQueue.main.async {
                                    self?.myReactions.remove(at: indexPath.row)
                                    self?.tableView.reloadData()
                                    if self?.myReactions.count == 0 {
                                        self?.showNoReactionView(forOthers: false)
                                    }
                                }
                            }
                        }
                    }
                }))
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
            cell.setupCellforReaction(reaction: post)
            if let reactionImage = AppImageCache.fetchReactionImage(reactionId: post.reactId!) {
                DispatchQueue.main.async {
                    cell.videoImageView.image = reactionImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.videoImageView.image = nil
                }
            }
              if post.mediaDetails?.mediaType == 4 {
                DispatchQueue.global(qos: .background).async {
                        //self.loadGif(url: post.mediaDetails!.externalMeta!, imageView: cell.videoImageView)
                    
                }
            } else {
                if let urlStr = post.mediaDetails?.thumbUrl {
                    CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.reactId!, completion: { (image, key) in
                        DispatchQueue.main.async { [weak self] in
                            if let cell = self?.tableView.cellForRow(at: indexPath) as? UserProfileVideoTableViewCell {
                                cell.videoImageView.image = image
                            }
                            AppImageCache.saveReactionImage(image: image, reactionId: key)
                        }
                    })
                }
            }
        }
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedVideosSection == .kMyCreations {
            let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
            destinationVC.postId = (othersUserId != nil && isMyself == false) ? othersPostsList[indexPath.row].postId : myPostsList[indexPath.row].postId
            isComingFromHomeDetail = true
            self.navigationController?.pushViewController(destinationVC, animated: true)
        } else {
            let reaction = myReactions[indexPath.row]
            guard (reaction.mediaDetails?.mediaUrl) != nil else {
                return
            }
            let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "ReactionDetailsViewController") as! ReactionDetailsViewController
            destinationVC.reaction = reaction
            destinationVC.userProfile = userProfile
            destinationVC.myReaction = true
            destinationVC.updateReactionBlock = { [weak self] (views, likes) in
                if let list = self?.myReactions, likes != nil {
                    if list.count > indexPath.row {
                        self?.myReactions[indexPath.row].canLike = (likes! > 0) ? false : true
                        self?.myReactions[indexPath.row].likes! += likes!
                        DispatchQueue.main.async {
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    }
                }
            }
            navigationController?.present(destinationVC, animated: true, completion: nil)
        }
    }
}

extension UserProfileViewController {
    
    func fetchMyProfile() {
        UserProfileAPIHandler().getUserProfile() { [weak self] (responseData) in
            if let error = responseData.errorObject {
               ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let user = responseData.user {
                strongSelf.userProfile = responseData
                strongSelf.setupData(user: user)
            }
        }
    }
    
    func fetchOthersProfile(userId: Int) {
        UserProfileAPIHandler().getOtherProfileDetails(userId) {  [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let user = responseData.friend {
                strongSelf.friendProfile = responseData
                strongSelf.setupDataForFriend(user: user)
            }
        }
    }
    
    func setupData(user: User) {
        if let image = AppImageCache.fetchMyProfileImage() {
            profileImageView.image = image
        } else {
            if let mediaURL = user.profileMedia?.mediaUrl {
                downloadProfileImage(url: mediaURL, userId: nil)
            } else {
                profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
    
        if let image = AppImageCache.fetchMyCoverImage() {
            blurredImageView.image = image
        } else {
            if let mediaURL = user.profileMedia?.thumbUrl {
                downloadCoverImage(url: mediaURL, userId: nil)
            } else {
                profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        fullName.text = user.userName
        userNameTitleLbl.text = "@" + user.userName!
        usernameLabel.text = "\u{25CF} \(user.firstName!) \(user.lastName ?? "")"
        bioLabel.text = user.description ?? ""
        creationBtn.setTitle("\(userProfile!.totalVideo!) Creations", for: .normal)
        followersBtn.setTitle("\(userProfile!.followers!) Followers", for: .normal)
        followingBtn.setTitle("\(userProfile!.following!) Following", for: .normal)
        statsView.isHidden = false
        profileDetailsView.isHidden = false
    
    }
    
    func setupDataForFriend(user: Friend) {
        if let image = AppImageCache.fetchOthersProfileImage(userId: user.userId!) {
            profileImageView.image = image
        } else {
            if let mediaURL = user.profileMedia?.mediaUrl {
                downloadProfileImage(url: mediaURL, userId: user.userId!)
            } else {
                profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        if let image = AppImageCache.fetchOthersCoverImage(userId: user.userId!) {
            blurredImageView.image = image
        } else {
            if let mediaURL = user.profileMedia?.thumbUrl {
                downloadCoverImage(url: mediaURL, userId: user.userId!)
            } else {
                profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        fullName.text = user.userName
        userNameTitleLbl.text = "@" + user.userName!
        usernameLabel.text = "\u{25CF} \(user.firstName!) \(user.lastName ?? "")"
        bioLabel.text = user.bio ?? ""
        creationBtn.setTitle("\(friendProfile!.totalVideo!) Creations", for: .normal)
        followersBtn.setTitle("\(friendProfile!.followers!) Followers", for: .normal)
        followingBtn.setTitle("\(friendProfile!.following!) Following", for: .normal)
        statsView.isHidden = false
        profileDetailsView.isHidden = false
        
        blockLabel.text = (friendProfile?.followInfo?.blocked == true) ? "Unblock" : "Block"
        moreBtn.isHidden = false
        
        if isBlocked == true || friendProfile?.followInfo?.blocked == true {
            followBtnLbl.text = "Blocked"
            DispatchQueue.main.async {
                self.followBtnImageView.isHidden = true
            }
            followBtnLbl.frame.origin.x = 27
        } else {
            if friendProfile?.followInfo?.isRequestReceived == true {
                followBtnLbl.text = "Accept"
                DispatchQueue.main.async {
                    self.followBtnImageView.isHidden = true
                }
                followBtnLbl.frame.origin.x = 27
            } else {
                if friendProfile?.friend?.accountType == 1 {
                    if friendProfile?.followInfo?.isRequestSent == true {
                        followBtnLbl.text = "Requested"
                        DispatchQueue.main.async {
                            self.followBtnImageView.isHidden = true
                        }
                        followBtnLbl.frame.origin.x = 18
                    } else {
                        followBtnLbl.text = (friendProfile?.followInfo?.isFollowing == true) ? "Following" : "Follow"
                        if followBtnLbl.text == "Following" {
                            followBtnImageView.isHidden = false
                            followBtnLbl.frame.origin.x = 27
                        } else {
                            followBtnImageView.isHidden = true
                            followBtnLbl.frame.origin.x = 27
                        }
                    }
                } else {
                    followBtnLbl.text = (friendProfile?.followInfo?.isFollowing == true) ? "Following" : "Follow"
                    if followBtnLbl.text == "Following" {
                        DispatchQueue.main.async {
                            self.followBtnImageView.isHidden = false
                        }
                        followBtnLbl.frame.origin.x = 27
                    } else {
                        DispatchQueue.main.async {
                            self.followBtnImageView.isHidden = true
                        }
                        followBtnLbl.frame.origin.x = 27
                    }
                }
            }
        }
    }
    
    func fetchMyCreations(pageNo:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getUserPosts(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
                self?.refreshControl?.endRefreshing()
                self?.loaderView?.removeLoaderView()
                self?.loaderView = nil
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let myVideos = responseData.posts, myVideos.count > 0 {
                if let value = responseData.nextPage {
                    strongSelf.hasMoreMyCreations = value
                }
                
                if pageNo == 1 {
                    DispatchQueue.main.async {
                        self?.myPostsList = Array(myVideos)
                        self?.hideNoPostsView()
                        self?.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        let firstIndex = self!.myPostsList.count
                        var i = 0
                        for post in myVideos {
                            let indexPath = IndexPath(item: firstIndex + i, section: 0)
                            self?.myPostsList.append(post)
                            self?.tableView.insertRows(at: [indexPath], with: .automatic)
                            i += 1
                        }
                    }
                }
            } else {
                if self?.selectedVideosSection == .kMyReactions {
                    return
                }
                DispatchQueue.main.async {
                    self?.showNoPostsView(forOthers: false)
                }
            }
        }
    }
    
    func fetchMyReactions(pageNo:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getUserReactions(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
                self?.refreshControl?.endRefreshing()
                self?.loaderView?.removeLoaderView()
                self?.loaderView = nil
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let myReactions = responseData.reactions, myReactions.count > 0 {
                DispatchQueue.main.async {
                    self?.hideNoReactionView()
                    if let value = responseData.nextPage {
                        strongSelf.hasMoreMyReaction = value
                    }
                    if strongSelf.pageNumberForMyReactions == 1 {
                        strongSelf.myReactions = Array(myReactions)
                        strongSelf.tableView.reloadData()
                    } else {
                        let firstIndex = self!.myReactions.count
                        var i = 0
                        for reaction in myReactions {
                            let indexPath = IndexPath(item: firstIndex + i, section: 0)
                            self?.myReactions.append(reaction)
                            self?.tableView.insertRows(at: [indexPath], with: .automatic)
                            i += 1
                        }
                    }
                }
            } else if pageNo == 1 {
                if self?.selectedVideosSection == .kMyCreations {
                    return
                }
                DispatchQueue.main.async {
                    self?.showNoReactionView(forOthers: false)
                }
            }
        }
    }
    
    
    
    func fetchOthersCreations(pageNo:Int, userId:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getOtherPost(pageNo, userId: userId) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
                self?.refreshControl?.endRefreshing()
                self?.loaderView?.removeLoaderView()
                self?.loaderView = nil
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let othersVideos = responseData.posts, othersVideos.count > 0 {
                self?.hideNoPostsView()
                self?.hidePrivateAccountView()
                if let value = responseData.nextPage {
                    strongSelf.hasMoreMyCreations = value
                }
                
                if pageNo == 1 {
                    DispatchQueue.main.async {
                        self?.othersPostsList = Array(othersVideos)
                        self?.hideNoPostsView()
                        self?.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        let firstIndex = self!.myPostsList.count
                        var i = 0
                        for post in othersVideos {
                            let indexPath = IndexPath(item: firstIndex + i, section: 0)
                            self?.othersPostsList.append(post)
                            self?.tableView.insertRows(at: [indexPath], with: .automatic)
                            i += 1
                        }
                    }
                }
            } else if pageNo == 1 {
                DispatchQueue.main.async {
                    if self?.isAccountPrivate == true {
                        self?.showPrivateAccountView()
                    } else {
                        self?.showNoPostsView(forOthers: true)
                    }
                }
            }
        }
    }
    
    func reportTheProfile(reportType:ReportType) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
      
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        let params:[String:Any] = [
            "user_id"           :       othersUserId!,
            "report_type_id"    :       reportType.reportTypeId!
        ]
        UserProfileAPIHandler().reportUser(param: params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
           if responseData.status == true {
                self?.view.makeToast("Reported successfully")
                self?.blockUser()
            } else {
                self?.view.makeToast("There is some problem reporting this user.")
            }
        })
    }
    
    func subReportTheProfile(reportType:SubReports) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        let params:[String:Any] = [
            "user_id"           :       othersUserId!,
            "report_type_id"    :       reportType.reportTypeId!
        ]
        UserProfileAPIHandler().reportUser(param: params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if responseData.status == true {
                self?.view.makeToast("Reported successfully")
                self?.blockUser()
            } else {
                self?.view.makeToast("There is some problem reporting this user.")
            }
        })
    }
    
    func blockUser() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        UserProfileAPIHandler().blockUser(othersUserId!, 1, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if responseData.status == true {
                let list = PostCacheData.shared.fetchPostsForUserId(self!.othersUserId!)
                NotificationsCacheData.shared.deleteNotificationsByUserId(userId: self!.othersUserId!)
                PostCacheData.shared.deletePostsList(list: list, completionBlock: {
                    DispatchQueue.main.async {
                        self?.isBlocked = true
                        self?.showPrivateAccountView()
                        self?.blockTitle = "Unblock"
                        self?.view.makeToast("User blocked successfully")
                        //self?.blockLabel.text = "Unblock"
                        self?.friendProfile?.followInfo?.blocked = true
                        self?.friendProfile?.followInfo?.isFollowing = false
                        self?.setupDataForFriend(user: self!.friendProfile!.friend!)
                    }
                }) 
            } else {
                DispatchQueue.main.async {
                    self?.view.makeToast("User cannot be blocked. Please try again later")
                }
            }
        })
    }
    
    func unblockUser() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        UserProfileAPIHandler().blockUser(othersUserId!, 2, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if responseData.status == true {
                self?.isBlocked = false
                self?.blockTitle = "Block"
                if self?.friendProfile?.friend?.accountType == 2 {
                    self?.hidePrivateAccountView()
                    self?.fetchOthersCreations(pageNo:1, userId:(self?.othersUserId)!)
                }
                self?.view.makeToast("User unblocked successfully")
                self?.blockLabel.text = "Block"
                self?.followBtnLbl.text = "Follow"
                self?.friendProfile?.followInfo?.blocked = false
            } else {
               self?.view.makeToast("User cannot be unblocked. Please try again.")
            }
        })
    }
    
    func followUser(userId:Int, isPrivate:Int) {
        UserAPIHandler().sendJoinRequestbyUserID(userId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    if isPrivate == 1 {
                        self?.friendProfile?.followInfo?.isRequestSent = true
                    } else {
                        self?.friendProfile?.followInfo?.isFollowing = true
                    }
                }
            }
        })
    }
    
    func unFollowUser(userId:Int) {
        UserProfileAPIHandler().unfollowUser(userId) {  [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
               strongSelf.view.makeToast( error.message)
                return
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    self?.friendProfile?.followInfo?.isFollowing = false
                }
            }
        }
    }
    
    func cancelSentRequest(userId:Int) {
        UserProfileAPIHandler().cancelJoinRequest(userId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
                strongSelf.view.makeToast( error.message)
                return
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    self?.friendProfile?.followInfo?.isRequestSent = false
                }
            }
        })
    }
    
    func acceptJoinRequest() {
        UserAPIHandler().acceptJoinRequest(friendProfile!.followInfo!.requestId!) { (responseData) in

            if let error = responseData.errorObject {
                self.view.makeToast( error.message)
                return
            }

            if responseData.status == true {
                DispatchQueue.main.async {
                    self.friendProfile?.followInfo?.isRequestReceived = false
                }
            }
        }
    }
    
    func downloadProfileImage(url:String, userId:Int?) {
        CommonAPIHandler().getDataFromUrl(imageURL: url, completion: { [weak self] (image) in
            DispatchQueue.main.async {
                if image != nil {
                    let profileImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                    self?.profileImageView.image = profileImage
                    if userId != nil {
                        AppImageCache.saveOthersProfileImage(image: profileImage, userId: userId!)
                    } else {
                        AppImageCache.saveMyProfileImage(image: profileImage)
                    }
                }
            }
        })
    }
    
    func downloadCoverImage(url:String, userId:Int?) {
        CommonAPIHandler().getDataFromUrl(imageURL: url, completion: { [weak self] (image) in
            DispatchQueue.main.async {
                if image != nil {
                    self?.blurredImageView.image = image
                    if userId != nil {
                        AppImageCache.saveOthersProfileImage(image: image, userId: userId!)
                    } else {
                        AppImageCache.saveMyCoverImage(image: image)
                    }
                }
            }
        })
    }
    
//    func loadGif(url: String , imageView: UIImageView) {
//        let dict  = convertToDictionary(text: url)
//            let imageURL = UIImage.gif(url:URL!)
//            let imageView1 = UIImageView(image: imageURL)
//            imageView1.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: imageView.frame.size.height)
//            imageView.addSubview(imageView1)
//        }

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

extension UserProfileViewController: UIScrollViewDelegate {
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl!)
        }
    }
    
    @objc func refreshOptions(sender: UIRefreshControl) {
        if selectedVideosSection == .kMyCreations {
            pageNumberForMyCreations = 1
            ((othersUserId == nil) || (othersUserId != nil && isMyself == true)) ? loadTableView(pageNo: pageNumberForMyCreations) : loadTableViewForOthers(pageNo:1 , userId: othersUserId!)
        } else {
            pageNumberForMyReactions = 1
            loadTableView(pageNo: pageNumberForMyReactions)
        }
    }

    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if selectedVideosSection == .kMyCreations {
            if offsetY + 283 > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasMoreMyCreations {
                pageNumberForMyCreations += 1
                loadTableView(pageNo: pageNumberForMyCreations)
            }
        } else {
            if offsetY + 283 > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasMoreMyCreations {
                pageNumberForMyReactions += 1
                loadTableView(pageNo: pageNumberForMyReactions)
            }
        }
        
        let scrollY = scrollView.contentOffset.y + 283
        userNameTitleLbl.isHidden = true
        if scrollY > 0 {
            profileContentView.frame = CGRect(x: 0, y: 67 - scrollY, width: profileContentView.frame.size.width, height: profileContentView.frame.size.height)
            segmentView.frame = CGRect(x: 0, y: 290 - scrollY, width: profileContentView.frame.size.width, height: segmentView.frame.size.height)
            if scrollY > 224  {
                segmentView.frame = CGRect(x: 0, y: 67, width: profileContentView.frame.size.width, height: segmentView.frame.size.height)
            }
            profileContentView.alpha = 1 - scrollY / 200
            if scrollY > 70 {
                profileTitleLbl.isHidden  = true
                userNameTitleLbl.isHidden = false
                userNameTitleLbl.alpha = (scrollY - 72) / 100
            } else {
                profileTitleLbl.isHidden = false
            }
            
        } else if scrollY < 20.5 {
            profileContentView.frame = CGRect(x: 0, y: 67 , width: profileContentView.frame.size.width, height: profileContentView.frame.size.height)
            segmentView.frame = CGRect(x: 0, y: 290 , width: profileContentView.frame.size.width, height: segmentView.frame.size.height)
            profileContentView.alpha = 1
        }
    }

}

extension UserProfileViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}


