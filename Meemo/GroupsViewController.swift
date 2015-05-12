//
//  GroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/21/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import Foundation
import Spring
class GroupsViewController: UIViewController, CustomSegmentControlDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let viewModel = GroupsViewModel()
    var groups:[Group] = []
    var posts:[Post] = []
    @IBOutlet weak var addButton: SpringButton!
    var shadeView: ShadeView = ShadeView()
    
    @IBOutlet var addGroupButtonContainer: SpringView!
    @IBOutlet var addGroupButton: SpringButton!
    
    @IBOutlet var writeMemoryButton: SpringButton!
    @IBOutlet var writeMemoryContainer: SpringView!
    
    @IBOutlet var captureMemoryButton: SpringButton!
    @IBOutlet var captureMemoryContainer: SpringView!
    
    @IBOutlet var segmentControl: CustomSegmentControl!
    
    @IBOutlet var tableView: UITableView!
    
   
    
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
        self.addButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.addButton.layer.shadowOpacity = 0.8
        self.addButton.layer.shadowRadius = 4
        self.addButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        self.segmentControl.delegate = self
        setUpTableView()
        
        self.viewModel.getGroups { (groups) -> Void in
            self.groups = groups
            self.tableView.reloadData()
        }
        
        PhoneContactsManager.sharedManager.getPhoneContactsWithCompletion { (contacts) -> Void in
            /*let phoneSearchController = PhoneSearchViewController(nibName: "PhoneSearchViewController", bundle: nil) as PhoneSearchViewController
            self.presentViewController(phoneSearchController, animated: true, completion: nil)*/
        }

    }
    
    func setUpTableView() {
        let nib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        let textNib = UINib(nibName: "TextPostCell", bundle: nil)
        let photoNib = UINib(nibName: "PhotoPostCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "GroupTableViewCell")
        self.tableView.registerNib(textNib, forCellReuseIdentifier: "TextPostCell")
        self.tableView.registerNib(photoNib, forCellReuseIdentifier: "PhotoPostCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        animateOutShadeView()
        self.addButton.selected = false
        setRotation()
    }
    
    
    

    
    // MARK: - ShadeView
    
    func animateInShadeView() {
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        let inframe = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)
        
        self.shadeView = ShadeView(frame: outframe)
        self.view.addSubview(self.shadeView)
        self.view.bringSubviewToFront(self.addButton)
        
        UIView.animateWithDuration(0.6, delay: 0, options: nil, animations: { () -> Void in
            self.shadeView.frame = inframe
        }) { (completed) -> Void in
            self.animateInButton(self.addGroupButton, container: self.addGroupButtonContainer)
            self.animateInButton(self.writeMemoryButton, container: self.writeMemoryContainer)
            self.animateInButton(self.captureMemoryButton, container: self.captureMemoryContainer)
        }
        
        
    }
    
    func animateOutShadeView() {
        self.animateOutButton(self.addGroupButton, container: self.addGroupButtonContainer)
        self.animateOutButton(self.writeMemoryButton, container: self.writeMemoryContainer)
        self.animateOutButton(self.captureMemoryButton, container: self.captureMemoryContainer)
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        UIView.animateWithDuration(0.6, delay: 0, options: nil, animations: { () -> Void in
             self.shadeView.frame = outframe
        }) { (finished) -> Void in
            self.shadeView.removeFromSuperview()
        }
    }
    
    //MARK: - TableView
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.segmentControl.selectedIndex == 0) {
            return self.groups.count
        } else {
            return self.posts.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.segmentControl.selectedIndex == 0) {
             return 90;
        } else {
            return self.view.frame.size.width
        }
       
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.segmentControl.selectedIndex == 0) {
            let group = self.groups[indexPath.row]
        
            let cell = tableView.dequeueReusableCellWithIdentifier("GroupTableViewCell") as! GroupTableViewCell
            cell.group = group
            cell.configureCell()
            cell.dateLabel.text = self.viewModel.formatDate(group.last_updated)
            return cell
        } else {
            let post = self.posts[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostCell
            cell.post = post
            cell.configureCell()
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.segmentControl.selectedIndex == 0) {
            self.performSegueWithIdentifier("showGroup", sender: self)
            
        }
    }
    
    //MARK: - Buttons
    
    @IBAction func addButtonPressed(sender: AnyObject) {
        let duration = 0.6
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
    
    @IBAction func createGroupPressed(sender: AnyObject) {
        //self.performSegueWithIdentifier("createGroup", sender: self)
        let vc: CreateGroupsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CreateGroupsViewController") as! CreateGroupsViewController
        let transition = CATransition()
        transition.duration = 0.8
        transition.timingFunction = CAMediaTimingFunction(name: "easeInEaseOut")
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.addAnimation(transition, forKey: nil)
        self.presentViewController(vc, animated: false, completion: nil)
        
        
    }
    
    @IBAction func writeMemoryPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("writeMemory", sender: self)
    }

    @IBAction func captureMemoryPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("showCaptureMemory", sender: self)
        
    }
    
    func animateInButton(button:SpringButton, container:SpringView) {
        container.hidden = false
        self.view.bringSubviewToFront(container)
        button.layer.cornerRadius = button.frame.size.width/4
        container.animation = "fadeInLeft"
        container.animate()
    }
    
    func animateOutButton(button:SpringButton, container:SpringView) {
        container.hidden = true
        container.animate()
        
    }
    
    
    func setRotation() {
        if self.addButton.selected {
            self.addButton.transform = CGAffineTransformMakeRotation(CGFloat(M_PI/4))
        } else {
            self.addButton.transform = CGAffineTransformMakeRotation(CGFloat(0))
        }
        
    }
    

    
    //MARK: - SegmentControl Delegate
    
    func segmentControlDidChange() {
        if (self.segmentControl.selectedIndex == 0 ) {
            self.viewModel.getGroups { (groups) -> Void in
                self.groups = groups
                self.tableView.reloadData()
            }
        } else {
            self.viewModel.getPosts { (posts) -> Void in
                self.posts = posts
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        if (segue.identifier == "showGroup") {
            let group = self.groups[indexPath!.row]
            let vc = segue.destinationViewController as! FullGroupsViewController
            vc.group = group
        }
    }


}
