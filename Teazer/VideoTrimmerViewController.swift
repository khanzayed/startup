//
//  ViewController.swift
//  videoeditor
//
//  Created by Oscar J. Irun on 10/12/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation
//import ABVideoRangeSlider


class VideoTrimmerViewController: UIViewController, ABVideoRangeSliderDelegate {
   
    @IBOutlet var btnImport: UIButton!
    @IBOutlet var videoContainer: UIView!
    @IBOutlet var rangeSlider: ABVideoRangeSlider!
    @IBOutlet weak var playPauseImageView: UIImageView!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    
    var url:URL!
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
    var isFromReaction = false
    var postDetails:Post!
    var progressBar:UIProgressView?
    var exportSession:AVAssetExportSession?
    var exportTimer:Timer?
    var alertView:UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableExportButton()
        if durationInSecs < 5 {
            ErrorView().showAcknowledgementAlertWithCompletionBlock(title:"Alert", message: "Please select a video greater than 5 secs", forVC: self, completionBlock: { _ in
                 self.removeVideoPlayer()
                 self.navigationController?.popViewController(animated: true)
            })
        }
        
        if durationInSecs > 60.0 {
            durationInSecs = 60.0
        }
        endTime = Double(durationInSecs)
        if durationInSecs < 60 && durationInSecs >= 10 {
            durationLbl.text = "00:\(Int(durationInSecs))"
        } else if durationInSecs < 10{
            durationLbl.text = "00:0\(Int(durationInSecs))"
        }
        
        rangeSlider.maxSpace = 60.0
        rangeSlider.setVideoURL(videoURL: url)
        rangeSlider.setEndPosition(seconds: durationInSecs)
        rangeSlider.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        avPlayerItem = AVPlayerItem(url: url)
        avPlayer = AVPlayer()
        isPlaying = false
        avPlayer.replaceCurrentItem(with: avPlayerItem)
        avPlayer.actionAtItemEnd = .none
        avPlayer.volume = 1.0
        enableExportButton()
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoContainer.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")
        
        videoContainer.layer.insertSublayer(avPlayerLayer, at: 0)
        videoContainer.layer.masksToBounds = true
        
