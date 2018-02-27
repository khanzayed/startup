//
//  OTPViewControllerViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVKit

class OTPViewControllerViewController: UIViewController {

    typealias OTPVerifiedBlock = () -> Void
    var otpVerifiedBlock:OTPVerifiedBlock?
    
    @IBOutlet weak var firstDigitTF: OTPTextField!
    @IBOutlet weak var secondDigitTF: OTPTextField!
    @IBOutlet weak var thirdDigitTF: OTPTextField!
    @IBOutlet weak var fourthDigitTF: OTPTextField!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var verifiedView: UIView!
    @IBOutlet weak var resendOTPBtn: UIButton!
    @IBOutlet weak var stringLbl: UILabel!
    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var durationLbl: UILabel!
    
    var mobileNumberOrEmail = String()
    var user:User!
    var loaderView:LoaderView?
    var isLoginThroughOTP = false
    var isSignup = false
    var isPresented = false
    var profileImage:UIImage?
    var isResetPassword = false
    var videoPlayerView:VideoPlayerView?
    var count = 60
    var timer = Timer()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setDoneOnKeyboard()
        resendOTPBtn.isEnabled = false
        if mobileNumberOrEmail.contains("@"){
        stringLbl?.text = "An OTP has been sent to your registered emailId \(mobileNumberOrEmail)"
        } else {
            stringLbl?.text = "An OTP has been sent to your registered mobile number \(mobileNumberOrEmail)"
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firstDigitTF.becomeFirstResponder()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !isPresented {
            videoPlayerView = VideoPlayerView(frame: movieView.frame)
            videoPlayerView?.setupVideoPlayer(forView: movieView, forResource: Constants.kWelcomeVideo, playerVolume: 0)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func update() {
        
        if count > 0 {
            let seconds = String(count)
            if count > 9 && count != 60 {
                durationLbl.text = "Resend OTP in: \("00" + ":" + seconds)"
            } else if count < 10 {
               durationLbl.text = "Resend OTP in: \("00" + ":" + "0"+seconds)"
            } else {
               durationLbl.text = "Resend OTP in: 01:00"
            }
            resendOTPBtn.alpha = 0.5
            count -= 1
        } else {
            resendOTPBtn.alpha = 1.0
            durationLbl.text = "Retry Now"
            resendOTPBtn.isEnabled = true
            timer.invalidate()
        }
        
    }
    
    func setupView() {
        messageLbl.isHidden = true
        firstDigitTF.becomeFirstResponder()
        firstDigitTF.backButtonTappedBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.firstDigitTF.text = ""
            }
        }
        
        secondDigitTF.backButtonTappedBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.secondDigitTF.text = ""
                self?.firstDigitTF.becomeFirstResponder()
            }
        }
        
        thirdDigitTF.backButtonTappedBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.thirdDigitTF.text = ""
                self?.secondDigitTF.becomeFirstResponder()
            }
        }
        
        fourthDigitTF.backButtonTappedBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.fourthDigitTF.text = ""
                self?.thirdDigitTF.becomeFirstResponder()
            }
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        firstDigitTF.inputAccessoryView = keyboardToolbar
        secondDigitTF.inputAccessoryView = keyboardToolbar
        thirdDigitTF.inputAccessoryView = keyboardToolbar
        fourthDigitTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func isOTPComplete() -> Bool {
        if firstDigitTF.text?.count == 1 && secondDigitTF.text?.count == 1 && thirdDigitTF.text?.count == 1 && fourthDigitTF.text?.count == 1 {
            return true
        }
        return false
    }

    func verifyOTPForSignup() {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
        }
        user.otp = firstDigitTF.text! + secondDigitTF.text! + thirdDigitTF.text! + fourthDigitTF.text!
        UserAPIHandler().registrationVerify(user) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            if let authToken = responseData.authToken {
                self?.user.setAuthToken(authToken: authToken)
                self?.uploadProfilePicture()
                self?.launchHomePage(isNewUser: true)
            } else {
                DispatchQueue.main.async {
                    self?.durationLbl.isHidden = true
                    self?.messageLbl.text = "Incorrect OTP. Try again."
                    self?.messageLbl.isHidden = false
                }
            }
        }
    }
    
    func verifyOTP() {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
        }
        user.otp = firstDigitTF.text! + secondDigitTF.text! + thirdDigitTF.text! + fourthDigitTF.text!
        UserAPIHandler().verifyOTPForEditProfile(user) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            if responseData.status == true {
                DispatchQueue.main.async {
                    self?.otpVerifiedBlock?()
                    self?.dismiss(animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self?.messageLbl.text = "Incorrect OTP. Try again."
                    self?.messageLbl.isHidden = false
                }
            }
        }
    }
    
    func uploadProfilePicture() {
        if profileImage == nil {
            return
        }
        if let imageData = UIImageJPEGRepresentation(profileImage!, 1) {
            UserProfileAPIHandler().uploadProfileMedia(imageData: imageData, completionHandler: { (responseData) in
                
            })
        }
    }
    
    func verifyOTPForLogin() {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
        }
        user.otp = firstDigitTF.text! + secondDigitTF.text! + thirdDigitTF.text! + fourthDigitTF.text!
        var params:[String:Any] = [
            "country_code" : 91,
            "phone_number" : user.phoneNumber ?? "",
            "otp" : user.otp ?? "",
            "device_id" : user.deviceId ?? "",
            "device_type" : user.deviceType
        ]
        
        if user.fcmToken != nil {
            params["fcm_token"] = user.fcmToken
        }
        
        UserAPIHandler().loginVerifyThroughMobileOTP(params) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showBasicAlertForError(message: error.message!, forVC: self)
                return
            }
            if let authToken = responseData.authToken {
                self?.user.setAuthToken(authToken: authToken)
                self?.launchHomePage(isNewUser: false)
            } else {
                DispatchQueue.main.async {
                    self?.messageLbl.text = "Incorrect OTP. Try again."
                    self?.messageLbl.isHidden = false
                }
            }
        }
    }

    func resendOTPThroughSignUpMobile(user: User) {
        
        UserAPIHandler().registrationVerify(user) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            guard let status = responseData.status else {
                self?.view.makeToast(Constants.kGenericErrorMessage)
                return
            }
            
            if status {
                
            } else {
                
            }
        }
        
    }
    
    func resendOTPThroughResetPasswordMobile(params:[String:Any]) {
        
        UserAPIHandler().getOTPToResetPasswordByMobile(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            guard let status = responseData.status else {
                self?.view.makeToast(Constants.kGenericErrorMessage)
                return
            }
            
            if status {
                
            } else {
                
            }
        })
        
    }
    
    func resendOTPThroughLoginThroughOTPMobile(params:[String:Any]) {
        
        UserAPIHandler().getOTPToLoginThroughMobile(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            guard let status = responseData.status else {
                self?.view.makeToast(Constants.kGenericErrorMessage)
                return
            }
            
            if status {
                
            } else {
                
            }
        })
    }
    
    func verifyOTPForResetPassword() {
        user.otp = firstDigitTF.text! + secondDigitTF.text! + thirdDigitTF.text! + fourthDigitTF.text!
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
        }
        
        UserAPIHandler().authenticateForgotPasswordOTP(user.otp!) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            guard let status = responseData.status else {
                DispatchQueue.main.async {
                    self?.view.makeToast(Constants.kGenericErrorMessage)
                }
                return
            }
            if status {
                self?.launchResetPasswordPage()
            } else {
                DispatchQueue.main.async {
                    self?.messageLbl.text = "Incorrect OTP. Try again."
                    self?.messageLbl.isHidden = false
                }
            }
        }
    }
    
    func verifyOTPForupdateMobile() {
        user.otp = firstDigitTF.text! + secondDigitTF.text! + thirdDigitTF.text! + fourthDigitTF.text!
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
        }
        
        UserAPIHandler().authenticateForgotPasswordOTP(user.otp!) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                self?.view.makeToast(error.message)
                return
            }
            
            guard let status = responseData.status else {
                DispatchQueue.main.async {
                    self?.view.makeToast(Constants.kGenericErrorMessage)
                }
                return
            }
            if status {
                self?.launchResetPasswordPage()
            } else {
                DispatchQueue.main.async {
                    self?.messageLbl.text = "Incorrect OTP. Try again."
                    self?.messageLbl.isHidden = false
                }
            }
        }
    }
    
    func launchResetPasswordPage() {
        timer.invalidate()
        count = 0
        DispatchQueue.main.async { [weak self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let resetPasswordVC = storyboard.instantiateViewController(withIdentifier: "ResetPasswordViewController") as! ResetPasswordViewController
            resetPasswordVC.user = self?.user
            self?.navigationController?.pushViewController(resetPasswordVC, animated: true)
        }
    }
    
    func launchHomePage(isNewUser:Bool) {
        timer.invalidate()
        count = 0
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabbarCntrlr = storyboard.instantiateViewController(withIdentifier: "TabbarViewController") as! TabbarViewController
            tabbarCntrlr.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
            let navCntrl = tabbarCntrlr.selectedViewController as! UINavigationController
            let homeVC = navCntrl.viewControllers[0] as! NewHomeViewController
            homeVC.isNewUser = isNewUser
            self.navigationController?.pushViewController(tabbarCntrlr, animated: true)
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        if isPresented {
           dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func resendOtpButtonTapped(_ sender: UIButton) {
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView?.addLoaderView(forView: self?.view)
            
        }
        messageLbl.isHidden = true
        durationLbl.isHidden = false
        count = 60
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(update), userInfo: nil, repeats: true)
        firstDigitTF.text = ""
        secondDigitTF.text = ""
        thirdDigitTF.text = ""
        fourthDigitTF.text = ""
        
        if user.email != nil {
            UserAPIHandler().getOTPToResetPasswordByEmail(user.email!, completionBlock: { [weak self] (responseData) in
                DispatchQueue.main.async {
                    self?.loaderView?.removeLoaderView()
                }
                
                if let error = responseData.errorObject {
                    self?.view.makeToast( error.message)
                    return
                }
                
                guard let status = responseData.status else {
                    self?.view.makeToast(Constants.kGenericErrorMessage)
                    return
                }
                
                if status {
                    
                } else {
                    
                }
            })
        } else if user.phoneNumber != nil {
            let params:[String:Any] = [
                "phone_number": user.phoneNumber!,
                "country_code": user.countryDialCode!
            ]
            if isLoginThroughOTP {
                resendOTPThroughLoginThroughOTPMobile(params: params)
            } else if isResetPassword {
                resendOTPThroughResetPasswordMobile(params: params)
            } else if isSignup {
                resendOTPThroughSignUpMobile(user: user)
            }
        }
    }
    
}

extension OTPViewControllerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text?.count == 0 && string !=  "" {
            messageLbl.isHidden = true
            durationLbl.isHidden = false
            let nextTag = textField.tag + 1
            if textField.tag < 105 {
                textField.text = string
                if let nextTextField = view.viewWithTag(nextTag) as? UITextField {
                    nextTextField.becomeFirstResponder()
                }
            } else {
                self.view.endEditing(true)
            }
            if isOTPComplete() {
                textField.resignFirstResponder()
                if isLoginThroughOTP {
                    verifyOTPForLogin()
                } else if isResetPassword {
                    verifyOTPForResetPassword()
                } else if isSignup {
                    verifyOTPForSignup()
                } else if isPresented {
                    verifyOTP()
                }
            }
            return false
        } else if textField.text?.count == 1 && string != "" {
            messageLbl.isHidden = true
            durationLbl.isHidden = false
            let nextTag = textField.tag + 1
            if textField.tag < 105 {
                if let nextTextField = view.viewWithTag(nextTag) as? UITextField {
                    nextTextField.becomeFirstResponder()
                    return true
                }
            }
            return false
        } else if string == "" {
            messageLbl.isHidden = true
            durationLbl.isHidden = false
            return true
        }
        return false
    }
    
}
