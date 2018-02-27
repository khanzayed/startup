//
//  GradientExtension.swift
//  Teazer
//
//  Created by Mraj singh on 19/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import Foundation
import UIKit


extension UIView {

    func applyGradientForTop() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        let startColor = UIColor.clear
        let endColor = UIColor.black.withAlphaComponent(0.7)
        gradient.colors = [endColor.cgColor,startColor.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func applyGradientForBottom() {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        let startColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        let endColor = UIColor.black.withAlphaComponent(0.7)
        gradient.colors = [startColor.cgColor,endColor.cgColor]
        self.layer.insertSublayer(gradient, at: 0)
    }
}


