//
//  MainViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/19/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class MainViewController: UIViewController, CustomSegmentControlDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let viewModel = GroupsViewModel()
    var groups:[Group] = []
    var posts:[Post] = []
    var userID = CoreDataRequest.sharedManager.getUserCredentials()?.object_id
    @IBOutlet weak var addButton: SpringButton!
    var shadeView: ShadeView = ShadeView()
    
    @IBOutlet var customNavBar: UIView!
    @IBOutlet var addGroupButtonContainer: SpringView!
    @IBOutlet var addGroupButton: SpringButton!
    var previousScrollViewYOffset = 0.0;
    
    @IBOutlet var writeMemoryButton: SpringButton!
    @IBOutlet var writeMemoryContainer: SpringView!
    
    @IBOutlet var captureMemoryButton: SpringButton!
    @IBOutlet var captureMemoryContainer: SpringView!
    
    @IBOutlet var segmentControl: CustomSegmentControl!
    
    @IBOutlet var tableView: UITableView!
    
    var page: Int = 1
    var photoCache = NSCache()
    var onLastPage:Bool = false
    
    let transitionManager = TransitionManager()
    
    var standbyPost:Post? = nil
    
    //MARK: - Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
        self.addButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.addButton.layer.shadowOpacity = 0.8
        self.addButton.layer.shadowRadius = 4
        self.addButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        
        self.segmentControl.delegate = self
        page = 1
        setUpTableView()

        self.loadPosts(self.page, completion: { () -> Void in
            if let post = self.standbyPost {
                
                self.posts.insert(post, atIndex: 0)
                
            }
            self.viewModel.getGroups({ (groups) -> Void in
                self.groups = groups
                self.tableView.reloadData()
            })
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStandbyPost:", name: "postStandByPost", object: nil)
        super.viewWillAppear(animated)
        
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
    
    func loadPosts(cursor:Int, completion:() -> Void) {
        self.viewModel.getPosts(cursor, completion: { (posts) -> Void in
            if self.posts.count == 0 && cursor == 1 {
                self.posts = posts
            } else {
                self.posts += posts
            }
            if  posts.count == 0 {
                self.onLastPage = true
            }
            completion()
        })
        
        
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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        if (self.segmentControl.selectedIndex == 0) {
            
            return self.posts.count
        } else {
            return self.groups.count
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.segmentControl.selectedIndex == 0) {
            return self.view.frame.size.width
        } else {
            
            return 90;
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (self.segmentControl.selectedIndex == 0) {
            if !onLastPage {
                willPaginate(indexPath.row)
            }
            let post = self.posts[indexPath.row]
            if post.post_type == "text" {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostCell
                cell.post = post
                cell.user_id = userID
                if let date = post.created_at?.formatDate() {
                    cell.dateLabel.text = date
                } else {
                    cell.dateLabel.text = "Just Now"
                }
                cell.configureCell()
                return cell
                
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("PhotoPostCell") as! PhotoPostCell
                cell.post = post
                cell.user_id = userID
                if let date = post.created_at?.formatDate() {
                    cell.dateLabel.text = date
                } else {
                    cell.dateLabel.text = "Just Now"
                }
                cell.titleLabel.text = post.title
                if let file_url = post.file_url {
                    if let cachedImage = self.photoCache.objectForKey(file_url) as? UIImage {
                        cell.postImageView.image = cachedImage
                    } else {
                        cell.configureCell({ (image) -> Void in
                            self.photoCache.setObject(image, forKey: file_url)
                        })
                    }
                }
                
                return cell
            }

            
        } else {
            let group = self.groups[indexPath.row]
            
            let cell = tableView.dequeueReusableCellWithIdentifier("GroupTableViewCell") as! GroupTableViewCell
            cell.group = group
            cell.configureCell()
            cell.dateLabel.text = group.last_updated?.conventionalDate()
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let deleteButton:UITableViewRowAction = UITableViewRowAction(style: .Default, title: "Leave") { (action, actionIndexPath) -> Void in
            self.viewModel.leaveGroup(self.groups[actionIndexPath.row])
            self.tableView.beginUpdates()
            self.groups.removeAtIndex(actionIndexPath.row)
            self.tableView.deleteRowsAtIndexPaths([actionIndexPath], withRowAnimation: .Fade)
            
            self.tableView.endUpdates()
        }
        deleteButton.backgroundColor = UIColor(red: 202/255.0, green: 77/255.0, blue: 82/255.0, alpha: 1.0)
        deleteButton.title = "Leave Group"
        return [deleteButton]
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func willPaginate(row:Int) {
        if row == self.posts.count - 1 {
            page += 1
            println("LOAD MORE!\(page)")
            loadPosts(page, completion: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (self.segmentControl.selectedIndex == 0) {
            let post = self.posts[indexPath.row]
            if post.post_type == "photo" {
                dispatch_async(dispatch_get_main_queue(),{
                    self.performSegueWithIdentifier("showFullPost", sender: self)
                })
            }
        } else {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! GroupTableViewCell
            cell.colorBar.hidden = true
            self.performSegueWithIdentifier("showGroup", sender: self)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.customNavBar.frame.size.height + self.segmentControl.frame.size.height
        }else {
            return 0
        }
        
    }
    
    func loadStandbyPost(notification:NSNotification) {
        let post = notification.object as! Post
        self.standbyPost = post
        self.tableView.setContentOffset(CGPointMake(0,0), animated: false)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            ServerRequest.sharedManager.createPost(post, completion: { (finished) -> Void in
            })
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
               // self.canLoadPosts = true
            }
            
            
        }
        /* self.viewModel.getPostsFromGroup(1,group: self.group!, completion: { (result) -> Void in
        self.posts = result
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0,0), animated: false)
        }) */
    }
    
    //MARK: - Disappearing NavBar
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var frame = self.customNavBar.frame;
        var segmentFrame = self.segmentControl.frame
        let size = frame.size.height;
        let segmentSize = segmentFrame.size.height
        var scrollOffset = CGFloat(scrollView.contentOffset.y)
        var scrollDiff = CGFloat(Double(scrollOffset) - self.previousScrollViewYOffset)
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            if (self.customNavBar.hidden) {
                self.customNavBar.hidden = false
                self.segmentControl.hidden = false
            }
            frame.origin.y = 0;
            segmentFrame.origin.y = frame.size.height
            
        } else {
            if (self.customNavBar.hidden) {
                frame.origin.y = -self.customNavBar.frame.size.height;
                segmentFrame.origin.y = -self.segmentControl.frame.size.height
                self.customNavBar.hidden = false
                self.segmentControl.hidden = false
            }
            frame.origin.y = min(0, max(-size,frame.origin.y-scrollDiff))
            segmentFrame.origin.y = min(self.customNavBar.frame.size.height, max(-segmentSize, segmentFrame.origin.y - scrollDiff))
            
        }
        
        self.customNavBar.frame = frame
        self.segmentControl.frame = segmentFrame
        self.previousScrollViewYOffset = Double(scrollOffset)
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
        self.performSegueWithIdentifier("createGroup", sender: self)
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
        self.segmentControl.frame = CGRectMake(0, self.customNavBar.frame.size.height, self.segmentControl.frame.size.width, self.segmentControl.frame.size.height)
        self.tableView.reloadData()
    }
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let indexPath = self.tableView.indexPathForSelectedRow()
        if (segue.identifier == "showGroup") {
            let group = self.groups[indexPath!.row]
            let vc = segue.destinationViewController as! FullGroupsViewController
            vc.transitioningDelegate = self.transitionManager
            vc.group = group
        } else if (segue.identifier == "showFullPost") {
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! PhotoPostCell
            let post = self.posts[indexPath!.row]
            post.image = cell.postImageView.image
            let vc = segue.destinationViewController as! PhotoPostViewController
            vc.transitioningDelegate = self.transitionManager
            vc.post = post
        } else if (segue.identifier == "writeMemory") {
            let vc = segue.destinationViewController as! WriteMemoryViewController
            vc.transitioningDelegate = self.transitionManager
        } else if (segue.identifier == "showCaptureMemory") {
            let vc = segue.destinationViewController as! CaptureMemoryViewController
            vc.transitioningDelegate = self.transitionManager
        } else if (segue.identifier == "createGroup") {
            let vc = segue.destinationViewController as! CreateGroupsViewController
            vc.transitioningDelegate = self.transitionManager
        }
    }

}
