//
//  NewHomeViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 26/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import AlamofireImage

class NewHomeViewController: UIViewController {
    
    typealias HidePostBlock = () -> Void
    var hidePostBlock:HidePostBlock?

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noInternetView: NoInternetDetectedView!
    @IBOutlet weak var uploadProgressView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var imageUploadVideo: UIImageView!
    @IBOutlet weak var btnCancelUpload: UIButton!
    @IBOutlet weak var constraintTableViewTop: NSLayoutConstraint!
    
    var cellHeight:CGFloat = 0
    var hasNext = false
    var previousHasNext = true
    var refreshControl:UIRefreshControl?
    var pageNo = 1
    var isWebserviceCallGoingOn = false
    var isNewUser = false
    var isRefreshRequired = true
    let imageCache = AutoPurgingImageCache()
    var popRecognizer: InteractivePopRecognizer?
    var postsList = [Post]()
    var openPost = false
    var openReaction = false
    var isUploading = false
    var postId = -1
    var reactionId = -1
    var cellToBeDisplayed = [IndexPath]()
    var lastVideoPlayingCellIndexPath:IndexPath?
    var lastSelectedIndexPath:IndexPath?
    var lastSelectedIndexPathForReaction:IndexPath?
    var updatedPost:Post?
    var updatedReactionPostsList = [IndexPath]()
    var lastCreatedCellIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let deviceToken = FIRInstanceID.instanceID().token() {
            print("FCM Token : \(FIRInstanceID.instanceID().token() ?? "")")
            UserAPIHandler().registerDeviceToken(deviceToken)
            connectToFcm()
        }
        
        //        setInteractiveRecognizer()
        
        postsTableView.separatorStyle = .none
        postsTableView.delegate = self
        postsTableView.dataSource = self
        
        let temp = (UIScreen.main.bounds.height * 0.75)
        cellHeight = (temp < 500) ? temp : 500
        
        addPullToRefresh()
        setupDefaultValues()
        fetchPostsList(forPage: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Connectivity.isConnectedToInternet() {
            noInternetView.contentView.isHidden = false
            
            return
        }
        noInternetView.isHidden = true
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.bringSubview(toFront: tabbarVC.cameraBtn)
        tabbarVC.scrollToTopBlock = { [weak self] in
            DispatchQueue.main.async {
                if self?.postsList.count != 0 {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self?.postsTableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: true)
                }
            }
        }
        
        if openPost {
            openPost = false
            pushToHomeDetailsVC(postId: postId, openReaction: openReaction, reactionId: reactionId)
        }
        
        if tabbarVC.isUploading, uploadProgressView.isHidden {
            uploadProgressView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintTableViewTop.constant = 50
                self.uploadProgressView.layoutIfNeeded()
            })
        } else if !isUploading, !uploadProgressView.isHidden {
            hideUploadProgressView()
        }
    
        tabbarVC.tabBar.isHidden = false
        tabbarVC.hideCameraButton(value: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isNewUser {
            let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
            let interestingCategoriesVC = storyboard.instantiateViewController(withIdentifier: "InterestCategoryViewController") as! InterestCategoryViewController
            interestingCategoriesVC.view.backgroundColor = UIColor.clear
            interestingCategoriesVC.modalPresentationStyle = .overCurrentContext
            interestingCategoriesVC.isNewUser = isNewUser
            tabBarController?.present(interestingCategoriesVC, animated: true, completion: { [weak self] in
                self?.isNewUser = false
            })
        }
        
        if let index = lastVideoPlayingCellIndexPath, !isUploading {
            if let postCell = postsTableView.cellForRow(at: index) as? NewPostTableViewCell {
                postCell.playVideo()
            }
        }
        
        if let index = lastSelectedIndexPath, let post = updatedPost {
            if let postCell = postsTableView.cellForRow(at: index) as? NewPostTableViewCell {
                postsList.remove(at: index.section)
                postsList.insert(post, at: index.section)
                postCell.updateCellDetails(postDetails: postsList[index.section])
            }
            updatedPost = nil
            lastSelectedIndexPath = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let index = lastVideoPlayingCellIndexPath else {
            return
        }
        
        if let postCell = postsTableView.cellForRow(at: index) as? NewPostTableViewCell {
            postCell.pauseVideo()
        }
        
        lastVideoPlayingCellIndexPath = nil
    }
    
    func hideUploadProgressView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.constraintTableViewTop.constant = 0
            self.uploadProgressView.layoutIfNeeded()
        }) { (value) in
            self.uploadProgressView.isHidden = true
        }
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.removeVideoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setInteractiveRecognizer() {
        guard let controller = navigationController else { return }
        popRecognizer = InteractivePopRecognizer(controller: controller)
        controller.interactivePopGestureRecognizer?.delegate = popRecognizer
    }
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            postsTableView.refreshControl = refreshControl
        } else {
            postsTableView.addSubview(refreshControl!)
        }
    }
    
    @objc func refreshOptions(sender: UIRefreshControl) {
        if isUploading {
            return
        }
        
        pageNo = 1
        AppImageCache.removeAllImages()
        fetchPostsList(forPage: pageNo)
    }
    
    func setupDefaultValues() {
        hidePostBlock = { [weak self] in
            self?.hidePost()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            
        }
    }
    
    @IBAction func cancelUploadButtonTapped(sender:UIButton) {
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.cancelUpload()
        hideUploadProgressView()
    }
    
}

