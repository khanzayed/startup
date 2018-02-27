//
//  DiscoverNewViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 16/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class DiscoverNewViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollBackgroundView: UIView!
    @IBOutlet weak var mostPopularView: UIView!
    @IBOutlet weak var firstInterestView: UIView!
    @IBOutlet weak var secondInterestView: UIView!
    @IBOutlet weak var thirdInterestView: UIView!
    @IBOutlet weak var trendingView: UIView!
    @IBOutlet weak var featuredView: UIView!
    @IBOutlet weak var viewUploadProgress: UploadProgressView!
    
    @IBOutlet weak var mostPopularHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstInterestViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondInterestViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdInterestViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var trendingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var featuredViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollBackgroundViewHeightConstraint: NSLayoutConstraint! //1572
    
    @IBOutlet weak var mostPopularViewAllBtn: UIButton!
    @IBOutlet weak var myInterestsViewAllBtn: UIButton!
    
    @IBOutlet weak var mostPopularCollectionView: UICollectionView!
    @IBOutlet weak var firstInterestCollectionView: UICollectionView!
    @IBOutlet weak var secondInterestCollectionView: UICollectionView!
    @IBOutlet weak var thirdInterestCollectionView: UICollectionView!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var featuredCollectionView: UICollectionView!
    @IBOutlet weak var lblThirdInterest: UILabel!
    @IBOutlet weak var lblSecondInterest: UILabel!
    @IBOutlet weak var lblFirstInterest: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var pageTitleLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var videoHeaderBtn: UIButton!
    @IBOutlet weak var peopleHeaderBtn: UIButton!
    @IBOutlet weak var headerUnderLineView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchTextView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var cancelBtnTrailingConstraint: NSLayoutConstraint! // -75
    
    var trendingCategories:[Category]?
    var userInterest:[Category]?
    var mostPopularVideos = [Post]()
    var featuredVideos = [Post]()
    var userInterestsVideosDetails = [MyInterestDataModal]()
    var searchUsersResults = [Friend]()
    var searchVideosResults = [Post]()
    
    var featuredVideosCellHeight:CGFloat = 260
    var isVideoSearchSelected = true
    var pageNoForVideosResults = 1
    var pageNoForUsersResults = 1
    var pageNoForFeaturedVideos = 1
    var refreshControl:UIRefreshControl?
    var hasNextForFeaturedVideos = false
    var previousHasNextForFeaturedVideos = false
    var hasNextForVideoResults = false
    var hasNextForUserResults = false
    var isWebserviceCallGoingOn = false
    var lastSelectedIndexpath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        mostPopularCollectionView.delegate = self
        mostPopularCollectionView.dataSource = self
        
        firstInterestCollectionView.delegate = self
        firstInterestCollectionView.dataSource = self
        
        secondInterestCollectionView.delegate = self
        secondInterestCollectionView.dataSource = self
        
        thirdInterestCollectionView.delegate = self
        thirdInterestCollectionView.dataSource = self
        
        trendingCollectionView.delegate = self
        trendingCollectionView.dataSource = self
        
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        searchTextField.delegate = self
        
        if let layout = featuredCollectionView.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
            featuredCollectionView.delegate = self
            featuredCollectionView.dataSource = self
        }
        
        addPullToRefresh()
        
        setupView()
        setDoneOnKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = false
        tabbarVC.hideCameraButton(value: false)
        tabbarVC.scrollToTopBlockForDiscover = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                let topRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 10)
                strongSelf.scrollView.scrollRectToVisible(topRect, animated: true)
            }
        }
        
        if let indexPath = lastSelectedIndexpath, let cell = searchTableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell, indexPath.row < searchUsersResults.count {
            lastSelectedIndexpath = nil
            cell.setupCell(friend: searchUsersResults[indexPath.row])
        }
        
        if mostPopularVideos.count == 0 {
            fetchLandingPage()
        }
        
        if featuredVideos.count == 0 {
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1572)
            featuredVideosCellHeight = 260
            pageNoForFeaturedVideos = 1
            featuredViewHeightConstraint.constant = 260
            scrollBackgroundViewHeightConstraint.constant = 1572
            fetchFeaturedVideos(pageNo: 1)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        searchTextView.layer.cornerRadius = 10.0
