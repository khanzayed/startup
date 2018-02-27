//
//  CategoriesSelectionViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class CategoriesSelectionViewController: UIViewController {

    typealias CategoriesSelectedBlock = ([Category]) -> Void
    var categoriesSelectedBlock:CategoriesSelectedBlock!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var doneBtn: UIButton!
   
    
    let buttonFont:UIFont = UIFont(name: "ProximaNova-Regular", size: 17.0)!
    var selectedCategories = [Category]()
    var originalCategories = [Category]()
    var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchCategoriesList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        searchView.layer.borderWidth = 0.5
        searchView.layer.borderColor = UIColor(rgba: "#B2B2B2").cgColor
        
        doneBtn.isEnabled = false
        doneBtn.setTitleColor(UIColor(rgba: "#C6C6C6"), for: .normal)
        
        searchTextField.isEnabled = false
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
                        self?.doneBtn.isEnabled = true
                        self?.doneBtn.titleLabel?.font = UIFont(name:Constants.kProximaNovaSemibold, size: 17.0)
                        self?.doneBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
                    }
                    self?.searchTextField.isEnabled = true
                    self?.originalCategories = Array(list)
                    self?.setupCategoryView(categories: list)
                }
            }
        })
    }
    
    func setupCategoryView(categories:[Category]) {
        var x:CGFloat = 15,y:CGFloat = 20
        let height:CGFloat = 37
        
        for category in categories {
            let title = "+ " + category.categoryName!
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
            button.setTitleColor((index == nil) ? UIColor(rgba: "#333333") : UIColor(rgba: "#FFFFFF"), for: .normal)
            button.backgroundColor = (index == nil) ? UIColor(rgba: "#FFFFFF") : UIColor(rgba: "#26C6DA")
            button.layer.borderColor = (index == nil) ? UIColor(rgba: "#333333").cgColor : UIColor(rgba: "#26C6DA").cgColor
            button.layer.cornerRadius = height / 2
            button.tag = category.categoryId!
            button.addTarget(self, action: #selector(self.categoryButtonTapped(sender:)), for: .touchUpInside)
            
            x += width + 20
            
            scrollView.addSubview(button)
           
        }
        y += height + 20
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: y)
        
    }
    
    func clearScrollView() {
        let subViews = scrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }
    
    @objc func categoryButtonTapped(sender:UIButton) {
        let index = selectedCategories.index(where: { (category) -> Bool in
            return (category.categoryId == sender.tag)
        })
        
        if index == nil && selectedCategories.count <= 4 {
            let category = Category(categoryId: sender.tag, categoryName: sender.titleLabel!.text!, categoryColorStr: "#26C6DA")
            sender.layer.borderColor = ColorConstants.kAppGreenColor.cgColor
            sender.setTitleColor(UIColor(rgba: "#FFFFFF"), for: .normal)
            sender.layer.backgroundColor = ColorConstants.kAppGreenColor.cgColor
            selectedCategories.append(category)
            UIView.animate(withDuration: 0.01, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    sender.transform = CGAffineTransform.identity
                }
            })
        }
        else if selectedCategories.count > 4 && index == nil && firstTime {
                showAlert()
                firstTime = false
            }
        else if index != nil {
            selectedCategories.remove(at: index!)
            firstTime = true
            sender.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            sender.layer.borderColor = UIColor(rgba: "#333333").cgColor
            sender.layer.backgroundColor = ColorConstants.kWhiteColorKey.cgColor
            if selectedCategories.count < 1 {
                doneBtn.setTitleColor(UIColor(rgba: "#C6C6C6"), for: .normal)
                doneBtn.titleLabel?.font = UIFont(name:Constants.kProximaNovaRegular, size: 17.0)
            }
        }
        
        if selectedCategories.count >= 0 && selectedCategories.count <= 5 {
            doneBtn.isEnabled = true
            doneBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            doneBtn.titleLabel?.font = UIFont(name:Constants.kProximaNovaSemibold, size: 17.0)
        } else {
            doneBtn.isEnabled = false
            doneBtn.setTitleColor(UIColor(rgba: "#C6C6C6"), for: .normal)
            doneBtn.titleLabel?.font = UIFont(name:Constants.kProximaNovaRegular, size: 17.0)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            if let strongSelf = self {
                strongSelf.categoriesSelectedBlock(strongSelf.selectedCategories)
            }
        }
    }
    func showAlert() {
       self.view.makeToast("You can only choose maximum 5 categories!")
    }

}

extension CategoriesSelectionViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text!
        if string !=  "" {
            text = text + "\(string)"
        } else {
            text = text.replacingCharacters(in: Range(range, in: text)!, with: "")
        }
        
        if text != "" {
            let filteredArr = originalCategories.filter { (category) -> Bool in
                return category.categoryName!.lowercased().contains(text.lowercased())
            }
            clearScrollView()
            setupCategoryView(categories: filteredArr)
        } else {
            clearScrollView()
            setupCategoryView(categories: originalCategories)
        }
        
        return true
    }
    
}
