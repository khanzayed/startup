//
//  TabbarViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import Instructions


class TabbarViewController: UITabBarController {

    typealias ScrollToTopBlock = () -> Void
    var scrollToTopBlock:ScrollToTopBlock?
    
    typealias ScrollToTopBlockForDiscover = () -> Void
    var scrollToTopBlockForDiscover:ScrollToTopBlockForDiscover?
    
    typealias ScrollToTopBlockForNotification = () -> Void
    var scrollToTopBlockForNotification:ScrollToTopBlockForNotification?
    
    var previousSelectedIndex = TabbarControllerIndex.kHomeVCIndex
    var cameraBtn:UIButton!
    let buttonWidth:CGFloat = 55.0
    var isListUpdated = false
    let coachMarksController = CoachMarksController()
    var homeView:UIView!
    var discoverView: UIView!
    var profileView: UIView!
    var seletedItemIndex = 0
    var compressedVideoURL:URL?
    var isVideoReadyToUpload = false
    var uploadViewImage:UIImage?
    var isReactionVideo = false
    var taggedFriendsIdsList = ""
    var taggedCategoriesIdsList = ""
    var taggedLocation:GooglePlace?
    var videoTitle:String?
    var reactionPostId:Int!
    var cameraAPIHandler:CameraControllerAPIHandler?
    var isUploading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coachMarksController.overlay.allowTap = true
        coachMarksController.overlay.color = UIColor.black.withAlphaComponent(0.8)
        self.coachMarksController.dataSource = self
        self.tabBar.backgroundColor = UIColor.clear
        self.tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.7)
        for tabbarItem in self.tabBar.items! {
            tabbarItem.title = ""
            //tabbarItem.image = tabbarItem.image?.withRenderingMode(.alwaysOriginal)
            tabbarItem.imageInsets = UIEdgeInsetsMake(4, 0, -8, 0)
        
        }
        var screenHeight:CGFloat = UIScreen.main.bounds.height
        if screenHeight > 800 {
            screenHeight -= 30
        }
        let x:CGFloat = (UIScreen.main.bounds.width - buttonWidth) / 2
        let y:CGFloat = (screenHeight - 10 - buttonWidth)
        homeView = UIView(frame: CGRect(x: 10, y: y+15, width: buttonWidth, height: buttonWidth))
        discoverView = UIView(frame: CGRect(x: UIScreen.main.bounds.width/5+10, y: y+15, width: buttonWidth, height: buttonWidth))
        profileView = UIView(frame: CGRect(x: (4*(UIScreen.main.bounds.width/5))+10, y: y+15, width: buttonWidth, height: buttonWidth))
        cameraBtn = UIButton(frame: CGRect(x: x, y: -20, width: buttonWidth, height: buttonWidth))
        cameraBtn.setImage(UIImage(named: "ic_add"), for: .normal)
        cameraBtn.layer.borderWidth = 1.0
        cameraBtn.layer.borderColor = UIColor(rgba: "#ED3E51").cgColor
        cameraBtn.layer.cornerRadius = buttonWidth / 2
        cameraBtn.backgroundColor = UIColor(rgba: "#ED3E51")
        cameraBtn.adjustsImageWhenHighlighted = false
        cameraBtn.addTarget(self, action: #selector(self.cameraButtonTapped), for: .touchUpInside)
        self.tabBar.addSubview(cameraBtn)// view.insertSubview(cameraBtn, at: 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "isSecondTimeForHome")
        if launchedBefore  {
           return
        } else {
            self.coachMarksController.start(on: self)
            UserDefaults.standard.set(true, forKey: "isSecondTimeForHome")
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

    
    func hideCameraButton(value:Bool) {
        cameraBtn.isHidden = value
        if !value {
            self.view.bringSubview(toFront: cameraBtn)
        }
    }
    
    @objc func cameraButtonTapped() {
        DispatchQueue.main.async {
            self.selectedIndex = 2
        }
    }
    
    func removeVideoDetails() {
        compressedVideoURL = nil
        isVideoReadyToUpload = false
        uploadViewImage = nil
    }
    
}

extension TabbarViewController: UITabBarControllerDelegate {

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if TabbarControllerIndex.kCameraVCIndex == TabbarControllerIndex(rawValue: self.selectedIndex) {
            self.previousSelectedIndex = TabbarControllerIndex(rawValue: self.selectedIndex)!
            self.cameraBtn.isHidden = true
        } else {
            self.cameraBtn.isHidden = false
        }
        
        guard let items = tabBar.items else {
            return
        }
        
        guard let itemIndex =  items.index(of: item) else {
            return
        }
        seletedItemIndex = itemIndex
        if TabbarControllerIndex.kHomeVCIndex == TabbarControllerIndex(rawValue: itemIndex) && previousSelectedIndex == TabbarControllerIndex.kHomeVCIndex {
            scrollToTopBlock?()
        }
        
        if TabbarControllerIndex.kSearchVCIndex == TabbarControllerIndex(rawValue: itemIndex) && previousSelectedIndex == TabbarControllerIndex.kSearchVCIndex {
            scrollToTopBlockForDiscover?()
        }
        
        if TabbarControllerIndex.kNotificationVCIndex == TabbarControllerIndex(rawValue: itemIndex) && previousSelectedIndex == TabbarControllerIndex.kNotificationVCIndex {
            scrollToTopBlockForNotification?()
        }
        
        previousSelectedIndex = TabbarControllerIndex(rawValue: itemIndex)!

        
        if TabbarControllerIndex.kMyActivitiesVCIndex  ==  TabbarControllerIndex(rawValue: itemIndex) {
            let launchedBefore = UserDefaults.standard.bool(forKey: "isSecondTimeForProfile")
            if !launchedBefore  {
                self.coachMarksController.start(on: self)
                UserDefaults.standard.set(true, forKey: "isSecondTimeForProfile")
            }
        } else if TabbarControllerIndex.kSearchVCIndex  ==  TabbarControllerIndex(rawValue: itemIndex) {
            let launchedBefore = UserDefaults.standard.bool(forKey: "isSecondTimeForDiscover")
            if !launchedBefore {
                self.coachMarksController.start(on: self)
                UserDefaults.standard.set(true, forKey: "isSecondTimeForDiscover")
            }
        }
    }

}

