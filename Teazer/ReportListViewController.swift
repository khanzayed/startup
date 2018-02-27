//
//  ReportListViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 16/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ReportListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var reportTypesList = [ReportType]()
    var loaderView:LoaderView?
    var isFromReportPost = false
    var reportId:Int?
    var userId:Int?
    var previousIndex:Int?
    var otherReason:String?
    var post:Post!
    var isFromProfile = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitButton.isEnabled = false
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension

        if isFromReportPost {
            getReportTypesForPost()
        } else {
           getReportTypesForProfile()
        }
        // Do any additional setup after loading the view.
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

    
    @IBAction func BackButtonTapped(sender:UIButton) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        
        (isFromReportPost) ? reportThePost() : reportTheProfile()
    }
}

extension ReportListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportTypesList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell") as! ReportTableViewCell
        cell.titlelbl.text = reportTypesList[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! ReportTableViewCell
        
        if reportTypesList[indexPath.row].subReports != nil {
            if previousIndex != nil {
                let cell = tableView.cellForRow(at: IndexPath(item: previousIndex!, section: 0)) as! ReportTableViewCell
                cell.tickImage.isHidden = true
            }
            submitButton.isEnabled = true
            submitButton.layer.backgroundColor = ColorConstants.kWhiteColorKey.cgColor
            let storyboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
            let reportVC = storyboard.instantiateViewController(withIdentifier: "ReportListDetailViewController") as! ReportListDetailViewController
            reportVC.subReportTypesList = reportTypesList[indexPath.row].subReports!
            reportVC.isFromReportPost = isFromReportPost
            reportVC.userId = userId
            reportVC.post = post
            reportVC.isFromProfile = isFromProfile
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(reportVC, animated: true)
            }
        } else {
            if previousIndex != nil {
                let cell = tableView.cellForRow(at: IndexPath(item: previousIndex!, section: 0)) as! ReportTableViewCell
                cell.cellDeselected()
            }
            cell.cellSelected()
            submitButton.isEnabled = true
            submitButton.layer.backgroundColor = ColorConstants.kAppGreenColor.cgColor
            reportId = reportTypesList[indexPath.row].reportTypeId
            previousIndex = indexPath.row
        }
    }
}

extension ReportListViewController {
    
    func getReportTypesForPost() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        CommonAPIHandler().getReportTypesListForPost { [weak self] (reponseData) in
            if let error = reponseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if let list = reponseData.repostTypesList {
                self?.reportTypesList = list
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func getReportTypesForProfile() {
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast("You are not connected to the internet.Please try again later!")
            return
        }

        CommonAPIHandler().getReportTypesListForProfile { [weak self] (reponseData) in
            if let error = reponseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
    
            if let list = reponseData.repostTypesList {
                self?.reportTypesList = list
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            
            }
        }
    }
    
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
            "post_id"               :       postId,
            "report_type_id"        :       reportId!
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
                self?.view.makeToast("Post has been reported successfully")
                if let viewControllers = self?.navigationController?.viewControllers {
                    if self?.isFromProfile == false {
                        let homeDetailVC = viewControllers[viewControllers.count - 2] as! HomePageDetailViewController
                        homeDetailVC.removeVideoPlayer()
                    } else {
                        self?.navigationController?.popToViewController(viewControllers[viewControllers.count - 2], animated: true)
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
            "report_type_id"    :       reportId!,
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
                self?.view.makeToast("Profile has been reported successfully")
                if let viewControllers = self?.navigationController?.viewControllers {
                    DispatchQueue.main.async {
                        self?.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                    }
                }
            } else {
                self?.view.makeToast(responseData.message)
            }
        })
    }

}