//        pageTitleLbl.isHidden = true
        searchView.isHidden = true
        searchTextField.returnKeyType = UIReturnKeyType.search
        
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        searchTextField.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK:- Refresh control
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }
    
    @objc func refreshOptions(sender: UIRefreshControl) {
        pageNoForFeaturedVideos = 1
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1795.0)
        featuredVideosCellHeight = 260
        featuredViewHeightConstraint.constant = 260
        scrollBackgroundViewHeightConstraint.constant = 1795.0
        
        fetchLandingPage()
        fetchFeaturedVideos(pageNo: pageNoForFeaturedVideos)
    }
    
    @IBAction func viewAllMostPopularVideos(sender: UIButton) {
        pushToMostPopularVC()
    }
    
    @IBAction func viewAllMyInterestVideos(sender: UIButton) {
        pushToMyInterestVC()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        searchTextField.resignFirstResponder()
        searchView.isHidden = true
        searchTextField.text = ""
        UIView.animate(withDuration: 0.3) {
            self.cancelBtnTrailingConstraint.constant = -75
            self.topView.layoutIfNeeded()
        }
        searchTableView.delegate = nil
        searchTableView.dataSource = nil
    }
    
    @IBAction func videoTabButtonTapped(_ sender: UIButton) {
        isVideoSearchSelected = true
        peopleHeaderBtn.setTitleColor(UIColor(rgba: "#666666"), for: .normal)
        videoHeaderBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
        searchTableView.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.headerUnderLineView.frame.origin.x = 0
        }
    }
    
    @IBAction func peopleTabButtonTapped(_ sender: UIButton) {
        isVideoSearchSelected = false
        peopleHeaderBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
        videoHeaderBtn.setTitleColor(UIColor(rgba: "#666666"), for: .normal)
        searchTableView.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.headerUnderLineView.frame.origin.x = UIScreen.main.bounds.width / 2
        }
    }
    
}

