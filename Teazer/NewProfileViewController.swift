//
//  NewProfileViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 19/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

enum RelationTypes:String {
    case kFollow = "Follow"
    case kRequested = "Requested"
    case kFollowing = "Following"
    case kAccept = "Accept"
    case kUnblock = "Unblock"
    case kBlock = "Block"
}

class NewProfileViewController: UIViewController {
    
    @IBOutlet weak var viewToolBar: UIView!
    @IBOutlet weak var viewProfileDetails: UIView!
    @IBOutlet weak var viewProfileImageBackground: UIView!
    @IBOutlet weak var viewUserName: UIView!
    @IBOutlet weak var viewCreations: UIView!
    @IBOutlet weak var viewReactions: UIView!
    @IBOutlet weak var viewFollowers: UIView!
    @IBOutlet weak var viewFollowings: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var viewOthersProfileMyCreation: UIView!
    @IBOutlet weak var viewHeadingButtons: UIView!
    @IBOutlet weak var viewButtonUnderline: UIView!
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var imageToolBar: UIImageView!
    @IBOutlet weak var collectionViewReactions: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lblUserNameTop: UILabel!
    @IBOutlet weak var headerView: ProfileHeaderView!
    @IBOutlet weak var constraintProfileViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintProfileImageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintProfileImageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintUnderlineViewLeading: NSLayoutConstraint!
    @IBOutlet weak var btnSettings: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var btnMyCreations: UIButton!
    @IBOutlet weak var btnMyReactions: UIButton!
    @IBOutlet weak var btnCreations: UIButton!
    @IBOutlet weak var btnReactions: UIButton!
    @IBOutlet weak var btnFollowers: UIButton!
    @IBOutlet weak var btnFollowings: UIButton!
    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var viewTopReactions: UIView!
    @IBOutlet weak var imageFirstReactionProfile: UIImageView!
    @IBOutlet weak var imageSecondReactionProfile: UIImageView!
    @IBOutlet weak var imageThirdReactionProfile: UIImageView!
    @IBOutlet weak var viewFirstReactionProfile: UIView!
    @IBOutlet weak var viewSecondReactionProfile: UIView!
    @IBOutlet weak var viewThirdReactionProfile: UIView!
    @IBOutlet weak var imageViewLikes: UIImageView!
    @IBOutlet weak var lblProfileLikes: UILabel!
    @IBOutlet weak var lblFollow: UILabel!
    
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblUserBio: UILabel!
    @IBOutlet weak var lblCreationsCount: UILabel!
    @IBOutlet weak var lblReactionsCount: UILabel!
    @IBOutlet weak var lblFollowersCount: UILabel!
    @IBOutlet weak var lblFollowingsCount: UILabel!
    
    @IBOutlet weak var viewError: UIView!
    @IBOutlet weak var lblError: UILabel!
    @IBOutlet weak var viewPrivateAccount: UIView!
    
    @IBOutlet weak var imageViewBackButton: UIImageView!
    @IBOutlet weak var btnBack: UIButton!
    
    var refreshControl:UIRefreshControl?
    private let heightTableViewHeader:CGFloat = 485
    private var valueInitialProfileBottomConstraint:CGFloat = 0
    private var heightHeaderView:CGFloat = 0
    private var gradientLayer: CAGradientLayer!
    private var creationsList = [Post]()
    private var reactionsList = [Reaction]()
    private var userProfile: UserProfileDataModal?
    private var friendProfile: FriendProfileDataModal?
    private var isWebserviceCallGoingOn = false
    private var selectedVideosSection:ProfileVideos = .kMyCreations
    private var pageNoForCreations = 1
    private var hasMoreCreations = false
    private var pageNoForReactions = 1
    private var hasMoreReactions = false
    private var followInfo:FollowInfo? {
        didSet {
            updateActionButton()
        }
    }
    
    var isMyProfile = true
    var friendUserId:Int?
    var isUserBlocked = false
    var isBasicProfile = true
    var isFromNotification = false
    var isFromVideo = false
    var isFollowing = false
    var isAccountPrivate = false
    
