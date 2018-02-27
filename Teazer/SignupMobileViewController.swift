//
//  SignupMobileViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class SignupMobileViewController: UIViewController {

    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var mobileView: UIView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var okayBtn: UIButton!
    @IBOutlet weak var firstNameErrorLbl: UILabel!
    @IBOutlet weak var lastNameErrorLbl: UILabel!
    @IBOutlet weak var emailErrorLbl: UILabel!
    @IBOutlet weak var mobileErrorLbl: UILabel!
    @IBOutlet weak var greenTickImageView: UIImageView!
    @IBOutlet weak var greenMobileTickImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var baseViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var dialCodeLbl: UILabel!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isEmailAvailable = false
    var user:User!
    var diffKeyboard:CGFloat = 0
    var loaderView:LoaderView!
    var videoPlayerView:VideoPlayerView?
    var profileImage:UIImage?
    var goesInside = false
    var moreValue:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setDoneOnKeyboard()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisappear), name: .UIKeyboardDidHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPlayerView = VideoPlayerView(frame: movieView.frame)
        videoPlayerView?.setupVideoPlayer(forView: movieView, forResource: Constants.kWelcomeVideo, playerVolume: 0)
        registerNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
         unregisterNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        videoPlayerView?.removeVideoPlayer()
        videoPlayerView = nil

    }
    
    func setupView() {
        firstNameView.layer.cornerRadius = firstNameView.bounds.height / 2
        lastNameView.layer.cornerRadius = lastNameView.bounds.height / 2
        emailView.layer.cornerRadius = emailView.bounds.height / 2
        mobileView.layer.cornerRadius = mobileView.bounds.height / 2
        okayBtn.layer.cornerRadius = okayBtn.bounds.height/2
        okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
        okayBtn.isEnabled = false
        
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
        firstNameTF.inputAccessoryView = keyboardToolbar
        lastNameTF.inputAccessoryView = keyboardToolbar
        emailTF.inputAccessoryView = keyboardToolbar
        mobileTF.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardDidDisappear() {
        diffKeyboard = 0
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    func isFormComplete(mobileNo:String) -> Bool {
        if firstNameTF.text?.count == 0 || lastNameTF.text?.count == 0 || emailTF.text!.count == 0 {
            return false
        }
        if !emailTF.text!.isValidEmail() {
            emailErrorLbl.text = "**Invalid email address"
            emailErrorLbl.isHidden = false
            return false
        } else {
            emailErrorLbl.isHidden = true
        }
        if !isEmailAvailable {
            emailErrorLbl.text = "**Email address unavailable"
            emailErrorLbl.isHidden = false
            return false
        } else {
            emailErrorLbl.isHidden = true
        }
        
        if mobileNo.count > 0 && (mobileNo.count < 4 || mobileNo.count > 13) {
            mobileErrorLbl.text = "**Invalid mobile number"
            mobileErrorLbl.isHidden = false
            return false
        } else {
            mobileErrorLbl.isHidden = true
        }
        return true
    }
    
    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue else { return }
       UIView.animate(withDuration: 0.1) {
            self.scrollView.contentInset.bottom = self.view.convert(keyboardFrame.cgRectValue, from: nil).size.height + 100
            self.scrollView.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
       UIView.animate(withDuration: 0.1) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.layoutIfNeeded()
        }
        
    }

    
    func pushToOTPViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "OTPViewControllerViewController") as! OTPViewControllerViewController
            destinationVC.user = self.user
            destinationVC.isSignup = true
            destinationVC.profileImage = self.profileImage
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    //MARK:- Button delegates
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okayButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return
        }
        
        user.firstName = firstNameTF.text
        user.lastName = lastNameTF.text
        user.email = emailTF.text
        user.phoneNumber = mobileTF.text
        
        DispatchQueue.main.async { [weak self] in
            self?.loaderView = LoaderView()
            self?.loaderView.addLoaderView(forView: self?.view)
        }
        UserAPIHandler().registerUser(user) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView.removeLoaderView()
            }

            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }

            if let status = responseData.status {
                (status) ? (self?.pushToOTPViewController()) : (ErrorView().showBasicAlertForError(title: "Registration", message: responseData.message!, forVC: self))
            } else {
                ErrorView().showBasicAlertForError(title: "Registration", message: Constants.kGenericErrorMessage, forVC: self)
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
    
    //MARK:- Navigation method
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }

}

extension SignupMobileViewController: UITextFieldDelegate {
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.fieldsView.frame = self.fieldsView.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
        
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 101 {
            DispatchQueue.main.async { [weak self] in
                self?.firstNameErrorLbl.isHidden = true
            }
        } else if textField.tag == 102 {
            DispatchQueue.main.async { [weak self] in
                self?.greenTickImageView.isHidden = true
                self?.emailErrorLbl.isHidden = true
            }
        } else if textField.tag == 103 {
            DispatchQueue.main.async { [weak self] in
                self?.mobileErrorLbl.isHidden = true
                self?.greenMobileTickImageView.isHidden = true
            }
        } else if textField.tag == 104 {
            DispatchQueue.main.async { [weak self] in
                self?.lastNameErrorLbl.isHidden = true
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        moreValue = 0.0
        
        if textField.tag == 101 || textField.tag == 100 {
            if textField.text?.count == 15 && string != ""  {
                return false
            }
        }
        
        var text = textField.text!
        if string !=  "" {
            text = text + "\(string)"
        } else {
            text = text.replacingCharacters(in: Range(range, in: text)!, with: "")
        }
        
        if textField.tag == 102 && text.count > 0 && text.isValidEmail() {
            UserAPIHandler().checkEmailAvailability(text, completionBlock: { [weak self] (isAvailable, error) in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.isEmailAvailable = isAvailable!
                self?.greenTickImageView.isHidden = (strongSelf.isEmailAvailable) ? false : true
                if strongSelf.isFormComplete(mobileNo: strongSelf.mobileTF.text!) {
                    strongSelf.okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                    strongSelf.okayBtn.isEnabled = true
                } else {
                    strongSelf.okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                    strongSelf.okayBtn.isEnabled = false
                }
            })
        } else if textField.tag == 103 {
            if isFormComplete(mobileNo: text) {
                okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                okayBtn.isEnabled = true
            } else {
                okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                okayBtn.isEnabled = false
            }
        } else {
            if isFormComplete(mobileNo: mobileTF.text!) {
                okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                okayBtn.isEnabled = true
            } else {
                okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                okayBtn.isEnabled = false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
 

}

