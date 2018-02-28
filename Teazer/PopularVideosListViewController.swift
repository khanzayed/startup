//
//  PopularVideosListViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 28/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

class PopularVideosListViewController: UIViewController {
    
    typealias UpdatePostBlock = (Int?, Int?, Int?, Bool?) -> Void
    var updatePostBlock: UpdatePostBlock?
    
    typealias ReactionRecordedBlock = () -> Void
    var reactionRecordedBlock: ReactionRecordedBlock?
    
    typealias UserInterestUpdated = ([Category]) -> Void
    var userInterestUpdated: UserInterestUpdated?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint! // 182 - 41
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var BigTitleView: UIView!
    @IBOutlet weak var topMostPopularLbl: UILabel!
    @IBOutlet weak var topConstraintBigTitleView: NSLayoutConstraint!
    
    var loaderView:LoaderView!
    var posts:[Post]?
    var userInterests:[Category]!
    var selectedCategory:Category!
    var hasNext = false
    var refreshControl:UIRefreshControl?
    var pageNo = 1
    var selectedCategoryId:Int!
    var isWebserviceCallGoingOn = false
    var isMyInterests = false
    var isTrendingCategories = false
    var loader:LoaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let layout = collectionView?.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
            collectionView.delegate = self
            collectionView.dataSource = self
        }
        
        if isMyInterests {
            setupCategoryList()
        } else if isTrendingCategories {
            titleLbl.text = selectedCategory.categoryName
            editBtn.isHidden = true
            topViewHeightConstraint.constant = 182 - 41
            fetchPost(categoryId: selectedCategory.categoryId!, pageNo: pageNo)
        } else {
            titleLbl.text = "Most Popular"
            editBtn.isHidden = true
            topViewHeightConstraint.constant = 182 - 41
            fetchPopularPosts(pageNo: pageNo)
        }
        collectionView.contentInset = UIEdgeInsetsMake(71, 0.0, 0.0, 0.0)
        collectionView.scrollRectToVisible(CGRect(x:0,y:0,width: 1,height: 1), animated: false)
        addPullToRefresh()
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
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        //let title = NSLocalizedString("Refreshing.....", comment: "Refreshing.....")
        //refreshControl?.attributedTitle = NSAttributedString(string: title)
        refreshControl?.addTarget(self, action: #selector(refreshOptions(sender:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl!)
        }
    }
    
    @objc func refreshOptions(sender: UIRefreshControl) {
        pageNo = 1
        
        if isMyInterests {
            fetchPost(categoryId: selectedCategoryId, pageNo: pageNo)
        } else if isTrendingCategories {
            fetchPost(categoryId: selectedCategory.categoryId!, pageNo: pageNo)
        } else {
            fetchPopularPosts(pageNo: pageNo)
        }
    }
    
    func setupCategoryList() {
        let font = UIFont(name: Constants.kProximaNovaSemibold, size: 16.0)!
        var x:CGFloat = 0
        for category in userInterests {
            let title = category.categoryName!
            let width:CGFloat = title.getWidthForText(font: font) + 50.0
        
            let button = UIButton(frame: CGRect(x: x, y: 0, width: width, height: 41.0))
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = font
            button.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            button.tag = category.categoryId!
            button.addTarget(self, action: #selector(self.categoryButtonTapped(sender:)), for: .touchUpInside)
            
            let view = UIView(frame: CGRect(x: x, y: 39.0, width: width, height: 2.0))
            view.backgroundColor = ColorConstants.kTextBlackColor
            view.tag = button.tag + 1000
            view.isHidden = true
            
            x += width
                
            categoriesScrollView.addSubview(button)
            categoriesScrollView.addSubview(view)
        }
        categoriesScrollView.contentSize = CGSize(width: x, height: 41.0)
        
        
        selectedCategoryId = userInterests[0].categoryId!
        fetchPost(categoryId: selectedCategoryId, pageNo: pageNo)
        let view = categoriesScrollView.viewWithTag(selectedCategoryId + 1000)
        view?.isHidden = false
        
    }
    
    @objc func categoryButtonTapped(sender: UIButton) {
        if selectedCategoryId == sender.tag {
            return
        }
        
        pageNo = 1
        showBottomLineView(tag: sender.tag)
        selectedCategoryId = sender.tag
        fetchPost(categoryId: selectedCategoryId, pageNo: pageNo)
    }
    
    func showBottomLineView(tag:Int) {
        let previousView = categoriesScrollView.viewWithTag(selectedCategoryId + 1000)
        previousView?.isHidden = true
        
        let nextView = categoriesScrollView.viewWithTag(tag + 1000)
        nextView?.isHidden = false
    }
    
    @IBAction func backButtonTapped(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let interestingCategoriesVC = storyboard.instantiateViewController(withIdentifier: "InterestCategoryViewController") as! InterestCategoryViewController
        interestingCategoriesVC.selectedCategories = userInterests
        interestingCategoriesVC.view.backgroundColor = UIColor.clear
        interestingCategoriesVC.modalPresentationStyle = .overCurrentContext
        interestingCategoriesVC.updateUserInterestsBlock = { [weak self] (interests) in
            DispatchQueue.main.async {
                self?.userInterestUpdated?(interests)
                self?.userInterests = interests
                self?.categoriesScrollView.subviews.forEach({ $0.removeFromSuperview() })
                self?.setupCategoryList()
            }
        }
        tabBarController?.present(interestingCategoriesVC, animated: true, completion: nil)
    }
    
}