extension DiscoverNewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isVideoSearchSelected ? searchVideosResults.count : searchUsersResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row == 0) ? 100 : 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as! SearchTableViewCell
        
        if isVideoSearchSelected {
            let post = searchVideosResults[indexPath.row]
            cell.setupCell(withPost: post, isFirstCell: (indexPath.row == 0))
        } else {
            let friend = searchUsersResults[indexPath.row]
            cell.setupCell(withUser: friend, isFirstCell: (indexPath.row == 0))
            
            if let postOwnerId = friend.userId {
                if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                    DispatchQueue.main.async {
                        cell.cellImageView.image = postImage
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.cellImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                }
                if let urlStr = friend.profileMedia?.thumbUrl {
                    CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                        DispatchQueue.main.async { [weak self] in
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                            if let cell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell {
                                cell.cellImageView.image = resizedImage
                            }
                            AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                        }
                    })
                }
            } else {
                DispatchQueue.main.async {
                    cell.cellImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            cell.sendRequestButtonTappedBlock = { [weak self] (userId, isAccountPrivage, info) in
                if info.blocked == true {
                    self?.unblockAction(friendId: userId, followInfo: info, indexPath: indexPath)
                } else if info.isRequestReceived == true {
                    self?.acceptAction(friendId: userId, followInfo: info, indexPath: indexPath)
                } else if info.isRequestSent == true {
                    self?.cancelRequestAction(friendId: userId, followInfo: info, indexPath: indexPath)
                } else if info.isFollowing == true {
                    self?.unfollowAction(friendId: userId, followInfo: info, indexPath: indexPath)
                } else {
                    self?.followAction(friendId: userId, isAccountPrivate: isAccountPrivage,  followInfo: info, indexPath: indexPath)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == searchTableView {
            if isVideoSearchSelected {
                pushToHomeDetailVC(searchVideosResults[indexPath.row].postId!)
            } else {
                let user = searchUsersResults[indexPath.row]
                lastSelectedIndexpath = indexPath
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
                    let userProfileVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
                    userProfileVC.isBasicProfile = false
                    userProfileVC.isAccountPrivate = (user.accountType == 1) ? true : false
                    userProfileVC.friendUserId = user.userId!
                    userProfileVC.isFollowing = (user.followInfo?.isFollowing == true)
                    userProfileVC.isUserBlocked = (user.blocked == true) ? true : false
                    userProfileVC.isMyProfile = (user.userId! == UserDefaults.standard.value(forKey: Constants.kUserIdKey) as? Int)
                    self.navigationController?.pushViewController(userProfileVC, animated: true)
                }
            }
        }
    }
}

extension DiscoverNewViewController {
    
    func followAction(friendId:Int, isAccountPrivate:Bool, followInfo:FollowInfo, indexPath:IndexPath) {
        guard Connectivity.isConnectedToInternet() else {
            return
        }
        
        var newFollowInfo = followInfo
        UserAPIHandler().sendJoinRequestbyUserID(friendId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                return
            }
            
            searchCell.followBtn.isEnabled = true
            searchCell.followingBtn.isEnabled = true
            
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                if isAccountPrivate {
                    newFollowInfo.isRequestSent = true
                } else {
                    newFollowInfo.isFollowing = true
                }
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                
                searchCell.followInfo = newFollowInfo
            }
        })
        
        guard let searchCell = searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
            return
        }

        if isAccountPrivate {
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = true
            searchCell.followView.isHidden = false
            searchCell.followBtn.isEnabled = true
            searchCell.followLbl.text = RelationTypes.kRequested.rawValue
        } else {
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = false
            searchCell.followView.isHidden = true
            searchCell.followingBtn.isEnabled = true
        }
        searchCell.followBtn.isEnabled = false
        searchCell.followingBtn.isEnabled = false
    }
    
    func acceptAction(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        guard let requestId = followInfo.requestId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        var newFollowInfo = followInfo
        UserAPIHandler().acceptJoinRequest(requestId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                return
            }
            
            searchCell.followBtn.isEnabled = true
            searchCell.followingBtn.isEnabled = true
            
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                newFollowInfo.isRequestReceived = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                
                searchCell.followInfo = newFollowInfo
            }
        })
        
        guard let searchCell = searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
            return
        }
        
        if newFollowInfo.isFollowing == true {
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = false
            searchCell.followView.isHidden = true
            searchCell.followingBtn.isEnabled = true
        } else {
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = true
            searchCell.followView.isHidden = false
            searchCell.followBtn.isEnabled = true
            searchCell.followLbl.text = RelationTypes.kFollow.rawValue
        }
        searchCell.followBtn.isEnabled = false
        searchCell.followingBtn.isEnabled = false
    }
    
    func unblockAction(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unblock", style: .destructive, handler: { [weak self] (action) in
            self?.unblockFriend(friendId: friendId, followInfo: followInfo, indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func cancelRequestAction(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        var newFollowInfo = followInfo
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel Request", style: .destructive, handler: { [weak self] (action) in
            guard Connectivity.isConnectedToInternet() else {
                return
            }
            
            UserProfileAPIHandler().cancelJoinRequest(friendId, completionBlock: { (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                    return
                }
                
                searchCell.followBtn.isEnabled = true
                searchCell.followingBtn.isEnabled = true
                
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    newFollowInfo.isRequestSent = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)

                    searchCell.followInfo = newFollowInfo
                }
            })
            
            guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                return
            }
            
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = true
            searchCell.followView.isHidden = false
            searchCell.followBtn.isEnabled = true
            searchCell.followLbl.text = RelationTypes.kFollow.rawValue
            
            searchCell.followBtn.isEnabled = false
            searchCell.followingBtn.isEnabled = false
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
    func unfollowAction(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        var newFollowInfo = followInfo
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Unfollow", style: .destructive, handler: { [weak self] (action) in
            guard Connectivity.isConnectedToInternet() else {
                return
            }
            
            UserProfileAPIHandler().unfollowUser(friendId, completionBlock: { (responseData) in
                guard let strongSelf = self else {
                    return
                }
                
                guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                    return
                }
                
                searchCell.followBtn.isEnabled = true
                searchCell.followingBtn.isEnabled = true
                
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    newFollowInfo.isFollowing = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                    
                    searchCell.followInfo = newFollowInfo
                }
            })
            
            guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                return
            }
            
            searchCell.trendingImageView.isHidden = true
            searchCell.followingView.isHidden = true
            searchCell.followView.isHidden = false
            searchCell.followBtn.isEnabled = true
            searchCell.followLbl.text = RelationTypes.kFollow.rawValue
            
            searchCell.followBtn.isEnabled = false
            searchCell.followingBtn.isEnabled = false
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
}

extension DiscoverNewViewController {
    
    func unblockFriend(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        guard Connectivity.isConnectedToInternet() else {
            return
        }
        
        var newFollowInfo = followInfo
        UserProfileAPIHandler().blockUser(friendId, 2) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            guard let searchCell = self?.searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
                return
            }
            
