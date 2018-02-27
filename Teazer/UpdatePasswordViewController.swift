//
//  UpdatePasswordViewController.swift
//  Teazer
//
//  Created by Ankita Satpathy on 23/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class UpdatePasswordViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var oldPasswordView: UIView!
    @IBOutlet weak var newPasswordView: UIView!
    @IBOutlet weak var confirmPasswordView: UIView!
    @IBOutlet weak var oldPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var oldPasswordErrorLabel: UILabel!
    @IBOutlet weak var newPasswordErrorLabel: UILabel!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var newPasswordViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var newEyeIconButton: UIButton!
    @IBOutlet weak var confirmEyeIconButton: UIButton!
    
    var loaderView: LoaderView!
    var userProfile: UserProfileDataModal?
    var isClicked = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDelegates()
        setDoneOnKeyboard()
        setUIForUpdatePassword()
    }
    
    func setUIForUpdatePassword() {
        if (userProfile?.canChangePassword)! {
            oldPasswordView.isHidden = false
            titleLabel.text = "Update Password"
        } else {
            oldPasswordView.isHidden = true
            newPasswordViewTopConstraint.constant = 93
            newPasswordView.layoutIfNeeded()
            titleLabel.text = "Set Password"
        }
    }
    
    func setDelegates() {
        oldPasswordTF.delegate = self
        newPasswordTF.delegate = self
        confirmPasswordTF.delegate = self
    }
    
    func setupUI() {
        newPasswordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        oldPasswordErrorLabel.isHidden = true
        newPasswordErrorLabel.isHidden = true
        confirmPasswordErrorLabel.isHidden = true
        saveButton.isEnabled = false
        saveButton.backgroundColor = UIColor(rgba: "#C6C6C6")
        oldPasswordTF.tag = 10
        newPasswordTF.tag = 11
        confirmPasswordTF.tag = 12
    }
    
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        oldPasswordTF.inputAccessoryView = keyboardToolbar
        newPasswordTF.inputAccessoryView = keyboardToolbar
        confirmPasswordTF.inputAccessoryView = keyboardToolbar
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        if (userProfile?.canChangePassword)!{
            updatePassword()
        }
        else {
            setPassword()
        }
    }
    
    func isFormComplete() -> Bool {
        if (userProfile?.canChangePassword)! {
            if oldPasswordTF.text?.count == 0 || newPasswordTF.text?.count == 0 || confirmPasswordTF.text?.count == 0 {
                return false
            } else if oldPasswordTF.text != userProfile?.user?.getPassword() {
                oldPasswordErrorLabel.text = "Password does not match with current password"
                oldPasswordErrorLabel.isHidden = false
                return false
            } else if newPasswordTF.text!.count < 7 && newPasswordTF.text!.count > 0 {
                newPasswordErrorLabel.text  = "**Password must be at least 8 charachters"
                newPasswordErrorLabel.isHidden = false
                return false
            }
            else if confirmPasswordTF.text != newPasswordTF.text {
                confirmPasswordErrorLabel.text = "Confirm password does not match with new password"
                confirmPasswordErrorLabel.isHidden = false
                return false
            }
        } else {
            if  newPasswordTF.text?.count == 0 || confirmPasswordTF.text?.count == 0 {
                return false
            } else if newPasswordTF.text!.count < 7 && newPasswordTF.text!.count > 0 {
                newPasswordErrorLabel.text  = "**Password must be at least 8 charachters"
                newPasswordErrorLabel.isHidden = false
                return false
            }
            else if confirmPasswordTF.text != newPasswordTF.text {
                confirmPasswordErrorLabel.text = "Confirm password does not match with new password"
                confirmPasswordErrorLabel.isHidden = false
                return false
            }
        }
        return true
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func eyeIconTapped(_ sender: Any) {
        if isClicked == true {
            newPasswordTF.isSecureTextEntry = false
            newEyeIconButton.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
            isClicked = false
        }else {
            newPasswordTF.isSecureTextEntry = true
            newEyeIconButton.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
            isClicked = true
        }
    }
    
    @IBAction func confirmButtonEyeIconTapped(_ sender: Any) {
        if isClicked == true {
            confirmPasswordTF.isSecureTextEntry = false
            confirmEyeIconButton.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
            isClicked = false
        }else {
            confirmPasswordTF.isSecureTextEntry = true
            confirmEyeIconButton.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
            isClicked = true
        }
    }
}



extension UpdatePasswordViewController {
    
    func updatePassword() {
        let params:[String:Any] = [
            "old_password"      :      oldPasswordTF.text!,
            "new_password"      :      confirmPasswordTF.text!
        ]
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        
        UserProfileAPIHandler().updatePassword(params) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true { // Success
                self?.userProfile?.user?.setPassword(password: (self?.newPasswordTF.text!)!)
                self?.view.makeToast(responseData.message)
                self?.navigationController?.popViewController(animated: true)
            } else { // Failure
                self?.view.makeToast(responseData.message)
            }
        }
        
    }
    
    func setPassword() {
        let params:[String:Any] = [
            "new_password"      :      confirmPasswordTF.text!
        ]
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        
        UserProfileAPIHandler().setPassword(params) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true { // Success
                self?.userProfile?.user?.setPassword(password: (self?.newPasswordTF.text!)!)
                self?.view.makeToast(responseData.message)
                self?.navigationController?.popViewController(animated: true)
            } else { // Failure
                self?.view.makeToast(responseData.message)
            }
        }
        
    }
}

extension UpdatePasswordViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 10 {
            DispatchQueue.main.async { [weak self] in
                self?.oldPasswordErrorLabel.isHidden = true
            }
        } else if textField.tag == 11 {
            DispatchQueue.main.async { [weak self] in
                self?.newPasswordErrorLabel.isHidden = true
            }
        }
        else if textField.tag == 12 {
            DispatchQueue.main.async { [weak self] in
                self?.confirmPasswordErrorLabel.isHidden = true
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let _ = textField.text else {
            print("Empty textfield")
            return
        }
        
        if textField.tag == 10 {
            DispatchQueue.main.async { [weak self] in
                if (self?.isFormComplete())! {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#26C6DA")
                    self?.saveButton.isEnabled = true
                } else {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#C6C6C6")
                    self?.saveButton.isEnabled = false
                }
            }
        } else if textField.tag == 11 {
            DispatchQueue.main.async { [weak self] in
                if (self?.isFormComplete())! {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#26C6DA")
                    self?.saveButton.isEnabled = true
                } else {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#C6C6C6")
                    self?.saveButton.isEnabled = false
                }
            }
        } else if textField.tag == 12 {
            DispatchQueue.main.async { [weak self] in
                if (self?.isFormComplete())! {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#26C6DA")
                    self?.saveButton.isEnabled = true
                } else {
                    self?.saveButton.backgroundColor = UIColor(rgba: "#C6C6C6")
                    self?.saveButton.isEnabled = false
                }
            }
        }
    }
}

