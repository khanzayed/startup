//
//  SignupUserNameViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 05/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import MobileCoreServices

class SignupUserNameViewController: UIViewController {

    @IBOutlet weak var movieView: UIView!
    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var passwordView: UIView!
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var okayBtn: UIButton!
    @IBOutlet weak var greenTickImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var userNameErrorLbl: UILabel!
    @IBOutlet weak var passwordErrorLbl: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeProfileBtn: UIButton!
    
    @IBOutlet weak var eyeIconButton: UIButton!
    @IBOutlet weak var fieldsView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addImageView: UIImageView!
    @IBOutlet weak var plusSignButton: UIButton!
    
    
    var imagePicker = UIImagePickerController()
    var videoPlayerView:VideoPlayerView?
    var isUserNameAvailable = false
    var isClicked = true
    var profileImage:UIImage?
    var user:User!
    var moreValue:CGFloat = 0.0
    var imageAlreadyChosen = false
    let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setDoneOnKeyboard()
        isClicked = true
        imagePicker.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoPlayerView = VideoPlayerView(frame: movieView.frame)
        videoPlayerView?.setupVideoPlayer(forView: movieView, forResource: Constants.kWelcomeVideo, playerVolume: 0)
        registerNotifications()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        videoPlayerView?.removeVideoPlayer()
        videoPlayerView = nil
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    func setupView() {
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2        
        userNameView.layer.cornerRadius = userNameView.bounds.height / 2
        passwordView.layer.cornerRadius = passwordView.bounds.height / 2
        okayBtn.layer.cornerRadius = okayBtn.bounds.height / 2
        addImageView.layer.cornerRadius = addImageView.bounds.height / 2
        okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
        okayBtn.isEnabled = false
        
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
    
    func removeImage() {
        profileImageView.image = nil
        imageAlreadyChosen = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        
    }
    
    @IBAction func eyeIconReleased(_ sender: Any) {
        if isClicked == true{
            passwordTF.isSecureTextEntry = false
            eyeIconButton.setImage(#imageLiteral(resourceName: "ic_password_hide"), for: .normal)
            isClicked = false
        }else{
            passwordTF.isSecureTextEntry = true
            eyeIconButton.setImage(#imageLiteral(resourceName: "ic_login_show_password_icon"), for: .normal)
            isClicked = true
        }
    }
    
    
    @IBAction func changeProfilePictureButtonTapped(sender:UIButton) {
        let alert = UIAlertController(title: nil , message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        if imageAlreadyChosen {
            alert.addAction(UIAlertAction(title: "Remove Image", style: .destructive, handler: { _ in
                self.removeImage()
            }))
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func isFormComplete() -> Bool {
        if userNameTF.text?.count == 0 || passwordTF.text?.count == 0 {
            return false
        } else if !isUserNameAvailable && userNameTF.text!.count > 3 {
            userNameErrorLbl.text = "Username is unavailable"
            userNameErrorLbl.isHidden = false
            greenTickImageView.isHidden = false
            greenTickImageView.image = #imageLiteral(resourceName: "ic_cross")
            
            return false
        } else if isUserNameAvailable && userNameTF.text!.count > 0{
            greenTickImageView.isHidden = false
            greenTickImageView.image = #imageLiteral(resourceName: "ic_green_tick")
            
        } else if passwordTF.text!.count <= 7 && passwordTF.text!.count > 0 {
            passwordErrorLbl.text  = "Password must be at least 8 charachters"
            passwordErrorLbl.isHidden = false
            return false
        }
        return true
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func okayButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
    }
    
    //MARK:- Navigation method
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if !Connectivity.isConnectedToInternet() {
            self.view.makeToast(Constants.kInternetMessage)
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SignupMobileViewController {
            user = User()
            user.userName = userNameTF.text
            user.setPassword(password: passwordTF.text!)
            destinationVC.profileImage = profileImage
            destinationVC.user = user
        }
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
        guard let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentInset.bottom = self.view.convert(keyboardFrame.cgRectValue, from: nil).size.height + 100 + self.moreValue
            self.scrollView.layoutIfNeeded()
        }
        
    }

    @objc func keyboardWillHide(notification: NSNotification){
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentInset.bottom = 0
            self.moreValue = 260.0
            self.scrollView.layoutIfNeeded()
        }
       
    }
}

extension SignupUserNameViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        moreValue = 0.0
        if textField.tag == 101 {
            if textField.text?.count == 15 && string != "" {
                return false
            }
            let cs = CharacterSet(charactersIn: acceptableCharacters).inverted
            let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
            return (string == filtered)
        }
        
        if textField.tag == 102 {
            if textField.text!.count < 32 {
            if (passwordTF.text!.count >= 7 && string != "")||(passwordTF.text!.count > 8 && string == "")
            {
                if isFormComplete() {
                    okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                    okayBtn.isEnabled = true
                    passwordErrorLbl.isHidden = true
                } }else {
                    okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                    okayBtn.isEnabled = false
                }
                return true
            }else if textField.text!.count < 33 && string == "" {
                return true
            } else {
                return false
            }
        } else if textField.tag == 101 {
            okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
            okayBtn.isEnabled = false
        }
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        if textField.tag == 101 { // Username

            DispatchQueue.main.async { [weak self] in
                self?.greenTickImageView.isHidden = true
                self?.userNameErrorLbl.isHidden = true
                self?.passwordTF.isSecureTextEntry = true
            }
        } else if textField.tag == 102 { // Password
   
            DispatchQueue.main.async { [weak self] in
                self?.passwordErrorLbl.isHidden = true
            }
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            print("Empty textfield")
            return
        }

            if textField.tag == 101 {
 
            if text.count > 3 {
                DispatchQueue.main.async { [weak self] in
                    self?.userNameTF.resignFirstResponder()
                    self?.activityIndicator.startAnimating()
                }
                UserAPIHandler().checkUserNameAvailability(text, completionBlock: { [weak self] (isAvailable, error) in
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                    }
                    if error != nil {
                        self?.view.makeToast(error!.message)
                        return
                    }
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.isUserNameAvailable = isAvailable!
                        strongSelf.greenTickImageView.isHidden = false
                        if strongSelf.isUserNameAvailable {
                            strongSelf.greenTickImageView.isHidden = false
                            strongSelf.greenTickImageView.image = #imageLiteral(resourceName: "ic_green_tick")
                        } else {
                            strongSelf.greenTickImageView.isHidden = false
                            strongSelf.greenTickImageView.image = #imageLiteral(resourceName: "ic_cross")
                        }
                        if strongSelf.isFormComplete() {
                            //strongSelf.greenTickImageView.image = #imageLiteral(resourceName: "ic_green_tick")
                            strongSelf.okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                            strongSelf.okayBtn.isEnabled = true
                        } else {
                           // strongSelf.greenTickImageView.image = #imageLiteral(resourceName: "ic_cross")
                            strongSelf.okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                            strongSelf.okayBtn.isEnabled = false
                        }
                    }
                })
            }else{
                userNameErrorLbl.text = "Username should be of atleast 4 character"
                userNameErrorLbl.isHidden = false
                }
                
        } else if textField.tag == 102 {
            

            if isFormComplete() {
                okayBtn.backgroundColor = UIColor(rgba: "#26C6DA")
                okayBtn.isEnabled = true
            } else {
                okayBtn.backgroundColor = UIColor(rgba: "#C6C6C6")
                okayBtn.isEnabled = false
            }
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

extension SignupUserNameViewController :UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openGallary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as String]
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let scaledProfileImage = pickedImage.af_imageAspectScaled(toFill: CGSize(width: 60.0, height: 60.0))
            let scaledCoverImage = pickedImage.af_imageAspectScaled(toFill: CGSize(width: 375.0, height: 375.0))
            
            profileImageView.contentMode = .scaleAspectFit
            profileImageView.image = scaledProfileImage
            imageAlreadyChosen = true
            
            profileImage = pickedImage
            plusSignButton.setImage(#imageLiteral(resourceName: "ic_edit_grey"), for: .normal)
            
            AppImageCache.saveMyProfileImage(image: scaledProfileImage)
            AppImageCache.saveMyCoverImage(image: scaledCoverImage)
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
    
    
}