    //MARK:- Controller life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
        }
        
        if let layout = collectionViewReactions.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.scrollToTopBlockForProfile = { [weak self] in
            DispatchQueue.main.async {
                let area = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
                self?.collectionViewReactions.scrollRectToVisible(area, animated: true)
                self?.collectionView.scrollRectToVisible(area, animated: true)
            }
        }
        
        if isMyProfile {
            tabbarVC.tabBar.isHidden = isFromVideo
            tabbarVC.hideCameraButton(value: isFromVideo)

            imageViewProfile.image = AppImageCache.fetchMyProfileImage()
            imageToolBar.image = AppImageCache.fetchMyCoverImage()
            imageViewCover.image = AppImageCache.fetchMyCoverImage()
            viewFollow.isHidden = true
            fetchMyProfile()
            fetchMyCreations(pageNo: 1)
            fetchMyReactions(pageNo: 1)
        } else if let userId = friendUserId {
            followInfo = UserProfileCache.shared.fetchFriendRelation(friendId: userId)?.followInfo
            lblUserBio.text = ""
            fetchOthersProfile(userId: userId)
            if isAccountPrivate && followInfo?.isFollowing == false {
                showViewForPrivateAccount()
            } else if creationsList.count == 0 {
                hideViewForPrivateAccount()
                fetchOthersCreations(pageNo: 1, userId: userId)
            } else {
                hideViewForPrivateAccount()
            }
        } else {
            setupDefaultProfile()
        }
        
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupView() {
        heightHeaderView = (UIScreen.main.bounds.width < 375) ? ((UIScreen.main.bounds.width * heightTableViewHeader) / 375.0) : heightTableViewHeader
        constraintProfileViewHeight.constant = heightHeaderView
        collectionView.contentInset = UIEdgeInsetsMake(heightHeaderView, 0, 0, 0)
        collectionViewReactions.contentInset = UIEdgeInsetsMake(heightHeaderView, 0, 0, 0)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: viewGradient.bounds.width, height: viewGradient.bounds.height + 10)
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        viewGradient.layer.addSublayer(gradientLayer)
        
        valueInitialProfileBottomConstraint = constraintProfileImageViewBottom.constant
        
        viewToolBar.bringSubview(toFront: lblUserNameTop)
        
        viewOthersProfileMyCreation.isHidden = isMyProfile
        btnEditProfile.isHidden = !isMyProfile
        btnShare.isHidden = !isMyProfile
        
        viewFirstReactionProfile.layer.cornerRadius = 12.0
        viewSecondReactionProfile.layer.cornerRadius = 12.0
        viewThirdReactionProfile.layer.cornerRadius = 12.0
        imageFirstReactionProfile.layer.cornerRadius = 12.0
        imageSecondReactionProfile.layer.cornerRadius = 12.0
        imageThirdReactionProfile.layer.cornerRadius = 12.0
        
        viewFollow.layer.cornerRadius = viewFollow.bounds.height / 2
        viewError.isHidden = true
        
        imageViewBackButton.isHidden = isBasicProfile
        btnBack.isHidden = isBasicProfile
        
        let settingButtonImage = (isMyProfile) ? "ic_settings" : "ic_more"
        btnSettings.setImage(UIImage(named: settingButtonImage), for: .normal)
    }
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl!)
        }
    }
    
    @objc func refreshOptions(sender: UIRefreshControl) {
        if selectedVideosSection == .kMyCreations {
            pageNoForCreations = 1
            if isMyProfile {
                fetchMyCreations(pageNo: pageNoForCreations)
            } else {
                fetchMyReactions(pageNo: pageNoForReactions)
            }
        }
    }
    
    //MARK:- Button action delegates
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        if isMyProfile {
            pushToSettingsViewController()
        } else {
            moreAction()
        }
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        guard let personId = userProfile?.user?.userId else {
            return
        }
        
        let params:[String:String] = [
            Constants.kDeepLinkUserIdKey  :   "\(personId)"
        ]
        
        let branch = BranchDeepLink(title: "Teazer App", description: "To know more about me follow me on Teazer", imageUrl: userProfile?.user?.profileMedia?.mediaUrl, channel: "Social")
        branch.createDeepLinks(params: params, viewController: self)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        guard let user = userProfile?.user else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let editVC = storyboard.instantiateViewController(withIdentifier: "EditProfileViewController") as! EditProfileViewController
        editVC.user = user
        editVC.updateProfileImageBlock = { (profileImageData, coverImageData) in
            if let profileImage = profileImageData {
                UserProfileAPIHandler().uploadProfileMedia(imageData: profileImage, completionHandler: {  (responseData) in
                    if responseData.isVideoUploaded == true {
                        //self?.view.makeToast("Profile picture updated successfully")
                    }
                })
            }
            
            if let coverImage = coverImageData {
                UserProfileAPIHandler().uploadCoverMedia(imageData: coverImage, completionHandler: { (responseData) in
                    if responseData.isVideoUploaded == true {
                        print("Cover image is uploaded")
                    }
                })
            }
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    @IBAction func creationsButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func reactionsButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func followersButtonTapped(_ sender: UIButton) {
        pushToFollowersListViewController()
    }
    
    @IBAction func followingsButtonTapped(_ sender: UIButton) {
        pushToFollowingsListViewController()
    }
    
    @IBAction func myCreationsButtonTapped(_ sender: UIButton) {
        if selectedVideosSection == .kMyCreations {
            return
        }
        
        selectedVideosSection = .kMyCreations
        btnMyReactions.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
        btnMyCreations.setTitleColor(ColorConstants.kAppGreenColor, for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.constraintUnderlineViewLeading.constant = 0
            self.viewButtonUnderline.layoutIfNeeded()
        }
        DispatchQueue.main.async {
            let area = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
            self.collectionViewReactions.scrollRectToVisible(area, animated: true)
            self.collectionView.scrollRectToVisible(area, animated: true)
        }
        
        collectionView.isHidden = false
        collectionViewReactions.isHidden = true
        
        hideErrorView()
        if creationsList.count == 0 {
            showErrorForCreations()
        }
    }
    
    @IBAction func myReactionsButtonTapped(_ sender: UIButton) {
        if selectedVideosSection == .kMyReactions {
            return
        }
        
        selectedVideosSection = .kMyReactions
        btnMyReactions.setTitleColor(ColorConstants.kAppGreenColor, for: .normal)
        btnMyCreations.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
        UIView.animate(withDuration: 0.3) {
            self.constraintUnderlineViewLeading.constant = UIScreen.main.bounds.size.width / 2
            self.viewButtonUnderline.layoutIfNeeded()
        }
        DispatchQueue.main.async {
            let area = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
            self.collectionView.scrollRectToVisible(area, animated: true)
            self.collectionViewReactions.scrollRectToVisible(area, animated: true)
        }
        
        collectionViewReactions.isHidden = false
        collectionView.isHidden = true
        
        hideErrorView()
        if reactionsList.count == 0 {
            showErrorForReactions()
        }
    }

    @IBAction func followButtonTapped(_ sender: UIButton) {
        guard let info = followInfo else {
            return
        }
        
        if info.blocked == true {
            unblockAction()
        } else if info.isRequestReceived == true {
            acceptAction()
        } else if info.isRequestSent == true {
            cancelRequestAction()
        } else if info.isFollowing == true {
            unfollowAction()
        } else {
            followAction()
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

//MARK:- CTA actions
extension NewProfileViewController {
    
    func followAction() {
        guard let friendId = friendUserId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        btnFollow.isEnabled = false
        lblFollow.text = (isAccountPrivate) ? RelationTypes.kRequested.rawValue : RelationTypes.kFollowing.rawValue
        UserAPIHandler().sendJoinRequestbyUserID(friendId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.btnFollow.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                if strongSelf.isAccountPrivate {
                    strongSelf.followInfo?.isRequestSent = true
                } else {
                    strongSelf.followInfo?.isFollowing = true
                }
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
            }
        })
    }
    
    func acceptAction() {
        guard let requestId = followInfo?.requestId, let friendId = friendUserId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        btnFollow.isEnabled = false
        lblFollow.text = (followInfo?.isFollowing == true) ? RelationTypes.kFollowing.rawValue : RelationTypes.kFollow.rawValue
        UserAPIHandler().acceptJoinRequest(requestId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.btnFollow.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                strongSelf.followInfo?.isRequestReceived = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
            }
        })
    }
    
    func unblockAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unblock", style: .destructive, handler: { [weak self] (action) in
            self?.unblockFriend()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func cancelRequestAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel Request", style: .destructive, handler: { [weak self] (action) in
            guard let friendId = self?.friendUserId, Connectivity.isConnectedToInternet() else {
                return
            }
            
            self?.btnFollow.isEnabled = false
            self?.lblFollow.text = RelationTypes.kFollow.rawValue
            UserProfileAPIHandler().cancelJoinRequest(friendId, completionBlock: { (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.btnFollow.isEnabled = true
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    strongSelf.followInfo?.isRequestSent = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func unfollowAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { [weak self] (action) in
            guard let friendId = self?.friendUserId, Connectivity.isConnectedToInternet() else {
                return
            }
            
            self?.btnFollow.isEnabled = false
            self?.lblFollow.text = RelationTypes.kFollow.rawValue
            UserProfileAPIHandler().unfollowUser(friendId, completionBlock: { (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.btnFollow.isEnabled = true
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    strongSelf.followInfo?.isFollowing = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
                    
                    if (strongSelf.isAccountPrivate) {
                        strongSelf.showViewForPrivateAccount()
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func moreAction() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if followInfo?.blocked == true {
            alert.addAction(UIAlertAction.init(title: "Unblock", style: .destructive, handler:  { [weak self] (action) in
                self?.unblockFriend()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Report profile", style: .destructive, handler: { [weak self] (action) in
                self?.pushToReportProfileViewController()
            }))
            alert.addAction(UIAlertAction.init(title: "Block", style: .destructive, handler:  { [weak self] (action) in
                self?.blockFriend()
            }))
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK:- Profile setup
extension NewProfileViewController {
    
    func updateActionButton() {
        guard let info = followInfo else {
            viewFollow.isHidden = true
            return
        }
        
        viewFollow.isHidden = false
        if info.blocked == true {
            lblFollow.text = RelationTypes.kUnblock.rawValue
        } else if info.isRequestReceived == true {
            lblFollow.text = (info.isFollower == true) ? RelationTypes.kFollow.rawValue : RelationTypes.kAccept.rawValue
        } else if info.isRequestSent == true {
            lblFollow.text = RelationTypes.kRequested.rawValue
        } else if info.isFollowing == true {
            lblFollow.text = RelationTypes.kFollowing.rawValue
        } else {
            lblFollow.text = RelationTypes.kFollow.rawValue
        }
    }
    
    func setupDefaultProfile() {
        viewFollow.isHidden = true
    }
    
    func setupMyProfile() {
        guard let user = userProfile?.user else {
            return
        }
    
        if let image = AppImageCache.fetchMyProfileImage() {
            imageViewProfile.image = image
        } else {
            if let mediaURL = user.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        let resizedImage = image?.af_imageAspectScaled(toFit: CGSize(width: 74, height: 74))
                        self?.imageViewProfile.image = resizedImage
                        AppImageCache.saveMyProfileImage(image: resizedImage)
                    }
                })
            } else {
                imageViewProfile.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        if let image = AppImageCache.fetchMyCoverImage() {
            imageViewCover.image = image
        } else {
            if let mediaURL = user.coverMedia?.mediaUrl {
                activityIndicator.startAnimating()
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: UIScreen.main.bounds.width, height: strongSelf.heightHeaderView - 100))
                            strongSelf.imageViewCover.image = resizedImage
                            strongSelf.imageToolBar.image = resizedImage
                            strongSelf.activityIndicator.stopAnimating()
                            AppImageCache.saveMyCoverImage(image: resizedImage)
                        }
                    }
                })
            } else {
                imageViewCover.image = nil
                imageViewCover.backgroundColor = UIColor(rgba: "#DDDDDD")
            }
        }
        
        lblUserName.text = "@" + user.userName!
        lblUserNameTop.text = "@" + user.userName!
        lblFullName.text = "\(user.firstName!) \(user.lastName ?? "")"
        if let details = user.description, details.count > 0 {
            lblUserBio.text = details
        } else {
            lblUserBio.text = "Let others know more about you. Edit your profile to enter bio"
        }
        
        if let creationsCount = userProfile?.totalVideo {
            lblCreationsCount.text = "\(creationsCount)"
        } else {
            lblCreationsCount.text = "0"
        }
        
        if let reactionsCount = userProfile?.totalReactions {
            lblReactionsCount.text = "\(reactionsCount)"
        } else {
            lblReactionsCount.text = "0"
        }
        
        if let followersCount = userProfile?.followers {
            lblFollowersCount.text = "\(followersCount)"
        } else {
            lblFollowersCount.text = "0"
        }

        if let followingsCount = userProfile?.following {
            lblFollowingsCount.text = "\(followingsCount)"
        } else {
            lblFollowingsCount.text = "0"
        }
    }
    
    func setupFriendProfile() {
        guard let user = friendProfile?.friend else {
            return
        }
        
        UserProfileCache.shared.saveFriendRelation(friendProfile: friendProfile)
        followInfo = friendProfile?.followInfo
        
        if let image = AppImageCache.fetchOthersProfileImage(userId: user.userId!) {
            imageViewProfile.image = image
        } else {
            if let mediaURL = user.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        let resizedImage = image?.af_imageAspectScaled(toFit: CGSize(width: 74, height: 74))
                        self?.imageViewProfile.image = resizedImage
                        AppImageCache.saveOthersProfileImage(image: resizedImage, userId: user.userId!)
                    }
                })
            } else {
                imageViewProfile.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        if let image = AppImageCache.fetchOthersCoverImage(userId: user.userId!) {
            imageViewCover.image = image
        } else {
            if let mediaURL = user.profileMedia?.mediaUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: UIScreen.main.bounds.width, height: strongSelf.heightHeaderView - 100))
                            strongSelf.imageViewCover.image = resizedImage
                            strongSelf.imageToolBar.image = resizedImage
                        }
                    }
                })
            } else {
                imageViewCover.image = nil
                imageViewCover.backgroundColor = UIColor(rgba: "#DDDDDD")
            }
        }
        
        lblUserName.text = "@" + user.userName!
        lblUserNameTop.text = "@" + user.userName!
        lblFullName.text = "\(user.firstName!) \(user.lastName ?? "")"
        if let details = user.bio, details.count > 0 {
            lblUserBio.text = details
        } else {
            lblUserBio.text = "Let others know more about you. Edit your profile to enter bio"
        }
        
        if let creationsCount = friendProfile?.totalVideo {
            lblCreationsCount.text = "\(creationsCount)"
        } else {
            lblCreationsCount.text = "0"
        }
        
        if let reactionsCount = friendProfile?.totalReactions {
            lblReactionsCount.text = "\(reactionsCount)"
        } else {
            lblReactionsCount.text = "0"
        }
        
        if let followersCount = friendProfile?.followers {
            lblFollowersCount.text = "\(followersCount)"
        } else {
            lblFollowersCount.text = "0"
        }
        
        if let followingsCount = friendProfile?.following {
            lblFollowingsCount.text = "\(followingsCount)"
        } else {
            lblFollowingsCount.text = "0"
        }
    }
    
}

