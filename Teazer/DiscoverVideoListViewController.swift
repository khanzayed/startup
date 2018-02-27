//
//  DiscoverVideoListViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class DiscoverVideoListViewController: UIViewController {

    typealias UserInterestUpdated = () -> Void
    var userInterestUpdated: UserInterestUpdated?
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var categoriesScrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint! // 182 - 41
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var myInterestTopTitleLabel: UILabel!
    @IBOutlet weak var BigMyInsterestHeadingView: UIView!
    @IBOutlet weak var categoryView: UIView!
    
    var posts:[Post]?
    var userInterests:[Category]!
    var interestsPageNoList = [Int:[String:Any]]()
    var hasNext = false
    var refreshControl:UIRefreshControl?
    var pageNo = 1
    var selectedCategoryId:Int!
    var isWebserviceCallGoingOn = false
    var isMyInterests = false
    var isTrendingCategories = false
    var selectedIndex = 0
    var flowLayout:UICollectionViewFlowLayout!
    let font = UIFont(name: Constants.kProximaNovaSemibold, size: 16.0)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        for category in userInterests {
            let dict:[String:Any] = [
                "pageNo"    :      1,
                "hasNext"   :      false,
                ]
            let categoryId = category.categoryId!
            interestsPageNoList[categoryId] = dict
        }
        
        if isTrendingCategories {
            titleLbl.text = userInterests[0].categoryName
            editBtn.isHidden = true
            topViewHeightConstraint.constant = 182 - 41
            categoryCollectionView.isHidden = true
            categoryView.isHidden = true
        }
        
        if isMyInterests {
            categoryCollectionView.tag = 101
            categoryCollectionView.dataSource = self
            categoryCollectionView.delegate = self
            categoryCollectionView.reloadData()
        }
        
        collectionView.tag = 102
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData() 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self?.userInterests = interests
                self?.categoryCollectionView.reloadData()
                self?.collectionView.reloadData()
                self?.userInterestUpdated?()
            }
        }
        tabBarController?.present(interestingCategoriesVC, animated: true, completion: nil)
    }
    
}

extension DiscoverVideoListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 101 {
            return userInterests.count
        } else {
            return userInterests.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 101 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListCategoryCollectionViewCell", for: indexPath) as! ListCategoryCollectionViewCell
            cell.titleLbl.text = userInterests[indexPath.row].categoryName!
            if selectedIndex == indexPath.row {
                cell.titleLbl.textColor = UIColor(rgba: userInterests[indexPath.row].categoryColorStr!)
            } else {
                cell.titleLbl.textColor = ColorConstants.kTextLightColor
            }
            cell.lineView.backgroundColor = (indexPath.row == selectedIndex) ? UIColor(rgba: userInterests[indexPath.row].categoryColorStr!) : ColorConstants.kBackgroundGrayColor
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BaseCollectionViewCell", for: indexPath) as! BaseCollectionViewCell
            if let details = interestsPageNoList[userInterests[indexPath.row].categoryId!] {
                cell.setupCell(pageNo: details["pageNo"] as! Int, hasNext: details["hasNext"] as! Bool,
                               category: userInterests[indexPath.row])
                cell.updateInfo = { [weak self] (categoryId, dict) in
                    self?.interestsPageNoList[categoryId] = dict
                }
                
                cell.cellTappedBlock = { [weak self] (postId) in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "HomePageDetailViewController") as! HomePageDetailViewController
                    destinationVC.postId = postId
                    self?.navigationController?.pushViewController(destinationVC, animated: true)
                }
                
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 101 {
            let title = userInterests[indexPath.row].categoryName!
            let width:CGFloat = title.getWidthForText(font: font) + 50.0
            return CGSize(width: width, height: 41.0)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: collectionView.bounds.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 101 {
            self.collectionView.scrollToItem(at:indexPath, at: .left, animated: true)
            self.categoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            if let previousCell = categoryCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ListCategoryCollectionViewCell {
                UIView.animate(withDuration: 0.2, animations: {
                    previousCell.lineView.backgroundColor = ColorConstants.kBackgroundGrayColor
                    previousCell.titleLbl.textColor = ColorConstants.kTextLightColor
                })
            }
            
            selectedIndex = indexPath.row
            if let currentCell = categoryCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ListCategoryCollectionViewCell {
                UIView.animate(withDuration: 0.2, animations: {
                    currentCell.lineView.backgroundColor = UIColor(rgba: self.userInterests[indexPath.row].categoryColorStr!)
                    currentCell.titleLbl.textColor = UIColor(rgba: self.userInterests[indexPath.row].categoryColorStr!)
                })
            }
        }
    }
    
}

extension DiscoverVideoListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollY = scrollView.contentOffset.y
        BigMyInsterestHeadingView.frame = CGRect(x: 0, y: 70 - scrollY, width: BigMyInsterestHeadingView.frame.size.width, height: BigMyInsterestHeadingView.frame.size.height)
        categoryView.frame = CGRect(x: 0, y: 141 - scrollY, width: categoryView.frame.size.width, height: categoryView.frame.size.height)
        
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if self.collectionView == scrollView {
            targetContentOffset.pointee = scrollView.contentOffset
            let pageWidth:Float = Float(self.view.bounds.width)
            
            let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
            let extra = (translation.x > 0) ? -0.7 : 0.7
            var cellToSwipe:Double = Double(Float(scrollView.contentOffset.x) / Float(pageWidth)) + Double(extra)
            if cellToSwipe < 0 {
                cellToSwipe = 0
            } else if cellToSwipe >= Double(self.userInterests.count) {
                cellToSwipe = Double(self.userInterests.count) - Double(1)
            }
            let indexPath:IndexPath = IndexPath(row: Int(cellToSwipe), section:0)
            DispatchQueue.main.async {
                self.collectionView.scrollToItem(at:indexPath, at: .left, animated: true)
                self.categoryCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
            
            if let previousCell = categoryCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ListCategoryCollectionViewCell {
                UIView.animate(withDuration: 0.2, animations: {
                    previousCell.lineView.backgroundColor = ColorConstants.kBackgroundGrayColor
                    previousCell.titleLbl.textColor = ColorConstants.kTextLightColor
                })
            }
            
            selectedIndex = indexPath.row
            if let currentCell = categoryCollectionView.cellForItem(at: IndexPath(item: selectedIndex, section: 0)) as? ListCategoryCollectionViewCell {
                UIView.animate(withDuration: 0.2, animations: {
                    currentCell.lineView.backgroundColor = UIColor(rgba: self.userInterests[indexPath.row].categoryColorStr!)
                    currentCell.titleLbl.textColor = UIColor(rgba: self.userInterests[indexPath.row].categoryColorStr!)
                })
            }
        }
    }

}