extension NewHomeViewController {
    
    func fetchPostsList(forPage page:Int) {
        if !Connectivity.isConnectedToInternet() {
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
                self.noInternetView.isHidden = false
            }
            return
        }
        
        isWebserviceCallGoingOn = true
        isRefreshRequired = true
        noInternetView.isHidden = true
        HomeControllerAPIHandler().getHomePageDetails(page) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.posts {
                strongSelf.hasNext = responseData.nextPage!
                
                if page == 1 {
                    self?.postsList = Array(list)
                    self?.postsTableView.reloadData()
                    self?.playFirstVideoAfterReload()
                    self?.isWebserviceCallGoingOn = false
                } else {
                    DispatchQueue.main.async {
                        let firstIndex = self!.postsList.count
                        var i = 0
                        for post in list {
                            self?.postsList.append(post)
                            self?.postsTableView.isScrollEnabled = false
                            self?.postsTableView.insertSections([firstIndex + i], with: .automatic)
                            i += 1
                        }
                        self?.postsTableView.isScrollEnabled = true
                        self?.isWebserviceCallGoingOn = false
                    }
                }
            }
        }
    }
    
}

extension NewHomeViewController: UITableViewDataSource, UITableViewDelegate {
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return postsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
        headerView.backgroundColor = UIColor(rgba: "#EEEEEE")
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = postsList[indexPath.section]
        if let reactionsCount = post.reactions, reactionsCount.count > 0 {
            return cellHeight //346
        } else {
            return (cellHeight - 95.0)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = postsList[indexPath.section]
        if let reactionsCount = post.reactions, reactionsCount.count > 0 {
            return cellHeight //346
        } else {
            return (cellHeight - 95.0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let postCell = tableView.dequeueReusableCell(withIdentifier: "NewPostTableViewCell") as? NewPostTableViewCell
        
        let post = postsList[indexPath.section]
        postCell?.setupCell(postDetails: post)
        postCell?.profileButtonTappedBlock = { [weak self] (postOwnerId, isMyself) in
            self?.pushToProfileViewController(postOwnerId: postOwnerId, isMyself: isMyself)
        }
        postCell?.postDetailsButtonTappedBlock = { [weak self] (postId) in
            self?.pushToPostDetailsViewController(postId: postId)
        }
        postCell?.reactButtonTappedBlock = { [weak self] in
            self?.lastSelectedIndexPathForReaction = indexPath
            self?.pushToCameraViewController(postDetails: post)
        }
        
        lastCreatedCellIndexPath = indexPath
        
        if let postImage = AppImageCache.fetchPostImage(postId: post.postId!) {
            DispatchQueue.main.async {
                postCell?.videoImageView.image = postImage
            }
        } else {
            DispatchQueue.main.async {
                postCell?.videoImageView.image = nil
            }
        }
        if let list = post.mediaList, list.count > 0 {
            if let urlStr = list[0].thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: post.postId!, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                    DispatchQueue.main.async { [weak self] in
                        if image != nil, let cell = self?.postsTableView.cellForRow(at: lastIndexPath) as? NewPostTableViewCell {
                            cell.unhideDefaultViews()
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
                    postCell?.imageProfile.image = postImage
                }
            } else {
                DispatchQueue.main.async {
                    postCell?.imageProfile.image = #imageLiteral(resourceName: "ic_male_default")
                }
            }
            if let urlStr = post.postOwner?.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath,key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.postsTableView.cellForRow(at: lastIndexPath) as? NewPostTableViewCell {
                            cell.imageProfile.image = resizedImage
                        }
                        AppImageCache.saveOthersProfileImage(image: resizedImage, userId: key)
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                postCell?.imageProfile.image = #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        return postCell!
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellToBeDisplayed.append(indexPath)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        if let postCell = tableView.cellForRow(at: indexPath) as? NewPostTableViewCell {
            postCell.pauseVideo()
            postCell.removeVideoPlayer()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !Connectivity.isConnectedToInternet() {
            return
        }

        if let postCell = tableView.cellForRow(at: indexPath) as? NewPostTableViewCell {
            postCell.pauseVideo()
        }
        
        lastSelectedIndexPathForReaction = indexPath
        lastSelectedIndexPath = indexPath
        
        let post = postsList[indexPath.section]
        pushToHomeDetailsVC(postId: post.postId!, openReaction: false, reactionId: reactionId)
    }
    
}

extension NewHomeViewController {
    
    func hidePost() {
        if let indexPath = lastSelectedIndexPath {
            DispatchQueue.main.async {
                self.postsList.remove(at: indexPath.section)
                self.postsTableView.deleteSections([indexPath.section], with: .automatic)
            }
        }
    }
    
}

extension NewHomeViewController {
    
    func pushToHomeDetailsVC(postId:Int, openReaction:Bool, reactionId:Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
        destinationVC.postId = postId
        destinationVC.openReaction = openReaction
        destinationVC.reactionId = reactionId
        self.navigationController?.pushViewController(destinationVC, animated: true)
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
    
    func pushToPostDetailsViewController(postId:Int) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let likersListVC = storyboard.instantiateViewController(withIdentifier: "ListOfLikersViewController") as! ListOfLikersViewController
        likersListVC.postId = postId
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(likersListVC, animated: true)
        }
    }
    
    func pushToCameraViewController(postDetails:Post) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        destinationVC.postDetails = postDetails
        destinationVC.isRecordingReaction = true
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
}

extension NewHomeViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && hasNext && !isWebserviceCallGoingOn {
            pageNo += 1
            postsTableView.isScrollEnabled = false
            fetchPostsList(forPage: pageNo)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let lastIndex = lastVideoPlayingCellIndexPath {
            if let lastCell = postsTableView.cellForRow(at: lastIndex) as? NewPostTableViewCell {
                DispatchQueue.main.async {
                    lastCell.pauseVideo()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        playVideoUsingOffset(offsetY: scrollView.contentOffset.y, scrollView: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        playVideoUsingOffset(offsetY: scrollView.contentOffset.y, scrollView: scrollView)
    }
    
    func playVideoUsingOffset(offsetY: CGFloat, scrollView: UIScrollView) {
        let height = postsTableView.bounds.height / 2 + offsetY
        let centrePoint = CGPoint(x: postsTableView.bounds.width / 2, y: height)
        guard let indexPathAtCenter = postsTableView.indexPathForRow(at: centrePoint) else {
            return
        }
        
        if let cell = postsTableView.cellForRow(at: indexPathAtCenter) as? NewPostTableViewCell {
            playCellVideo(cell: cell, scrollView: scrollView, indexPath: indexPathAtCenter)
        }
    }
    
    func playFirstVideoAfterReload() {
        let cellSection = 0
        let cellIndexPath = IndexPath(item: 0, section: cellSection)
        if let cell = postsTableView.cellForRow(at: cellIndexPath) as? NewPostTableViewCell {
            if cell.isVideoAlreadyPlaying() {
                cell.playVideo()
                return
            }
            
            if let lastIndex = lastVideoPlayingCellIndexPath {
                if let lastCell = postsTableView.cellForRow(at: lastIndex) as? NewPostTableViewCell {
                    DispatchQueue.main.async {
                        lastCell.pauseVideo()
                        lastCell.removeVideoPlayer()
                    }
                }
            }
            
            let post = postsList[cellIndexPath.section]
            guard let list = post.mediaList else {
                return
            }
            
            guard let urlStr = list[0].mediaUrl else {
                return
            }
            
            DispatchQueue.main.async {
                cell.setupVideoPlayer(urlStr: urlStr)
                if AppPreferences.getIsVideoAutoPlay() {
                    cell.playVideo()
                }
            }
        
            
            lastVideoPlayingCellIndexPath = cellIndexPath
        }
    }
    
    func playCellVideo(cell:NewPostTableViewCell, scrollView:UIScrollView, indexPath:IndexPath) {
        if cell.isVideoAlreadyPlaying() {
            cell.playVideo()
            return
        }
        
        if let lastIndex = lastVideoPlayingCellIndexPath {
            if let lastCell = postsTableView.cellForRow(at: lastIndex) as? NewPostTableViewCell {
                DispatchQueue.main.async {
                    lastCell.pauseVideo()
                    lastCell.removeVideoPlayer()
                }
            }
        }
        
        let post = postsList[indexPath.section]
        guard let list = post.mediaList else {
            return
        }
        
        guard let urlStr = list[0].mediaUrl else {
            return
        }
        
        DispatchQueue.main.async {
            cell.setupVideoPlayer(urlStr: urlStr)
            if AppPreferences.getIsVideoAutoPlay() {
                cell.playVideo()
            }
        }
        
        lastVideoPlayingCellIndexPath = indexPath
    }
    
}
