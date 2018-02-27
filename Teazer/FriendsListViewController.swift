//
//  FriendsListViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 11/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage

class FriendsListViewController: UIViewController {

    typealias FriendsSelectedBlock = ([Friend]) -> Void
    var friendsSelectedBlock:FriendsSelectedBlock!
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var noFriendsView: UIView!
    
    var page = 1
    var hasNext:Bool? = false
    var isWebserviceCallGoingOn = false
    var originalDataSource = [Friend]()
    var dataSource = [Friend]()
    var selectedFriends = [Friend]()
    var friendsNameListStr = ""
    var friendsIdListStr = ""
    var loaderView:LoaderView?
    let imageCache = AutoPurgingImageCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        fetchFriendsList(pageNo: page)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
//        tabbarVC.tabBar.isHidden = true
//        tabbarVC.hideCameraButton(value: true)
        
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
    }
    
    func fetchFriendsList(pageNo:Int) {
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
            self.isWebserviceCallGoingOn = true
        }
        CameraControllerAPIHandler().fetchFriendsList(page: pageNo) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
                self?.isWebserviceCallGoingOn = false
            }
            
            if let error = responseData.errorObject {
                print(error.message ?? "")
                return
            }
            
            self?.hasNext = responseData.hasNext
            if let list = responseData.friendsList, list.count > 0 {
                if strongSelf.page == 1 {
                    strongSelf.dataSource = list
                    strongSelf.originalDataSource = list
                    strongSelf.tableView.reloadData()
                } else {
                    DispatchQueue.main.async {
                        var i = strongSelf.dataSource.count
                        for friend in list {
                            strongSelf.dataSource.append(friend)
                            strongSelf.originalDataSource.append(friend)
                            strongSelf.tableView.isScrollEnabled = false
                            strongSelf.tableView.insertRows(at: [IndexPath(item: i, section: 0)], with: .automatic)
                            i += 1
                        }
                        self?.tableView.isScrollEnabled = true
                    }
                }
            } else {
                if strongSelf.originalDataSource.count > 0 {
                    return
                }
                
                DispatchQueue.main.async {
                    strongSelf.noFriendsView.isHidden = false
                    strongSelf.view.makeToast("There are no friends. Follow people to make friends")
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: { [weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.friendsSelectedBlock(strongSelf.selectedFriends)
        })
    }
    
}

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagFriendTableViewCell") as! TagFriendTableViewCell
        let index = selectedFriends.index(where:{ (friendObj) -> Bool in
            return (friendObj.userId == dataSource[indexPath.row].userId)
        })
        
        if index != nil {
            cell.checkImageView.image = UIImage(named: "ic_select_tick_icon")
        } else {
            cell.checkImageView.image = nil
        }
        
        let friend =  dataSource[indexPath.row]
        cell.setupCell(friend: friend, imageKey: "UserProfileImage\(friend.userId!)", isSelected: (index == nil) ? false : true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let cell = tableView.cellForRow(at: indexPath) as? TagFriendTableViewCell else {
            return
        }
        
        let index = selectedFriends.index(where: { (friend) -> Bool in
            return (friend.userId == dataSource[indexPath.row].userId)
        })
        if index == nil {
            selectedFriends.append(dataSource[indexPath.row])
            cell.checkImageView.image = UIImage(named: "ic_select_tick_icon")
            cell.checkImageView.tintColor = ColorConstants.kAppGreenColor
        } else {
            selectedFriends.remove(at: index!)
            cell.checkImageView.image = nil
        }

        if selectedFriends.count > 0 {
            doneBtn.isEnabled = true
            doneBtn.setTitleColor(UIColor(rgba: "#333333"), for: .normal)
            doneBtn.titleLabel?.font = UIFont(name:Constants.kProximaNovaSemibold, size: 17.0)
            
        } else {
            doneBtn.isEnabled = false
            doneBtn.setTitleColor(UIColor(rgba: "#C6C6C6"), for: .normal)
        }
    }
    
}

extension FriendsListViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text!
        if string != "\n" {
            if string !=  "" {
                text = text + "\(string)"
            } else {
                text = text.replacingCharacters(in: Range(range, in: text)!, with: "")
            }
        }
        
        if text != "" {
            let filteredArr = originalDataSource.filter { (friend) -> Bool in
                return friend.userName!.contains(text)
            }
            dataSource = filteredArr
            tableView.reloadData()
        } else {
            dataSource = originalDataSource
            tableView.reloadData()
        }
        
        return true
    }
    
}

extension FriendsListViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if searchTextField.text!.count == 0 {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            
            if offsetY > contentHeight - scrollView.frame.size.height && !isWebserviceCallGoingOn && hasNext! {
                page += 1
                fetchFriendsList(pageNo: page)
            }
        }
    }
}
