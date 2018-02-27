//
//  LoginThroughOTPViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 08/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class LoginThroughOTPViewController: UIViewController {

    @IBOutlet weak var movieView:UIView!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var sendOTPBtn: UIButton!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var dialCodeLbl: UILabel!
    @IBOutlet weak var dialCodeWidthConstraint: NSLayoutConstraint!
    
    var user:User!
    var loaderView:LoaderView!
    var videoPlayerView:VideoPlayerView?
    var isFirstLetterNumeric = false
    var isLastLetterNumeric = false
    var isMobileOTPLogin = true
    let numericCharSet = NSCharacterSet(charactersIn:"0123456789").inverted
    
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
        mobileView.layer.cornerRadius = mobileView.bounds.height / 2
        sendOTPBtn.layer.cornerRadius = sendOTPBtn.bounds.height / 2
        
        let (countryDialCode,countryCode) = User().getCountryCode()
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
    
    func adjustViewsForEmailOTPLogin() {
        UIView.animate(withDuration: 0.3) {
            self.dialCodeWidthConstraint.constant = 0
        }
    }
    
    func adjustViewsForMobileOTPLogin() {
        UIView.animate(withDuration: 0.3) {
            self.dialCodeWidthConstraint.constant = 65
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        mobileTF.inputAccessoryView = keyboardToolbar
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
            destinationVC.isLoginThroughOTP = true
            strongSelf.navigationController?.pushViewController(destinationVC, animated: true)
            destinationVC.mobileNumberOrEmail = (self?.mobileTF.text!)!
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func sendOTPButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        
        let params:[String:Any] = [
            "phone_number": mobileTF.text ?? "",
            "country_code": user.countryDialCode ?? ""
        ]
        
        UserAPIHandler().getOTPToLoginThroughMobile(params) { [weak self] (responseData) in
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
                strongSelf.user.phoneNumber = strongSelf.mobileTF.text
                strongSelf.pushToOTPViewController()
            } else {
                self?.view.makeToast(responseData.message)
            }
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

extension LoginThroughOTPViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            var userName = text
            if string !=  "" {
                userName = text + "\(string)"
            } else {
                userName = userName.replacingCharacters(in: Range(range, in: userName)!, with: "")
            }
            
            if userName.isValidMobile() {
                sendOTPBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                sendOTPBtn.isEnabled = true
            } else {
                sendOTPBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                sendOTPBtn.isEnabled = false
            }
            return true
        }
        return false
    }
    
}
