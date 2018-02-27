//
//  NoInternetView.swift
//  Teazer
//
//  Created by Faraz Habib on 10/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class NoInternetView: UIView {
    
    typealias ViewTappedBlock = () -> Void
    var viewTappedBlock: ViewTappedBlock?
    
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var retryBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    
    @IBAction func retryButtonTapped(_ sender: UIButton) {
        
    }
    
}
