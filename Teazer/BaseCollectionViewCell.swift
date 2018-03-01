//
//  BaseCollectionViewCell.swift
//  Teazer
//
//  Created by Faraz Habib on 05/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
    typealias CellTappedBlock = (Int) -> Void
    var cellTappedBlock:CellTappedBlock?
    
    typealias UpdateInfo = (Int, [String:Any]) -> Void
    var updateInfo:UpdateInfo!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var noInternetView: UIView!
    
    var pageNo = 1
    var hasNext = false
    var isWebserviceCallGoingOn = false
    var category:Category!
    var indexList = [Int]()
    var lastCategoryId:Int!
    var interestsPost = [Post]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let layout = collectionView?.collectionViewLayout as? HomePageLayout {
            layout.delegate = self
            layout.cellPadding = 5.0
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    func setupCell(pageNo:Int, hasNext:Bool = false, category:Category) {
        self.indexList = PostCacheData.shared.fetchCategoryVideos(categoryId: category.categoryId!)
        self.pageNo = pageNo
        self.hasNext = hasNext
        self.category = category
        noInternetView.isHidden = true
        
        if indexList.count == 0 {
            fetchPostsForCategory(category.categoryId!, pageNo: 1)
        } else {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
}

extension BaseCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interestsPost.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FeaturesVideosCollectionViewCell", for: indexPath) as! FeaturesVideosCollectionViewCell
        
        let post = interestsPost[indexPath.row]
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
                    DispatchQueue.main.async {
                        cell.videoImageView.image = image
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
                    DispatchQueue.main.async {
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: 60, height: 60))
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
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if !Connectivity.isConnectedToInternet() {
            return
        }
        if let postId = interestsPost[indexPath.row].postId {
            cellTappedBlock?(postId)
        }
    }
    
}

extension BaseCollectionViewCell: HomePageLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        //let indexList = PostCacheData.shared.fetchCategoryVideos(categoryId: category.categoryId!)
        let post = interestsPost[indexPath.row]
        let height = post.mediaList![0].height! * (UIScreen.main.bounds.width / 2) / post.mediaList![0].width!
        return (height > 175.0)  ? height : 175.0
    }
    
}

extension BaseCollectionViewCell {
    
    func fetchPostsForCategory(_ categoryId:Int, pageNo:Int) {
        if !Connectivity.isConnectedToInternet() {
            return
            
        }
        
        isWebserviceCallGoingOn = true
        DiscoverControllerAPIsHandler().getCategoryVideos(categoryId, page: pageNo) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.isWebserviceCallGoingOn = false
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.posts {
                self?.noInternetView.isHidden = true
                if strongSelf.interestsPost.count == 0 || strongSelf.lastCategoryId != categoryId {
                    strongSelf.interestsPost = list
                } else if strongSelf.lastCategoryId == categoryId {
                    strongSelf.interestsPost.append(contentsOf: list)
                }
                if list.count == 0 {
                    DispatchQueue.main.async {
                        self?.noInternetView.isHidden = false
                    }
                }
                if responseData.nextPage == true {
                    strongSelf.hasNext = true
                    strongSelf.pageNo = pageNo + 1
                    let dict:[String:Any] = [
                        "pageNo"    :      pageNo + 1,
                        "hasNext"   :      true
                    ]
                    strongSelf.updateInfo(categoryId, dict)
                } else {
                    strongSelf.hasNext = false
                    strongSelf.pageNo = pageNo + 1
                    
                    let dict:[String:Any] = [
                        "pageNo"    :      pageNo,
                        "hasNext"   :      false
                    ]
                    strongSelf.updateInfo(categoryId, dict)
                }
                DispatchQueue.main.async {
                    strongSelf.collectionView.reloadData()
                }
            }
            strongSelf.lastCategoryId = categoryId
        }
    }
    
}

extension BaseCollectionViewCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasNext {
            fetchPostsForCategory(category.categoryId!, pageNo: pageNo)
        }
    }
    
}



