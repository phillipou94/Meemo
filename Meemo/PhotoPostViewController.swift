//
//  PhotoPostViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/13/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit



class PhotoPostViewController: UIViewController {
    
    @IBOutlet var firstShadeView: UIView!
    var secondShadeView:UIView? = nil
    var storyLabel:UILabel? = nil
    var post:Post? = nil
    var lastPage:Int = 1
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var imageView: UIImageView!
    var page:Int = 0
    var leftFrame = CGRectMake(0, 0, 0, 0)
    var rightFrame = CGRectMake(0, 0, 0, 0)
    var currentFrame = CGRectMake(0, 0, 0, 0)
    override func viewDidLoad() {
        super.viewDidLoad()
        let pan = UIPanGestureRecognizer(target: self, action: "draggedView:")
        self.view.addGestureRecognizer(pan)
        if let post = self.post {
            self.imageView.image = post.image
            self.titleLabel.text = post.title
            if let date = post.created_at?.formatDate() {
                self.descriptionLabel.text = "\(post.user_name!) posted this \(date)"
            }
            
        }
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpFrames()
    }
    
    func setUpFrames() {
        let imageSize = self.imageView.frame.size
        leftFrame = CGRectMake(-imageSize.width, self.imageView.frame.origin.y, imageSize.width, imageSize.height)
        rightFrame = CGRectMake(imageSize.width, self.imageView.frame.origin.y, imageSize.width, imageSize.height)
        currentFrame = self.imageView.frame
        if let content = post?.content {
            
            self.secondShadeView = UIView(frame: rightFrame)
            self.secondShadeView?.backgroundColor = UIColor(red: 63/255.0, green: 61/255.0, blue: 82/255.0, alpha: 0.6)
            
            self.view.addSubview(self.secondShadeView!)
            setUpStoryLabel()
            

            lastPage = 2
        }
    }
    
    func setUpStoryLabel() {
        let viewFrame = rightFrame
        let xMargin = CGFloat(15)
        let yMargin = CGFloat(50)
        let labelFrame = CGRectMake(viewFrame.origin.x + xMargin, viewFrame.origin.y + yMargin, viewFrame.size.width-(2*xMargin), viewFrame.size.height - (2*yMargin))
        self.storyLabel = UILabel(frame: labelFrame)
        if let storyLabel = self.storyLabel {
            storyLabel.text = post?.content
            storyLabel.textColor = UIColor.whiteColor()
            storyLabel.backgroundColor = UIColor.clearColor()
            storyLabel.numberOfLines = 0
            storyLabel.textAlignment = .Center
            storyLabel.font = UIFont(name: "STHeitiSC-Light", size: 17)
            self.view.addSubview(storyLabel)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func draggedView(recognizer:UIPanGestureRecognizer) {
        
        
        let velocity = recognizer.velocityInView(self.view)
        if (!(self.pageControl.currentPage == 0 && velocity.x > 0) && !(self.pageControl.currentPage == lastPage && velocity.x < 0)) {
            let translation = recognizer.translationInView(self.view)
            if self.pageControl.currentPage < lastPage {
                self.firstShadeView.center = CGPoint(x:self.firstShadeView.center.x+translation.x,
                    y:self.firstShadeView.center.y)
            }
            if self.pageControl.currentPage > 0  {
                if let secondShadeView = self.secondShadeView {
                    secondShadeView.center = CGPoint(x:secondShadeView.center.x+translation.x,
                        y:secondShadeView.center.y)
                    if let storyLabel = self.storyLabel {
                        storyLabel.center = CGPoint(x:storyLabel.center.x + translation.x,
                            y:storyLabel.center.y)
                    }
                    
                }
                
            }
            recognizer.setTranslation(CGPointZero, inView: self.view)
            
            if recognizer.state == UIGestureRecognizerState.Ended {
                if velocity.x < 0 { //swiped left
                    if self.pageControl.currentPage == 0 {
                        animateView(self.firstShadeView, frame: leftFrame)
                    } else if self.secondShadeView != nil{
                        
                        animateView(self.secondShadeView!, frame:currentFrame)
                        

                    }
                    page += 1
                    
                    
                } else { //right
                    if self.pageControl.currentPage == 2 && self.secondShadeView != nil {
                        animateView(self.secondShadeView!, frame:rightFrame)
                    } else if (self.pageControl.currentPage == 1) {
                        animateView(self.firstShadeView,frame:currentFrame)
    
                    }
                    page -= 1
                }
                
                self.pageControl.currentPage = page
                    
                    
            }
        
        }
        
    }

    
    func animateView(view:UIView,frame:CGRect) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            view.center = CGPointMake(frame.origin.x + (frame.size.width / 2), view.frame.origin.y + (view.frame.size.height / 2))
            if view == self.secondShadeView {
                self.storyLabel?.center = CGPointMake(frame.origin.x + (frame.size.width / 2), view.frame.origin.y + (view.frame.size.height / 2))
            }
            
            }, completion: { (completed) -> Void in
                
        })
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