//MARK:- API Calls for My Profile
extension NewProfileViewController {
    
    func fetchMyProfile() {
        UserProfileAPIHandler().getUserProfile() { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
    
            self?.userProfile = responseData
            self?.setupMyProfile()
        }
    }
    
    func fetchMyCreations(pageNo:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getUserPosts(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.posts, list.count > 0 {
                if let value = responseData.nextPage {
                    strongSelf.hasMoreCreations = value
                }
                
                if pageNo == 1 {
                    DispatchQueue.main.async {
                        strongSelf.creationsList = Array(list)
                        strongSelf.collectionView.reloadData()
                        self?.isWebserviceCallGoingOn = false
                    }
                } else {
                    let firstIndex = strongSelf.creationsList.count
                    strongSelf.collectionView.performBatchUpdates({
                        DispatchQueue.main.async {
                            for i in 0..<list.count {
                                let index = i + firstIndex
                                strongSelf.creationsList.append(list[i])
                                let indexPath = IndexPath(item: index, section: 0)
                                strongSelf.collectionView.insertItems(at: [indexPath])
                            }
                        }
                    }) { [weak self] (true) in
                        self?.isWebserviceCallGoingOn = false
                    }
                }
            } else {
                if strongSelf.selectedVideosSection == .kMyCreations {
                    strongSelf.showErrorForCreations()
                }
            }
        }
    }
    
    
    func fetchMyReactions(pageNo:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getUserReactions(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let myReactions = responseData.reactions, myReactions.count > 0 {
                if let value = responseData.nextPage {
                        strongSelf.hasMoreReactions = value
                    }
                    
                    if pageNo == 1 {
                        DispatchQueue.main.async {
                            strongSelf.reactionsList = Array(myReactions)
                            strongSelf.collectionViewReactions.reloadData()
                            self?.isWebserviceCallGoingOn = false
                        }
                    } else {
                        let firstIndex = strongSelf.reactionsList.count
                        strongSelf.collectionViewReactions.performBatchUpdates({
                            DispatchQueue.main.async {
                                for i in 0..<myReactions.count {
                                    let index = i + firstIndex
                                    strongSelf.reactionsList.append(myReactions[i])
                                    let indexPath = IndexPath(item: index, section: 0)
                                    strongSelf.collectionViewReactions.insertItems(at: [indexPath])
                                }
                            }
                        }) { [weak self] (true) in
                            self?.isWebserviceCallGoingOn = false
                        }
                    }
                } else {
                if strongSelf.selectedVideosSection == .kMyReactions {
                     strongSelf.showErrorForReactions()
                }
            }
        }
    }

    
    func deletePost(postId:Int, indexPath:IndexPath) {
        ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Are you sure you want to delete your post?", actionTitle: "Delete", message: "", forVC: self) { [weak self] (action) in
            UserProfileAPIHandler().deletePost(postId) {  (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = responseData.errorObject {
                    ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                    return
                }
                
                if let message = responseData.message {
                    self?.view.makeToast("\(message)")
                }
                
                if responseData.status == true {
                    DispatchQueue.main.async {
                        strongSelf.creationsList.remove(at: indexPath.row)
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                        if strongSelf.creationsList.count > 0 && indexPath.row < strongSelf.creationsList.count {
                            strongSelf.collectionView.reloadItems(at: [indexPath] )
                        }
                        if strongSelf.creationsList.count == 0 {
                            strongSelf.showErrorForCreations()
                        }
                    }
                }
            }
        }
    }
    
