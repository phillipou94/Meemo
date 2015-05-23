//
//  PhotoAlbumViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/14/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Photos

protocol AlbumViewDelegate {
    func exitAlbum()
}


class PhotoAlbumViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var sourceViewController: UIViewController? = nil
    var images:PHFetchResult = PHFetchResult()
    var collectionViewContainer =  UIView()
    var selectedIndex = -1
    
    var bottomState:CGFloat = CGFloat()
    var middleState:CGFloat = CGFloat()
    var topState:CGFloat = CGFloat()
    var currentState:CGFloat = CGFloat()
    var delegate: AlbumViewDelegate? = nil
    
    
    
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
        self.delegate?.exitAlbum()
    }
    
    //MARK: - CollectionView
    
    func setUpCollectionView() {
        
        self.collectionViewContainer.frame = CGRectMake(0,self.scrollView.frame.origin.y+self.scrollView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height - 40)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let frame = CGRectMake(0, 40, self.view.frame.size.width, self.collectionViewContainer.frame.size.height - 90)
        var collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")

        self.collectionViewContainer.addSubview(collectionView)
        self.collectionViewContainer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        let pan = UIPanGestureRecognizer(target: self, action: "draggedCollectionView:")
        self.collectionViewContainer.addGestureRecognizer(pan)
        collectionView.alwaysBounceVertical = true
        
        self.view.addSubview(self.collectionViewContainer)
        self.collectionViewContainer.bringSubviewToFront(collectionView)
        
        bottomState = self.view.frame.height - 40
        topState = 90
        middleState = CGRectGetMaxY(self.scrollView.frame)
        currentState = middleState
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
            let checkmark = UIImage(named:"Checkmark")
            cell.accessoryView.image = checkmark
            if indexPath.row != selectedIndex {
                cell.accessoryView.hidden = true
            } else {
                cell.accessoryView.hidden = false
            }
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            self.selectedIndex = indexPath.row
            let asset = self.images[indexPath.row-1] as! PHAsset
            loadImageFrom(asset, completionHandler: { (image) -> Void in
                self.imageView.image = image
                self.scrollView.zoomScale = 1.0
                collectionView.reloadData()
            })
        } else {
            self.delegate?.exitAlbum()
        }
        
    }
    
    //MARK: - Animate CollectionView
    
    func draggedCollectionView(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        self.collectionViewContainer.center = CGPoint(x:self.collectionViewContainer.center.x,
                y:self.collectionViewContainer.center.y + translation.y)
        
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            let closestPosition = roundToNearestState(self.collectionViewContainer.frame.origin.y)
            animateCollectionView(closestPosition, delay: 0.0)
        }
        
    }
    
    func animateCollectionView(state:CGFloat, delay: NSTimeInterval) {
        
        UIView.animateWithDuration(0.6, delay: delay, options: nil, animations: { () -> Void in
            self.collectionViewContainer.frame = CGRectMake(0,state,self.view.frame.size.width, self.view.frame.size.height)
            }) { (completed) -> Void in
                
        }
        
        
    }
    
    func roundToNearestState(y:CGFloat) -> CGFloat {
        
        if y > self.view.frame.size.height*0.6 {
            currentState = bottomState
        } else if y < self.view.frame.size.height*0.25 {
            currentState = topState
        } else {
            currentState = middleState
        }
        
        return currentState
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
    
    
    func croppedImageOfView(view:UIView, rect:CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -rect.origin.x, -rect.origin.y)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let visibleScrollViewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return visibleScrollViewImage
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        var visibleRect = CGRect()
        visibleRect.origin = self.scrollView.contentOffset;
        visibleRect.size = self.scrollView.bounds.size;
        
        var theScale = 1.0 / self.scrollView.zoomScale;
        visibleRect.origin.x *= theScale;
        visibleRect.origin.y *= theScale;
        visibleRect.size.width *= theScale;
        visibleRect.size.height *= theScale;
        let image = self.croppedImageOfView(self.imageView, rect: visibleRect)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = self.sourceViewController as? CaptureMemoryViewController {
            vc.firstTime = false
            vc.selectedImage = image
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
        
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
