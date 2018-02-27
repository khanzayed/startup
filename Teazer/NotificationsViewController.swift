 ////
//  NotificationsViewController.swift
//  Teazer
//
//  Created by Mraj singh on 06/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class NotificationsViewController: UIViewController {

    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topNotificationLabel: UILabel!
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noContentView: UIView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    private var refreshControl = UIRefreshControl()
    var swipeRightGesture: UISwipeGestureRecognizer?
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var selectedTitle = 0
    var activityIndicatorView = UIActivityIndicatorView()
    var segmentIndex = Int()
    var isPrivate : Bool?
    var isWebSserviceCall = false
    let notificatonCache = NotificationsCacheData.shared
    var verticalContentOffset : CGPoint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        setupSwipeGestures()
        setUpView()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notificatonCache.updateUnreadRequestsCount(count: 0)
        notificatonCache.updateUnreadFollowingCount(count: 0)
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        
        let tabbarItems = tabbarVC.tabBar.items!
        let item =  tabbarItems[TabbarControllerIndex.kNotificationVCIndex.rawValue]
        item.badgeValue = nil
        
        tabbarVC.tabBar.isHidden = false
        tabbarVC.hideCameraButton(value: false)
        tabbarVC.scrollToTopBlockForNotification = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                if let selectedIndex = self?.segmentControl.selectedSegmentIndex {
                    let topRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10)
                    if selectedIndex == 1, strongSelf.notificatonCache.fetchRequestsNotifications().count > 0 {
                        if strongSelf.notificationsTableView.contentOffset.y <= 0 {
                            strongSelf.segmentControl.selectedSegmentIndex = 0
                            strongSelf.segmentControlChanged()
                        }
                        strongSelf.notificationsTableView.scrollRectToVisible(topRect, animated: true)
                    } else if selectedIndex == 0, strongSelf.notificatonCache.fetchFollowingNotifications().count > 0 {
                        strongSelf.notificationsTableView.scrollRectToVisible(topRect, animated: true)
                    }
                }
            }
        }
        
        if notificatonCache.fetchFollowingNotifications().count == 0 || notificatonCache.fetchRequestsNotifications().count == 0 {
            reloadData()
        }
        
        let type = (segmentControl.selectedSegmentIndex == 0) ? 1 : 2
        NotificationsAPIHandler().resetNotificationsCount(type: type)
        DispatchQueue.main.async {
            self.notificationsTableView.setContentOffset(self.verticalContentOffset, animated: false)
        }
    }
    
    // setting up the view of tableView
    func setupTableView(){
        notificationsTableView.tableFooterView = UIView(frame: .zero)
        notificationsTableView.rowHeight = UITableViewAutomaticDimension
        notificationsTableView.estimatedRowHeight = 70
        verticalContentOffset = CGPoint(x: 0, y: -20)
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        refreshControl.tintColor = ColorConstants.kBackgroundGrayColor
        
        if #available(iOS 10.0, *) {
            notificationsTableView.refreshControl = refreshControl
            
        } else {
            notificationsTableView.addSubview(refreshControl)
          
        }
    }
    
    // setting up the view
    func setUpView() {
        topNotificationLabel.isHidden = true
        selectedTitle = segmentControl.selectedSegmentIndex
        let attrs:[String:Any] = [NSAttributedStringKey.font.rawValue : UIFont(name: Constants.kProximaNovaRegular, size: 14.0)!]
        segmentControl.setTitleTextAttributes(attrs, for: .normal)
        noContentView.isHidden = true
    }
    
    // setting swipe gesture
    func setupSwipeGestures() {
        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRightGesture?.direction = .right
        self.view.addGestureRecognizer(swipeRightGesture!)

        swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeftGesture?.direction = .left
        self.view.addGestureRecognizer(swipeLeftGesture!)
        
    }
    
    // reloading the tableView
    @objc func reloadData() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.notificatonCache.reset()
            self.notificatonCache.pageNoForFollowing = 1
            self.notificatonCache.pageNoForRequests = 1
            self.fetchRequestNotificationList(self.notificatonCache.pageNoForRequests)
            self.fetchFollowingNotificationList(self.notificatonCache.pageNoForRequests)
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.notificationsTableView.reloadData()
        }
    }


    @objc func swipeRight() {
        if selectedTitle == 0 {
            return
        }
        self.selectedTitle = 0
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: UIControlEvents.valueChanged)
        self.notificationsTableView.reloadData()
 
    }

    @objc func swipeLeft() {
        if selectedTitle == 1 {
            return
        }
        self.selectedTitle = 1
        segmentControl.selectedSegmentIndex = 1
        segmentControl.sendActions(for: UIControlEvents.valueChanged)
        self.notificationsTableView.reloadData()
    }

    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        segmentControlChanged()
    }
    
    func segmentControlChanged() {
        switch segmentControl.selectedSegmentIndex {
        case 0 :
            selectedTitle = 0
            noContentView.isHidden = (notificatonCache.fetchFollowingNotifications().count > 0)
            notificationsTableView.reloadData()
            NotificationsAPIHandler().resetNotificationsCount(type: 1)
            break
        default:
            selectedTitle = 1
            noContentView.isHidden = (notificatonCache.fetchRequestsNotifications().count > 0)
            notificationsTableView.reloadData()
            NotificationsAPIHandler().resetNotificationsCount(type: 2)
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        notificationsTableView.contentInset = UIEdgeInsetsMake(20, 0.0, 0.0, 0.0)
        notificationsTableView.scrollRectToVisible(CGRect(x:0,y:0,width: 1,height: 1), animated: false)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension NotificationsViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (segmentControl.selectedSegmentIndex == 0) ? notificatonCache.fetchFollowingNotifications().count : notificatonCache.fetchRequestsNotifications().count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = notificationsTableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as! NotificationsTableViewCell
        cell.reactBtn.tag = indexPath.row
        cell.setUpCell()
        cell.navigationController = self.navigationController
        
        var notification = (selectedTitle == 0) ? notificatonCache.fetchFollowingNotifications()[indexPath.row] : notificatonCache.fetchRequestsNotifications()[indexPath.row]
        if let postOwnerId = notification.metaData?.fromId {
            if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            if let urlStr = notification.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.notificationsTableView.cellForRow(at: indexPath) as? NotificationsTableViewCell {
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
        
        if selectedTitle == 0 {
            if notificatonCache.fetchFollowingNotifications().count == 0 {
                return cell
            }
            
            cell.buttonViewWidthConstraint.constant = 70
            let highlights = notification.highlights
            let message  = notification.message!
            
            cell.postImageView?.isHidden = false
            cell.profileImageView.isHidden = false
            cell.messageLbl.isHidden = false
            if highlights != nil{
                cell.boldTheUsername(message, highlights!)
            }
            
            if let postImage = AppImageCache.fetchNotificationPostImage(notificationId: notification.notificationId!) {
                DispatchQueue.main.async {
                    cell.postImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.postImageView.image = nil
                }
            }
            
            if let urlStr = notification.metaData?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: notification.notificationId!, completion: { (image, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.notificationsTableView.cellForRow(at: indexPath) as? NotificationsTableViewCell {
                            cell.postImageView.image = resizedImage
                        }
                        AppImageCache.saveNotificationPostImage(image: resizedImage, notificationId: key)
                    }
                })
            }
            
            cell.profileImageButtonTapped = { [weak self] in
                if let userId = notification.metaData?.fromId, let isAccountPrivate = notification.accountType {
                    self?.pushProfileVC(userId: userId, isAccountPrivate: (isAccountPrivate == 1),isFollowing:true)
                }
            }
            
            cell.layoutIfNeeded()
        } else {
            if notificatonCache.fetchRequestsNotifications().count == 0 {
                return cell
            }
            
            cell.buttonViewWidthConstraint.constant = 128
            let highlights = notification.highlights
            let message  = notification.message!
            
            if let postOwnerId = notification.metaData?.fromId {
                if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                    DispatchQueue.main.async {
                        cell.profileImageView.image = postImage
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                    }
                }
                if let urlStr = notification.profileMedia?.thumbUrl {
                    CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                        DispatchQueue.main.async { [weak self] in
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                            if let cell = self?.notificationsTableView.cellForRow(at: indexPath) as? NotificationsTableViewCell {
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
            
            cell.profileImageView.image = nil
            
            cell.acceptButtonTappedBlock = { [weak self] in
                if !Connectivity.isConnectedToInternet() {
                    self?.view.makeToast(Constants.kInternetMessage)
                    return
                }
                
                notification.isActioned = true
                self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                self?.reloadTableViewCell(indexPath: indexPath)
                UserAPIHandler().acceptJoinRequest(notification.notificationId!) { (responseData) in
                    if let error = responseData.errorObject {
                        ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                        
                        notification.isActioned = false
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    } else if responseData.status == false {
                        self?.view.makeToast(responseData.message)
                        
                        notification.isActioned = false
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    }
                }
            }

            cell.profileImageButtonTapped = { [weak self] in
                self?.pushProfileVC(notification: notification)
            }
            
            cell.followButtonTappedBlock = {
                if !Connectivity.isConnectedToInternet() {
                    self.view.makeToast(Constants.kInternetMessage)
                    return
                }
                    if notification.accountType == 1  {
                        notification.requestSent = true
                    } else if notification.accountType == 2 {
                        notification.following = true
                    }
                    self.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                    self.reloadTableViewCell(indexPath: indexPath)
                UserProfileAPIHandler().sendRequestUsingUserId((notification.metaData?.sourceId)!, completionBlock: { [weak self] (responseData) in
                    if let error = responseData.errorObject {
                       ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                        
                        notification.requestSent = false
                        notification.following = false
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    } else if responseData.status == false {
                        if responseData.followedInfo!.isFollowing! {
                            notification.following = true
                            self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                            self?.reloadTableViewCell(indexPath: indexPath)
                        } else if responseData.followedInfo!.isRequestSent! {
                            notification.requestSent = true
                            self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                            self?.reloadTableViewCell(indexPath: indexPath)
                        }else if responseData.followedInfo!.isRequestReceived!{
                            if notification.accountType == 1  {
                                notification.requestSent = true
                            } else if notification.accountType == 2 {
                                notification.following = true
                            }
                            notification.isActioned = true
                            self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                            self?.reloadTableViewCell(indexPath: indexPath)
                                UserAPIHandler().acceptJoinRequest(notification.notificationId!) { (responseData) in
                                    if let error = responseData.errorObject {
                                        ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                                        
                                        notification.isActioned = false
                                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                                        self?.reloadTableViewCell(indexPath: indexPath)
                                    } else if responseData.status == false {
                                        self?.view.makeToast(responseData.message)
                                        
                                        notification.isActioned = false
                                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                                        self?.reloadTableViewCell(indexPath: indexPath)
                                    }
                                }
                            
                        }else {
                            self?.view.makeToast(responseData.message)
                            notification.requestSent = false
                            notification.following = false
                            self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                            self?.reloadTableViewCell(indexPath: indexPath)
                        }
                    }
                })
            }
            cell.unFollowButtonTappedBlock = {
                if !Connectivity.isConnectedToInternet() {
                    self.view.makeToast(Constants.kInternetMessage)
                    return
                }
                notification.following = false
                self.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                self.reloadTableViewCell(indexPath: indexPath)
                
                UserProfileAPIHandler().unfollowUser((notification.metaData?.sourceId)!, completionBlock: {[weak self](responseData) in
                    if let error = responseData.errorObject {
                        ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                        notification.following = true
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    }else if responseData.status == false {
                        notification.following = true
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    }
                })
            }
            
            cell.cancelJoinRequestButtonTappedBlock = { [weak self] in
                if !Connectivity.isConnectedToInternet() {
                    self?.view.makeToast(Constants.kInternetMessage)
                    return
                }
                
                notification.requestSent = false
                self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                self?.reloadTableViewCell(indexPath: indexPath)
                
                UserProfileAPIHandler().cancelJoinRequest(notification.metaData!.sourceId!, completionBlock: {[weak self] (responseData) in
                    if let error = responseData.errorObject {
                        ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                        
                        notification.requestSent = true
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    } else if responseData.status == false {
                        self?.view.makeToast(responseData.message)
                        
                        notification.requestSent = true
                        self?.notificatonCache.updateRequestsNotifications(notification: notification, atIndex: indexPath.row)
                        self?.reloadTableViewCell(indexPath: indexPath)
                    }
                })
            }
            cell.postImageView?.isHidden = true
            cell.profileImageView.isHidden = false
            cell.messageLbl.isHidden = false
            
            if highlights != nil{
                cell.boldTheUsername(message, highlights!)

            }
            if notification.notificationType! == 1 || notification.notificationType! == 3 {
                cell.buttonView.isHidden = false
                if notification.isActioned == true {
                    if notification.following == true {
                        cell.followingButtonView()
                        return cell
                    } else if notification.following == false && notification.requestSent == true {
                        cell.requestedButtonView()
                        return cell
                    } else {
                        cell.followButtonView()
                        return cell
                    }
                } else {
                    if notification.notificationType! == 3 {
                        cell.acceptButttonView()
                        return cell
                    } else if notification.following == true {
                        cell.followingButtonView()
                        return cell
                    } else if notification.notificationType! == 1 {
                        cell.followButtonView()
                        return cell
                    }
                }
            } else {
                cell.buttonView.isHidden = true
                return cell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if selectedTitle == 0 {
            let notification = notificatonCache.fetchFollowingNotifications()[indexPath.row]
            let sourceId = notification.metaData?.sourceId
            let notificationType = notification.metaData?.notificationType
            if  (notificationType == 5) ||  (notificationType == 7) || (notificationType == 9) {
                fetchPostDetails(sourceId!)
            } else if (notificationType == 4)||(notificationType == 6) || (notificationType == 8) {
                openReactionPage(sourceId!)
            }
        } else {
            pushProfileVC(notification: notificatonCache.fetchRequestsNotifications()[indexPath.row])
        }
        verticalContentOffset = notificationsTableView.contentOffset
    }
    
    func reloadTableViewCell(indexPath:IndexPath) {
        DispatchQueue.main.async {
            self.notificationsTableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
}

extension NotificationsViewController: UIScrollViewDelegate {
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y + 20
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && notificatonCache.followingHasNext && selectedTitle == 0 && !isWebSserviceCall {
            notificatonCache.pageNoForFollowing += 1
            fetchFollowingNotificationList(notificatonCache.pageNoForFollowing)
        } else if offsetY > contentHeight - scrollView.frame.size.height && notificatonCache.requestsHasNext && selectedTitle == 1 && !isWebSserviceCall {
            notificatonCache.pageNoForRequests += 1
            fetchRequestNotificationList(notificatonCache.pageNoForRequests)
        }
        self.segmentView.frame = CGRect(x: 0, y: 50 - offsetY, width: segmentView.frame.size.width, height: segmentView.frame.size.height)

        if offsetY > 26 {
            let alpha: CGFloat = 0.0 + ((offsetY - 25) / 20)
            topNotificationLabel.alpha = alpha
            topNotificationLabel.isHidden = false
            if offsetY > 38 {
            self.segmentView.frame = CGRect(x: 0, y: 12, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
            }
        } else {
            topNotificationLabel.isHidden = true
            if offsetY < 0 {
               self.segmentView.frame = CGRect(x: 0, y: 50, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
            }
        }
    }
}
 
 extension NotificationsViewController {
 
    func fetchFollowingNotificationList(_ pageNo: Int) {
        isWebSserviceCall = true
        NotificationsAPIHandler().getFollowingNotificationsList(pageNo){ [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isWebSserviceCall = false
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            DispatchQueue.main.async {
                if let list = responseData.notifications {
                    if self?.segmentControl.selectedSegmentIndex == 0 {
                        if list.count == 0 && pageNo < 2 {
                            self?.noContentView.isHidden = false
                            return
                        }
                        self?.noContentView.isHidden = true
                    }
                    strongSelf.notificatonCache.updateFollowingNotifications(list: list,
                                                                             isReset: (strongSelf.notificatonCache.pageNoForFollowing == 1),
                                                                             hasNext: responseData.hasNext!)
                    strongSelf.notificationsTableView.reloadData()
                } else if self?.segmentControl.selectedSegmentIndex == 0 {
                    self?.noContentView.isHidden = false
                }
            }
        }
    }
    
    func fetchRequestNotificationList(_ pageNo: Int) {
        isWebSserviceCall = true
        NotificationsAPIHandler().getRequestNotificationsList(pageNo) {[weak self](responseData) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.isWebSserviceCall = false
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            DispatchQueue.main.async {
                if let list = responseData.notifications {
                    if self?.segmentControl.selectedSegmentIndex == 1 {
                        if list.count == 0 && pageNo < 2 {
                            //self?.noContentView.isHidden = false
                            return
                        }
                        self?.noContentView.isHidden = true
                    }
                    strongSelf.notificatonCache.updateRequestsNotifications(list: list,
                                                                            isReset: (strongSelf.notificatonCache.pageNoForRequests == 1),
                                                                            hasNext: responseData.hasNext!)
                    strongSelf.notificationsTableView.reloadData()
                } else if self?.segmentControl.selectedSegmentIndex == 1 {
                    self?.noContentView.isHidden = false
                }
            }
        }
        
    }
    
    func pushProfileVC(notification:Notification) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        userProfileVC.isBasicProfile = false
        userProfileVC.isAccountPrivate = (notification.accountType == 1) ? true : false
        userProfileVC.friendUserId = notification.metaData?.sourceId
        userProfileVC.isFollowing = notification.following!
        userProfileVC.isMyProfile = (notification.metaData?.sourceId == UserDefaults.standard.value(forKey: Constants.kUserIdKey) as? Int)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(userProfileVC, animated: true)
        }
    }
    
    func pushProfileVC(userId:Int, isAccountPrivate:Bool, isFollowing:Bool) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
            let userProfileVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
            userProfileVC.isBasicProfile = false
            userProfileVC.isAccountPrivate = isAccountPrivate
            userProfileVC.friendUserId = userId
            userProfileVC.isFollowing = isFollowing
            userProfileVC.isMyProfile = (userId == UserDefaults.standard.value(forKey: Constants.kUserIdKey) as? Int)
            self.navigationController?.pushViewController(userProfileVC, animated: true)
        }
    }
    
    
    func fetchPostDetails(_ postId:Int) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
        destinationVC.postId = postId
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    
    func openReactionPage(_ reactionId: Int) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ReactionDetailsViewController") as! ReactionDetailsViewController
        destinationVC.reactionId = reactionId
        DispatchQueue.main.async {
            self.navigationController?.present(destinationVC, animated: true, completion: nil)

        }
    }
 }



