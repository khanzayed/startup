//
//  TaggedFriendsViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 14/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class TaggedFriendsViewController: UIViewController {
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var postDetails: Post!
    var pageNo = 1
    var loaderView:LoaderView?
    var taggedFriends = [Friend]()
    let imageCache = AutoPurgingImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchTaggedFriendsList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
       navigationController?.popViewController(animated: true)
        
    }
    
}

extension TaggedFriendsViewController {
    
    func fetchTaggedFriendsList() {
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        HomeControllerAPIHandler().getTaggedFriends(postDetails.postId!, pageNo: pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            DispatchQueue.main.async {
                if let list = responseData.friendsList {
                    strongSelf.taggedFriends = Array(list)
                    strongSelf.tableView.dataSource = strongSelf
                    strongSelf.tableView.delegate = strongSelf
                    strongSelf.tableView.reloadData()
                }
            }
        }
    }
    
    func untagMyself(postId:Int , indexPath:IndexPath) {
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        HomeControllerAPIHandler().untagMyself(postId){ [weak self] (responseData) in
            
            guard let strongSelf = self else {
                return
            }
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            if let message = responseData.message {
                self?.view.makeToast("\(message)")
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    strongSelf.taggedFriends.remove(at: indexPath.row)
                    strongSelf.tableView.deleteRows(at: [indexPath], with: .right)
                    strongSelf.postDetails.totalTag = strongSelf.taggedFriends.count
                }
            }
        }
    }
    
}

extension TaggedFriendsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taggedFriends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaggedFriendsTableViewCell") as! TaggedFriendsTableViewCell
        let friend = taggedFriends[indexPath.row]
        cell.setupCell(friend: friend)
        
        if let postOwnerId = friend.userId {
            if let postImage = AppImageCache.fetchOthersProfileImage(userId: postOwnerId) {
                DispatchQueue.main.async {
                    cell.profileImageView.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            cell.blockUntagMyself = { [weak self] in
                self?.untagMyself(postId: (self?.postDetails.postId!)!, indexPath: indexPath)
            }
            
            if let urlStr = friend.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, completion: { (image, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                        
                        if resizedImage != nil, let cell = self?.tableView.cellForRow(at: indexPath) as? TaggedFriendsTableViewCell {
                            cell.profileImageView.image = resizedImage
                        }
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let friend = taggedFriends[indexPath.row]
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

