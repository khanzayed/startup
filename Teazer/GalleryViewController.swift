//
//  GalleryViewController.swift
//  Teazer
//
//  Created by Mraj singh on 03/01/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit
import Photos

class GalleryViewController: UIViewController {
    
    typealias PushToVideoTrimmerControllerBlock = (URL, Float) -> Void
    var pushToVideoTrimmerControllerBlock:PushToVideoTrimmerControllerBlock?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var allVideos: PHFetchResult<PHAsset>!
    var isRecordingReaction = false
    var postDetails:Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadVideosFromPhotosApp()
        // Do any additional setup after loading the view.
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width/3 - 15, height: UIScreen.main.bounds.size.width/3 - 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoGalleryCollectionViewCell", for: indexPath) as! VideoGalleryCollectionViewCell
        
        let asset = allVideos.object(at: indexPath.row)
        let size = CGSize(width: UIScreen.main.bounds.size.width/3 - 10, height: UIScreen.main.bounds.size.width/3 - 10)
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { (thumbnail, userInfo) in
            cell.thumbImageView.image = thumbnail
            cell.thumbImageView.contentMode = .scaleAspectFill
            cell.lblDuration.text = String(format: "%02d:%02d",Int((asset.duration / 60)),Int(asset.duration) % 60)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let asset = allVideos.object(at: indexPath.row)
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        options.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: { [weak self] (asset, audioMix, info) in
            guard let strongSelf = self else {
                return
            }
            
            if let urlAsset = asset as? AVURLAsset {
                strongSelf.dismiss(animated: true, completion: {
                    strongSelf.pushToVideoTrimmerControllerBlock?(urlAsset.url, Float(CMTimeGetSeconds(urlAsset.duration)))
                })
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}

extension GalleryViewController {
    
    
    func loadVideosFromPhotosApp() {
        let allVideosOption = PHFetchOptions()
        allVideosOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        allVideosOption.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        allVideos = PHAsset.fetchAssets(with: allVideosOption)
        PHPhotoLibrary.shared().register(self)
    }

}

extension GalleryViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allVideos) {
                self.allVideos = changeDetails.fetchResultAfterChanges
                self.collectionView.reloadData()
            }
        }
    }
    
}
