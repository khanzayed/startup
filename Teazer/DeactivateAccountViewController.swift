//
//  DeactivateAccountViewController.swift
//  Teazer
//
//  Created by Mraj singh on 02/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class DeactivateAccountViewController: UIViewController {

    
    @IBOutlet weak var tableVIew: UITableView!
    @IBOutlet weak var saveButton: UIButton!
    
    var deactivationReasonsList = [DeactivateReason]()
    var descriptionCellHeight:CGFloat = 0
    var selectedIndex = -1
    var deactivationId: Int?
    var reasonForDeactivation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableVIew.tableFooterView = UIView(frame: .zero)
        tableVIew.rowHeight = UITableViewAutomaticDimension
        fetchDeactivationReasonlist()
        saveButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    @objc func keyboardWillHide() {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillChange(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = -keyboardSize.height
            
        } 
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: nil)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func fetchDeactivationReasonlist(){
        
        UserProfileAPIHandler().getDeactivationList({ [weak self]  responseData in
            if let error  = responseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
            }
            if let list = responseData.deactivationReasonList{
                self?.deactivationReasonsList = list
                DispatchQueue.main.async {
                    self?.tableVIew.reloadData()
                }
            }
        })
    }
    
    func deactivateAccount(_ deactivateId:Int , _ reason: String){
        
        let params:[String:Any] = [
            "deactivate_id"    :   deactivateId,
            "reason"           :   reason
        ]
        
        UserProfileAPIHandler().deactivateAccount(params){[weak self] resposnseData in
            if let error  = resposnseData.errorObject{
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
            }
            if let status  = resposnseData.status{
                if status {
                    self?.view.makeToast("Account Deactivated Successfully!! Hope to see you soon!!")
                    LogOut().doLogOut()
                } else {
                    self?.view.makeToast("There is some problem in deactivating your account. Please try again.")
                }
            }
        }
        
    }
 
    @IBAction func saveButtonTapped(_ sender: Any) {
        if selectedIndex == deactivationReasonsList.count - 1 {
            if let cell = tableVIew.cellForRow(at: IndexPath(item: selectedIndex + 1, section: 0)) as? DeactivateAccountTypeReasonTableViewCell {
                reasonForDeactivation = cell.reasonTextView.text
            }
        }
        deactivateAccount(deactivationId!, reasonForDeactivation)
    }
}

extension DeactivateAccountViewController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (deactivationReasonsList.count > 0) ? deactivationReasonsList.count + 1 : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.row < deactivationReasonsList.count) ? 60.0 : descriptionCellHeight
     
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < deactivationReasonsList.count{
            let cell = tableView.dequeueReusableCell(withIdentifier: "DeactivateAccountListTableViewCell") as! DeactivateAccountListTableViewCell
            cell.contentLabel.text = deactivationReasonsList[indexPath.row].title
            return cell
        }else{
            let reasonCell = tableView.dequeueReusableCell(withIdentifier: "DeactivateAccountTypeReasonTableViewCell") as! DeactivateAccountTypeReasonTableViewCell
        
            return reasonCell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < deactivationReasonsList.count {
            let cell = tableView.cellForRow(at: indexPath) as! DeactivateAccountListTableViewCell
            
            if indexPath.row == selectedIndex {
                
                if deactivationReasonsList[indexPath.row].hasDescription == true {
                    descriptionCellHeight = (descriptionCellHeight == 0) ? 150 : 0
                    tableView.beginUpdates()
                    tableView.endUpdates()
                } else {
                    if cell.tickImageView.isHidden == false{
                        cell.tickImageView.isHidden = true
                        saveButton.isEnabled = false
                        saveButton.layer.backgroundColor = ColorConstants.kWhiteColorKey.cgColor
                    }else{
                        cell.tickImageView.isHidden = false
                        saveButton.isEnabled = true
                        saveButton.layer.backgroundColor = ColorConstants.kAppGreenColor.cgColor
                    }
                }
                
            } else {
                if selectedIndex > -1 {
                    let previousCell = tableView.cellForRow(at: IndexPath(item: selectedIndex, section: 0)) as! DeactivateAccountListTableViewCell
                    previousCell.tickImageView.isHidden = true
                    
                }
                
                if deactivationReasonsList[indexPath.row].hasDescription == false {
                    if descriptionCellHeight == 150 {
                        descriptionCellHeight = 0
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                    
                    cell.tickImageView.isHidden = !cell.tickImageView.isHidden
                    saveButton.isEnabled = cell.tickImageView.isHidden
                    saveButton.layer.backgroundColor = (cell.tickImageView.isHidden) ? ColorConstants.kWhiteColorKey.cgColor : ColorConstants.kAppGreenColor.cgColor
                } else {
                    saveButton.layer.backgroundColor = (descriptionCellHeight == 0) ? ColorConstants.kAppGreenColor.cgColor : ColorConstants.kWhiteColorKey.cgColor
                    descriptionCellHeight = (descriptionCellHeight == 0) ? 150 : 0
                    saveButton.isEnabled = (descriptionCellHeight == 0)
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
                selectedIndex = indexPath.row
                deactivationId = deactivationReasonsList[selectedIndex].deactivateId!
            }
        } else {
            let reasonCell = tableView.cellForRow(at: indexPath as IndexPath)  as? DeactivateAccountTypeReasonTableViewCell
            if let text = reasonCell?.reasonTextView.text {
                reasonForDeactivation = text
            }
            selectedIndex = indexPath.row - 1
            deactivationId = deactivationReasonsList[selectedIndex].deactivateId!
        }

       
    }

}




