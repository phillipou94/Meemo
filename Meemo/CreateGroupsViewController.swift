//
//  CreateGroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/23/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation
import Spring
import Photos
import UIKit

class CreateGroupsViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet var headerView: UIView!
    @IBOutlet var groupTextField: UITextField!
    @IBOutlet var photoContainer: SpringView!
    @IBOutlet var groupNameLabel: UILabel!
    @IBOutlet var messageView: SpringView!
    
    @IBOutlet var collectionView: UICollectionView!
     var images:PHFetchResult = PHFetchResult()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        
        let shadeView = ShadeView(frame: self.view.frame)
        self.view.insertSubview(shadeView, belowSubview: headerView)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        
        setUpTextField()
        fetchPhotos()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func setUpTextField() {
        let color = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        self.groupTextField.attributedPlaceholder = NSAttributedString(string: "Name Your Group", attributes: [NSForegroundColorAttributeName:color])
        
        self.groupTextField.delegate = self
        
    }
    
    //MARK: - Buttons
    @IBAction func checkPressed(sender: AnyObject) {
        
        if (self.groupTextField.text.length > 0) {
            self.groupNameLabel.text = self.groupTextField.text
            self.groupTextField.text = "Choose a Photo"
            self.groupTextField.userInteractionEnabled = false
            animatePhotoContainerTransition()
        }
        
    }
    
    //MARK: - ALAssets
    
    func fetchPhotos () {
        let imgManager = PHImageManager.defaultManager()
        
        // Note that if the request is not set to synchronous
        // the requestImageForAsset will return both the image
        // and thumbnail; by setting synchronous to true it
        // will return just the thumbnail
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
        
        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            self.images = fetchResult
            
        }

    }
    
    
    func loadImageFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset, targetSize: view.frame.size, contentMode: PHImageContentMode.AspectFill, options: requestOptions, resultHandler: { (image, _) in
            
            completionHandler(image:image)
        })
    }
    
    //MARK:  - CollectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        let asset = self.images[indexPath.row] as! PHAsset
        loadImageFrom(asset, completionHandler: { (image) -> Void in
            let thumbnail: UIImage = image as UIImage
            cell.imageView.image = thumbnail
        })
    
        return cell
    }
    
    
    //MARK: - Animations
    

    
    func animatePhotoContainerTransition() {
        self.messageView.animation = "slideRight"
        self.messageView.animateToNext({ () -> () in
            self.messageView.layer.frame.origin.x = -600
        })
        
        self.photoContainer.animation = "slideLeft"
        self.photoContainer.animate()
        
    }


}