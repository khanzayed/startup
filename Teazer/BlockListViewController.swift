//
//  BlockListViewController.swift
//  Teazer
//
//  Created by Ankita Satpathy on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class BlockListViewController: UIViewController {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var noContentView: UIView!
    
    var blockList = [Friend]() 
    var pageNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        noContentView.isHidden = true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchBlockList(pageNo:pageNumber)
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

}


extension BlockListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "BlockListCell") as! BlockListCell
        let blocklist = blockList[indexPath.row]
        cell.nameLabel.text = blocklist.userName!
        cell.fullNameLabel.text = blocklist.firstName! + " " + blocklist.lastName!
        cell.setupCell()
        if let mediaURL = blocklist.profileMedia?.thumbUrl {
            CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { (image) in
                DispatchQueue.main.async {
                    cell.profileImageView.image = image
                }
            })
        } else{
            cell.profileImageView.image = #imageLiteral(resourceName: "ic_male_default")
       }
        
        cell.unblockTappedBlock = { [weak self] in
            
            UserProfileAPIHandler().blockUser(blocklist.userId!, 2)  {  (responseData) in
                
                if let error = responseData.errorObject {
                   ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                    return
                }
                if let message = responseData.message {
                    self?.view.makeToast("\(message)")
                    
                }
                
                if let status = responseData.status {
                    if status {
                        self?.fetchBlockList(pageNo: 1)
                    }
                }
            }
        }
        
        return cell
    }
}


extension BlockListViewController {
    
    //MARK: get block list API
    
    func fetchBlockList(pageNo:Int) {
        UserProfileAPIHandler().getBlockList(pageNo: pageNo) { [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            guard let strongSelf = self else {
                return
            }
            
            if let list = responseData.blockedList {
                strongSelf.blockList = list
                DispatchQueue.main.async {
                    if list.count > 0 {
                        strongSelf.noContentView.isHidden = true
                    }else{
                        strongSelf.noContentView.isHidden = false
                    }
                    strongSelf.tableView.reloadData()
                }
                
            }
        }
    }
}
