//
//  LoaderView.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit

class LoaderView: UIView {
    
    var imageView:UIImageView?
    
    func addLoaderView(forView superView:UIView?) {
        DispatchQueue.main.async { [weak self] in
            guard let view = superView, let strongSelf = self else {
                return
            }
            
            strongSelf.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            strongSelf.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            
            strongSelf.imageView = UIImageView(frame: CGRect(x: (UIScreen.main.bounds.width - 50.0) / 2, y: (UIScreen.main.bounds.height - 50.0) / 2, width: 50.0, height: 50.0))
            strongSelf.imageView?.loadGif(name: "loader2")
            strongSelf.addSubview(strongSelf.imageView!)
            
            view.addSubview(strongSelf)
        }
    }

    func removeLoaderView() {
        DispatchQueue.main.async { [weak self] in
            self?.removeFromSuperview()
            self?.imageView?.removeFromSuperview()
            self?.imageView = nil
        }
    }
    
}
