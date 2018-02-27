//
//  LoginViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation

class LoginViewController: UIViewController {

    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var eyeIconButton: UIButton!
    
    var iconCLicked:Bool = false
    var isUserName:Bool = false
    var isPassword:Bool = false
    var loaderView:LoaderView!
    var videoPlayerView:VideoPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setDoneOnKeyboard()
        iconCLicked = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
        userNameView.layer.cornerRadius = userNameView.bounds.height / 2
        passwordView.layer.cornerRadius = passwordView.bounds.height / 2
        loginBtn.layer.cornerRadius = loginBtn.bounds.height / 2
        
        loginBtn.isEnabled = false
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        userNameTF.inputAccessoryView = keyboardToolbar
        passwordTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func iconPressed(_ sender: Any) {
        if iconCLicked == true {
            passwordTF.isSecureTextEntry = false
            eyeIconButton.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
            iconCLicked = false
        }else{
            passwordTF.isSecureTextEntry = true
            eyeIconButton.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
            iconCLicked = true
        }
    }
    
    
    func enableLoginButton() {
        if isUserName && isPassword {
            loginBtn.backgroundColor = UIColor(rgba: "#26C6DA")
            loginBtn.isEnabled = true
        } else {
            loginBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
            loginBtn.isEnabled = false
        }
    }
    
    func launchHomePage() {
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
            self?.navigationController?.pushViewController(tabbarCntrlr, animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        var user = User()
        user.userName = userNameTF.text
        user.setPassword(password: passwordTF.text!)
        UserAPIHandler().signIn(user) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
            }

            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }

            if let authToken = responseData.authToken {
                user.setAuthToken(authToken: authToken)
                self?.launchHomePage()
            } else {
                if responseData.message != nil {
                    self?.view.makeToast(responseData.message)
                } else {
                    self?.view.makeToast("Oops something went wrong")
                }
            }
        }
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: UIButton) {
        
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 101 {
            passwordTF.isSecureTextEntry = true
    }
}
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text!.count >= 0 && string != "") || (textField.text!.count > 1 && string == "") {
            (textField.tag == 101) ? (isUserName = true) : (isPassword = true)
        } else {
            (textField.tag == 101) ? (isUserName = false) : (isPassword = false)
        }
        enableLoginButton()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