extension TabbarViewController: CoachMarksControllerDataSource,CoachMarksControllerDelegate{
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
        
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        if seletedItemIndex == 0 {
            coachViews.bodyView.hintLabel.text = "Browse Videos & start exploring Videos with different mentioned Categories. Enjoy!"
        } else if seletedItemIndex == 1 {
            coachViews.bodyView.hintLabel.text = "Discover the most popular videos and search the videos you seek."
        } else if seletedItemIndex == 4 {
            coachViews.bodyView.hintLabel.text = "Have a track on your Creations & Reactions over Videos"
        }
        
        UIView.transition(with: coachViews.arrowView!, duration: 1.0, options: [.autoreverse,.repeat], animations: {
            coachViews.arrowView?.frame.origin.y -= 15
        }, completion: nil)
        
       
        coachViews.bodyView.nextLabel.text = "OKAY!"
        coachViews.bodyView.backgroundColor = UIColor.clear
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        if seletedItemIndex == 0 {
            let coachMark = coachMarksController.helper.makeCoachMark(for: homeView) {
                (frame: CGRect) -> UIBezierPath in
                
                return UIBezierPath(ovalIn: frame.insetBy(dx: -10, dy: -10))
            }
            return coachMark
        } else if seletedItemIndex == 1 {
            let coachMark = coachMarksController.helper.makeCoachMark(for: discoverView) {
                (frame: CGRect) -> UIBezierPath in
                
                return UIBezierPath(ovalIn: frame.insetBy(dx: -10, dy: -10))
            }
            return coachMark
        } else {
            let coachMark = coachMarksController.helper.makeCoachMark(for: profileView) {
                (frame: CGRect) -> UIBezierPath in
                
                return UIBezierPath(ovalIn: frame.insetBy(dx: -10, dy: -10))
            }
            return coachMark
        }
        
    }
}

extension TabbarViewController {
    
    func uploadVideo() {
        if isVideoReadyToUpload, let fileURL = compressedVideoURL, !isUploading {
            cameraAPIHandler = CameraControllerAPIHandler()
            let navController = self.viewControllers![TabbarControllerIndex.kHomeVCIndex.rawValue] as! UINavigationController
            let homeViewController = navController.viewControllers[0] as! NewHomeViewController
            homeViewController.progressView.progress = 0
            homeViewController.imageUploadVideo.image = uploadViewImage
            isUploading = true
            
            if isReactionVideo {
                cameraAPIHandler?.uploadReactionVideo(title: videoTitle, postId: reactionPostId, fileURL: fileURL, completionHandler: {  [weak self] (responseModal) in
                    guard self != nil else {
                        return
                    }
                    
                    self?.isUploading = false
                    self?.isVideoReadyToUpload = false
                    homeViewController.hideUploadProgressView()
                    
                    try? FileManager.default.removeItem(at: fileURL)
                    if let reaction = responseModal.reaction, let index = homeViewController.lastSelectedIndexPathForReaction {
                        var reactionList = [Reaction]()
                        if let list = homeViewController.postsList[index.section].reactions {
                            reactionList = list
                        }
                        reactionList.insert(reaction, at: 0)
                        homeViewController.postsList[index.section].reactions = reactionList
                        homeViewController.postsList[index.section].canReact = false
                        homeViewController.postsList[index.section].totalReactions! += 1
                        DispatchQueue.main.async {
                            homeViewController.postsTableView.reloadSections([index.section], with: .automatic)
                        }
                    } else {
                        ErrorView().showBasicAlertForError(message: "Reaction upload failed", forVC: homeViewController)
                    }
                    }, uploadProgressHandler: { (progress) in
                        homeViewController.progressView.progress = progress
                })
            } else {
                cameraAPIHandler?.uploadUserVideo(title: videoTitle, fileURL: fileURL, place: taggedLocation, taggedFriends: taggedFriendsIdsList, taggedCategories: taggedCategoriesIdsList, completionHandler: { [weak self] (responseModal) in
                    guard self != nil else {
                        return
                    }
                    
                    self?.isUploading = false
                    self?.isVideoReadyToUpload = false
                    homeViewController.hideUploadProgressView()
                    
                    try? FileManager.default.removeItem(at: fileURL)
                    
                    if responseModal.isVideoUploaded == true, let newPost = responseModal.post {
                        DispatchQueue.main.async {
                            homeViewController.postsList.insert(newPost, at: 0)
                            homeViewController.postsTableView.insertSections([0], with: .automatic)
                            homeViewController.playFirstVideoAfterReload()
                        }
                    } else {
                        ErrorView().showBasicAlertForError(message: "Video upload failed", forVC: self)
                    }
                    
                    }, uploadProgressHandler: { (progress) in
                        DispatchQueue.main.async {
                            homeViewController.progressView.progress = progress
                        }
                })
            }
        }
    }
    
    func cancelUpload() {
        cameraAPIHandler?.cancelUploadPost()
        cameraAPIHandler?.cancelUploadReaction()
    }
    
}
