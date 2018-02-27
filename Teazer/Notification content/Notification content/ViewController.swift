//
//  ViewController.swift
//  Notification content
//
//  Created by Mraj singh on 11/11/17.
//  Copyright © 2017 Mraj singh. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {
    
    
    @IBOutlet weak var segmentView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var topNotificationLabel: UILabel!
    @IBOutlet weak var segmentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var notificationsTableView: UITableView!
    @IBOutlet weak var noContentView: UIView!
    
    
    private var refreshControl = UIRefreshControl()
    var swipeRightGesture: UISwipeGestureRecognizer?
    var swipeLeftGesture: UISwipeGestureRecognizer?
    var selectedTitle = 0
    var activityIndicatorView = UIActivityIndicatorView()
    var segmentIndex  = Int()
    var loaderView:LoaderView!
    var notifications = [Notification]()
    var notificationCellObj = NotificationsTableViewCell()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        setupTableView()
        setupSwipeGestures()
        fetchNotificationList()
        notificationsTableView.reloadData()
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView.addLoaderView(forView: self.view)
        }
        
    }
    // setting up the view of tableView
    func setupTableView(){
        notificationsTableView.rowHeight = UITableViewAutomaticDimension
        notificationsTableView.estimatedRowHeight = 70
        
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        refreshControl.tintColor = UIColor(rgba: "#333333")
        
        
        if #available(iOS 10.0, *) {
            notificationsTableView.refreshControl = refreshControl
            
        } else {
            notificationsTableView.addSubview(refreshControl)
            
        }
        
    }
    // setting up the view
    func setUpView(){
        topNotificationLabel.isHidden = true
        selectedTitle = segmentControl.selectedSegmentIndex
        //segmentControl.setTitleTextAttributes([NSFontAttributeName: "ProximaNovaA-Regular"],for: .normal)
        noContentView.isHidden = true
    }
    
    // setting swipe gesture
    func setupSwipeGestures() {
        swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight))
        swipeRightGesture?.direction = .right
        self.view.addGestureRecognizer(swipeRightGesture!)
        
        swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft))
        swipeLeftGesture?.direction = .left
        self.view.addGestureRecognizer(swipeLeftGesture!)
        
    }
    
    // reloading the tableView
    func reloadData(){
        DispatchQueue.main.async{
            
            self.fetchNotificationList()
            self.activityIndicatorView.stopAnimating()
            self.activityIndicatorView.isHidden = true
            self.notificationsTableView.reloadData()
            self.refreshControl.endRefreshing()
            
        }
    }
    
    func fetchNotificationList(){
        
        NotificationsAPIHandler().getNotificationsList(1){[weak self](responseData) in
            DispatchQueue.main.async{
                self?.loaderView.removeLoaderView()
            }
            if let error = responseData.errorObject {
                print(error.message)
                return
            }
            guard let strongSelf = self else {
                return
            }
            if let list  = responseData.notifications{
                strongSelf.notifications = list
                self?.notificationsTableView.reloadData()
            }
        }
        
    }
    
    func swipeRight() {
        if selectedTitle == 0 {
            return
        }
        self.selectedTitle = 0
        segmentControl.selectedSegmentIndex = 0
        segmentControl.sendActions(for: UIControlEvents.valueChanged)
        self.notificationsTableView.reloadData()
        
    }
    
    func swipeLeft() {
        if selectedTitle == 1 {
            return
        }
        self.selectedTitle = 1
        segmentControl.selectedSegmentIndex = 1
        segmentControl.sendActions(for: UIControlEvents.valueChanged)
        self.notificationsTableView.reloadData()
        
    }
    
    @IBAction func segmentControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0 :
            selectedTitle = 0
            notificationsTableView.reloadData()
        default:
            selectedTitle = 1
            notificationsTableView.reloadData()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        notificationsTableView.contentInset = UIEdgeInsetsMake(20, 0.0, 0.0, 0.0)
        notificationsTableView.scrollRectToVisible(CGRect(x:0,y: 20,width: 1,height: 1), animated: false)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension NotificationsViewController : UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(notifications.count)
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell  = notificationsTableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as! NotificationsTableViewCell
        cell.reactBtn.tag = indexPath.row
        cell.setUpCell()
        
        if selectedTitle == 0 {
            //noContentView.isHidden = false
            
            let notification  = notifications[indexPath.row]
            print(notification.title)
            
            if notification.title == "Posted a video" {
                
                //noContentView.isHidden = true
                cell.imageView?.isHidden = false
                cell.profileImageView.isHidden = false
                cell.messageLbl.isHidden = false
                cell.messageLbl.text = notification.message!
                cell.layoutIfNeeded()
                //print("index path segment 0: \(indexPath.row)")
                
            }
        } else {
            //noContentView.isHidden = false
            let notification  = notifications[indexPath.row]
            
            if notification.title == "Join Request" {
                cell.acceptButtonTappedBlock = { [weak self] in
                    UserAPIHandler().acceptJoinRequest(notification.notificationId!) { (responseData) in
                        if let error = responseData.errorObject {
                            print(error)
                            return
                        }
                        if let status  = responseData.status{
                            print(status)
                            if status {
                                cell.reactBtn.setTitle("Follow", for: .normal)
                            } else {
                                return
                            }
                        }
                    }
                }
                cell.profileImageView.isHidden = false
                cell.messageLbl.isHidden = false
                cell.messageLbl.text = notification.message
                cell.reactBtn.isHidden = false
                cell.reactBtn.setTitle("Accept", for: .normal)
                //noContentView.isHidden = true
                cell.layoutIfNeeded()
                
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}

extension NotificationsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollY = scrollView.contentOffset.y + 20
        
        self.segmentView.frame = CGRect(x: 0, y: 50 - scrollY, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
        
        if scrollY > 26{
            let alpha: CGFloat = 0.0 + ((scrollY - 25) / 20)
            topNotificationLabel.alpha = alpha
            topNotificationLabel.isHidden = false
            if scrollY > 38{
                self.segmentView.frame = CGRect(x: 0, y: 12, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
            }
        }else{
            topNotificationLabel.isHidden = true
            if scrollY < 0{
                self.segmentView.frame = CGRect(x: 0, y: 50, width: segmentView.frame.size.width, height: segmentView.frame.size.height)
            }
        }
    }
    
}