extension PopularVideosListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let list = posts else {
            return 0
        }
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturesVideosCollectionViewCell", for: indexPath) as! FeaturesVideosCollectionViewCell
        
        let post = posts![indexPath.row]
        cell.setupCell(post: post)
        
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
                    DispatchQueue.main.async { [weak self] in
                        if let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? FeaturesVideosCollectionViewCell {
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
                CommonAPIHandler().getDataFromUrlWithId(imageURL: urlStr, imageId: postOwnerId, indexPath: indexPath, completion: { (image, lastIndexPath, key) in
                    DispatchQueue.main.async { [weak self] in
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
                        if let cell = self?.collectionView.cellForItem(at: lastIndexPath) as? FeaturesVideosCollectionViewCell {
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if !Connectivity.isConnectedToInternet() {
            return
        }
        let postId = posts![indexPath.row].postId!
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
        destinationVC.postId = postId
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}

extension PopularVideosListViewController: HomePageLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        let post = posts![indexPath.row]
        let height = post.mediaList![0].height! * (UIScreen.main.bounds.width / 2) / post.mediaList![0].width!
        return (height > 175) ? height : 175.0
    }
    
}

extension PopularVideosListViewController {
    
    func fetchPost(categoryId:Int, pageNo:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        if isMyInterests {
            DispatchQueue.main.async {
                self.loader = LoaderView()
                self.loader?.addLoaderView(forView: self.view)
            }
        }
        
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getCategoryVideos(categoryId, page: pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                self?.loader?.removeLoaderView()
                self?.loader = nil
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if let list = responseData.posts {
                var firstIndex = 0
                if pageNo == 1 {
                    strongSelf.posts = list
                } else {
                    firstIndex = strongSelf.posts!.count
                    strongSelf.posts!.append(contentsOf: list)
                }
                if responseData.nextPage == true {
                    strongSelf.hasNext = true
                    strongSelf.pageNo += 1
                } else {
                    strongSelf.hasNext = false
                }
                
                self?.collectionView.performBatchUpdates({
                    for i in 0..<list.count {
                        let index = i + firstIndex
                        let indexPath = IndexPath(item: index, section: 0)
                        self?.collectionView.insertItems(at: [indexPath])
                    }
                }, completion: { (true) in
                    self?.isWebserviceCallGoingOn = false
                })
//                DispatchQueue.main.async {
//                    strongSelf.collectionView.reloadData()
//                }
            }
        }
    }
    
    func fetchPopularPosts(pageNo:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getPopularVideos(pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                self?.loader = nil
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if let list = responseData.posts {
                var firstIndex = 0
                if pageNo == 1 {
                    strongSelf.posts = list
                    self?.collectionView.reloadData()
                } else {
                    firstIndex = strongSelf.posts!.count
                    strongSelf.posts!.append(contentsOf: list)
                    
                    self?.collectionView.performBatchUpdates({
                        for i in 0..<list.count {
                            let index = i + firstIndex
                            let indexPath = IndexPath(item: index, section: 0)
                            self?.collectionView.insertItems(at: [indexPath])
                        }
                    }, completion: { (true) in
                        self?.isWebserviceCallGoingOn = false
                    })
                }
                
                if responseData.nextPage == true {
                    strongSelf.hasNext = true
                    strongSelf.pageNo += 1
                } else {
                    strongSelf.hasNext = false
                }
            }
        }
    }
    
}

extension PopularVideosListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y + 71
        let contentHeight = scrollView.contentSize.height
        if offsetY > 0 {
            DispatchQueue.main.async {
                self.topConstraintBigTitleView.constant = -offsetY
            }
        }
        if offsetY  < 0 {
            BigTitleView.frame = CGRect(x: 0, y: 70, width: BigTitleView.frame.size.width, height: BigTitleView.frame.size.height)
        }
        let alpha: CGFloat = 0.0 + (((offsetY) - 25) / 40)
        topMostPopularLbl.alpha = alpha
        topMostPopularLbl.isHidden = false

        
        if offsetY > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasNext {
            pageNo += 1
            if isMyInterests {
                fetchPost(categoryId: selectedCategoryId, pageNo: pageNo)
            } else if isTrendingCategories {
                fetchPost(categoryId: selectedCategory.categoryId!, pageNo: pageNo)
            } else {
                fetchPopularPosts(pageNo: pageNo)
            }
        }
    }
    
}

