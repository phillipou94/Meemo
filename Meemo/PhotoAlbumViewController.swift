//
//  PhotoAlbumViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/14/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var images:PHFetchResult = PHFetchResult()
    var collectionViewContainer =  UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        fetchPhotos()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpCollectionView()
    }
    
    @IBAction func exitPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - CollectionView
    
    func setUpCollectionView() {
       

        
        self.collectionViewContainer.frame = CGRectMake(0,self.scrollView.frame.origin.y+self.scrollView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height - 40)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let frame = CGRectMake(0, 40, self.view.frame.size.width, self.collectionViewContainer.frame.size.height - 40)
        var collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")

        self.collectionViewContainer.addSubview(collectionView)
        let pan = UIPanGestureRecognizer(target: self, action: "draggedCollectionView:")
        //self.collectionViewContainer.addGestureRecognizer(pan)
        collectionView.alwaysBounceVertical = true
        
        self.view.addSubview(self.collectionViewContainer)
        self.collectionViewContainer.bringSubviewToFront(collectionView)
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count+1;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.size.width/3 - 8
        return CGSize(width: width, height: width)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        if (indexPath.row == 0) {
            let camera = UIImage(named: "camera_L")
            cell.imageView.hidden = true
            cell.accessoryView.image = camera
            cell.accessoryView.hidden = false
            cell.imageView.backgroundColor = UIColor.redColor()
        } else{
            let asset = self.images[indexPath.row-1] as! PHAsset
            loadThumbnailFrom(asset, completionHandler: { (image) -> Void in
                let thumbnail: UIImage = image as UIImage
                cell.imageView.image = thumbnail
                cell.imageView.hidden = false
                cell.accessoryView.hidden = true
            })
            /*let checkmark = UIImage(named:"Checkmark")
            cell.accessoryView.image = checkmark
            if indexPath.row != selectedIndex {
                cell.accessoryView.hidden = true
            } else {
                cell.accessoryView.hidden = false
            }*/
        }
        
        
        return cell
    }

    
    
    //MARK: - ALAssets
    
    func fetchPhotos () {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            self.images = fetchResult
            if self.images.count > 0 {
                if let firstImage = self.images[0] as? PHAsset {
                    loadImageFrom(firstImage, completionHandler: { (image) -> Void in
                        self.imageView.image = image
                    })
                }
            }
            
            
        }
        
    }
    
    
    func loadImageFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(CGFloat(asset.pixelHeight),CGFloat(asset.pixelWidth)),
            contentMode: PHImageContentMode.AspectFit,
            options: requestOptions,
            resultHandler: { (image, _) in
                
                completionHandler(image:image)
        })
    }
    
    func loadThumbnailFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(200.0,200.0),
            contentMode: PHImageContentMode.AspectFit,
            options: requestOptions,
            resultHandler: { (image, _) in
                
                completionHandler(image:image)
        })
    }

    

    
    //MARK-: Zooming
    
    func setUpScrollView() {
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 3.0
        self.scrollView.scrollEnabled = true
        self.scrollView.backgroundColor = UIColor.blackColor()
        
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView!, atScale scale: CGFloat) {
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
