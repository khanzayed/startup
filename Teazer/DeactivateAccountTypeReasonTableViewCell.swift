//
//  DeactivateAccountTypeReasonTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 04/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class DeactivateAccountTypeReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var reasonTextView: UITextView!
    weak var parentTableView:UITableView?
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setDoneOnKeyboard()
        reasonTextView.layer.borderWidth = 1.0
        reasonTextView.layer.borderColor = ColorConstants.kBackgroundGrayColor.cgColor
        reasonTextView.delegate = self
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        reasonTextView.inputAccessoryView = keyboardToolbar
       
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension DeactivateAccountTypeReasonTableViewCell: UITextViewDelegate{
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        parentTableView?.beginUpdates()
        parentTableView?.endUpdates()
    }
}
