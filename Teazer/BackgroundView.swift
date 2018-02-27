//
//  BackgroundView.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class BackgroundView: UIView {
    
    typealias BackgroundViewTappedBlock = () -> Void
    var backgroundViewTappedBlock: BackgroundViewTappedBlock?
    
    func addBackgroundView(frame:CGRect, alpha:CGFloat, superView:UIView, atIndex:NSInteger, viewTappedBlock:BackgroundViewTappedBlock?) {
        self.frame = frame
        self.alpha = (alpha == 0.0) ? 1.0 : alpha
        self.backgroundViewTappedBlock = viewTappedBlock
        self.backgroundColor = (alpha == 0.0) ? UIColor.clear : UIColor.black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backgroundViewDidTap))
        self.addGestureRecognizer(tapGesture)
        
        superView.insertSubview(self, at: atIndex)
    }
    
    func removeBackgroundView() {
        self.removeFromSuperview()
    }
    
    //MARK: With animation
    func addBackgroundViewWithAnimation(frame:CGRect, alpha:CGFloat, superView:UIView, atIndex:NSInteger, viewTappedBlock:BackgroundViewTappedBlock?) {
        self.frame = frame
        self.alpha = 0
        self.backgroundViewTappedBlock = viewTappedBlock
        self.backgroundColor = UIColor.black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.backgroundViewDidTap))
        self.addGestureRecognizer(tapGesture)
        
        superView.insertSubview(self, at: atIndex)
        
        UIView.animate(withDuration: 0.4) {
            self.alpha = alpha
        }
    }
    
    @objc func backgroundViewDidTap() {
        if self.backgroundViewTappedBlock != nil {
            backgroundViewTappedBlock!()
        }
    }
    
}
