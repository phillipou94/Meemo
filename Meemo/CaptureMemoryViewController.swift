//
//  CaptureMemoryViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/7/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class CaptureMemoryViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate, CameraViewControllerDelegate {
    @IBOutlet var imageView: UIImageView!
    var firstTime:Bool = true
    @IBOutlet var navBar: UIView!
    var cameraViewController = CameraViewController()
    var titleEditView = UIView()
    var storyEditView = UIView()
    
    var leftFrame = CGRectMake(0, 0, 0, 0)
    var currentFrame = CGRectMake(0,0,0,0)
    var rightFrame = CGRectMake(0,0,0,0)
    
    var titleTextField = UITextField()
    var storyTextView = UITextView()
    
    var post:Post? = nil

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
        }
        
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
        titleTextField = UITextField(frame: CGRectMake(0, titleEditView.frame.size.height/2-30,self.view.frame.size.width, 50))
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Write Your Title", attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
        titleTextField.textAlignment = .Center
        titleTextField.keyboardAppearance = .Dark
        titleTextField.textColor = UIColor.whiteColor()
        titleTextField.font = UIFont(name: "STHeitiSC-Medium", size: 30)
        titleTextField.delegate = self
        titleTextField.autocorrectionType = .No
        self.view.addSubview(titleEditView)
        titleEditView.addSubview(titleTextField)
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
        if textView.text == "Write Your Story" {
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
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 61/255.0, blue: 82/255.0, alpha: 1.0)
        self.navBar.hidden = false
        self.pageControl.hidden = false
        cameraViewController.dismissViewControllerAnimated(true, completion: nil)
        
        let width = min(image.size.width,image.size.height)
        
        let translation = (40/self.view.frame.size.height) * image.size.height  //40 = height of top menu in camera
        
        let rect = CGRectMake(0, 40, width, width);
        var newImage = cropImage(image, rect: rect)
        
        self.imageView.image = newImage
        
        setUpTitleEditView()
        setUpStoryEditView()
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
    
    // MARK: - Buttons

    @IBAction func checkPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("showFriends", sender: self)
    }
    @IBAction func backPressed(sender: AnyObject) {
        showCamera()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "showFriends") {
            post = Post()
            post?.image = self.imageView.image
            post?.title = self.titleTextField.text
            post?.content = self.storyTextView.text
        }
    }


}
