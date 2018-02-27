//
//  ChangeCategoryViewController.swift
//  Teazer
//
//  Created by Mraj singh on 31/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ChangeCategoryViewController: UIViewController{

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    
    typealias CategoriesSelectedBlock = ([Category]) -> Void
    var categoriesSelectedBlock:CategoriesSelectedBlock!
    
    var categoryList = [Category]()
    var selectedCategories = [Category]()
    var categoryIdListStr = ""
    var loaderView:LoaderView?
    var matched = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategoriesList()
        self.myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ChangeCategoryViewController")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func fetchCategoriesList(){
        UserAPIHandler().getListOfCategories(completionBlock: {[weak self] (reponseData) in
            if let error = reponseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            if let list  = reponseData.categoriesList {
                if list.count > 0 {
                    self?.categoryList = list
                    self?.myTableView.reloadData()
                }
               
            }
        })
        
    }
   
    @IBAction func goToSettingsPage(_ sender: Any) {
         navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if selectedCategories.count < 5 {
            self.view.makeToast("Please select atleast 5 categories")
            return
        }
        
        var categoryIdListStr = ""
        for category in selectedCategories {
            categoryIdListStr += "\(category.categoryId!)" + ","
        }
        
        let params:[String:Any] = [
            "categories"  :   categoryIdListStr
        ]
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        UserAPIHandler().updateCategories(params: params) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
                self?.loaderView = nil
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.reason)
                return
            }
            if responseData.status == true {
                self?.categoriesSelectedBlock(self!.selectedCategories)
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.view.makeToast(Constants.kGenericErrorMessage)
            }
        }
    }
    
}


extension ChangeCategoryViewController: UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: "ChangeCategoryTableViewCell", for: indexPath) as! ChangeCategoryTableViewCell
        
        let name = categoryList[indexPath.row].categoryName
        cell.contentLabel?.text = name
        
        let index = selectedCategories.index { (cat) -> Bool in
            return cat.categoryName == name
        }
        if index == nil {
            cell.seletedTickView.isHidden = true
        } else {
            cell.seletedTickView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: false)
        
        let cell = tableView.cellForRow(at: indexPath) as! ChangeCategoryTableViewCell
        let catId = categoryList[indexPath.row].categoryId!
        let index:Int? = selectedCategories.index(where: { (category) -> Bool in
            return (category.categoryId == catId)
        })
        
        if index != nil && selectedCategories.count >= 6 {
            selectedCategories.remove(at: index!)
            cell.seletedTickView.isHidden = true
        }else if index != nil && selectedCategories.count <= 5 {
            
            self.view.makeToast("Atleast 5 categories must be choosen!!")
        }else {
            selectedCategories.append(categoryList[indexPath.row])
            cell.seletedTickView.isHidden = false
        }
    }
    
}