    func deleteReaction(rectionId :Int, indexPath:IndexPath) {
        ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Are you sure you want to delete your reaction?", actionTitle: "Delete", message: "", forVC: self) { [weak self] (action) in
            UserProfileAPIHandler().deleteReaction(rectionId){ (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = responseData.errorObject {
                    ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                    return
                }
                
                if let message = responseData.message {
                    self?.view.makeToast("\(message)")
                }
                
                if responseData.status == true {
                    DispatchQueue.main.async {
                        strongSelf.reactionsList.remove(at: indexPath.row)
                        strongSelf.collectionViewReactions.deleteItems(at: [indexPath])
                        if strongSelf.reactionsList.count > 0 && indexPath.row < strongSelf.reactionsList.count {
                            strongSelf.collectionViewReactions.reloadItems(at: [indexPath] )
                        }
                        if strongSelf.reactionsList.count == 0 {
                            strongSelf.showErrorForReactions()
                        }
                    }
                }
            }
        }
    }

}

//MARK:- API Calls for Others Profile
extension NewProfileViewController {
    
    func fetchOthersProfile(userId: Int) {
        UserProfileAPIHandler().getOtherProfileDetails(userId) {  [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            self?.friendProfile = responseData
            self?.setupFriendProfile()
        }
    }
    
    func fetchOthersCreations(pageNo:Int, userId:Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getOtherPost(pageNo, userId: userId) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.posts, list.count > 0 {
                if let value = responseData.nextPage {
                    strongSelf.hasMoreCreations = value
                }
                
                if pageNo == 1 {
                    DispatchQueue.main.async {
                        strongSelf.creationsList = Array(list)
                        strongSelf.collectionView.reloadData()
                        self?.isWebserviceCallGoingOn = false
                    }
                } else {
                    let firstIndex = strongSelf.creationsList.count
                    strongSelf.collectionView.performBatchUpdates({
                        DispatchQueue.main.async {
                            for i in 0..<list.count {
                                let index = i + firstIndex
                                strongSelf.creationsList.append(list[i])
                                let indexPath = IndexPath(item: index, section: 0)
                                strongSelf.collectionView.insertItems(at: [indexPath])
                            }
                        }
                    }) { [weak self] (true) in
                        self?.isWebserviceCallGoingOn = false
                    }
                }
            } else {
                if strongSelf.selectedVideosSection == .kMyCreations {
                    strongSelf.showErrorForCreations()
                }
            }
        }
    }
    
