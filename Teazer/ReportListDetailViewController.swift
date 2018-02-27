//
//  ReportListDetailViewController.swift
//  Teazer
//
//  Created by Mraj singh on 29/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ReportListDetailViewController: UIViewController {
    
    typealias SubReportTypeSelectedBlock = (Int) -> Void
    var subReportTypeSelectedBlock:SubReportTypeSelectedBlock!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var subReportTypesList = [SubReports]()
    var subReportId:Int?
    var userId:Int?
    var isFromReportPost = false
    var loaderView:LoaderView?
    var previousIndex:Int?
    var otherReason:String?
    var selectedIndex:Int?
    var isFromProfile = false
    var post:Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonTapped(_ sender: Any) {
      navigationController?.popViewController(animated: true)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        if let cell = tableView.cellForRow(at: IndexPath(item:subReportTypesList.count, section: 0)) as? reportDetailOtherReasonTableViewCell {
            otherReason = cell.otherReasonTextView.text
        }
        
        (isFromReportPost) ? reportThePost() : reportTheProfile()
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
                self.view.frame.origin.y = -keyboardSize.height/2
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
}

extension ReportListDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subReportTypesList.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return (indexPath.row < subReportTypesList.count) ? 60.0 : 150.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.row < subReportTypesList.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "reportDetailTableViewCell") as! reportDetailTableViewCell
            if (subReportTypesList[indexPath.row].title?.contains("####"))! {
                let title = subReportTypesList[indexPath.row].title
                cell.titleLabel.text = title?.replacingOccurrences(of: "####", with: (post.postOwner?.firstName)!)
            } else {
                cell.titleLabel.text = subReportTypesList[indexPath.row].title
            }
            
            return cell
        } else {
           let otherReasonCell = tableView.dequeueReusableCell(withIdentifier: "reportDetailOtherReasonTableViewCell") as! reportDetailOtherReasonTableViewCell
            
            return otherReasonCell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! reportDetailTableViewCell
        
        if previousIndex != nil {
            let cell = tableView.cellForRow(at: IndexPath(item: previousIndex!, section: 0)) as! reportDetailTableViewCell
            cell.cellDeselected()
        }
        cell.cellSelected()
        submitButton.isEnabled = true
        submitButton.layer.backgroundColor = ColorConstants.kAppGreenColor.cgColor
        previousIndex = indexPath.row
        
        submitButton.layer.backgroundColor  = ColorConstants.kAppGreenColor.cgColor
        subReportId = subReportTypesList[indexPath.row].reportTypeId
        selectedIndex = indexPath.row
    }
    
}

extension ReportListDetailViewController {
    
    func reportThePost() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let postId = post.postId else {
            return
        }

        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        let params:[String:Any] = [
            "post_id"           :       postId,
            "report_type_id"    :       subReportId!,
            "other_reason"      :       otherReason!
        ]
        
        HomeControllerAPIHandler().reportPost(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return 
            }
            
            if responseData.status == true {
                DispatchQueue.main.async {
                    if let viewControllers = self?.navigationController?.viewControllers {
                        if self?.isFromProfile == false {
                            let homeDetailVC = viewControllers[viewControllers.count - 3] as! HomePageDetailViewController
                            homeDetailVC.removeVideoPlayer()
                            self?.navigationController?.popToViewController(homeDetailVC, animated: true)
                        } else {
                            self?.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                        }
                    }
                }
            } else {
                self?.view.makeToast(responseData.message)
            }
        })
    }
    
    func reportTheProfile() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        let params:[String:Any] = [
            "user_id"           :      userId!,
            "report_type_id"    :       subReportId!,
            "other_reason"      :       otherReason!
        ]
        
        HomeControllerAPIHandler().reportProfile(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true {
                if let viewControllers = self?.navigationController?.viewControllers {
                    DispatchQueue.main.async {
                        self?.navigationController?.popToViewController(viewControllers[viewControllers.count - 4], animated: true)
                    }
                }
            } else {
                self?.view.makeToast(responseData.message)
            }
        })
    }

}