        let timeInterval: CMTime = CMTimeMakeWithSeconds(0.01, 100)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval,
                                                        queue: DispatchQueue.main) { [weak self] (elapsedTime: CMTime) -> Void in
                                                                if self?.avPlayer.status == .readyToPlay {
                                                                    self?.observeTime(elapsedTime: elapsedTime)
                                                                }
                                                            } as AnyObject!
        
        let timescale = self.avPlayer.currentItem?.asset.duration.timescale
        let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
        if !self.isSeeking{
            self.isSeeking = true
            avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                self.isSeeking = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if avPlayerLayer != nil {
            avPlayerLayer.frame = videoContainer.bounds
        }
    }
    
    func enableExportButton() {
        btnImport.isEnabled = true
        btnImport.setTitleColor(ColorConstants.kTextBlackColor, for: .normal)
    }
    
    func disableExportButton() {
        btnImport.isEnabled = false
        btnImport.setTitleColor(ColorConstants.kDisabledGrayColor, for: .normal)
    }
  
    @IBAction func muteButtonTapped(_ sender: UIButton) {
        if avPlayer.isMuted{
            avPlayer.isMuted = false
            muteButton.setImage(#imageLiteral(resourceName: "ic_soundon_crop"), for: .normal)
        } else {
            avPlayer.isMuted = true
            muteButton.setImage(#imageLiteral(resourceName: "ic_soundoff_crop"), for: .normal)
        }
    }
    @IBAction func tapOnVideoButtonTapped(_ sender: UIButton) {
        if isPlaying {
            avPlayer.pause()
            playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")
            isPlaying = false
        } else {
            avPlayer.play()
            playPauseImageView.image = #imageLiteral(resourceName: "ic_stop")
            shouldUpdateProgressIndicator = true
            isPlaying = true
           
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        removeVideoPlayer()
        navigationController?.popViewController(animated: true)
       
    }
    
    @IBAction func importTapped(_ sender: UIButton) {
        avPlayer.pause()
        isPlaying = false
        playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")
        
        //        DispatchQueue.main.async {
        //            self.loaderView = LoaderView()
        //            self.loaderView?.addLoaderView(forView: self.view)
        //        }
        showProgressAlertBar()
        
        let asset = AVURLAsset(url: url)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        let interval = CMTime(value: 0, timescale: 1)
        do {
            let cGImage:CGImage = try imgGenerator.copyCGImage(at: interval, actualTime: nil)
            videoImage = UIImage(cgImage: cGImage, scale: 1, orientation: UIImageOrientation.up)
        } catch _ {
            debugPrint("Error creating thumbnail from the video")
        }
        
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + (User().deviceId ?? "") + "teazer_temp" + ".mov")
        try? FileManager.default.removeItem(at: outputURL)
        
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset640x480) else {return}
        exportSession = session
        exportSession?.outputURL = outputURL
        exportSession?.outputFileType = AVFileType.mov
        
        let start = CMTime(seconds: Double(startTime), preferredTimescale: 1000)
        let end = CMTime(seconds: Double(endTime), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: start, end: end)
        
        disableExportButton()
        exportSession?.timeRange = timeRange
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            switch strongSelf.exportSession!.status {
            case .completed:
                DispatchQueue.main.async {
                    self?.exportTimer?.invalidate()
                    self?.progressBar?.progress = 1.0
                    self?.alertView?.dismiss(animated: true, completion: {
                        strongSelf.pushToVideoUploadVC(outputURL: outputURL)
                    })
                }
                break
            case .failed, .cancelled, .unknown:
                DispatchQueue.main.async {
                    self?.exportTimer?.invalidate()
                    self?.enableExportButton()
                    self?.view.makeToast("Import cancelled")
                    self?.alertView?.dismiss(animated: true, completion: nil)
                }
                break
            default:
                self?.exportTimer?.invalidate()
                self?.enableExportButton()
                break
            }
        }
        
        exportTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] (timer) in
            guard let strongSelf = self else {
                return
            }
            
            guard let session = strongSelf.exportSession else {
                return
            }
            
            guard let progressView = strongSelf.progressBar else {
                return
            }
            
            DispatchQueue.main.async {
                progressView.progress = session.progress
                if progressView.progress > 0.99 {
                    timer.invalidate()
                }
            }
        })
    }
    
    func showProgressAlertBar() {
        alertView = UIAlertController(title: "Please wait", message: "Preparing the video file...", preferredStyle: .alert)
        alertView!.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] (action) in
            self?.exportTimer?.invalidate()
        }))
        
        self.present(alertView!, animated: true) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let margin: CGFloat = 8.0
            let rect = CGRect(x: margin, y: 72.0, width: strongSelf.alertView!.view.frame.width - margin * 2.0, height: 2.0)
            strongSelf.progressBar = UIProgressView(frame: rect)
            strongSelf.progressBar!.progress = 0.0
            strongSelf.progressBar!.tintColor = UIColor.blue
            strongSelf.alertView!.view.addSubview(strongSelf.progressBar!)
        }
    }
    
    private func observeTime(elapsedTime: CMTime) {
        let elapsedTime = CMTimeGetSeconds(elapsedTime)
 
        if (avPlayer.currentTime().seconds > self.endTime){
            avPlayer.pause()
            isPlaying = false
            playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")

        }
        
        if self.shouldUpdateProgressIndicator{
            rangeSlider.updateProgressIndicator(seconds: elapsedTime)
        }
    }
    
    func indicatorDidChangePosition(videoRangeSlider: ABVideoRangeSlider, position: Float64) {
        self.shouldUpdateProgressIndicator = false
        
        // Pause the player
        avPlayer.pause()
        isPlaying = false
        playPauseImageView.image = #imageLiteral(resourceName: "ic_play_camera")
        if self.progressTime != position {
            self.progressTime = position
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.progressTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
        
    }

    func didChangeValue(videoRangeSlider: ABVideoRangeSlider, startTime: Float64, endTime: Float64) {
        
        self.endTime = endTime
        if Int(self.endTime - self.startTime) < 10 {
            self.durationLbl.text = "00:0\(Int(self.endTime - self.startTime))"
        } else if Int(self.endTime - self.startTime) > 10 && Int(self.endTime - self.startTime) < 60 {
           self.durationLbl.text = "00:\(Int(self.endTime - self.startTime))"
        } else if Int(self.endTime - self.startTime) >= 60{
            self.durationLbl.text = "01:00"
        }
        if startTime != self.startTime{
            self.startTime = startTime
            
            let timescale = self.avPlayer.currentItem?.asset.duration.timescale
            let time = CMTimeMakeWithSeconds(self.startTime, timescale!)
            if !self.isSeeking{
                self.isSeeking = true
                avPlayer.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero){_ in
                    self.isSeeking = false
                }
            }
        }
    }
    
    func pushToVideoUploadVC(outputURL:URL) {
        DispatchQueue.main.async {
            self.removeVideoPlayer()
            
            let duration = Int(self.endTime - self.startTime)
            var durationStr = ""
            if duration < 10 {
                durationStr = "Duration 00:0\(duration)"
            } else {
                durationStr = "Duration 00:\(duration)"
            }
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let videoUploadVC = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
            videoUploadVC.compressedVideoURL = outputURL
            videoUploadVC.isFromPhotos = true
            videoUploadVC.duration = durationStr
            videoUploadVC.videoImage = self.videoImage
            videoUploadVC.isRecordingReaction = self.isFromReaction
            videoUploadVC.postDetails = self.postDetails

            self.loaderView?.removeLoaderView()
            self.navigationController?.pushViewController(videoUploadVC, animated: true)
        }
    }
    
    func removeVideoPlayer() {
        NotificationCenter.default.removeObserver(self)
        
        if self.timeObserver != nil {
            self.avPlayer.removeTimeObserver(self.timeObserver!)
            self.timeObserver = nil
        }
        
        self.avPlayerLayer?.removeFromSuperlayer()
        self.avPlayer = nil
        self.avPlayerLayer = nil
    }
    
}

