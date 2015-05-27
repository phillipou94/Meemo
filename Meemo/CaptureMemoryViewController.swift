//
//  CaptureMemoryViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/7/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import CoreLocation

class CaptureMemoryViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CameraViewControllerDelegate, AlbumViewDelegate,CLLocationManagerDelegate {
    @IBOutlet var imageView: UIImageView!
    var firstTime:Bool = true
    @IBOutlet var navBar: UIView!
    var cameraViewController = CameraViewController()
    var albumViewController = PhotoAlbumViewController()
    var titleEditView = UIView()
    var storyEditView = UIView()
    
    var leftFrame = CGRectMake(0, 0, 0, 0)
    var currentFrame = CGRectMake(0,0,0,0)
    var rightFrame = CGRectMake(0,0,0,0)
    
    var titleTextView = UITextView()
    var storyTextView = UITextView()
    
    var post:Post? = nil
    var group:Group? = nil
    var selectedImage: UIImage? = nil
    
    var locManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    

    @IBOutlet var pageControl: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navBar.hidden = true
        self.pageControl.hidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        leftFrame = CGRectMake(-self.imageView.frame.size.width,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        rightFrame = CGRectMake(self.imageView.frame.size.width,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        currentFrame = CGRectMake(0,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        
        if (firstTime) {
            showCamera()
            firstTime = false
        } else {
            self.navBar.hidden = false
            self.pageControl.hidden = false
            self.view.backgroundColor = UIColor(red: 63/255.0, green: 61/255.0, blue: 82/255.0, alpha: 1.0)
            if selectedImage != nil {
                self.imageView.image = selectedImage
                setUpTitleEditView()
                setUpStoryEditView()
                getLocation()
            }
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        selectedImage = nil
        self.imageView.image = nil
        leftFrame = CGRectMake(-self.imageView.frame.size.width,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        rightFrame = CGRectMake(self.imageView.frame.size.width,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        currentFrame = CGRectMake(0,self.imageView.frame.origin.y, self.imageView.frame.size.width, self.imageView.frame.size.height)
        storyTextView.text = nil
        storyTextView.text = nil
        
    }
    
    //force portrait
    override func supportedInterfaceOrientations() -> Int {
         return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    //MARK: - Shade View
    
    func setUpTitleEditView() {
        let pan = UIPanGestureRecognizer(target: self, action: "draggedView:")
        self.view.addGestureRecognizer(pan)
        titleEditView = UIView(frame: rightFrame)
        titleEditView.backgroundColor = UIColor(red: 62/255.0, green: 61/255.0, blue: 84/255.0, alpha: 0.40)
        titleTextView = UITextView(frame: CGRectMake(15, titleEditView.frame.size.height/2-45,self.view.frame.size.width-30, 100))
        titleTextView.text = "Write Your Title"
        titleTextView.textColor = UIColor(white: 1.0, alpha: 0.6)
        titleTextView.textAlignment = .Center
        titleTextView.backgroundColor = UIColor.clearColor()
        titleTextView.font = UIFont(name: "STHeitiSC-Medium", size: 30)
        titleTextView.delegate = self
        titleTextView.autocorrectionType = .No
        titleTextView.keyboardAppearance = .Dark
        self.view.addSubview(titleEditView)
        titleEditView.addSubview(titleTextView)
    }
    
    func setUpStoryEditView() {
        storyEditView = UIView(frame:rightFrame)
        storyEditView.backgroundColor = UIColor(red: 62/255.0, green: 61/255.0, blue: 84/255.0, alpha: 0.40)
        
        storyTextView = UITextView(frame: CGRectMake(20, self.imageView.frame.size.height*0.25, self.imageView.frame.size.width-40, self.imageView.frame.size.height*0.7))
        storyTextView.font = UIFont(name: "STHeitiSC-Medium", size: 15)
        storyTextView.textColor = UIColor.whiteColor()
        storyTextView.textAlignment = .Center
        storyTextView.layer.borderColor = UIColor.clearColor().CGColor
        storyTextView.backgroundColor = UIColor.clearColor()
        storyTextView.keyboardAppearance = .Dark
        storyTextView.text = "Write Your Story"
        storyTextView.textColor = UIColor(white: 1.0, alpha: 0.6)
        storyTextView.delegate = self
        storyTextView.autocorrectionType = .No
        
        self.view.addSubview(storyEditView)
        storyEditView.addSubview(storyTextView)
        
        
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView == storyTextView && textView.text == "Write Your Story") || textView == titleTextView && textView.text == "Write Your Title" {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
            
        }
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text == "Write Your Story"
            textView.textColor = UIColor.whiteColor()
        }
        textView.resignFirstResponder()
    }
    
    func draggedView(recognizer:UIPanGestureRecognizer) {
        let velocity = recognizer.velocityInView(self.view)
        if self.pageControl.currentPage != 2 || velocity.x > 0 {
            let translation = recognizer.translationInView(self.view)
            
            self.titleEditView.center = CGPoint(x:self.titleEditView.center.x+translation.x,
                y:self.titleEditView.center.y)
            if self.pageControl.currentPage != 0 {
                
                self.storyEditView.center = CGPoint(x:self.storyEditView.center.x + translation.x,y:self.storyEditView.center.y)
            }
            recognizer.setTranslation(CGPointZero, inView: self.view)
            
            if recognizer.state == UIGestureRecognizerState.Ended {
                if velocity.x < 0 { //swiped left
                    if (self.pageControl.currentPage == 0) {
                        animateTitleEditView(currentFrame,storyFrame:rightFrame,page:1)
                    } else if (self.pageControl.currentPage == 1) {
                        animateTitleEditView(leftFrame,storyFrame:currentFrame,page:2)
                        
                    }
                } else { //right
                    if (self.pageControl.currentPage == 1) {
                        animateTitleEditView(rightFrame,storyFrame:rightFrame,page:0)
                    } else if (self.pageControl.currentPage == 2) {
                        animateTitleEditView(currentFrame,storyFrame:rightFrame, page: 1)
                    }
                }
                
                
            }
            
        }
        
    }
    
    func animateTitleEditView(frame:CGRect,storyFrame:CGRect,page:Int) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.titleEditView.frame = frame
            if (self.pageControl.currentPage != 0) {
                self.storyEditView.frame = storyFrame
            }
        }, completion: { (completed) -> Void in
            self.pageControl.currentPage = page
        })
    }
    
    //MARK: - CAMERA
    
    func showCamera() {
        cameraViewController.sourceViewController = self
        cameraViewController.delegate = self
        cameraViewController.viewDelegate = self
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(cameraViewController, animated: false, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {

        self.navBar.hidden = false
        self.pageControl.hidden = false
        cameraViewController.dismissViewControllerAnimated(true, completion: nil)
        
        let width = min(image.size.width,image.size.height)
        
        let translation = (40/self.view.frame.size.height) * image.size.height  //40 = height of top menu in camera
        
        let rect = CGRectMake(0, 40, width, width);
        var newImage = cropImage(image, rect: rect)
        self.selectedImage = newImage
    }
    
    func cropImage(image:UIImage, rect:CGRect) -> UIImage {
        var rectTransform = CGAffineTransform()
        let translation = (40/self.view.frame.size.height) * image.size.height
        
        switch (image.imageOrientation) {
        case .Left:
            rectTransform =  CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(0.5*M_PI)), 0.0, -image.size.height-translation)
            break
        case .Right:
            rectTransform =  CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(-0.5*M_PI)), -image.size.width, translation)
            break
        case .Down:
            rectTransform =  CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(-M_PI)), -image.size.width, -image.size.height-translation)
            break
        default:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(CGFloat(0)),translation,0)
        }
        rectTransform = CGAffineTransformScale(rectTransform, image.scale, image.scale)
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, CGRectApplyAffineTransform(rect, rectTransform))
        let result = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return result!
        
    }

    func exitCamera() {
        cameraViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
           self.dismissViewControllerAnimated(true, completion: nil)
        })
       
    }
    
    func exitAlbum() {
        self.albumViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
            self.showCamera()
        })
        
    }
    
    func showAlbum()  {
        cameraViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.albumViewController = PhotoAlbumViewController(nibName: "PhotoAlbumViewController", bundle: nil)
            self.albumViewController.sourceViewController = self
            self.albumViewController.delegate = self
            self.presentViewController(self.albumViewController, animated: false, completion: nil)
        })
    }
    
    // MARK: - Buttons

    @IBAction func checkPressed(sender: AnyObject) {
        if group == nil {
            self.performSegueWithIdentifier("showFriends", sender: self)
        } else {
            post = Post()
            post?.post_type = "photo"
            post?.image = self.imageView.image
            if self.titleTextView.text != "Write Your Title" {
                post?.title = self.titleTextView.text
            }
            if self.storyTextView.text != "Write Your Story" {
                
                post?.content = self.storyTextView.text
            }

            post?.group_id = self.group?.object_id
            post?.file_url = "standby"
            UIImageWriteToSavedPhotosAlbum(self.selectedImage, nil, nil, nil)
            NSNotificationCenter.defaultCenter().postNotificationName("postStandByPostGroup", object: post)
            self.dismissViewControllerAnimated(true, completion: nil)
            
        }
        
    }
    @IBAction func backPressed(sender: AnyObject) {
        showCamera()
    }
    
    //MARK: - Location
    func getLocation() {
        locManager.delegate = self
        locManager.requestWhenInUseAuthorization()
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locManager.distanceFilter = kCLDistanceFilterNone;
        locManager.startUpdatingLocation()
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
                
                currentLocation = locManager.location
                println("LOCATION:\(currentLocation.coordinate.longitude)")
                locManager.stopUpdatingLocation()
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showFriends") {
            post = Post()
            post?.image = self.imageView.image
            if self.titleTextView.text != "Write Your Title" {
                 post?.title = self.titleTextView.text
            }
            if self.storyTextView.text != "Write Your Story" {
                post?.content = self.storyTextView.text
            }
            let vc = segue.destinationViewController as! ChooseFriendsViewController
            vc.post = post
        }
    }


}
