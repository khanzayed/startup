//
//  ForgotPasswordViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var movieView:UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailSentView: UIView!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var dialCodeLbl: UILabel!
    @IBOutlet weak var flagViewWidth: NSLayoutConstraint!
    @IBOutlet weak var flagView: UIView!
    @IBOutlet weak var flagWidthConstraint: NSLayoutConstraint!
    
    var loaderView:LoaderView!
    var user:User!
    var videoPlayerView:VideoPlayerView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        user = User()
        setupView()
        setDoneOnKeyboard()
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
        loginBtn.layer.cornerRadius = loginBtn.bounds.height / 2
        
        userNameTF.autocorrectionType = .no
        
        let (countryDialCode,countryCode) = user.getCountryCode()
        if countryDialCode != nil {
            mapImageView.image = UIImage(named: countryCode!.lowercased())
            dialCodeLbl.text = countryDialCode!
            user.countryDialCode = countryDialCode
            user.countryCode = countryCode
        } else {
            var dialCodesDS = DialCodesDataSource()
            dialCodesDS.parseJSON()
            
            var localCountry = Country(code: "IN", name: "India", dialCode: "+91")
            if let code = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
                let arr = dialCodesDS.countriesList.filter({ (country) -> Bool in
                    if country.code?.lowercased() == code.lowercased() {
                        return true
                    }
                    return false
                })
                if arr.count > 0 {
                    localCountry = arr[0]
                }
            }
            mapImageView.image = UIImage(named: localCountry.code!.lowercased())
            dialCodeLbl.text = localCountry.dialCode
            user.countryDialCode = localCountry.dialCode
            user.countryCode = localCountry.code
        }
        
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        userNameTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func pushToOTPViewController() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "OTPViewControllerViewController") as! OTPViewControllerViewController
            destinationVC.user = self?.user
            destinationVC.isResetPassword = true
            strongSelf.navigationController?.pushViewController(destinationVC, animated: true)
            destinationVC.mobileNumberOrEmail = (self?.userNameTF.text!)!
            
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
            
        }
        
        if userNameTF.text!.isValidEmail() {
            UserAPIHandler().getOTPToResetPasswordByEmail(userNameTF.text!, completionBlock: { [weak self] (responseData) in
                DispatchQueue.main.async {
                    self?.loaderView.removeLoaderView()
                }
                
                if let error = responseData.errorObject {
                    self?.view.makeToast(error.message)
                    return
                }
                
                guard let status = responseData.status, let strongSelf = self  else {
                   self?.view.makeToast(Constants.kGenericErrorMessage)
                    return
                }
                
                if status {
                    strongSelf.user = User()
                    strongSelf.user.email = strongSelf.userNameTF.text!
                    strongSelf.pushToOTPViewController()
                } else {
                    self?.view.makeToast(responseData.message)
                }
            })
        } else {
            let params:[String:Any] = [
                "phone_number": userNameTF.text ?? "",
                "country_code": user.countryDialCode ?? ""
            ]
            UserAPIHandler().getOTPToResetPasswordByMobile(params, completionBlock: { [weak self] (responseData) in
                DispatchQueue.main.async {
                    self?.loaderView.removeLoaderView()
                }
                
                if let error = responseData.errorObject {
                    self?.view.makeToast(error.message)
                    return
                }
                
                guard let status = responseData.status, let strongSelf = self  else {
                    self?.view.makeToast(Constants.kGenericErrorMessage)
                    return
                }
                
                if status {
                    strongSelf.user.phoneNumber = strongSelf.userNameTF.text
                    strongSelf.pushToOTPViewController()
                } else {
                   self?.view.makeToast(responseData.message)
                }
            })
        }
    }
    
    @IBAction func dialCodeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let countriesListVC = storyboard.instantiateViewController(withIdentifier: "CountriesListViewController") as! CountriesListViewController
        countriesListVC.countrySelectedBlock = { [weak self] (country) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.user.countryDialCode = country.dialCode
            strongSelf.user.countryCode = country.code
            strongSelf.dialCodeLbl.text = country.dialCode ?? ""
            DispatchQueue.main.async {
                strongSelf.mapImageView.image = UIImage(named: country.code!.lowercased())
            }
        }
        self.present(countriesListVC, animated: true, completion: nil)
    }

}

extension ForgotPasswordViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.count < 2 {
            if textField.text!.isNumber || textField.text == "" {
                UIView.animate(withDuration: 0.01, animations: {
                    self.flagViewWidth.constant = 74
                    self.flagWidthConstraint.constant = 25
                })
            
            } else {
                UIView.animate(withDuration: 0.01, animations: {
                    self.flagViewWidth.constant = 0
                    self.flagWidthConstraint.constant = 0
                })
            }
        }

        
    
        if let text = textField.text {
            var userName = text
            if string !=  "" {
                userName = text + "\(string)"
            } else {
                userName = userName.replacingCharacters(in: Range(range, in: userName)!, with: "")
            }
            if userName.count > 0  && (userName.isValidEmail() || userName.isValidMobile()) {
                loginBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                loginBtn.isEnabled = true
            } else {
                loginBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                loginBtn.isEnabled = false
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
