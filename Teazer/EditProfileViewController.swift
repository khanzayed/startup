//
//  EditProfileViewController.swift
//  Teazer
//
//  Created by Mraj singh on 30/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AlamofireImage
import Photos

class EditProfileViewController: UIViewController {
    
    typealias UpdateProfileDetailsBlock = (User) -> Void
    var updateProfileDetailsBlock:UpdateProfileDetailsBlock?
    
    typealias UpdateProfileImageBlock = (Data?, Data?) -> Void
    var updateProfileImageBlock:UpdateProfileImageBlock?

    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var viewProfileBackground: UIView!
    @IBOutlet weak var viewProfileBlackFront: UIView!
    @IBOutlet weak var btnEditProfileImage: UIButton!
    
    @IBOutlet weak var imageViewCover: UIImageView!
    @IBOutlet weak var viewCoverBackground: UIView!
    @IBOutlet weak var viewCoverBlackFront: UIView!
    @IBOutlet weak var btnEditCoverImage: UIButton!
    
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var textFieldFullName: UITextField!
    @IBOutlet weak var textViewBio: UITextView!
    @IBOutlet weak var textFieldPhoneNumber: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var btnMale: UIButton!
    @IBOutlet weak var btnMaleText: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    @IBOutlet weak var btnFemaleText: UIButton!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblCountryCode: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    

    var user:User!
    var loaderView:LoaderView?
    var fullname: String?
    var updatedProfileImage:UIImage?
    var updatedThumbnailProfileImage:UIImage?
    var imagePicker = UIImagePickerController()
    let acceptableCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@"
    var updateMobile = false
    var defaultCoverImages = [CoverImage]()
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        populateFields()
        setDoneOnKeyboard()
        imagePicker.delegate = self
        btnSave.isEnabled = validateProfileDetails()
        checkPermission()
        
        let tabbarVC = self.navigationController?.tabBarController as! TabbarViewController
        tabbarVC.tabBar.isHidden = true
        tabbarVC.hideCameraButton(value: true)
        
        fetchDeafaultCoverImages(isButtonTapped: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotifications()
    }

