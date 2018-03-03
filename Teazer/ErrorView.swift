//
//  ErrorView.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class ErrorView: NSObject {
    
    func showBasicAlertForError(message:String, forVC parentVC:UIViewController?) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showBasicAlertForError(title:String, message:String, forVC parentVC:UIViewController?) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showBasicAlertForErrorWithCompletionBlock(title:String, actionTitle:String, message:String, forVC parentVC:UIViewController?, completionBlock: @escaping (UIAlertAction) -> Void) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        alertVC.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: { (action) in
            completionBlock(action)
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showBasicAlertForUpdateWithCompletionBlock(title:String, actionTitle:String, message:String, forVC parentVC:UIViewController?, completionBlock: @escaping (UIAlertAction) -> Void) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ignore", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        alertVC.addAction(UIAlertAction(title: actionTitle, style: .cancel, handler: { (action) in
            completionBlock(action)
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showAcknowledgementAlertWithCompletionBlock(title:String, message:String, forVC parentVC:UIViewController?, completionBlock: @escaping (UIAlertAction) -> Void) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            completionBlock(action)
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func showAcknowledgementAlertForForceUpdateWithCompletionBlock(title:String, message:String, forVC parentVC:UIViewController?, completionBlock: @escaping (UIAlertAction) -> Void) {
        guard let viewController = parentVC else {
            print("View Controller is nil for error message display")
            return
        }
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action: UIAlertAction!) in
            completionBlock(action)
        }))
        
        DispatchQueue.main.async {
            viewController.present(alertVC, animated: true, completion: nil)
        }
    }

    
    func showAPIErrorToastMessage(errorObj:APIErrorModal, onView view:UIView?) {
        if view != nil {
            if errorObj.reason != nil {
                view!.makeToast(errorObj.reason)
            } else {
                view!.makeToast(errorObj.message)
            }
        }
    }
    
}

