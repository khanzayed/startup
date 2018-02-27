//
//  InviteFriendsViewController.swift
//  Teazer
//
//  Created by Ankita Satpathy on 21/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import Social
import MessageUI

class InviteFriendsViewController: UIViewController, MFMailComposeViewControllerDelegate ,MFMessageComposeViewControllerDelegate {
    
   
    var userProfile: UserProfileDataModal?
    var qrcodeImage: CIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // convertToQRCode()
    }
    
//    func convertToQRCode(){
//        if  let nameStrng = userProfile?.user?.userName {
//            let data = nameStrng.data(using: .ascii, allowLossyConversion: false)
//            let filter = CIFilter(name: "CIQRCodeGenerator")
//            filter?.setValue(data, forKey: "inputMessage")
//            let QRimg = filter?.outputImage!
//
//            let scaleX = QRimageView.frame.size.width / (QRimg?.extent.size.width)!
//            let scaleY = QRimageView.frame.size.height / (QRimg?.extent.size.height)!
//            let transformedImage = QRimg?.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
//            QRimageView.image = UIImage(ciImage: transformedImage!)
//        }
//    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnTapped(_ sender: Any) {
        DispatchQueue.main.async {
            let branch = BranchDeepLink(title: "Teazer App", description: "Hey, checkout this cool app-Teazer. Let's do something crazy, an all new way to interact socially. Join the fun and let's keep it going.", imageUrl: nil, channel: "Social")
            branch.createDeepLinks(params: nil, viewController: self)
        }
       
    }
    
    @IBAction func teazerLinkTapped(_ sender: Any) {
        if let url = URL(string: "http://cnapplications.com/") {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    @IBAction func facebookIconTapped(_ sender: Any) {
        DispatchQueue.main.async {
            let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            socialController?.setInitialText("Hey, checkout this cool app-Teazer. Let's do something crazy, an all new way to interact socially. Join the fun and let's keep it going.")
            let url:URL = URL(string:"https://teazer.app.link/kCJ5vr85CI")!
            socialController?.add(url)
            self.present(socialController!, animated: true, completion: nil)
        }
    }
    
    @IBAction func whatsappIconTapped(_ sender: Any) {
        let msg = "Hey, checkout this cool app-Teazer. Let's do something crazy, an all new way to interact socially. Join the fun and let's keep it going. https://teazer.app.link/kCJ5vr85CI"
        let urlWhats = "whatsapp://send?text=\(msg)"
        DispatchQueue.main.async {
            if let urlString = urlWhats.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
                if let whatsappURL = URL(string: urlString) {
                    UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func smsIconTapped(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            DispatchQueue.main.async {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey, checkout this cool app-Teazer. Let's do something crazy, an all new way to interact socially. Join the fun and let's keep it going.https://teazer.app.link/kCJ5vr85CI"
                controller.messageComposeDelegate = self as MFMessageComposeViewControllerDelegate
                self.present(controller, animated: true, completion: nil)
            }
        }else{
            self.view.makeToast("Message could not send")
        }
        
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            self.view.makeToast("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            self.view.makeToast("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            self.view.makeToast("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func emailIconTapped(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
        
    }
 
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self as MFMailComposeViewControllerDelegate // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        mailComposerVC.setSubject("Teazer - EXPRESS BETTER")
        mailComposerVC.setMessageBody("Hey, checkout this cool app-Teazer. Let's do something crazy, an all new way to interact socially. Join the fun and let's keep it going. https://teazer.app.link/kCJ5vr85CI", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        self.view.makeToast("Your device could not send e-mail.  Please check e-mail configuration and try again.")
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        DispatchQueue.main.async {
               controller.dismiss(animated: true, completion: nil)
        }
    }
}

