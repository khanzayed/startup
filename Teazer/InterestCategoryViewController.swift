//
//  interestCategoryViewController.swift
//  Teazer
//
//  Created by Mraj singh on 25/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class InterestCategoryViewController: UIViewController {
    
    typealias UpdateUserInterestsBlock = ([Category]) -> Void
    var updateUserInterestsBlock:UpdateUserInterestsBlock?
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var user:User!
    let buttonFont:UIFont = UIFont(name: Constants.kProximaNovaRegular, size: 17.0)!
    var selectedCategories = [Category]()
    var isNewUser = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchCategoriesList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isNewUser {
            closeButton.isHidden = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        saveButton.isEnabled = false
    }
    
    func updateCategoryList(params:[String:Any]) {
        UserAPIHandler().updateCategories(params: params) { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if let status = responseData.status {
                if status == true {
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.dismiss(animated: true, completion: {
                                strongSelf.updateUserInterestsBlock?(strongSelf.selectedCategories)
                            })
                        }
                    }
                }
            }
        }
    }
   
    
    func fetchCategoriesList() {
        UserAPIHandler().getListOfCategories(completionBlock:{ [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            if let list = responseData.categoriesList {
                if list.count > 0 {
                    if self?.selectedCategories.count != 0 {
                        self?.saveButton.isEnabled = true
                        self?.saveButton.setTitleColor(UIColor(rgba: "#FFFFFF"), for: .normal)
                    }
                    self?.setupCategoryView(categories: list)
                }
            }
        })
    }
    
    func setupCategoryView(categories:[Category]) {
        var x:CGFloat = 15,y:CGFloat = 0
        let height:CGFloat = 37
        
        for category in categories {
            let title = category.categoryName!
            let width = title.getWidthForText(font: buttonFont) + 40
            
            if (x + width) > UIScreen.main.bounds.width {
                //x = (UIScreen.main.bounds.width - anotherWidth)/2
                x = 15
                y += height + 20
                
            }
            
            let button = UIButton(frame: CGRect(x: x, y: y, width: width ,height: height))
            button.setTitle(title, for: .normal)
            button.layer.borderWidth = 1
            let index = selectedCategories.index(where: { (categoryObj) -> Bool in
                return (categoryObj.categoryId == category.categoryId)
            })
            if index != nil {
                button.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
                button.layer.backgroundColor = ColorConstants.kAppGreenColor.cgColor
            } else {
                button.layer.borderColor =  ColorConstants.kWhiteColorKey.cgColor
                button.layer.backgroundColor = UIColor.clear.cgColor
            }
            
            button.setTitleColor(ColorConstants.kWhiteColorKey, for: .normal)
            button.layer.cornerRadius = height / 2
            button.tag = category.categoryId!
            button.addTarget(self, action: #selector(self.categoryButtonTapped(sender:)), for: .touchUpInside)
            
            x += width + 20
            
            scrollView.addSubview(button)
           
        }
        y += height + 20
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: y)
        
    }
    
    @objc func categoryButtonTapped(sender:UIButton) {
        let index = selectedCategories.index(where: { (category) -> Bool in
            return (category.categoryId == sender.tag)
        })
    
        if index == nil {
            let category = Category(categoryId: sender.tag, categoryName: sender.titleLabel!.text!, categoryColorStr: "#26C6DA")
            sender.layer.borderColor = UIColor(rgba: "#26C6DA").cgColor
            sender.setTitleColor(UIColor(rgba: "#FFFFFF"), for: .normal)
            sender.layer.backgroundColor = UIColor(rgba: "#26C6DA").cgColor
            sender.titleLabel?.font = UIFont(name: Constants.kProximaNovaRegular ,size:17)
            selectedCategories.append(category)
            UIView.animate(withDuration: 0.01, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    sender.transform = CGAffineTransform.identity
                }
            })
        } else {
            selectedCategories.remove(at: index!)
            sender.setTitleColor(UIColor(rgba: "#FFFFFF"), for: .normal)
            sender.layer.borderColor = UIColor(rgba: "#FFFFFF").cgColor
            sender.layer.backgroundColor = nil
            sender.titleLabel?.font = UIFont(name: Constants.kProximaNovaRegular, size:17)
        }
        
        if selectedCategories.count >= 5 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        var categoryIdListStr = ""
        for category in selectedCategories {
            categoryIdListStr += "\(category.categoryId!)" + ","
        }
        
        let params:[String:Any] = [
            "categories"  :   categoryIdListStr
        ]
        updateCategoryList(params: params)
    }

}