    func setupUI() {
        imageViewProfile.layer.cornerRadius = imageViewProfile.bounds.height / 2
        viewProfileBackground.layer.cornerRadius = viewProfileBackground.bounds.height / 2
        viewProfileBlackFront.layer.cornerRadius = viewProfileBlackFront.bounds.height / 2
        imageViewProfile.clipsToBounds = true
    
        imageViewCover.clipsToBounds = true
        
        if let image = AppImageCache.fetchMyProfileImage() {
            imageViewProfile.image = image
        } else {
            if let mediaURL = user.profileMedia?.thumbUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        let resizedImage = image?.af_imageAspectScaled(toFit: CGSize(width: 74, height: 74))
                        self?.imageViewProfile.image = resizedImage
                        AppImageCache.saveMyProfileImage(image: resizedImage)
                    }
                })
            } else {
                imageViewProfile.image = (user.gender == 2) ? #imageLiteral(resourceName: "ic_female_default") : #imageLiteral(resourceName: "ic_male_default")
            }
        }
        
        if let image = AppImageCache.fetchMyCoverImage() {
            imageViewCover.image = image
        } else {
            if let mediaURL = user.coverMedia?.mediaUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: UIScreen.main.bounds.width, height: 400))
                            strongSelf.imageViewCover.image = resizedImage
                            AppImageCache.saveMyCoverImage(image: resizedImage)
                        }
                    }
                })
            } else {
                imageViewCover.image = nil
            }
        }
    }
    
    func populateFields() {
        textFieldUserName.text = user.userName
        textFieldFullName.text = user.firstName! + " " + (user.lastName ?? "")
        textViewBio.text =  user.description ?? ""
        textFieldPhoneNumber.text = user.phoneNumber
        textFieldEmail.text = user.email
        
        if user.gender == 1 {
            btnMaleText.setTitleColor(ColorConstants.kAppBlueColor, for: .normal)
            btnFemaleText.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
            btnMale.setImage(#imageLiteral(resourceName: "ic_male_selected"), for: .normal)
        } else if user.gender == 2 {
            btnFemaleText.setTitleColor(ColorConstants.kAppPinkColor, for: .normal)
            btnMaleText.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
            btnFemale.setImage(#imageLiteral(resourceName: "ic_female_selected"), for: .normal)
        } else {
            btnMaleText.setTitleColor(ColorConstants.kAppBlueColor, for: .normal)
            btnFemaleText.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
            btnMale.setImage(#imageLiteral(resourceName: "ic_male_selected"), for: .normal)
            user.gender = 1
            imageViewProfile.image = #imageLiteral(resourceName: "ic_male_default")
        }
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized: break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                if newStatus ==  PHAuthorizationStatus.authorized {
                }
            })
        case .restricted, .denied: break
        }
    }
    
    func validateProfileDetails() -> Bool {
        if textFieldUserName.text == "" || textFieldFullName.text == "" || textFieldEmail.text == "" || user.gender == nil {
            return false
        }
        
        return true
    }
    
    func removeProfileImage() {
        imageViewProfile.image = (user.gender == 2) ? #imageLiteral(resourceName: "ic_female_default") : #imageLiteral(resourceName: "ic_male_default")
        AppImageCache.removeProfileImage()
        UserProfileAPIHandler().removeProfile({ [weak self] (responseData) in
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true {
                self?.view.makeToast("Profile picture removed successfully")
            } else {
                self?.view.makeToast(responseData.message)
            }
        })
     }
    
    
    @IBAction func countryCodeButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let countriesListVC = storyboard.instantiateViewController(withIdentifier: "CountriesListViewController") as! CountriesListViewController
        countriesListVC.countrySelectedBlock = { [weak self] (country) in
            guard let strongSelf = self else {
                return
            }
            strongSelf.user.countryDialCode = country.dialCode
            strongSelf.user.countryCode = country.code
            
            DispatchQueue.main.async {
                strongSelf.lblCountryCode.text = country.dialCode ?? ""
            }
        }
        self.present(countriesListVC, animated: true, completion: nil)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func photoEditBtnTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary()
        }))
        alert.addAction(UIAlertAction(title: "Remove Image", style: .destructive, handler: { _ in
            self.removeProfileImage()
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func maleIconTapped(_ sender: Any) {
        user.gender = 1
        btnMaleText.setTitleColor(ColorConstants.kAppBlueColor, for: .normal)
        btnFemaleText.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
        btnSave.isEnabled = validateProfileDetails()
        btnFemale.setImage(#imageLiteral(resourceName: "ic_female"), for: .normal)
        btnMale.setImage(#imageLiteral(resourceName: "ic_male_selected"), for: .normal)
        
        if imageViewProfile.image == #imageLiteral(resourceName: "ic_female_default") {
            imageViewProfile.image = #imageLiteral(resourceName: "ic_male_default")
            AppImageCache.saveMyProfileImage(image: #imageLiteral(resourceName: "ic_male_default"))
        }
    }
    
    @IBAction func femaleIconTapped(_ sender: Any) {
        user.gender = 2
        btnFemaleText.setTitleColor(ColorConstants.kAppPinkColor, for: .normal)
        btnMaleText.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
        btnSave.isEnabled = validateProfileDetails()
        btnFemale.setImage(#imageLiteral(resourceName: "ic_female_selected"), for: .normal)
        btnMale.setImage(#imageLiteral(resourceName: "ic_male"), for: .normal)
        
        if imageViewProfile.image == #imageLiteral(resourceName: "ic_male_default") {
            imageViewProfile.image = #imageLiteral(resourceName: "ic_female_default")
            AppImageCache.saveMyProfileImage(image: #imageLiteral(resourceName: "ic_female_default"))
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        if !validateProfileDetails() {
            return
        }
        
        user.fullName = textFieldFullName.text
        var nameArray = user.fullName!.components(separatedBy: " ")
        user.firstName = nameArray[0]
        if nameArray.count > 2 {
            nameArray.remove(at: 0)
            var lastName = ""
            for name in nameArray {
                lastName = lastName + name + " "
            }
            
            let truncated = String(lastName[..<lastName.index(before: lastName.endIndex)])
            user.lastName = truncated
        } else if nameArray.count == 2 {
            user.lastName = nameArray[1]
        }
        
        user.userName = textFieldUserName.text
        user.description = textViewBio.text
        user.phoneNumber = textFieldPhoneNumber.text
        user.email = textFieldEmail.text
        
        if updateMobile {
            updatePhoneNumber()
        } else {
            DispatchQueue.main.async {
                self.loaderView = LoaderView()
                self.loaderView?.addLoaderView(forView: self.view)
            }
            updateProfile()
        }
     }
    
    @IBAction func changeCoverButtonTapped(_ sender: Any) {
        if defaultCoverImages.count > 0 {
            pushToChangeCoverViewController()
        } else {
            fetchDeafaultCoverImages(isButtonTapped: true)
        }
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textFieldUserName.inputAccessoryView = keyboardToolbar
        textFieldFullName.inputAccessoryView = keyboardToolbar
        textFieldPhoneNumber.inputAccessoryView = keyboardToolbar
        textFieldEmail.inputAccessoryView = keyboardToolbar
        textViewBio.inputAccessoryView = keyboardToolbar
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        btnSave.isHidden = false
    }

    
    func goToProfile() {
        navigationController?.popViewController(animated: true)
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
        DispatchQueue.main.async {
            self.scrollView.contentInset.bottom = self.view.convert(keyboardFrame.cgRectValue, from: nil).size.height + 100
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    func pushToOTPViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "OTPViewControllerViewController") as! OTPViewControllerViewController
            destinationVC.user = self.user
            destinationVC.isPresented = true
            destinationVC.otpVerifiedBlock = { [weak self] in
                self?.updateProfile()
            }
            self.tabBarController?.present(destinationVC, animated: true, completion: nil)
        }
    }
  
}


extension EditProfileViewController :UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
    
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let scaledImage = pickedImage.af_imageAspectScaled(toFill: CGSize(width: 400, height: 300))
            if let imageData = UIImageJPEGRepresentation(scaledImage, 1) {
                
                let scaledProfileImage = pickedImage.af_imageAspectScaled(toFill: CGSize(width: 60.0, height: 60.0))
                imageViewProfile.contentMode = .scaleAspectFit
                imageViewProfile.image = scaledProfileImage
                
                AppImageCache.saveMyProfileImage(image: scaledProfileImage)
                
                updateProfileImageBlock?(imageData, nil)
            }
        }
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}

extension EditProfileViewController {
    
    //MARK: update profile API call
    func updatePhoneNumber() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        let params:[String:Any] = [
            "phone_number"      :       textFieldPhoneNumber.text ?? "",
            "country_code"      :       lblCountryCode.text ?? ""
        ]
        
        DispatchQueue.main.async {
            self.loaderView = LoaderView()
            self.loaderView?.addLoaderView(forView: self.view)
        }
        
        UserProfileAPIHandler().updatePhoneNumber(params, completionBlock: { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true {
                self?.pushToOTPViewController()
            } else {
                self?.view.makeToast(responseData.message)
            }
        })
    }
    
    func updateProfile() {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        guard let person = user else {
            return
        }
        
        UserProfileAPIHandler().updateProfileInfo(person) { [weak self] (responseData) in
            DispatchQueue.main.async {
                self?.loaderView?.removeLoaderView()
            }
            
            if let error = responseData.errorObject {
                ErrorView().showAPIErrorToastMessage(errorObj: error, onView: self?.view)
                return
            }
            
            if responseData.status == true, let strongSelf = self {
                strongSelf.updateProfileDetailsBlock?(person)
                self?.navigationController?.popViewController(animated: true)
            } else {
               self?.view.makeToast(responseData.message)
            }
        }
    }
    
    func fetchDeafaultCoverImages(isButtonTapped:Bool) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        CommonAPIHandler().getDefaultCoverImages(1) { [weak self] (responseData) in
            guard let strongSelf = self else {
                return
            }
            
            if responseData.errorObject != nil {
                return
            }
            
            if let list = responseData.coverImagesList {
                strongSelf.defaultCoverImages.append(contentsOf: list)
                if isButtonTapped {
                    strongSelf.pushToChangeCoverViewController()
                }
            }
        }

    }
    
}

extension EditProfileViewController {
    
    func pushToChangeCoverViewController() {
        let storyboard = UIStoryboard(name: StoryboardOptions.Profile.rawValue, bundle: nil)
        let changeCoverViewController = storyboard.instantiateViewController(withIdentifier: "ChangeCoverViewController") as! ChangeCoverViewController
        changeCoverViewController.imagesList = defaultCoverImages
        changeCoverViewController.coverImageSelectedBlock = { [weak self] (selectedImage) in
            let scaledImage = selectedImage.af_imageAspectScaled(toFill: CGSize(width: 400, height: 300))
            if let imageData = UIImageJPEGRepresentation(scaledImage, 1) {
                self?.imageViewCover.image = scaledImage
                AppImageCache.saveMyCoverImage(image: scaledImage)
                self?.updateProfileImageBlock?(nil, imageData)
            }
        }
        DispatchQueue.main.async {
            self.present(changeCoverViewController, animated: true, completion: nil)
        }
    }
    
}

extension EditProfileViewController: UITextFieldDelegate, UITextViewDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 200 {
            btnSave.isEnabled = validateProfileDetails()
            let cs = CharacterSet(charactersIn: acceptableCharacters).inverted
            let filtered: String = (string.components(separatedBy: cs) as NSArray).componentsJoined(by: "")
            return (string == filtered)
        } else if textField.tag == 201 {
            var text = textField.text!
            if string !=  "" {
                text = text + "\(string)"
            } else {
                text = text.replacingCharacters(in: Range(range, in: text)!, with: "")
            }
            if text.count > 3 && text.count < 14 {
                updateMobile = (text != user.phoneNumber)
                btnSave.isEnabled = true
                btnSave.alpha = 1.0
            } else {
                btnSave.isEnabled = false
                btnSave.alpha = 0.5
                updateMobile = false
            }
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text.count <= 50 && text != "") || (textView.text.count <= 51 && text == "") {
            return true
        } else {
            return false
        }
    }
 
}

