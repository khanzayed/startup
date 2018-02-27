//
//  PeopleFollowViewController.swift
//  Teazer
//
//  Created by Ankita Satpathy on 09/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class PeopleFollowListViewController: UIViewController {

    typealias FollowCellTappedBlock = (Friend) -> Void
    var followCellTappedBlock:FollowCellTappedBlock!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var followers = [Friend]()
    var friendUserId:Int?
    var hasNext = false
    var isMyProfile = false
    var refreshControl:UIRefreshControl?
    var isWebserviceCallGoingOn = false
    var pageNo = 1
    var lastSelectedIndexpath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        (isMyProfile) ? fetchFollowers(pageNo: 1) : fetchFollowersForOthers(pageNo: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = true
        tabbarVC.hideCameraButton(value: true)
        
        if let indexPath = lastSelectedIndexpath, let cell = tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell, indexPath.row < followers.count {
            lastSelectedIndexpath = nil
            cell.setupCell(friend: followers[indexPath.row])
        }

    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

extension PeopleFollowListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "UserProfileFriendsListTableViewCell") as! UserProfileFriendsListTableViewCell
        let follower = followers[indexPath.row]
        cell.setupCell(friend: follower)
        
        if let postOwnerId = follower.userId {
            if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            if let urlStr = follower.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell {
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        lastSelectedIndexpath = indexPath
        
        let follower = followers[indexPath.row]
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        userProfileVC.isBasicProfile = false
        userProfileVC.isAccountPrivate = (follower.accountType == 1) ? true : false
        userProfileVC.friendUserId = follower.userId
        userProfileVC.isFollowing = (follower.followInfo?.isFollowing == true)
        userProfileVC.isMyProfile = (follower.isMyself == true) ? true : false
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

extension PeopleFollowListViewController {
    
    func followAction(friendId:Int, isAccountPrivate:Bool, followInfo:FollowInfo, indexPath:IndexPath) {
        guard Connectivity.isConnectedToInternet() else {
            return
        }
        
        var newFollowInfo = followInfo
        UserAPIHandler().sendJoinRequestbyUserID(friendId, completionBlock: { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                return
            }
            followCell.requestBtn.isEnabled = true
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
                followCell.followInfo = newFollowInfo
            }
        })
        
        guard let followCell = tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
            return
        }
        
        let buttonTitle = (isAccountPrivate) ? RelationTypes.kRequested.rawValue : RelationTypes.kFollowing.rawValue
        followCell.requestBtn.setTitle(buttonTitle, for: .normal)
        followCell.requestBtn.isEnabled = false
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
            
            guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                return
            }
            followCell.requestBtn.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                newFollowInfo.isRequestReceived = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                followCell.followInfo = newFollowInfo
            }
        })
        
        guard let followCell = tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
            return
        }
        
        let buttonTitle = (newFollowInfo.isFollowing == true) ? RelationTypes.kFollowing.rawValue : RelationTypes.kFollow.rawValue
        followCell.requestBtn.setTitle(buttonTitle, for: .normal)
        followCell.requestBtn.isEnabled = false
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
                
                guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                    return
                }
                followCell.requestBtn.isEnabled = true
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    newFollowInfo.isRequestSent = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                    followCell.followInfo = newFollowInfo
                }
            })
            
            guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                return
            }
            
            let buttonTitle = RelationTypes.kFollow.rawValue
            followCell.requestBtn.setTitle(buttonTitle, for: .normal)
            followCell.requestBtn.isEnabled = false
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
                
                guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                    return
                }
                followCell.requestBtn.isEnabled = true
                if let error = responseData.errorObject {
                    ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                    return
                }
                
                if responseData.status == true {
                    newFollowInfo.isFollowing = false
                    UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                    followCell.followInfo = newFollowInfo
                }
            })
            
            guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                return
            }
            
            let buttonTitle = RelationTypes.kFollow.rawValue
            followCell.requestBtn.setTitle(buttonTitle, for: .normal)
            followCell.requestBtn.isEnabled = false
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.navigationController?.present(alert, animated: false, completion: nil)
    }
    
}


extension PeopleFollowListViewController {
    
    //MARK: fetch followers for user API
    
