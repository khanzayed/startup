//
//  LoginViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 03/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn
import Firebase
import SwiftKeychainWrapper
import AVFoundation

class BaseLoginViewController: UIViewController {

    @IBOutlet weak var movieView:UIView!
    @IBOutlet weak var loginBtn:UIButton!
    @IBOutlet weak var facebookLoginBtn: UIButton!
    @IBOutlet weak var googleLoginBtn:UIButton!

    var loaderView:LoaderView!
    var videoPlayerView:VideoPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginBtn.isEnabled = true
        videoPlayerView = VideoPlayerView(frame: movieView.frame)
        videoPlayerView?.setupVideoPlayer(forView: movieView, forResource: Constants.kWelcomeVideo, playerVolume: 0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        videoPlayerView?.removeVideoPlayer()
        videoPlayerView = nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        facebookLoginBtn.layer.cornerRadius = facebookLoginBtn.bounds.height / 2
        googleLoginBtn.layer.cornerRadius = googleLoginBtn.bounds.height / 2
        
    }
    
    func launchHomePage(isNewUser:Bool) {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
            let navCntrl = tabbarCntrlr.selectedViewController as! UINavigationController
            let homeVC = navCntrl.viewControllers[0] as! NewHomeViewController
            homeVC.isNewUser = isNewUser
            self?.navigationController?.pushViewController(tabbarCntrlr, animated: true)
        }
    }
    
    func soSocialLogin(user:User) {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        
        UserAPIHandler().socialLogin(user) { [weak self] (responseData) in
            if let error = responseData.errorObject {
                DispatchQueue.main.async { [weak self] in
                    self?.loaderView.removeLoaderView()
                }
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.responseCode == 201, let urlStr = user.socialAccountImageURL, let authToken = responseData.authToken {
           // if let urlStr = user.socialAccountImageURL {
                user.setAuthToken(authToken: authToken)
                CommonAPIHandler().getDataFromUrl(imageURL: urlStr, completion: { (image) in
                    DispatchQueue.main.async {
                        self?.loaderView.removeLoaderView()
                    }
                    
                    if image != nil {
                        let imageData = UIImageJPEGRepresentation(image!, 1)!
                        UserProfileAPIHandler().uploadProfileMedia(imageData: imageData, completionHandler: { [weak self] (imageResponseData) in
                            self?.launchHomePage(isNewUser: true)
                        })
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self?.loaderView.removeLoaderView()
                }
                
                if let authToken = responseData.authToken {
                    user.setAuthToken(authToken: authToken)
                    self?.launchHomePage(isNewUser: false)
                } else {
                    self?.view.makeToast(Constants.kGenericErrorMessage)
                }
            }
        }
    }
    
    //MARK: - Button delegates
    @IBAction func loginButtonTapped(sender:UIButton) {
        loginBtn.isEnabled = false
        User().removeAuthToken()
        
    }
    
    @IBAction func createAccountButtonTapped(sender:UIButton) {
        User().removeAuthToken()
    }
    
    @IBAction func facebookLoginButtonTapped(_ sender: UIButton) {
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email",], from: self) { (loginResult, error) in
            guard let result = loginResult else {
                if error != nil {
                    print(error!.localizedDescription)
                }
                return
            }
            if result.isCancelled {
                ErrorView().showBasicAlertForError(message: "Permission declined", forVC: self)
            } else {
//                let credential = FIRFacebookAuthProvider.credential(withAccessToken: result.token.tokenString)
//                FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                        return
//                    }
//                    print(user?.displayName ?? "ERROR")
//                    print(user?.email)
//
//                })
                
                FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, first_name, gender, last_name, email, picture.width(\(500)).height(\(500))"]).start(completionHandler: { [weak self] (connection, result, error) in
                    if error != nil {
                        // Show error
                        return
                    }
                    if let fbDetails = result as? [String:Any] {
                        print(fbDetails)
                        var user = User()
                        user.socialId = fbDetails["id"] as? String
                        user.socialLoginType = 1
                        user.userName = fbDetails["name"] as? String
                        user.firstName = fbDetails["first_name"] as? String
                        user.lastName = fbDetails["last_name"] as? String
                        user.email = fbDetails["email"] as? String
                        
                        if let picture = fbDetails["picture"] as? [String:Any] {
                            if let data = picture["data"] as? [String:Any] {
                                user.socialAccountImageURL = data["url"] as? String
                            }
                        }
                        
                        self?.soSocialLogin(user: user)
                    }
                })
            }
        }
    }
    
    @IBAction func googleLoginButtonTapped(sender:UIButton) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }

}

extension BaseLoginViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            self.view.makeToast(error.localizedDescription)
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential, completion: { [weak self] (firUser, error) in
            if let error = error {
               self?.view.makeToast(error.localizedDescription)
                return
            }
            
            var localUser = User()
            localUser.socialId = user.userID
            localUser.socialLoginType = 2
            localUser.userName = user.profile.name
            localUser.firstName = user.profile.givenName
            localUser.lastName = user.profile.familyName
            localUser.email = user.profile.email
            if let url = user.profile.imageURL(withDimension: 500) {
                localUser.socialAccountImageURL = url.absoluteString
            }
            self?.soSocialLogin(user: localUser)
        })
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }

}