            searchCell.followBtn.isEnabled = true
            searchCell.followingBtn.isEnabled = true
            
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                newFollowInfo.blocked = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                
                searchCell.followInfo = newFollowInfo
            }
        }
        
        guard let searchCell = searchTableView.cellForRow(at: indexPath) as? SearchTableViewCell else {
            return
        }
        
        searchCell.trendingImageView.isHidden = true
        searchCell.followingView.isHidden = true
        searchCell.followView.isHidden = false
        searchCell.followBtn.isEnabled = true
        searchCell.followLbl.text = RelationTypes.kFollow.rawValue
        
        searchCell.followBtn.isEnabled = false
        searchCell.followingBtn.isEnabled = false
    }
    
    func fetchVideoSearchResults(searchText:String, pageNo:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        if searchText.count == 0 {
            return
        }
        
        let params:[String:Any] = [
            "page"           :      pageNo,
            "searchTerm"     :      searchText
        ]
        
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getSearchVideoResult(params) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            self?.isWebserviceCallGoingOn = false
            if let list = responseData.videos {
                if pageNo == 1 {
                    strongSelf.searchVideosResults = list
                } else {
                    strongSelf.searchVideosResults.append(contentsOf: list)
                }
                
                if responseData.hasNext == true {
                    strongSelf.hasNextForVideoResults = true
                } else {
                    strongSelf.hasNextForVideoResults = false
                }
                
                strongSelf.searchTableView.reloadData()
            }
        }
    }
    
    func fetchUserSearchResults(searchText:String, pageNo:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        if searchText.count == 0 {
            return
        }
        
        let params:[String:Any] = [
            "page"           :      pageNo,
            "searchTerm"     :      searchText
        ]
        
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getSearchUserResult(params) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            self?.isWebserviceCallGoingOn = false
            if let list = responseData.users {
                if pageNo == 1 {
                    strongSelf.searchUsersResults = list
                } else {
                    strongSelf.searchUsersResults.append(contentsOf: list)
                }
                
                if responseData.hasNext == true {
                    strongSelf.hasNextForUserResults = true
                } else {
                    strongSelf.hasNextForUserResults = false
                }
                
                strongSelf.searchTableView.reloadData()
            }
        }
    }
    
    func followUser(userId:Int, indexPath:IndexPath, cell:SearchTableViewCell) {
        UserAPIHandler().sendJoinRequestbyUserID(userId, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isFollowing = false
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isFollowing = false
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
    
    func unFollowUser(userId:Int, indexPath:IndexPath, cell:SearchTableViewCell) {
        UserProfileAPIHandler().unfollowUser(userId) {  [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isFollowing = true
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isFollowing = true
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func cancelSentRequest(userId:Int, indexPath:IndexPath) {
        UserProfileAPIHandler().cancelJoinRequest(userId, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isRequestSent = true
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.searchUsersResults[indexPath.row].followInfo?.isRequestSent = true
                    self?.searchTableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
    
}

extension DiscoverNewViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case 101:
            return mostPopularVideos.count
        case 102:
            if userInterestsVideosDetails.count > 0 {
                let myInterest = userInterestsVideosDetails[0]
                guard let postsList = myInterest.post else {
                    return 0
                }
                return postsList.count
            } else {
                return 0
            }
        case 103:
            if userInterestsVideosDetails.count > 1 {
                let myInterest = userInterestsVideosDetails[1]
                guard let postsList = myInterest.post else {
                    return 0
                }
                return postsList.count
            } else {
                return 0
            }
        case 104:
            if userInterestsVideosDetails.count > 2 {
                let myInterest = userInterestsVideosDetails[2]
                guard let postsList = myInterest.post else {
                    return 0
                }
                return postsList.count
            } else {
                return 0
            }
        case 105:
            guard let categories = trendingCategories else {
                return 0
            }
            return categories.count
        case 106:
            return featuredVideos.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 101 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MostPopularPostCollectionViewCell", for: indexPath) as! MostPopularPostCollectionViewCell
            
            if mostPopularVideos.count > indexPath.row {
                let post = mostPopularVideos[indexPath.row]
                cell.setupCell(post: post)
                cell.profileTappedBlock = { [weak self] (postOwnerId, isMyself) in
                    self?.pushToProfileViewController(postOwnerId: postOwnerId, isMyself: isMyself)
                }
                
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    cell.hideVides(value: false)
                    cell.videoImageView.image = postImage
                } else {
                    cell.videoImageView.image = nil  
                }
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                if let cell = self?.mostPopularCollectionView.cellForItem(at: indexPath) as? MostPopularPostCollectionViewCell {
                                    cell.hideVides(value: false)
                                    cell.videoImageView.image = image
                                }
                                AppImageCache.savePostImage(image: image, postId: key)
                            }
                        })
                    }
                }
                
                if let postOwnerId = post.postOwner?.userId {
                    if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                        cell.profileImageView.image = postImage
                    } else {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                    if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                if let cell = self?.mostPopularCollectionView.cellForItem(at: indexPath) as? MostPopularPostCollectionViewCell {
                                    cell.profileImageView.image = resizedImage
                                }
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            return cell
        } else if collectionView.tag == 102 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCollectionViewCell", for: indexPath) as! InterestsCollectionViewCell
            
            let myInterest = userInterestsVideosDetails[0]
            lblFirstInterest.text = myInterest.titleStr
            if let postsList = myInterest.post, postsList.count > 0 {
                let post = postsList[indexPath.row]
                cell.setupCell(post: post)
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    cell.hideVides(value: false)
                    cell.videoImageView.image = postImage
                } else {
                    cell.videoImageView.image = nil
                }
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                cell.hideVides(value: false)
                                cell.videoImageView.image = image
                            }
                            AppImageCache.savePostImage(image: image, postId: key)
                        })
                    }
                }
                
                if let postOwnerId = post.postOwner?.userId {
                    if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                        cell.profileImageView.image = postImage
                    } else {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                    if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                cell.profileImageView.image = resizedImage
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            return cell
        } else if collectionView.tag == 103 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCollectionViewCell", for: indexPath) as! InterestsCollectionViewCell
            
            let myInterest = userInterestsVideosDetails[1]
            lblSecondInterest.text = myInterest.titleStr
            if let postsList = myInterest.post, postsList.count > 0 {
                let post = postsList[indexPath.row]
                cell.setupCell(post: post)
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    cell.hideVides(value: false)
                    cell.videoImageView.image = postImage
                } else {
                    cell.videoImageView.image = nil
                }
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                cell.hideVides(value: false)
                                cell.videoImageView.image = image
                                AppImageCache.savePostImage(image: image, postId: key)
                            }
                        })
                    }
                }
                
                if let postOwnerId = post.postOwner?.userId {
                    if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                        cell.profileImageView.image = postImage
                    } else {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                    if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                cell.profileImageView.image = resizedImage
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            return cell
        } else if collectionView.tag == 104 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsCollectionViewCell", for: indexPath) as! InterestsCollectionViewCell
            
            let myInterest = userInterestsVideosDetails[2]
            lblThirdInterest.text = myInterest.titleStr
            if let postsList = myInterest.post, postsList.count > 0 {
                let post = postsList[indexPath.row]
                cell.setupCell(post: post)
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    cell.hideVides(value: false)
                    cell.videoImageView.image = postImage
                } else {
                    cell.videoImageView.image = nil
                }
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                    cell.hideVides(value: false)
                                    cell.videoImageView.image = image
                            }
                            AppImageCache.savePostImage(image: image, postId: key)
                        })
                    }
                }
                
                if let postOwnerId = post.postOwner?.userId {
                    if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                        cell.profileImageView.image = postImage
                    } else {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                    if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                cell.profileImageView.image = resizedImage
                                AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                            }
                        })
                    }
                } else {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            
            return cell
        } else if collectionView.tag == 105 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrendingCategoriesCollectionViewCell", for: indexPath) as! TrendingCategoriesCollectionViewCell
            cell.setupCell(category: trendingCategories![indexPath.row])
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturesVideosCollectionViewCell", for: indexPath) as! FeaturesVideosCollectionViewCell
            if featuredVideos.count > indexPath.row {
                let post = featuredVideos[indexPath.row]
                cell.setupCell(post: post)
                cell.profileTappedBlock = { [weak self] (postOwnerId, isMyself) in
                    self?.pushToProfileViewController(postOwnerId: postOwnerId, isMyself: isMyself)
                }
                
                if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = postImage
                        cell.hideVides(value: false)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.videoImageView.image = nil
                    }
                }
                if let list = post.mediaList, list.count > 0 {
                    if let urlStr = list[0].thumbUrl {
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                if let cell = self?.featuredCollectionView.cellForItem(at: indexPath) as? FeaturesVideosCollectionViewCell {
                                    cell.hideVides(value: false)
                                    cell.videoImageView.image = image
                                }
                                AppImageCache.savePostImage(image: image, postId: key)
                            }
                        })
                    }
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
                        CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                            DispatchQueue.main.async { [weak self] in
                                let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                                if let cell = self?.featuredCollectionView.cellForItem(at: indexPath) as? FeaturesVideosCollectionViewCell {
                                    cell.profileImageView.image = resizedImage
                                }
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
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch collectionView.tag {
        case 101:
            return CGSize(width: 333, height: 249)
        case 102, 103, 104:
            return CGSize(width: 322, height: 88)
        case 105:
            return CGSize(width: trendingCategories![indexPath.row].textWidth! + 30.0, height: 30.0)
        case 106:
            return CGSize(width: 187, height: 200)
        default:
            return CGSize.zero
        }
     
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView.tag == 101 {
            if mostPopularVideos.count > indexPath.row {
                let post = mostPopularVideos[indexPath.row]
                pushToHomeDetailVC(post.postId)
            }
        } else if collectionView.tag == 102 {
            if userInterestsVideosDetails.count > 0 {
                let myInterest = userInterestsVideosDetails[0]
                guard let postsList = myInterest.post else {
                    return
                }
                if postsList.count > indexPath.row {
                    if let postId = postsList[indexPath.row].postId {
                        pushToHomeDetailVC(postId)
                    }
                }
            }
        } else if collectionView.tag == 103 {
            if userInterestsVideosDetails.count > 1 {
                let myInterest = userInterestsVideosDetails[1]
                guard let postsList = myInterest.post else {
                    return
                }
                if postsList.count > indexPath.row {
                    if let postId = postsList[indexPath.row].postId {
                        pushToHomeDetailVC(postId)
                    }
                }
            }
        } else if collectionView.tag == 104 {
            if userInterestsVideosDetails.count > 2 {
                let myInterest = userInterestsVideosDetails[2]
                guard let postsList = myInterest.post else {
                    return
                }
                if postsList.count > indexPath.row {
                    if let postId = postsList[indexPath.row].postId {
                        pushToHomeDetailVC(postId)
                    }
                }
            }
        } else if collectionView.tag == 105 {
            pushToTrendingInterestVC(interest: [trendingCategories![indexPath.row]])
        } else if collectionView.tag == 106 {
            if featuredVideos.count > indexPath.row {
                let post = featuredVideos[indexPath.row]
                pushToHomeDetailVC(post.postId)
            }
        }
    }
    
}

