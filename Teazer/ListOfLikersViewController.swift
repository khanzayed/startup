//
//  ListOfLikersViewController.swift
//  Teazer
//
//  Created by Mraj singh on 29/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class ListOfLikersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noLikersView: UIView!
    @IBOutlet weak var searchView: UIView!
    
    var likersList = [Friend]()
    var pageNo = 1
    var postId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
       fetchlikersList(pageNo:pageNo,postId:postId)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        
    }
    
    func fetchlikersList(pageNo:Int,postId:Int) {
        HomeControllerAPIHandler().getLikersList(postId, pageNo:pageNo){[weak self] (responseData) in
            if let error  = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
            }
            if let list  = responseData.likedUserList{
                if pageNo == 1 {
                    if list.count == 0 {
                        self?.noLikersView.isHidden = false
                    }else{
                       self?.noLikersView.isHidden = true
                    }
                   self?.likersList = list
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                } else if pageNo > 1 {
                    self?.likersList.append(list[0])
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }

                }
            }
        }
    }
    
}

extension ListOfLikersViewController: UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return likersList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListOfLikersTableViewCell") as! ListOfLikersTableViewCell
        cell.setUpCell(friend: likersList[indexPath.row], imageKey: "LikersProfileImage\(likersList[indexPath.row].userId!)")
        
        if let postOwnerId = likersList[indexPath.row].userId {
            if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            if let urlStr = likersList[indexPath.row].profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.tableView.cellForRow(at: lastIndexPath) as? ListOfLikersTableViewCell {
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
        
        cell.followButtonTappedBlock = {[weak self] (isFollowing,isRequestSent) in
            if isRequestSent {
                ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Request", actionTitle: "Confirm", message: "Are you sure you want to cancel the request?", forVC: self, completionBlock: { [weak self] (action) in
                    self?.cancelSentRequest(userId: (self?.likersList[indexPath.row].followInfo?.userId)!, indexPath: indexPath)
                    DispatchQueue.main.async {
                        self?.likersList[indexPath.row].followInfo?.isRequestSent = false
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
            } else {
                if isFollowing {
                    ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Unfollow", actionTitle: "Unfollow", message: "Are you sure you want to unfollow this user?", forVC: self, completionBlock: { [weak self] (action) in
                        self?.unFollowUser(userId: (self?.likersList[indexPath.row].followInfo?.userId!)!, indexPath: indexPath, cell: cell)
                        DispatchQueue.main.async {
                            self?.likersList[indexPath.row].followInfo?.isFollowing = false
                            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                        }
                    })
                } else {
                    if !Connectivity.isConnectedToInternet() {
                        self?.view.makeToast(Constants.kInternetMessage)
                        return
                    }
                    if self?.likersList[indexPath.row].accountType == 1 && self?.likersList[indexPath.row].followInfo?.blocked == false {
                        self?.likersList[indexPath.row].followInfo?.isRequestSent = true
                        
                    } else if self?.likersList[indexPath.row].accountType == 2 && self?.likersList[indexPath.row].followInfo?.blocked == false {
                        self?.likersList[indexPath.row].followInfo?.isFollowing = true
                        
                    }else if self?.likersList[indexPath.row].blocked == true {
                        ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Blocked", actionTitle: "Unblock", message: "This user is blocked. Tap Unblock to unblock the user.", forVC: self, completionBlock: { [weak self] (action) in
                            self?.unblockUser(indexPath)
                        })
                    }
                    DispatchQueue.main.async {
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                    self?.followUser(userId: (self?.likersList[indexPath.row].followInfo!.userId)!, indexPath: indexPath, cell: cell)
                }
            }
            
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let friend = likersList[indexPath.row]
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "NewProfileViewController") as! NewProfileViewController
        userProfileVC.isBasicProfile = false
        userProfileVC.isAccountPrivate = (friend.accountType == 1) ? true : false
        userProfileVC.friendUserId = friend.userId
        userProfileVC.isFollowing = (friend.followInfo?.isFollowing == true) ? true : false
        userProfileVC.isMyProfile = friend.isMyself!
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

extension ListOfLikersViewController {
    
    func unblockUser(_ indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        UserProfileAPIHandler().blockUser(likersList[indexPath.row].followInfo!.userId!, 2, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            if responseData.status == true {
                self?.view.makeToast("User unblocked successfully")
                self?.likersList[indexPath.row].followInfo?.blocked = false
            } else {
                self?.view.makeToast("User cannot be unblocked. Please try again.")
            }
            DispatchQueue.main.async {
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        })
    }
    
    func followUser(userId:Int, indexPath:IndexPath, cell:ListOfLikersTableViewCell) {
        UserAPIHandler().sendJoinRequestbyUserID(userId, completionBlock: { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                
                DispatchQueue.main.async {
                    self?.likersList[indexPath.row].followInfo?.isRequestSent = false
                    self?.likersList[indexPath.row].followInfo?.isFollowing = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.likersList[indexPath.row].followInfo?.isRequestSent = false
                    self?.likersList[indexPath.row].followInfo?.isFollowing = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
    
    func unFollowUser(userId:Int, indexPath:IndexPath, cell:ListOfLikersTableViewCell) {
        UserProfileAPIHandler().unfollowUser(userId) {  [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                
                DispatchQueue.main.async {
                    self?.likersList[indexPath.row].followInfo?.isFollowing = true
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.likersList[indexPath.row].followInfo?.isFollowing = true
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
                    self?.likersList[indexPath.row].followInfo?.isRequestSent = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            } else if responseData.status == false {
                DispatchQueue.main.async {
                    self?.likersList[indexPath.row].followInfo?.isRequestSent = false
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        })
    }
}
