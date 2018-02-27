//
//  ResetPasswordViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 08/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var movieView:UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var resetPasswordBtn: UIButton!
    @IBOutlet weak var resetPasswordErrorLbl: UILabel!
    @IBOutlet weak var passwordEyeButton: UIButton!
    @IBOutlet weak var confirmEyeButtonTapped: UIButton!
    
    var isClicked = Bool()
    var loaderView:LoaderView!
    var user:User!
    var videoPlayerView:VideoPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setDoneOnKeyboard()
        isClicked = true
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
        resetPasswordErrorLbl.text = "**Password mismatch"
        
        passwordView.layer.cornerRadius = passwordView.bounds.height / 2
        confirmPasswordView.layer.cornerRadius = confirmPasswordView.bounds.height / 2
        resetPasswordBtn.layer.cornerRadius = resetPasswordBtn.bounds.height / 2
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        confirmPasswordTF.inputAccessoryView = keyboardToolbar
        passwordTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @IBAction func eyeIconTapped(_ sender: Any) {
        if isClicked == true {
            passwordTF.isSecureTextEntry = false
            isClicked = false
            passwordEyeButton.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
        } else {
            passwordTF.isSecureTextEntry = true
            isClicked = true
             passwordEyeButton.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
        }
    }
   
    @IBAction func confirmButtonEyeIconTapped(_ sender: Any) {
        if isClicked == true {
            confirmPasswordTF.isSecureTextEntry = false
            isClicked = false
            confirmEyeButtonTapped.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
        }else{
            confirmPasswordTF.isSecureTextEntry = true
            isClicked = true
            confirmEyeButtonTapped.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
        }
    }
    
    func launchHomePage() {
        DispatchQueue.main.async { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
//            tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
//            self?.navigationController?.pushViewController(tabbarCntrlr, animated: true)
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func resetPasswordButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return
        }
        
        let params:[String:Any] = [
            "new_password": confirmPasswordTF.text ?? "",
            "email": user.email ?? "",
            "phone_number": user.phoneNumber ?? "",
            "country_code": user.countryDialCode ?? "",
            "otp": user.otp ?? ""
        ]
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        
        UserAPIHandler().resetPassword(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast( error.message)
                return
            }
            
            guard let status = responseData.status else {
                DispatchQueue.main.async {
                    ErrorView().showBasicAlertForError(title: "Reset Password", message: Constants.kGenericErrorMessage, forVC: self)
                }
                return
            }
            if status {
                ErrorView().showAcknowledgementAlertWithCompletionBlock(title: "Reset Password", message: "Password Reset Successfully", forVC: self, completionBlock: {_ in self?.launchHomePage()})                 
                    
            
                
            } else {
                DispatchQueue.main.async {
                    ErrorView().showBasicAlertForError(title: "Reset Password", message: responseData.message!, forVC: self)
                }
            }
        })
    }
    
}

extension ResetPasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 101 {
            confirmPasswordTF.isSecureTextEntry = true
        }else{
            passwordTF.isSecureTextEntry = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return true
        }
        
        if let text = textField.text {
            var userName = text
            if string !=  "" {
                userName = text + "\(string)"
            } else {
                userName = userName.replacingCharacters(in: Range(range, in: userName)!, with: "")
            }
            
            if textField.tag == 101 && confirmPasswordTF.text!.count > 7 {
                if userName == confirmPasswordTF.text! {
                    resetPasswordErrorLbl.isHidden = true
                    resetPasswordBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                    resetPasswordBtn.isEnabled = true
                } else {
                    resetPasswordErrorLbl.isHidden = !(confirmPasswordTF.text!.count > 0)
                    resetPasswordBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                    resetPasswordBtn.isEnabled = false
                }
            } else if textField.tag == 102 && passwordTF.text!.count > 7 {
                if userName == passwordTF.text! {
                    resetPasswordErrorLbl.isHidden = true
                    resetPasswordBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                    resetPasswordBtn.isEnabled = true
                } else {
                    resetPasswordErrorLbl.isHidden = !(passwordTF.text!.count > 0)
                    resetPasswordBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                    resetPasswordBtn.isEnabled = false
                }
            }
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
