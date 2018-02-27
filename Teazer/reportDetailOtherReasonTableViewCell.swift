//
//  reportDetailOtherReasonTableViewCell.swift
//  Teazer
//
//  Created by Mraj singh on 09/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class reportDetailOtherReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var otherReasonTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setDoneOnKeyboard()
        otherReasonTextView.layer.borderWidth = 1.0
        otherReasonTextView.layer.borderColor = ColorConstants.kBackgroundGrayColor.cgColor
    }
    
    func setDoneOnKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.endEditing(_:)))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        otherReasonTextView.inputAccessoryView = keyboardToolbar
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
