//
//  UploadProgressView.swift
//  Teazer
//
//  Created by Mraj singh on 26/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class UploadProgressView: UIView {
    
    typealias BlockCancelButtonTapped = () -> Void
    var blockCancelButtonTapped:BlockCancelButtonTapped?
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var lblUploading: UILabel!
    @IBOutlet weak var progressViewUpload: UIProgressView!
    @IBOutlet weak var btnCancel: UIButton!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        uploadProgressView()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        uploadProgressView()
    }
    
    private func uploadProgressView(){
        Bundle.main.loadNibNamed("UploadProgressView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    func updateProgress(progress:Float) {
        DispatchQueue.main.async {
            self.progressViewUpload.progress = progress
        }
    }
    
    @IBAction func stopUploadingButtonTapped(_ sender: UIButton) {
        blockCancelButtonTapped?()
    }
    
}

