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

class CreateGroupsViewController: UIViewController, UITextFieldDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet var headerView: UIView!
    @IBOutlet var groupTextField: UITextField!
    @IBOutlet var photoContainer: SpringView!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet var groupNameLabel: UILabel!
    @IBOutlet var messageView: SpringView!
    @IBOutlet var checkButton: SpringButton!
    var shadeView:ShadeView = ShadeView()
    
    var cameraViewController = CameraViewController()
    var capturedImages:NSArray = []
    
    @IBOutlet var collectionViewContainer: UIView!
    
    
    var bottomState:CGFloat = CGFloat()
    var middleState:CGFloat = CGFloat()
    var topState:CGFloat = CGFloat()
    var currentState:CGFloat = CGFloat()
    
    var selectedIndex:Int = -1
    
    var lastOffset = CGPoint()
    var lastOffsetCapture = NSTimeInterval()
    var isScrollingFast = false
    
    @IBOutlet var collectionView: UICollectionView!
    var initialX:CGFloat? = 0.0
    var initialY:CGFloat? = 0.0
    
     var images:PHFetchResult = PHFetchResult()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        
        self.shadeView = ShadeView(frame: self.view.frame)
        self.view.insertSubview(self.shadeView, belowSubview: headerView)

        setUpCollectionView()
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
        
        if self.checkButton.selected {
            let transition = CATransition()
            let vc: PickFriendsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("PickFriendsViewController") as! PickFriendsViewController
            let group = Group()
            if let user_credentials = CoreDataRequest.sharedManager.getUserCredentials() {
                group.user_ids = [user_credentials.object_id]
            }
            group.name = self.groupNameLabel.text
            group.image = self.groupImageView.image
            
            vc.group = group
            transition.duration = 0.8
            transition.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.view.window!.layer.addAnimation(transition, forKey: nil)
            self.presentViewController(vc, animated: false, completion: nil)
            
            //self.performSegueWithIdentifier("showFriends", sender: self)
        } else if (self.groupTextField.text.length > 0) {
            self.groupNameLabel.text = self.groupTextField.text
            self.groupTextField.text = "Choose a Photo"
            self.groupTextField.userInteractionEnabled = false
            animatePhotoContainerTransition()
            animateCollectionView(middleState,delay:0.2)
            self.checkButton.selected = true
        }
        
    }
    
    
    //MARK:  - CollectionView
    func setUpCollectionView() {
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        self.collectionView.collectionViewLayout = layout
        self.collectionViewContainer.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        self.collectionViewContainer.frame = CGRectMake(0,self.view.frame.size.height+self.collectionView.frame.size.height,self.view.frame.size.width,self.view.frame.size.height)
        self.collectionViewContainer.addSubview(self.collectionView)
        self.collectionView.frame = CGRectMake(0, 40, self.collectionView.frame.size.width, self.collectionView.frame.size.height - 40)
        self.collectionViewContainer.addSubview(self.collectionView)
        let pan = UIPanGestureRecognizer(target: self, action: "draggedCollectionView:")
        self.collectionViewContainer.addGestureRecognizer(pan)
        self.collectionView.alwaysBounceVertical = true
        
        self.view.addSubview(self.collectionViewContainer)
        self.collectionViewContainer.bringSubviewToFront(self.collectionView)
        
        bottomState = self.view.frame.height - 40
        topState = self.headerView.frame.height + 50
        middleState = CGRectGetMaxY(self.photoContainer.frame)
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
            loadImageFrom(asset, completionHandler: { (image) -> Void in
                let thumbnail: UIImage = image as UIImage
                cell.imageView.image = thumbnail
                cell.imageView.hidden = false
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
            selectedIndex = indexPath.row
            let cell:PhotoCell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
            self.groupImageView.image = cell.imageView.image
            let checkmark = UIImage(named:"Checkmark")
            cell.accessoryView.image = checkmark
            cell.accessoryView.hidden = false
            cell.imageView.backgroundColor = UIColor.blackColor()
            cell.imageView.hidden = false
            self.collectionView.reloadData()

        } else {
            showCamera()
        }
        
        
    }
    
    func draggedCollectionView(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        if let view = self.collectionViewContainer {
            view.center = CGPoint(x:view.center.x,
                y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            let closestPosition = roundToNearestState(self.collectionViewContainer.frame.origin.y)
            animateCollectionView(closestPosition, delay: 0.0)
        }
        
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var currentOffset = scrollView.contentOffset
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        var timeDiff = currentTime - lastOffsetCapture
        if timeDiff > 0.1 {
            let scrollSpeed = currentOffset.y - lastOffset.y
            if scrollSpeed > 5.0 {
                animateCollectionView(topState, delay: 0)
            }
            println("\(scrollSpeed)")
        }
        
        lastOffset = currentOffset
        lastOffsetCapture = currentTime

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
            
        }
        
    }
    
    
    func loadImageFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(200,200),
            contentMode: PHImageContentMode.AspectFit,
            options: requestOptions,
            resultHandler: { (image, _) in
            
                completionHandler(image:image)
        })
    }
    
    
    //MARK: - Animations
    
    func animateCollectionView(state:CGFloat, delay: NSTimeInterval) {
        
        UIView.animateWithDuration(0.6, delay: delay, options: nil, animations: { () -> Void in
            self.collectionViewContainer.frame = CGRectMake(0,state,self.view.frame.size.width, self.view.frame.size.height)
        }) { (completed) -> Void in
            if (self.shadeView.superview != nil) {
                self.messageView.hidden = true
                self.view.backgroundColor = self.photoContainer.backgroundColor
                self.shadeView.removeFromSuperview()

            }
            
        }
        

    }
    
    func animatePhotoContainerTransition() {
        self.messageView.animation = "slideRight"
        self.messageView.animateToNext({ () -> () in
            self.messageView.layer.frame.origin.x = -600
        })
        
        self.photoContainer.animation = "slideLeft"
        self.photoContainer.animate()
        
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
    
    //MARK: - CAMERA
    
    func showCamera() {
        
        cameraViewController.delegate = self
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(cameraViewController, animated: true, completion: nil)
        
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        cameraViewController.dismissViewControllerAnimated(true, completion: nil)
        
        let width = min(image.size.width,image.size.height)
        
        let frame = CGRectMake(0,100,width,width)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
        let selectedImage = UIImage(CGImage: imageRef, scale: 1, orientation: image.imageOrientation)
        groupImageView.image = selectedImage
        
        
    }


}
