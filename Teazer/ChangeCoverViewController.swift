//
//  ChangeCoverViewController.swift
//  Teazer
//
//  Created by Faraz Habib on 23/02/18.
//  Copyright © 2018 Faraz Habib. All rights reserved.
//

import UIKit

class ChangeCoverViewController: UIViewController {

    typealias CoverImageSelectedBlock = (UIImage) -> Void
    var coverImageSelectedBlock:CoverImageSelectedBlock?
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var collectionViewCover: UICollectionView!
    
    var imagePicker = UIImagePickerController()
    var selectedImage:UIImage!
    var imagesList:[CoverImage]!
    var selectedIndexPath:IndexPath?
    var loaderView:LoaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeButtonTapped(sender:UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(sender:UIButton) {
        guard let indexPath = selectedIndexPath else {
            return
        }
        if indexPath.row == imagesList.count {
            coverImageSelectedBlock?(selectedImage)
            dismiss(animated: true, completion: nil)
        } else {
            if let mediaURL = imagesList[indexPath.row].mediaUrl {
                DispatchQueue.main.async {
                    self.loaderView = LoaderView()
                    self.loaderView?.addLoaderView(forView: self.view)
                }
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { [weak self] (image) in
                    guard let strongSelf = self else {
                        return
                    }
                    DispatchQueue.main.async {
                        strongSelf.loaderView?.removeLoaderView()
                        if image != nil {
                            strongSelf.coverImageSelectedBlock?(image!)
                            strongSelf.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            } else {
                view.makeToast("Error in downloading cover image")
            }
        }
    }
    
}

extension ChangeCoverViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesList.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoverCollectionViewCell", for: indexPath) as! CoverCollectionViewCell
        if indexPath.row < imagesList.count {
            cell.setupImageCell(isSelected: (indexPath == selectedIndexPath))
            
            let image = imagesList[indexPath.row]
            if let mediaURL = image.thumbUrl {
                CommonAPIHandler().getDataFromUrl(imageURL: mediaURL, completion: { (image) in
                    DispatchQueue.main.async {
                        let width = (UIScreen.main.bounds.width - 45) / 2
                        let height = (100 * width) / 165
                        let resizedImage = image?.af_imageAspectScaled(toFill: CGSize(width: width, height: height))
                        if let cell = collectionView.cellForItem(at: indexPath) as? CoverCollectionViewCell {
                            cell.imageViewCover.image = resizedImage
                        }
                    }
                })
            } else {
                cell.imageViewCover.image = nil
                cell.imageViewCover.backgroundColor = UIColor(rgba: "#DDDDDD")
            }
        } else {
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if indexPath.row == 9 {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera()
            }))
            alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
                self.openGallary()
            }))
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if selectedIndexPath == nil {
                let cell = collectionView.cellForItem(at: indexPath) as? CoverCollectionViewCell
                cell?.cellSelected()
                selectedIndexPath = indexPath
            } else {
                let previousCell = collectionView.cellForItem(at: selectedIndexPath!) as? CoverCollectionViewCell
                previousCell?.cellDeselected()
                
                let cell = collectionView.cellForItem(at: indexPath) as? CoverCollectionViewCell
                cell?.cellSelected()
                selectedIndexPath = indexPath
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.width - 45) / 2
        let height = (100 * width) / 165
        
        return CGSize(width: width, height: height)
    }
    
}

extension ChangeCoverViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if !Connectivity.isConnectedToInternet() {
            return
        }
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = pickedImage
            coverImageSelectedBlock?(selectedImage)
        }
        
        dismiss(animated:true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated:true, completion: nil)
    }
}

extension ChangeCoverViewController {
    
    
}

