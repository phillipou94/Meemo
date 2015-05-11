//
//  WriteMemoryViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/11/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class WriteMemoryViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
       

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.textView.alignToCenter()
        self.textView.delegate = self
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.textView.disableAlignment()
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
    }

    func keyboardWasShown(notification:NSNotification) {
        let width = CGFloat(40)
        let originX = self.textView.frame.size.width * 0.125
        let originY = self.textView.frame.origin.y+self.textView.frame.size.height - width/2
        
        var diamond = UIView(frame: CGRectMake(originX, originY, width, width))
        let rotation = CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(0.25*M_PI));
        diamond.transform = rotation;
        diamond.backgroundColor = UIColor.whiteColor()
        self.view.insertSubview(diamond, belowSubview: self.textView)
      
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.text == "Write Your Story" {
            textView.text = ""
            
        }
        textView.becomeFirstResponder()
    }
    
    @IBAction func nextPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("tagFriends", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tagFriends" {
            var post = Post()
            post.content = self.textView.text
            post.post_type = "text"
            let vc = segue.destinationViewController as! ChooseFriendsViewController
            vc.post = post
        }
    }


}