extension DiscoverNewViewController: HomePageLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let post = featuredVideos[indexPath.row]
        let height = post.mediaList![0].height! * (UIScreen.main.bounds.width / 2) / post.mediaList![0].width!
        return (height > 175.0)  ? height : 175.0
    }
    
}

extension DiscoverNewViewController {
    
    func fetchLandingPage() {
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getLandingPageVideos(1) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            self?.isWebserviceCallGoingOn = false
            if responseData.errorObject != nil {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.userInterest = responseData.userInterest
                if let mostPopularVideos = responseData.mostPopularVideos, mostPopularVideos.count > 0 {
                    strongSelf.mostPopularVideos = mostPopularVideos
                    self?.showMostPopularSection()
                    self?.mostPopularCollectionView.reloadData()
                } else {
                    self?.hideMostPopularSection()
                }
                
                if let myInterests = responseData.myInterests, myInterests.count > 0 {
                    strongSelf.userInterestsVideosDetails = myInterests
                    
                    if myInterests.count > 2 { // Do not hide anything
                        self?.showMyInterestSection()
                        self?.firstInterestCollectionView.reloadData()
                        self?.secondInterestCollectionView.reloadData()
                        self?.thirdInterestCollectionView.reloadData()
                    } else if myInterests.count > 1 { // Hide last section
                        self?.showFirstTwoInterestSection()
                        self?.hideLastInterestSection()
                        self?.firstInterestCollectionView.reloadData()
                        self?.secondInterestCollectionView.reloadData()
                    } else if myInterests.count > 0 { // Hide bottom two
                        self?.showFirstInterestSection()
                        self?.hideLastTwoInterestSection()
                        self?.firstInterestCollectionView.reloadData()
                    }
                } else {
                    self?.hideMyInterestSection()
                }
                
                if let categoriesList = responseData.trendingCategories, categoriesList.count > 0 {
                    self?.showTrendingCategoriesSection()
                    strongSelf.trendingCategories = categoriesList
                    self?.trendingCollectionView.reloadData()
                } else {
                    self?.hideTrendingCategoriesSection()
                }
            }
        }
    }
    
    func fetchFeaturedVideos(pageNo:Int) {
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getFeaturedVideos(pageNo) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            if let error = responseData.errorObject {
                print(error.message ?? "")
                return
            }
            if let list = responseData.posts {
                if pageNo == 1 {
                    DispatchQueue.main.async {
                        self?.featuredVideos = Array(list)
                        strongSelf.featuredVideosCellHeight = responseData.contentHeightForCustomLayout + 61
                        self?.changeContentSizeForFeaturedVideos()
                        self?.featuredCollectionView.reloadData()
                        self?.isWebserviceCallGoingOn = false
                    }
                } else {
                    strongSelf.featuredVideosCellHeight += responseData.contentHeightForCustomLayout
                    self?.changeContentSizeForFeaturedVideos()
                    self?.reloadFeaturedVideosSection(list: list)
                }
                
                if responseData.nextPage == true {
                    strongSelf.hasNextForFeaturedVideos = true
                } else {
                    strongSelf.hasNextForFeaturedVideos = false
                }
            }
        }
    }
    
}