    func blockFriend() {
        guard let friendId = friendUserId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        lblFollow.text = RelationTypes.kBlock.rawValue
        UserProfileAPIHandler().blockUser(friendId, 1) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.btnFollow.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                strongSelf.followInfo?.blocked = true
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
                if strongSelf.isAccountPrivate {
                    strongSelf.showViewForPrivateAccount()
                }
            }
        }
    }
    
    func unblockFriend() {
        guard let friendId = friendUserId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        lblFollow.text = RelationTypes.kFollow.rawValue
        UserProfileAPIHandler().blockUser(friendId, 2) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.btnFollow.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                strongSelf.followInfo?.blocked = false
                strongSelf.followInfo?.isFollowing = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: strongSelf.followInfo)
            }
        }
    }
    
    func hidePost(postId:Int, status:Int, indexPath:IndexPath) {
        HomeControllerAPIHandler().hidePost(postId, status){ [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
            }
            
            if responseData.status == true {
                strongSelf.creationsList[indexPath.row].isHidden = (status == 1)
                if let cell = strongSelf.collectionView.cellForItem(at: indexPath) as? FeaturesVideosCollectionViewCell {
                    DispatchQueue.main.async {
                        cell.showPostDetails(post: strongSelf.creationsList[indexPath.row])
                    }
                }
            } else {
                self?.view.makeToast(responseData.message)
            }
        }
    }
    
}

