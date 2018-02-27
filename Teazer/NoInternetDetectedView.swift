//
//  NoInternetDetectedView.swift
//  Teazer
//
//  Created by Mraj singh on 16/12/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class NoInternetDetectedView: UIView {
    
    @IBOutlet weak var contentView: UIView!
  
    override init(frame:CGRect) {
        super.init(frame: frame)
        noInternetView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        noInternetView()
    }
    
    private func noInternetView(){
        Bundle.main.loadNibNamed("NoInternetView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }

    @IBAction func retryButtonTapped(_ sender: UIButton) {
        self.contentView.isHidden = true
      
    }
    

}

