//
//  PhotoAlbumViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/14/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Photos

class PhotoAlbumViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var images:PHFetchResult = PHFetchResult()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpScrollView()
        fetchPhotos()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func loadThumNailFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(100.0,100.0),
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