//MARK:- UICollection View data source and delegate methods
extension NewProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 101 {
            return creationsList.count
        } else if collectionView.tag == 102 {
            return reactionsList.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturesVideosCollectionViewCell", for: indexPath) as! FeaturesVideosCollectionViewCell
        
        if collectionView.tag == 101 {
            if indexPath.row < creationsList.count {
                let post = creationsList[indexPath.row]
                cell.setupCell(post: post)
                
                cell.profileTappedBlock = { [weak self] (postOwnerId, isMyself) in
                    self?.pushToProfileViewController(postOwnerId: postOwnerId, isMyProfile: isMyself)
                }
                
                cell.moreTappedBlock = { [weak self] in
                    self?.showMoreOptionsForAPost(post: post, indexPath: indexPath)
                }
                
                cell.hideTappedBlock = { [weak self] in
                    self?.hidePost(postId: post.postId!, status: 2, indexPath: indexPath)
                }
                
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = postImage
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = nil
                    }
                }
                
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                            DispatchQueue.main.async {
//                                if let cell = self?.collectionView.cellForItem(at: indexPath) as? FeaturesVideosCollectionViewCell {
//                                    cell.videoImageView.image = image
//                                }
                                cell.videoImageView.image = image
                                AppImageCache.savePostImage(image: image, postId: key)
                            }
                        })
                    }
                } else {
                    cell.hideVides(value: true)
                }
                
                if let postOwnerId = post.postOwner?.userId {
                    if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                        DispatchQueue.main.async {
                            cell.profileImageView.image = postImage
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                        }
                    }
                    if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                            DispatchQueue.main.async {
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
//                                if let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? FeaturesVideosCollectionViewCell {
//                                    cell.profileImageView.image = resizedImage
//                                }
                                cell.profileImageView.image = resizedImage
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                }
            }
        } else if collectionView.tag == 102 {
            if indexPath.row < reactionsList.count {
                let reaction = reactionsList[indexPath.row]
                cell.showReactionDetails(reaction: reaction)
                cell.showReactionOwnerName(userName: userProfile?.user?.userName)
                
                cell.moreTappedBlock = { [weak self] in
                    self?.showMoreOptionForReaction(reaction: reaction, indexPath: indexPath)
                }
                
                if let reactionImage = AppImageCache.fetchReactionImage(reactionId: reaction.reactId!) {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = reactionImage
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = nil
                    }
                }
                
                if let reactionDetails = reaction.mediaDetails {
                    
                    if reactionDetails.mediaType == 4 {
                        loadGif(url: reactionDetails.externalMeta!, imageView: cell.videoImageView, reactionId: reaction.reactId!)
                    }
                    if let urlStr = reactionDetails.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: reaction.reactId!, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                            DispatchQueue.main.async {
//                                if let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? FeaturesVideosCollectionViewCell {
//                                    cell.videoImageView.image = image
//                                }
                                cell.videoImageView.image = image
                                AppImageCache.saveReactionImage(image: image, reactionId: key)
                            }
                        })
                    }
                } else {
                    cell.hideVides(value: true)
                }
                
                if let reactionOwnerId = reaction.reactId {
                    if let reactionImage = AppImageCache.fetchOthersProfileImage(userId: reactionOwnerId) {
                        DispatchQueue.main.async {
                            cell.profileImageView.image = reactionImage
                        }
                    } else {
                        DispatchQueue.main.async {
                            cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                        }
                    }
                    if let urlStr = reaction.reactionOwner?.profileMedia?.thumbUrl! {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: reactionOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                            DispatchQueue.main.async {
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                cell.profileImageView.image = resizedImage
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if selectedVideosSection == .kMyCreations {
            pushToHomeDetailPageViewControllerForPost(index: indexPath.row)
        } else {
            presentReactionDetailPageViewControllerForPost(index: indexPath.row, indexPath: indexPath)
        }
    }
    
}

//MARK:- Custom collection view layout delegate method
extension NewProfileViewController: HomePageLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        if collectionView.tag == 101 {
            let post = creationsList[indexPath.row]
            let height = post.mediaList![0].height! * (UIScreen.main.bounds.width / 2) / post.mediaList![0].width!
            return (height > 175.0)  ? height : 175.0
        } else if collectionView.tag == 102 {
            let reaction = reactionsList[indexPath.row]
            let height = reaction.mediaDetails!.height! * (UIScreen.main.bounds.width / 2) / reaction.mediaDetails!.width!
            return (height > 175.0)  ? height : 175.0
        } else {
            return 0
        }
        
    }

}