extension DiscoverNewViewController {
    
    func showMostPopularSection() {
        if !mostPopularView.isHidden {
            return
        }
        
        DispatchQueue.main.async {
            self.mostPopularView.isHidden = false
            self.mostPopularHeightConstraint.constant = 346
            let newHeight = self.scrollView.contentSize.height + self.mostPopularHeightConstraint.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideMostPopularSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - self.mostPopularHeightConstraint.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.mostPopularView.isHidden = true
            self.mostPopularHeightConstraint.constant = 0
        }
    }
    
    func showMyInterestSection() {
        if !firstInterestView.isHidden {
            return
        }
        DispatchQueue.main.async {
            self.firstInterestView.isHidden = false
            self.secondInterestView.isHidden = false
            self.thirdInterestView.isHidden = false
            self.firstInterestViewHeightConstraint.constant = 312
            self.secondInterestViewHeightConstraint.constant = 276
            self.thirdInterestViewHeightConstraint.constant = 276
            let newHeight = self.scrollView.contentSize.height + (self.secondInterestViewHeightConstraint.constant + self.thirdInterestViewHeightConstraint.constant + self.firstInterestViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideMyInterestSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - (self.firstInterestViewHeightConstraint.constant + self.secondInterestViewHeightConstraint.constant + self.thirdInterestViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.thirdInterestView.isHidden = true
            self.secondInterestView.isHidden = true
            self.firstInterestView.isHidden = true
            self.firstInterestViewHeightConstraint.constant = 0
            self.secondInterestViewHeightConstraint.constant = 0
            self.thirdInterestViewHeightConstraint.constant = 0
        }
    }
    
    func showFirstTwoInterestSection() {
        if !secondInterestView.isHidden {
            return
        }
        DispatchQueue.main.async {
            self.firstInterestView.isHidden = false
            self.secondInterestView.isHidden = false
            self.secondInterestViewHeightConstraint.constant = 276
            self.firstInterestViewHeightConstraint.constant = 312
            let newHeight = self.scrollView.contentSize.height + (self.secondInterestViewHeightConstraint.constant + self.firstInterestViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideLastTwoInterestSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - (self.secondInterestViewHeightConstraint.constant + self.thirdInterestViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.firstInterestView.isHidden = true
            self.secondInterestView.isHidden = true
            self.secondInterestViewHeightConstraint.constant = 0
            self.thirdInterestViewHeightConstraint.constant = 0
        }
    }
    
    func showFirstInterestSection() {
        if !firstInterestView.isHidden {
            return
        }
        DispatchQueue.main.async {
            self.firstInterestView.isHidden = false
            self.firstInterestViewHeightConstraint.constant = 276
            let newHeight = self.scrollView.contentSize.height + self.firstInterestViewHeightConstraint.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideLastInterestSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - (self.thirdInterestViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.thirdInterestView.isHidden = true
            self.thirdInterestViewHeightConstraint.constant = 0
        }
    }
    
    func showTrendingCategoriesSection() {
        if !trendingView.isHidden {
            return
        }
        DispatchQueue.main.async {
            self.trendingView.isHidden = false
            self.trendingViewHeightConstraint.constant = 102
            let newHeight = self.scrollView.contentSize.height + self.trendingViewHeightConstraint.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideTrendingCategoriesSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - (self.trendingViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.trendingView.isHidden = true
            self.trendingViewHeightConstraint.constant = 0
        }
    }
    
    func showFeaturedVideosSection() {
        if !featuredView.isHidden {
            return
        }
        DispatchQueue.main.async {
            self.featuredView.isHidden = false
            self.featuredViewHeightConstraint.constant = 260
            let newHeight = self.scrollView.contentSize.height + self.featuredViewHeightConstraint.constant
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
        }
    }
    
    func hideFeaturedVideosSection() {
        DispatchQueue.main.async {
            let newHeight = self.scrollView.contentSize.height - (self.featuredViewHeightConstraint.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: newHeight)
            self.featuredView.isHidden = true
            self.featuredViewHeightConstraint.constant = 0
        }
    }
    
    func reloadFeaturedVideosSection(list:[Post]) {
        let firstIndex = featuredVideos.count
    
        self.featuredCollectionView.performBatchUpdates({
            DispatchQueue.main.async {
                for i in 0..<list.count {
                    let index = i + firstIndex
                    self.featuredVideos.append(list[i])
                    let indexPath = IndexPath(item: index, section: 0)
                    self.featuredCollectionView.insertItems(at: [indexPath])
                }
            }
        }) { [weak self] (true) in
            self?.isWebserviceCallGoingOn = false
        }
        
//        if firstIndex == 0 {
//            DispatchQueue.main.async {
//                self.featuredCollectionView.reloadData()
//            }
//        } else {
//
//        }
    }
    
    func changeContentSizeForFeaturedVideos() {
        DispatchQueue.main.async {
            let newHeightChange = self.featuredVideosCellHeight - self.featuredViewHeightConstraint.constant
            self.featuredViewHeightConstraint.constant = self.featuredVideosCellHeight
            self.scrollView.contentSize = CGSize(width: self.scrollView.bounds.width, height: self.scrollView.contentSize.height + newHeightChange)
            self.scrollBackgroundViewHeightConstraint.constant = self.scrollView.contentSize.height
        }
    }
    
}

extension DiscoverNewViewController {
    
    func pushToHomeDetailVC(_ postId:Int?) {
        guard let postId = postId else {
            return
        }
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
        //destinationVC.postIndex = postIndex
        destinationVC.postId = postId
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    func pushToMostPopularVC() {
        if mostPopularVideos.count > 0  {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: StoryboardOptions.Discover.rawValue, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "PopularVideosListViewController") as! PopularVideosListViewController
                viewController.isMyInterests = false
                viewController.isTrendingCategories = false
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func pushToMyInterestVC() {
        if userInterest?.count != 0 && userInterest != nil {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: StoryboardOptions.Discover.rawValue, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoListViewController") as! DiscoverVideoListViewController
                viewController.isMyInterests = true
                viewController.isTrendingCategories = false
                viewController.userInterests = self.userInterest!
                viewController.userInterestUpdated = {
                    // Call to update my interests and trending categories
                }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func pushToTrendingInterestVC(interest:[Category]) {
        if userInterest?.count != 0 && userInterest != nil {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: StoryboardOptions.Discover.rawValue, bundle: nil)
                let viewController = storyboard.instantiateViewController(withIdentifier: "DiscoverVideoListViewController") as! DiscoverVideoListViewController
                viewController.isMyInterests = false
                viewController.isTrendingCategories = true
                viewController.userInterests = interest
                viewController.userInterestUpdated = {
                    // Call to update my interests and trending categories
                }
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func pushToProfileViewController(postOwnerId:Int, isMyself:Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        destinationVC.friendUserId = postOwnerId
        destinationVC.isFromVideo = true
        destinationVC.isMyProfile = isMyself
        destinationVC.isBasicProfile = false
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
}

extension DiscoverNewViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        pageNoForVideosResults = 1
        pageNoForUsersResults = 1
        
        searchView.isHidden = false
        searchTableView.delegate = self
        searchTableView.dataSource = self
        UIView.animate(withDuration: 0.4) {
            self.cancelBtnTrailingConstraint.constant = 0
            self.topView.layoutIfNeeded()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text!
        var searchText = ""
        if string !=  "" {
            searchText = text + string
        } else {
            searchText = text.replacingCharacters(in: Range(range, in: text)!, with: "")
        }
        
        if isVideoSearchSelected {
            fetchVideoSearchResults(searchText: searchText, pageNo: pageNoForVideosResults)
        } else {
            fetchUserSearchResults(searchText: searchText, pageNo: pageNoForUsersResults)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension DiscoverNewViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - (scrollView.frame.size.height + 300) && hasNextForFeaturedVideos && !isWebserviceCallGoingOn {
            pageNoForFeaturedVideos += 1
            fetchFeaturedVideos(pageNo: pageNoForFeaturedVideos)
        }
        
//        if offsetY > contentHeight - scrollView.frame.size.height && !hasNextForFeaturedVideos && !isWebserviceCallGoingOn {
//            if featuredVideos.count > 20 {
//                isWebserviceCallGoingOn = true
//                featuredCollectionView.performBatchUpdates({
//                    for i in 0...9 {
//                        let indexPath = IndexPath(item: i, section: 0)
//                        self.featuredCollectionView.reloadItems(at: [indexPath])
//                    }
//                }, completion: { (true) in
//                    self.isWebserviceCallGoingOn = false
//                })
//            }
//        }
        
    }
}
