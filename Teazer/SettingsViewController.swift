//
//  SettingViewController.swift
//  Teazer
//
//  Created by Ankita Satpathy on 21/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import Social

class SettingsViewController: UIViewController {
    
    typealias UpdateUserProfile = (UserProfileDataModal) -> Void
    var updateUserProfile:UpdateUserProfile!
    
    @IBOutlet weak var switchView: UISwitch!
    @IBOutlet weak var settingsTopLabel: UILabel!
    @IBOutlet weak var switchAutoPlayVideo: UISwitch!
    @IBOutlet weak var switchAutoPlayAudio: UISwitch!
    @IBOutlet weak var switchShowReaction: UISwitch!
    
    var userProfile: UserProfileDataModal!
    var categories = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsTopLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = true
        tabbarVC.hideCameraButton(value: true)
        
        if AppPreferences.getIsPrivateAccount(){
            switchView.isOn = true
        } else {
            switchView.isOn = false
        }
        if AppPreferences.getIsVideoAutoPlay(){
            switchAutoPlayVideo.isOn = false
        } else {
            switchAutoPlayVideo.isOn = true
        }
        
        if AppPreferences.getIsAudioAutoPlay(){
            switchAutoPlayAudio.isOn = false
        } else {
            switchAutoPlayAudio.isOn = true
        }
        
    }
    
    @IBAction func feedbackBtnTapped(_ sender: Any) {
        let feedbackURL = URL(string: "http://cnapplications.com/contact.php")!
        UIApplication.shared.open(feedbackURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        updateUserProfile?(userProfile!)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func invitefriendsBtnTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
        let inviteVC = storyboard.instantiateViewController(withIdentifier: "InviteFriendsViewController") as? InviteFriendsViewController
        inviteVC?.userProfile = self.userProfile
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(inviteVC!, animated: true)
        }
       
    }
    
    @IBAction func changeCategoriesBtnTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Main.rawValue, bundle: nil)
        let changeCategoryVCObj = storyboard.instantiateViewController(withIdentifier: "ChangeCategoryViewController") as? ChangeCategoryViewController
        changeCategoryVCObj?.selectedCategories = userProfile!.user!.categories!
        changeCategoryVCObj?.categoriesSelectedBlock = { [weak self] (list) in
            self?.userProfile?.user?.categories = list
            self?.view.makeToast("Categories updated successfully")
        }
        navigationController?.pushViewController(changeCategoryVCObj!, animated: true)
    }
    
    @IBAction func changePasswordBtnTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: StoryboardOptions.Settings.rawValue, bundle: nil)
        let changePasswordVCObj = storyboard.instantiateViewController(withIdentifier: "UpdatePasswordViewController") as? UpdatePasswordViewController
        changePasswordVCObj?.userProfile = userProfile
        navigationController?.pushViewController(changePasswordVCObj!, animated: true)
    }
    
    @IBAction func linkAccountBtnTapped(_ sender: Any) {
        //        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //        let linkAccountVCObj = storyboard.instantiateViewController(withIdentifier: "linkAccountViewController") as? LinkAccountViewController
        //        navigationController?.pushViewController(linkAccountVCObj!, animated: true)
    }
    
    @IBAction func blockListBtnTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name:StoryboardOptions.Profile.rawValue, bundle: nil)
        let blockVC = storyboard.instantiateViewController(withIdentifier: "BlockListViewController") as? BlockListViewController
        navigationController?.pushViewController(blockVC!, animated: true)
    }
    
    
    
    @IBAction func switchTapped(_ sender: Any) {
        if (sender as AnyObject).isOn {
            AppPreferences.setIsPrivateAccount(isPrivateAccount: true)
            userProfile.user?.isPrivate = true
            changeAccountVisibility(type:1)
        } else {
            AppPreferences.setIsPrivateAccount(isPrivateAccount: false)
            userProfile.user?.isPrivate = false
            changeAccountVisibility(type:2)
        }
    }
    @IBAction func autoPlaySwitchTapped(_ sender: UISwitch) {
        if sender.isOn {
            AppPreferences.setIsVideoAutoPlay(autoplay: false)
        } else {
            AppPreferences.setIsVideoAutoPlay(autoplay: true)
        }
        
    }
    @IBAction func autoPlayAudioTapped(_ sender: UISwitch) {
        if sender.isOn {
            AppPreferences.setIsAudioAutoPlay(autoplay: false)
        } else {
            AppPreferences.setIsAudioAutoPlay(autoplay: true)
        }
    }
    
    @IBAction func showReactionsSwitchTapped(_ sender: UISwitch) {
        
    }
    
    
    @IBAction func instagramBtnTapped(_ sender: Any) {
        let instaAppURL = URL(string: "instagram://user?username=/madhavendraraj")!
        let instaWebURL = URL(string: "https://instagram.com/")!
        
        if (UIApplication.shared.canOpenURL(instaAppURL as URL)) {
            UIApplication.shared.open(instaAppURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(instaWebURL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let fbAppURL = URL(string: "fb://profile/ankita")!
        let fbWebURL = URL(string: "http://www.facebook.com/")!
        
        if (UIApplication.shared.canOpenURL(fbAppURL as URL)) {
            UIApplication.shared.open(fbAppURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(fbWebURL, options: [:], completionHandler: nil)
        }
        
    }
    
    @IBAction func helpBtnTapped(_ sender: Any) {
    }
    
    @IBAction func privacyPolicyBtnTapped(_ sender: Any) {
    }

    @IBAction func termsBtnTapped(_ sender: Any) {
    }
    
    @IBAction func deactivateBtnTapped(_ sender: Any) {
        
        let storyboard: UIStoryboard = UIStoryboard(name:StoryboardOptions.Main.rawValue, bundle: nil)
        let blockVC = storyboard.instantiateViewController(withIdentifier: "DeactivateAccountViewController") as? DeactivateAccountViewController
        navigationController?.pushViewController(blockVC!, animated: true)
        
    }
    
    @IBAction func licenseBtnTapped(_ sender: Any) {
    }
    
    @IBAction func logoutBtnTapped(_ sender: Any) {
        LogOut().doLogOut()
    }
    
}
extension SettingsViewController {
    
    func changeAccountVisibility(type: Int) {
        UserProfileAPIHandler().setProfileVisibility(accountType: type) { [weak self] (responseData) in
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            guard let strongSelf = self else {
                return
            }
            
            if let status = responseData.status {
                if status{
                    DispatchQueue.main.async {
                        strongSelf.userProfile?.user?.accountType = type
                    }
                }
            }
            
        }
    }
}

extension SettingsViewController: UIScrollViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollY = scrollView.contentOffset.y
        if scrollY > 32{
            let alpha: CGFloat = 0.0 + ((scrollY - 32) / 32)
            settingsTopLabel.alpha = alpha
            settingsTopLabel.isHidden = false
        }else{
            settingsTopLabel.isHidden = true
        }
    }
}