extension NewProfileViewController {
    
    func showMoreOptionsForAPost(post:Post, indexPath:IndexPath) {
        if isMyProfile == false {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Hide", style: .destructive, handler: { [weak self] (action) in
                self?.hidePost(postId: post.postId!, status: 1, indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction.init(title: "Report", style: .destructive, handler:  { [weak self] (action) in
                self?.pushToReportPostViewController(postDetails: post)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] (action) in
                self?.pushToEditPostViewController(postDetails: post)
            }))
            alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler:  { [weak self] (action) in
                self?.deletePost(postId: post.postId!, indexPath: indexPath)
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func showMoreOptionForReaction(reaction: Reaction , indexPath : IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteReaction(rectionId: reaction.reactId!, indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

//MARK:- Push controllers on navigation
extension NewProfileViewController {
    
    func pushToProfileViewController(postOwnerId:Int, isMyProfile:Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        destinationVC.friendUserId = postOwnerId
        destinationVC.isFromVideo = true
        destinationVC.isMyProfile = isMyProfile
        destinationVC.isBasicProfile = false
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func pushToFollowersListViewController() {
        if isAccountPrivate == true, followInfo?.isFollowing == false  {
            return
        }
        
        if isUserBlocked == true, userProfile?.followers == 0 {
            return
        }
        
        let storyboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let followersVC = storyboard.instantiateViewController(withIdentifier: "PeopleFollowListViewController") as! PeopleFollowListViewController
        followersVC.friendUserId = friendUserId
        followersVC.isMyProfile = isMyProfile
        navigationController?.pushViewController(followersVC, animated: true)
    }

    func pushToFollowingsListViewController() {
        if isAccountPrivate == true, followInfo?.isFollowing == false  {
            return
        }
        
        if isUserBlocked == true, userProfile?.following == 0 {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let followingVC = storyboard.instantiateViewController(withIdentifier: "FollowingListViewController") as! FollowingListViewController
        followingVC.friendUserId = friendUserId
        followingVC.isMyProfile = isMyProfile
        navigationController?.pushViewController(followingVC, animated: true)
    }
    
    func pushToSettingsViewController() {
        guard let _ = userProfile?.user else {
            return
        }
        
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
        let settingsVC   = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        settingsVC.userProfile = userProfile
        settingsVC.updateUserProfile = { [weak self] (profile) in
            self?.userProfile = profile
        }
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func pushToReportProfileViewController() {
        guard let friendId = friendUserId else {
            return
        }
        
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
            let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
            reportVC.isFromReportPost = false
            reportVC.userId = friendId
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
    
    func pushToHomeDetailPageViewControllerForPost(index:Int) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
        destinationVC.postId = creationsList[index].postId!
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    func presentReactionDetailPageViewControllerForPost(index:Int,indexPath:IndexPath) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ReactionDetailsViewController") as! ReactionDetailsViewController
        destinationVC.reactionId = reactionsList[index].reactId!
        destinationVC.updateReactionBlock = { [weak self] (views, likes) in
            if views != nil {
                self?.reactionsList[indexPath.row].views! += views!
            } else if likes != nil {
                self?.reactionsList[indexPath.row].canLike = (likes! > 0) ? false : true
                self?.reactionsList[indexPath.row].likes! += likes!
            }
            self?.collectionView.reloadItems(at: [indexPath])
        }

        self.navigationController?.present(destinationVC, animated: true, completion: nil)
    }
    
    func pushToReportPostViewController(postDetails:Post) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
        let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListViewController") as! ReportListViewController
        reportVC.isFromReportPost = true
        reportVC.isFromProfile = true
        reportVC.post = postDetails
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(reportVC, animated: true)
        }
    }
    
    func pushToEditPostViewController(postDetails:Post) {
        guard let mediaUrl = postDetails.mediaList![0].mediaUrl else {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let videoUploadVC = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
        videoUploadVC.postDetails = postDetails
        videoUploadVC.isEditPost = true
        videoUploadVC.videoURL = NSURL(fileURLWithPath: mediaUrl) as URL!
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(videoUploadVC, animated: true)
        }
    }
    
}

//MARK:- Error view handling
extension NewProfileViewController {
    
    func showErrorForCreations() {
        DispatchQueue.main.async {
            if self.isMyProfile {
                self.lblError.text = "Your Profile is still empty. Create your first video to start your journey on Teazer."
            } else {
                self.lblError.text = "This user has no creations."
            }
            self.viewError.isHidden = false
        }
    }
    
    func showErrorForReactions() {
        DispatchQueue.main.async {
            self.lblError.text = "Reactions are a new ways to communicate!! Let's start by reacting on the post you like."
            self.viewError.isHidden = false
        }
    }
    
    func hideErrorView() {
        DispatchQueue.main.async {
            self.viewError.isHidden = true
        }
    }
    
    func showViewForPrivateAccount() {
        DispatchQueue.main.async {
            self.viewPrivateAccount.isHidden = false
        }
    }
    
    func hideViewForPrivateAccount() {
        DispatchQueue.main.async {
            self.viewPrivateAccount.isHidden = true
        }
    }
    
    func loadGif(url: String , imageView: UIImageView, reactionId:Int) {
        let dict = convertToDictionary(text: url)
        if let stillDict = dict!["downsized"] as? [String:Any] {
            if (stillDict["url"] as? String) != nil {
                let imageURL = UIImage.gif(url: (stillDict["url"] as? String)!)
                DispatchQueue.main.async {
                    let imageView1 = UIImageView(image: imageURL)
                    imageView.addSubview(imageView1)
                    AppImageCache.saveReactionImage(image: imageURL, reactionId: reactionId)
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

//MARK:- Scroll View delegate method
extension NewProfileViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if heightHeaderView == 0 {
            return
        }
        
        let y = heightHeaderView - (scrollView.contentOffset.y + heightHeaderView)
        let height = min(max(y, 110), 550)
        constraintProfileViewHeight.constant = height
        
        let diff = (heightHeaderView - y) / heightHeaderView
        viewToolBar.alpha = min(max(diff, 0), 0.7)
        imageToolBar.alpha = min(max(diff / 4, 0), 0.3)
        viewProfileDetails.alpha = min(max((y - 110) / 110, 0), 1.0)
        viewUserName.alpha = min(max((y - 110) / 400, 0), 1.0)
        viewCreations.alpha = min(max((y - 110) / 400, 0), 1.0)
        viewReactions.alpha = min(max((y - 110) / 400, 0), 1.0)
        viewFollowers.alpha = min(max((y - 110) / 400, 0), 1.0)
        viewFollowings.alpha = min(max((y - 110) / 400, 0), 1.0)
        
        let imageHeight:CGFloat = (height / 6)
        constraintProfileImageViewHeight.constant = min(max(imageHeight, 30.0), 74.0)
        imageViewProfile.layer.cornerRadius = imageViewProfile.bounds.height / 2
        viewProfileImageBackground.layer.cornerRadius = viewProfileImageBackground.bounds.height / 2
        
        let imageBottomHeight:CGFloat = 12.0 + (height / 3)
        constraintProfileImageViewBottom.constant = min(max(imageBottomHeight, 18.0), 160)
        
        if hasMoreCreations && selectedVideosSection == .kMyCreations {
            if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height && !isWebserviceCallGoingOn {
                pageNoForCreations += 1
                if let othersId = friendUserId {
                    fetchOthersCreations(pageNo: pageNoForCreations, userId: othersId)
                } else {
                    fetchMyCreations(pageNo: pageNoForCreations)
                }
            }
        } else if hasMoreReactions && selectedVideosSection == .kMyReactions {
            if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height && !isWebserviceCallGoingOn {
                pageNoForReactions += 1
                if friendUserId != nil {
                    
                } else {
                    fetchMyReactions(pageNo: pageNoForReactions)
                }
            }
        }
        
    }
}

