//
//  GroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation
import Spring
class GroupsViewController: UIViewController {
    @IBOutlet weak var addButton: SpringButton!
    var shadeView: ShadeView = ShadeView()
    
    @IBOutlet var addGroupButton: SpringButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
    }
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        let duration = 1.0
        var angle = 0.0
        if self.addButton.selected {
            animateOutShadeView()
            angle = M_PI/2
            
        } else {
             angle = -M_PI/4.0
            animateInShadeView()
        }
        self.addButton.selected = !self.addButton.selected
        
        var rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = angle
        rotation.duration = duration
        self.addButton.layer.addAnimation(rotation, forKey: "rotationAnimation")
        
        NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "setRotation", userInfo: nil, repeats: false)
    }
    
    func setRotation() {
        if self.addButton.selected {
            self.addButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/4))
        } else {
            self.addButton.transform = CGAffineTransformMakeRotation(CGFloat(0))
        }
        
    }
    
    func animateInShadeView() {
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        let inframe = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)
        
        self.shadeView = ShadeView(frame: outframe)
        self.view.addSubview(self.shadeView)
        self.view.bringSubviewToFront(self.addButton)
        
        UIView.animateWithDuration(1.0, delay: 0, options: nil, animations: { () -> Void in
            self.shadeView.frame = inframe
        }) { (completed) -> Void in
            self.animateInButtons()
        }
        
        
    }
    
    func animateOutShadeView() {
        animateOutButtons()
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        UIView.animateWithDuration(1.0, delay: 0, options: nil, animations: { () -> Void in
             self.shadeView.frame = outframe
        }) { (finished) -> Void in
            self.shadeView.removeFromSuperview()
        }
    }
    
    func animateInButtons() {
        self.view.bringSubviewToFront(self.addGroupButton)
        self.addGroupButton.hidden = false
        self.addGroupButton.animation = "fadeInLeft"
        self.addGroupButton.animate()
    }
    
    func animateOutButtons() {
        self.addGroupButton.hidden = true
        self.addGroupButton.animate()
        
    }

}
