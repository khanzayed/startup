//
//  OTPTextField.swift
//  Teazer
//
//  Created by Faraz Habib on 07/10/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit

class OTPTextField: UITextField {
    
    typealias BackButtonTappedBlock = () -> Void
    var backButtonTappedBlock:BackButtonTappedBlock!
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)) || action == #selector(UIResponderStandardEditActions.select(_:)) || action == #selector(UIResponderStandardEditActions.selectAll(_:)) || action == #selector(UIResponderStandardEditActions.delete(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func deleteBackward() {
        super.deleteBackward()
        backButtonTappedBlock()
    }
    
}
