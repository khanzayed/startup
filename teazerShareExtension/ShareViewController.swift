//
//  ShareViewController.swift
//  teazerShareExtension
//
//  Created by Mraj singh on 09/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import Social
import Photos
import MobileCoreServices

class ShareViewController: SLComposeViewController { 
    
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var imageFrameView: ABVideoRangeSlider!
    
    var videoUrl:URL!
    var avPlayer:AVPlayer!
    var avPlayerItem:AVPlayerItem!
    var avPlayerLayer: AVPlayerLayer!
    var timeObserver: AnyObject!
    var startTime = 0.0;
    var endTime = 0.0;
    var progressTime = 0.0;
    var durationInSecs:Float = 0.0
    var shouldUpdateProgressIndicator = true
    var isSeeking = false
    var videoImage:UIImage?
    var isPlaying = true
    var loaderView:LoaderView?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.pickVideo()
        }
//        imageFrameView.maxSpace = 60.0
//        imageFrameView.setVideoURL(videoURL: videoUrl)
//        imageFrameView.setEndPosition(seconds: durationInSecs)
//        imageFrameView.delegate = self
    }
    
    
    func pickVideo() {
        
        let content = extensionContext!.inputItems[0] as! NSExtensionItem
        let contentType = kUTTypeMovie as String
        
        for (_,attachment) in (content.attachments as! [NSItemProvider]).enumerated() {
            if attachment.hasItemConformingToTypeIdentifier(contentType) {
                attachment.loadItem(forTypeIdentifier: contentType, options: nil) { data, error in
                    
                    if error == nil, let url = data as? URL {
                        do {
                            self.videoUrl = url
                            let imageData = try Data(contentsOf: url)
                            let image = UIImage(data: imageData)
                            self.videoImageView.image = image
                            
                        }
                        catch let exp {
                            print("GETTING ERROR \(exp.localizedDescription)")
                        }
                    }
                }
            }
        }
    }
    
    
//    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
//
//        self.endTime = endTime
//        if Int(self.endTime - self.startTime) < 10 {
//            self.durationLabel.text = "00:0\(Int(self.endTime - self.startTime))"
//        } else if Int(self.endTime - self.startTime) > 10 && Int(self.endTime - self.startTime) < 60 {
//            self.durationLabel.text = "00:\(Int(self.endTime - self.startTime))"
//        }else if Int(self.endTime - self.startTime) >= 60 {
//            self.durationLabel.text = "01:00"
//        }
//        if startTime != self.startTime{
//            self.startTime = startTime
//
//            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
//            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
//            if !self.isSeeking{
//                self.isSeeking = true
//                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
//                    self.isSeeking = false
//                }
//            }
//        }
//    }
//
//    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
//
//        avPlayer.pause()
//        isPlaying = false
//        //playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")
//        if self.progressTime != position {
//            self.progressTime = position
//            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
//            let time = CMTimeMakeWithSeconds(self.progressTime, timescale!)
//            if !self.isSeeking{
//                self.isSeeking = true
//                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
//                    self.isSeeking = false
//                }
//            }
//        }
//    }
//
    
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
     self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        
    }
    @IBAction func uploadButtonTapped(_ sender: Any) {
        
        
    }
    @IBAction func locationButtonTapped(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let locationVC = storyboard.instantiateViewController(withIdentifier: "TagLocationViewController") as! TagLocationViewController
        DispatchQueue.main.async {
            self.present(locationVC, animated: true, completion: nil)
            
        }

    }
    @IBAction func tagFriendButtonTapped(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let tagFriendsVC = storyboard.instantiateViewController(withIdentifier: "TagFriendsViewController") as! TagFriendsViewController
        DispatchQueue.main.async {
            self.present(tagFriendsVC, animated: true, completion: nil)

        }

    }
    @IBAction func tagCategoryButtonTapped(_ sender: UIButton) {
        let storyboard: UIStoryboard = UIStoryboard(name: "MainInterface", bundle: nil)
        let tagCategoryVC = storyboard.instantiateViewController(withIdentifier: "TagCategoryViewController") as! TagCategoryViewController
        DispatchQueue.main.async {
            self.present(tagCategoryVC, animated: true, completion: nil)

        }

    }
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {


    }
    
    
    
}