    func unblockFriend(friendId:Int, followInfo:FollowInfo, indexPath:IndexPath) {
        guard let friendId = friendUserId, Connectivity.isConnectedToInternet() else {
            return
        }
        
        var newFollowInfo = followInfo
        UserProfileAPIHandler().blockUser(friendId, 2) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            guard let followCell = self?.tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
                return
            }
            followCell.requestBtn.isEnabled = true
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: strongSelf)
                return
            }
            
            if responseData.status == true {
                newFollowInfo.blocked = false
                UserProfileCache.shared.updateFollowInfo(friendId: friendId, followInfo: newFollowInfo)
                followCell.followInfo = newFollowInfo
            }
        }
        
        guard let followCell = tableView.cellForRow(at: indexPath) as? UserProfileFriendsListTableViewCell else {
            return
        }
        
        let buttonTitle = RelationTypes.kFollow.rawValue
        followCell.requestBtn.setTitle(buttonTitle, for: .normal)
        followCell.requestBtn.isEnabled = false
    }
    
    func fetchFollowers(pageNo: Int) {
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getUserFollwerDetails(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
                self?.refreshControl?.endRefreshing()
            }
            
            if let error = responseData.errorObject {
               ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let value = responseData.nextPage {
                strongSelf.hasNext = value
            }
            
            if let followersList = responseData.followers {
                if pageNo == 1 {
                    strongSelf.followers = Array(followersList)
                    strongSelf.tableView.reloadData()
                    self?.isWebserviceCallGoingOn = false
                } else {
                    DispatchQueue.main.async {
                        var i = self!.followers.count
                        for post in followersList {
                            self?.followers.append(post)
                            self?.tableView.isScrollEnabled = false
                            self?.tableView.insertRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
                            i += 1
                        }
                        self?.tableView.isScrollEnabled = true
                        self?.isWebserviceCallGoingOn = false
                    }
                }
            }
        }
    }
  
    //MARK: fetch followers for friend API
    
    func fetchFollowersForOthers(pageNo: Int) {
        guard let userId = friendUserId else {
            return
        }
        
        isWebserviceCallGoingOn = true
        UserProfileAPIHandler().getFriendsFollowers(pageNo,userId ) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
                self?.refreshControl?.endRefreshing()
            }
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let followersList = responseData.followers {
                if pageNo == 1 {
                    strongSelf.followers = Array(followersList)
                } else {
                    strongSelf.followers.append(contentsOf: followersList)
                }
                
                if let value = responseData.nextPage {
                    strongSelf.hasNext = value
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func followUser(userId:Int, indexPath:IndexPath, cell:UserProfileFriendsListTableViewCell) {
        UserAPIHandler().sendJoinRequestbyUserID(userId, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                
                DispatchQueue.main.async {
                    self?.followers[indexPath.row].followInfo?.isRequestSent = false
                    self?.followers[indexPath.row].followInfo?.isFollowing = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    if responseData.followedInfo!.isFollowing! {
                        self?.followers[indexPath.row].followInfo?.isFollowing = true
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else if responseData.followedInfo!.isRequestSent! {
                        self?.followers[indexPath.row].followInfo?.isRequestSent = true
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    } else {
                        self?.followers[indexPath.row].followInfo?.isRequestSent = false
                        self?.followers[indexPath.row].followInfo?.isFollowing = false
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        })
    }
    
    func unFollowUser(userId:Int, indexPath:IndexPath, cell:UserProfileFriendsListTableViewCell) {
        UserProfileAPIHandler().unfollowUser(userId) {  [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                
                DispatchQueue.main.async {
                    self?.followers[indexPath.row].followInfo?.isFollowing = true
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.followers[indexPath.row].followInfo?.isFollowing = true
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }
    
    func cancelSentRequest(userId:Int, indexPath:IndexPath) {
        UserProfileAPIHandler().cancelJoinRequest(userId, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                
                DispatchQueue.main.async {
                    self?.followers[indexPath.row].followInfo?.isRequestSent = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.followers[indexPath.row].followInfo?.isRequestSent = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
}

extension PeopleFollowListViewController: UIScrollViewDelegate {
    
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
        (isMyProfile) ? fetchFollowers(pageNo: 1) : fetchFollowersForOthers(pageNo: 1)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasNext {
            pageNo += 1
            (isMyProfile) ? fetchFollowers(pageNo: pageNo) : fetchFollowersForOthers(pageNo: pageNo)
        }
    }
    
}
