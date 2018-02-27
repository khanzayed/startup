//
//  VideoPlayerView.swift
//  Teazer
//
//  Created by Faraz Habib on 02/11/17.
//  Copyright © 2017 Faraz Habib. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerView: UIView {

    var playerItem:AVPlayerItem?
    var player:AVPlayer?
    var playerLayer:AVPlayerLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlayingVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        playerItem = nil
        playerLayer = nil
        player = nil
    }
    
    func setupVideoPlayer(forView view:UIView, forResource resource:String, playerVolume volume:Float) {
        DispatchQueue.global().async {
            guard let videoURL = Bundle.main.path(forResource: resource, ofType:"mp4") else { //welcome_video
                debugPrint("welcome_video.mp4 not found")
                return
            }
            self.playerLayer?.removeFromSuperlayer()
            self.playerItem = AVPlayerItem(url: URL(fileURLWithPath: videoURL))
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: self.playerItem!)
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.player!.actionAtItemEnd = .none
                self.playerLayer?.frame = self.bounds
                self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.layer.addSublayer(self.playerLayer!)
                self.player!.volume = volume
                self.player?.play()
                view.addSubview(self)
            }
        }
    }
    
    func setupVideoPlayer(forView view:UIView) {
        DispatchQueue.global().async {
            guard let videoURL = Bundle.main.path(forResource: "welcome_video", ofType:"mp4") else {
                debugPrint("welcome_video.mp4 not found")
                return
            }
            self.playerLayer?.removeFromSuperlayer()
            self.playerItem = AVPlayerItem(url: URL(fileURLWithPath: videoURL))
            DispatchQueue.main.async {
                self.player = AVPlayer(playerItem: self.playerItem!)
                self.playerLayer = AVPlayerLayer(player: self.player!)
                self.player!.actionAtItemEnd = .none
                self.playerLayer?.frame = self.bounds
                self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                self.layer.addSublayer(self.playerLayer!)
                self.player!.volume = 0
                self.player?.play()
            }
        }
    }
    
    func playVideo() {
        player?.play()
    }
    
    func pauseVideo() {
        player?.pause()
    }
    
    func removeVideoPlayer() {
        self.removeFromSuperview()
        
        playerItem = nil
        playerLayer = nil
        player = nil
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func finishedPlayingVideo() {
        player?.seek(to: kCMTimeZero)
    }
    
}
