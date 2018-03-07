//
//  CameraViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 20/09/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import MobileCoreServices
import AlamofireImage

class CameraViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var mPreviewView: UIView!
    @IBOutlet weak var mCancelBtn: UIButton!
    @IBOutlet weak var mFlashBtn: UIButton!
    @IBOutlet weak var mCameraBtn: UIButton!
    @IBOutlet weak var mPlayBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var nextLbl: UILabel!
    @IBOutlet weak var mFlipBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var tapToRecordLbl: UILabel!
    @IBOutlet weak var mCameraCoverBtn: UIButton!
    
    //MARK: - Properties
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var movieOutput: AVCaptureMovieFileOutput?
    var audioInput: AVCaptureDeviceInput?
    var progressBar:UIProgressView!
    var videoImage:UIImage?
    var isFrontCamera = true
    var isStoredSectionOpen = false
    var isRecordingAborted = false
    let constraintBottomValue:CGFloat = -113
    var counter = 0
    var videoTimer:Timer!
    let maxVideoLength = 60
    var heightOfStoredVideosView:CGFloat = 280
    var pulledStoredVideos = false
    var downSwipeGesture:UISwipeGestureRecognizer?
    var upSwipeGesture:UISwipeGestureRecognizer?
    var videoURL:URL?
    var videoCellWidth:CGFloat = UIScreen.main.bounds.size.width/3 - 12
    var viceoCellHeight:CGFloat = 100.0
    var isRecordingReaction = false
    var postDetails:Post!
    
    //MARK: - Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProgressBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let tabbarCntrl = tabBarController as? TabbarViewController {
            tabbarCntrl.cameraBtn.isHidden = true
        }
        
        mCameraCoverBtn.isEnabled = false
        mPlayBtn.isEnabled = true
        mFlipBtn.isHidden = false
        nextBtn.isHidden = true
        mFlashBtn.isHidden = false
        mPlayBtn.isHidden = false
        backBtn.isHidden = false
        nextLbl.isHidden = true
        timerLbl.isHidden = true
        tapToRecordLbl.isHidden = false
        tapToRecordLbl.text = "Tap To Record"
        isFrontCamera = isRecordingReaction
        counter = 0
        progressBar.progress = 0
        setupSwipeGestures()
        loadCamera()
        removeProgressBarAnimation()
        removeCameraButtonAnimation()
        mCameraBtn.isEnabled = true

        let microPhoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if (AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  .authorized) &&  microPhoneStatus == .authorized {
            DispatchQueue.main.async {
                self.loadCamera()
            }
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    DispatchQueue.main.async {
                        self.loadCamera()
                    }
                } else {
                    ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Denied", actionTitle: "Settings", message: "Grant permission to Teazer app from Settings to access Camera and Microphone .", forVC: self, completionBlock: { (action) in
                        UIApplication.shared.open(URL(string:"App-Prefs:root=Teazer")!, options: [:], completionHandler: nil)
                    })
                }
            })

        }
        
        PHPhotoLibrary.requestAuthorization({ (status) in
            switch status {
            case .authorized:
//                self?.loadVideosFromPhotosApp()
                break
            default:
                break
            }
        })
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        captureSession = nil
        videoPreviewLayer = nil
        movieOutput = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupProgressBar() {
        progressBar = UIProgressView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20.0))
        progressBar.trackTintColor = UIColor.black
        progressBar.tintColor = UIColor.white
        progressBar.progress = 0
        
        mPreviewView.addSubview(progressBar)
    }
    
    func setupTimer() {
        if videoTimer != nil && videoTimer.isValid {
            return
        }
        
        counter = 0
        videoTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerStarted), userInfo: nil, repeats: true)
    }
    
    
    //MARK: - Camera methods
    func loadCamera() {
        progressBar.progress = 0
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        
        var captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        mFlashBtn.isHidden = isFrontCamera
        if isFrontCamera && captureDevice?.torchMode == .on {
            toggleFlash()
        }
        let videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        for device in videoDevices.devices {
            if device.position == AVCaptureDevice.Position.front && isFrontCamera {
                captureDevice = device
                break
            } else if device.position == AVCaptureDevice.Position.back && !isFrontCamera {
                captureDevice = device
                break
            }
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.beginConfiguration()
            captureSession?.addInput(input)
            
            movieOutput = AVCaptureMovieFileOutput()
            audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            captureSession?.addOutput(movieOutput!)
            captureSession?.addInput(audioInput!)
            captureSession?.commitConfiguration()
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = mPreviewView.layer.bounds
            mPreviewView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()

            mPreviewView.bringSubview(toFront: mFlashBtn)
            mPreviewView.bringSubview(toFront: mFlipBtn)
            mPreviewView.bringSubview(toFront: mCancelBtn)
            mPreviewView.bringSubview(toFront: progressBar)
            mCameraCoverBtn.isEnabled = true
        } catch  {
            print(error)
        }
        
    }
    
    func toggleFlash() {
        if let device = AVCaptureDevice.default(for: AVMediaType.video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                let torchOn = !device.isTorchActive
                try device.setTorchModeOn(level: 1.0)
                device.torchMode = torchOn ? .on : .off
                mFlashBtn.setImage(torchOn ? #imageLiteral(resourceName: "ic_camera_flash_icon"): #imageLiteral(resourceName: "ic_camera_flashoff_icon"), for: .normal)
                device.unlockForConfiguration()
            } catch {
                print("error")
            }
        }
    }
    
    func flipCamera() {
        progressBar.progress = 0
        captureSession?.stopRunning()
        videoPreviewLayer?.removeFromSuperlayer()
        let animationOption:UIViewAnimationOptions = (!isFrontCamera) ? [.transitionFlipFromTop] : [.transitionFlipFromBottom]
        UIView.transition(with: self.mPreviewView, duration: 0.2, options: animationOption, animations: {
            
        }) { [weak self] (true) in
            guard let strongSelf = self else {
                print("self is nil")
                return
            }
            strongSelf.isFrontCamera = !strongSelf.isFrontCamera
            strongSelf.loadCamera()
        }
    }
    
    //MARK: - Swipe Gestures Methods
    func setupSwipeGestures() {
        downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedDown))
        downSwipeGesture?.direction = .down
        mPreviewView.addGestureRecognizer(downSwipeGesture!)
        
        upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        upSwipeGesture?.direction = .up
        mPreviewView.addGestureRecognizer(upSwipeGesture!)
    }
    
    @objc func swipedDown() {
        if isFrontCamera {
            return
        }
        flipCamera()
    }
    
    @objc func swipedUp() {
        if !isFrontCamera {
            return
        }
        flipCamera()
    }
    
    //MARK:- Timer methods
    @objc func timerStarted() {
        DispatchQueue.main.async {
            if self.counter < 10 {
                self.timerLbl.text = "00:0\(self.counter)"
            } else if self.counter < 60 {
                self.timerLbl.text = "00:\(self.counter)"
            } else if self.counter == 60 {
                self.timerLbl.text = "01:00"
            }
            self.counter += 1
        }
    }
    
    //MARK: - Animations methods
    func showProgressBar() {
        UIView.animate(withDuration: TimeInterval(maxVideoLength), animations: {
            self.progressBar.progress = 1.0
            self.mPreviewView.layoutIfNeeded()
        }) { (true) in
            self.removeProgressBarAnimation()
            self.removeCameraButtonAnimation()
            self.mPlayBtn.isEnabled = true
            self.mFlipBtn.isHidden = false
            self.recordingStopped()
            self.movieOutput?.stopRecording()
        }
    }
    
    func removeProgressBarAnimation() {
        progressBar.layer.removeAllAnimations()
        mPreviewView.layoutIfNeeded()
    }

    func animateCameraButton() {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.mCameraBtn.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.mCameraBtn.layoutIfNeeded()
        }) { (true) in
            self.mCameraBtn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.mCameraBtn.layoutIfNeeded()
        }
    }
    
    func removeCameraButtonAnimation() {
        mCameraBtn.layer.removeAllAnimations()
    }
    
    func recordingStarted() {
        nextBtn.isHidden = true
        nextLbl.isHidden = true
        mPlayBtn.isHidden = true
        mFlipBtn.isHidden = true
        mFlashBtn.isHidden = true
        showProgressBar()
        animateCameraButton()
        setupTimer()
        videoTimer.fire()
        timerLbl.isHidden = false
        tapToRecordLbl.text = "Recording"
    }
    
    func recordingStopped() {
        DispatchQueue.main.async {
            self.removeProgressBarAnimation()
            self.removeCameraButtonAnimation()
            self.videoTimer.invalidate()
        }
    }
    
    func showAlertToSaveVideo() {
        let saveVideoAlert = UIAlertController(title: "Message", message: "Do you want to save the video to camera roll ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                strongSelf.saveVideoToCameraRoll()
                strongSelf.pushToVideoUploadViewController()
                break
            case .denied, .restricted:
                strongSelf.pushToVideoUploadViewController()
                break
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        strongSelf.saveVideoToCameraRoll()
                        strongSelf.pushToVideoUploadViewController()
                    } else {
                        strongSelf.pushToVideoUploadViewController()
                    }
                })
                break
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] (action) in
            self?.pushToVideoUploadViewController()
        }
        
        saveVideoAlert.addAction(okAction)
        saveVideoAlert.addAction(cancelAction)
        
        self.present(saveVideoAlert, animated: true, completion: nil)
    }
    
    func saveVideoToCameraRoll() {
        DispatchQueue.main.async { [weak self] in
            if let url = self?.videoURL {
                UISaveVideoAtPathToSavedPhotosAlbum(url.path, nil, nil, nil)
            }
        }
    }
    
    func pushToVideoUploadViewController() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let videoUploadVC = storyboard.instantiateViewController(withIdentifier: "VideoUploadViewController") as! VideoUploadViewController
            videoUploadVC.videoURL = self.videoURL
            videoUploadVC.postDetails = self.postDetails
            videoUploadVC.duration = "Duration " + (self.timerLbl.text ?? "")
            videoUploadVC.isRecordingReaction = self.isRecordingReaction
            videoUploadVC.videoImage = self.videoImage
            self.navigationController?.pushViewController(videoUploadVC, animated: true)
        }
    }
    
    func rotateButton(button:UIButton, fromValue:CGFloat, toValue:CGFloat, duration:Double, angle:CGFloat) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = fromValue
        rotateAnimation.toValue = toValue
        rotateAnimation.duration = duration
        button.layer.add(rotateAnimation, forKey: "transform");
        button.layer.transform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)
    }
    
    func createThumbnailForVideo(url:URL) {
        do {
            let asset = AVURLAsset(url: url)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let interval = CMTime(value: 0, timescale: 1)
            let cGImage:CGImage = try imgGenerator.copyCGImage(at: interval, actualTime: nil)
            let tempVideoImage = UIImage(cgImage: cGImage)
            videoImage = tempVideoImage.af_imageAspectScaled(toFill: CGSize(width: UIScreen.main.bounds.width, height: 200))
        } catch _ {
            debugPrint("Error creating thumbnail from the video")
        }
    }

    // MARK:- Button delegates
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        guard let dataOutput = movieOutput else {
            print("Capture session is null")
            
            if let tabbarVC = self.navigationController?.tabBarController as? TabbarViewController {
                if tabbarVC.previousSelectedIndex != TabbarControllerIndex.kCameraVCIndex {
                    tabbarVC.selectedIndex = tabbarVC.previousSelectedIndex.rawValue
                } else {
                    tabbarVC.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
                }
            }
            
            return
        }
        
        if isRecordingReaction {
            navigationController?.popViewController(animated: true)
        } else {
            if dataOutput.isRecording {
                isRecordingAborted = true
                recordingStopped()
                dataOutput.stopRecording()
            } else {
                isRecordingAborted = false
            }
            if let tabbarVC = self.navigationController?.tabBarController as? TabbarViewController {
                if tabbarVC.previousSelectedIndex != TabbarControllerIndex.kCameraVCIndex {
                    tabbarVC.selectedIndex = tabbarVC.previousSelectedIndex.rawValue
                } else {
                    tabbarVC.selectedIndex = TabbarControllerIndex.kHomeVCIndex.rawValue
                }
            }
        }
    }
    
    @IBAction func flashButtonTapped(_ sender: UIButton) {
        if !isFrontCamera {
            toggleFlash()
        }
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        let microPhoneStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        if !(AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  .authorized &&  microPhoneStatus == .authorized) {
            ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Denied", actionTitle: "Settings", message: "Grant permission to Teazer app from Settings to access Camera and Microphone .", forVC: self, completionBlock: { (action) in
                UIApplication.shared.open(URL(string:"App-Prefs:root=Teazer")!, options: [:], completionHandler: nil)
            })
            return
        }
        
        guard let dataOutput = movieOutput else {
            print("Capture session is null")
            return
        }

        if dataOutput.isRecording {
            if counter < 6 {
                self.view.makeToast("Video cannot be of less than 5 secs duration")
                return
            }
            mCameraBtn.isSelected = false
            recordingStopped()
            dataOutput.stopRecording()
        } else if counter == 0 {
            mCameraBtn.isSelected = true
            let fileUrl = URL(fileURLWithPath: NSTemporaryDirectory() + UUID().uuidString + "teazer" + ".mov")
            try? FileManager.default.removeItem(at: fileUrl)
            dataOutput.startRecording(to: fileUrl, recordingDelegate: self)
        }
    }
    func getMediaDuration(url: NSURL!) -> Float64{
        let asset : AVURLAsset = AVURLAsset(url: url as URL) as AVURLAsset
        let duration : CMTime = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    @IBAction func flipButtonTapped(_ sender: UIButton) {
        flipCamera()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if  PHPhotoLibrary.authorizationStatus() == .authorized {
            if isStoredSectionOpen {
                
            } else {
                openGallery()
            }
        } else {
            ErrorView().showBasicAlertForErrorWithCompletionBlock(title: "Denied", actionTitle: "Settings", message: "Grant permission to Teazer app from Settings to access Photos.", forVC: self, completionBlock: { (action) in
                    UIApplication.shared.open(URL(string:"App-Prefs:root=Photos")!, options: [:], completionHandler: nil)
            })
        }
    }
    
    @IBAction func pullStoredVideosButtonTapped(_ sender: UIButton) {

    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        
    }
    
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

    }

    func fileOutput(_ captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        recordingStarted()
    }

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {

    }

    func fileOutput(_ captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil && isRecordingAborted == false {
            videoURL = outputFileURL
            createThumbnailForVideo(url: outputFileURL)
            pushToVideoUploadViewController()
        } else {
            backBtn.isHidden = false
        }
    }
    
    func openGallery() {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let videoUploadVC = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as! GalleryViewController
        videoUploadVC.postDetails = self.postDetails
        videoUploadVC.isRecordingReaction = isRecordingReaction
        videoUploadVC.pushToVideoTrimmerControllerBlock = { [weak self] (videoURL, duration) in
            self?.pushToVideoTrimmerViewController(videoUrl: videoURL, duration: duration)
        }
        DispatchQueue.main.async {
            self.navigationController?.present(videoUploadVC, animated: true, completion: nil)
        }
    }
    
    func pushToVideoTrimmerViewController(videoUrl:URL, duration:Float) {
        let storyboard = UIStoryboard(name: "Discover", bundle: nil)
        let videoTrimmerVC = storyboard.instantiateViewController(withIdentifier: "VideoTrimmerViewController") as! VideoTrimmerViewController
        videoTrimmerVC.url = videoUrl
        videoTrimmerVC.isFromReaction = isRecordingReaction 
        videoTrimmerVC.postDetails = postDetails
        videoTrimmerVC.durationInSecs = duration
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(videoTrimmerVC, animated: true)
        }
    }

}
