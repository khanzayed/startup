//
//  ShareExtension.swift
//  Teazer
//
//  Created by Faraz Habib on 01/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

class Share {
    
    func sharePost(_ message:String, withURL url:String, andImage image:UIImage, sender:UIButton, controller:UIViewController) {
        let firstActivityItem = "Teazer App"
        let secondActivityItem = URL(string: url)!

        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = sender
        
        activityViewController.popoverPresentationController?.permittedArrowDirections = .unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        activityViewController.excludedActivityTypes = [
            .postToWeibo,
            .print,
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .postToFlickr,
            .postToVimeo,
            .postToTencentWeibo
        ]
        
        DispatchQueue.main.async {
            controller.present(activityViewController, animated: true, completion: nil)
        }
    }
    
//    func sharePostOnWhatsApp() {
//        let urlString = "Sending WhatsApp message through app in Swift"
//        let urlStringEncoded = urlString.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
//        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
//
//        if UIApplication.sharedApplication().canOpenURL(url!) {
//            UIApplication.sharedApplication().openURL(url!)
//        } else {
//            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Your device is not able to send WhatsApp messages.", delegate: self, cancelButtonTitle: "OK")
//            errorAlert.show()
//        }
//    }
    
}
