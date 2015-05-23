//
//  FullGroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class FullGroupsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    var userID = CoreDataRequest.sharedManager.getUserCredentials()?.object_id
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var addButton: SpringButton!
    @IBOutlet weak var tableView: UITableView!
    var shadeView: ShadeView = ShadeView()
    var photoCache = NSCache()
    
    var previousScrollViewYOffset = 0.0;
    @IBOutlet var customNavBar: UIView!
    
    @IBOutlet var addFriendButtonContainer: SpringView!
    @IBOutlet var addFriendButton: SpringButton!
    
    @IBOutlet var writeMemoryButton: SpringButton!
    @IBOutlet var writeMemoryContainer: SpringView!
    
    @IBOutlet var captureMemoryButton: SpringButton!
    @IBOutlet var captureMemoryContainer: SpringView!
    
    let transitionManager = TransitionManager()
    
    let viewModel = GroupsViewModel()
    var group:Group? = nil
    var posts:[Post] = []
    var onLastPage:Bool = false
    var page:Int = 1
    
    var postToDelete:Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        if let group = self.group {
            self.groupNameLabel.text = group.name
        }
        self.addButton.layer.cornerRadius = self.addButton.frame.size.width/2
        self.addButton.layer.shadowColor = UIColor.blackColor().CGColor
        self.addButton.layer.shadowOpacity = 0.8
        self.addButton.layer.shadowRadius = 4
        self.addButton.layer.shadowOffset = CGSizeMake(4.0, 4.0);
        self.view.bringSubviewToFront(self.addButton)
        setUpTableView()
        page = 1
        loadPosts(page, completion: { () -> Void in
        })

    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStandbyPost:", name: "postStandByPostGroup", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showActionSheet:", name: "ShowActionSheet", object: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        animateOutShadeView()
        self.addButton.selected = false
        setRotation()
    }
    
    func loadPosts(cursor:Int, completion:() -> Void) {
        self.viewModel.getPostsFromGroup(cursor,group:self.group!, completion: { (result) -> Void in
            if self.posts.count == 0 && cursor == 1 {
               self.posts = result
            } else {
                self.posts += result
            }
            self.tableView.reloadData()
            if result.count == 0 {
                self.onLastPage = true
            }
            completion()
            
        })
        
    }
    
    // MARK: - TableView
    
    func setUpTableView() {
        let textNib = UINib(nibName: "TextPostCell", bundle: nil)
        let photoNib = UINib(nibName: "PhotoPostCell", bundle: nil)
        self.tableView.registerNib(textNib, forCellReuseIdentifier: "TextPostCell")
        self.tableView.registerNib(photoNib, forCellReuseIdentifier: "PhotoPostCell")
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return self.posts.count
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
            cell.titleLabel.text = post.title
            if let date = post.created_at?.formatDate() {
                cell.dateLabel.text = date
            } else {
                cell.dateLabel.text = "Just Now"
            }
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

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let post = self.posts[indexPath.row]
        if post.post_type == "photo" {
            dispatch_async(dispatch_get_main_queue(),{
                self.performSegueWithIdentifier("showFullPost", sender: self)
            })
        }
        
    }
    
   
    
    func willPaginate(row:Int) {
        if row == self.posts.count - 1 {
            page += 1
            loadPosts(page, completion: { () -> Void in
                self.tableView.reloadData()
            })
        }
    }

    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.customNavBar.frame.size.height
        }else {
            return 0
        }
        
    }
    
    //MARK: - Actionsheet
    func showActionSheet(notification:NSNotification) {
        let actionSheet = UIActionSheet()
        actionSheet.delegate = self
        actionSheet.actionSheetStyle = .BlackTranslucent
        if self.postToDelete?.user_id == userID {
            actionSheet.addButtonWithTitle("Delete")
            actionSheet.addButtonWithTitle("Close")
            actionSheet.cancelButtonIndex = 1
        } else {
            actionSheet.addButtonWithTitle("Flag As Inappropriate")
            actionSheet.addButtonWithTitle("Hide Post")
            actionSheet.addButtonWithTitle("Close")
            actionSheet.cancelButtonIndex = 2
        }
        
        actionSheet.destructiveButtonIndex = 0
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0 {
            if let post = self.postToDelete {
                if let row = find(self.posts, post) {
                    let indexPath = NSIndexPath(forRow: row, inSection: 1)
                    self.posts.removeAtIndex(indexPath.row)
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                    if post.user_id == userID {
                        ServerRequest.sharedManager.deletePost(post)
                    }
                    
                }
            }
        }
    }

    
    //MARK: - Disappearing NavBar
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var frame = self.customNavBar.frame;
        let size = frame.size.height;
        var scrollOffset = CGFloat(scrollView.contentOffset.y)
        var scrollDiff = CGFloat(Double(scrollOffset) - self.previousScrollViewYOffset)
        
        if (scrollOffset <= -scrollView.contentInset.top) {
            if (self.customNavBar.hidden) {
                self.customNavBar.hidden = false
                
            }
            frame.origin.y = 0;
            
        } else {
            if (self.customNavBar.hidden) {
                frame.origin.y = -self.customNavBar.frame.size.height;
               
                self.customNavBar.hidden = false
                
            }
            frame.origin.y = min(0, max(-size,frame.origin.y-scrollDiff))
            
        }
        
        self.customNavBar.frame = frame
        
        self.previousScrollViewYOffset = Double(scrollOffset)
        
        
    }
    
    func animateInShadeView() {
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        let inframe = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)
        
        self.shadeView = ShadeView(frame: outframe)
        self.view.addSubview(self.shadeView)
        self.view.bringSubviewToFront(self.addButton)
        
        UIView.animateWithDuration(0.6, delay: 0, options: nil, animations: { () -> Void in
            self.shadeView.frame = inframe
            }) { (completed) -> Void in
                self.animateInButton(self.addFriendButton, container: self.addFriendButtonContainer)
                self.animateInButton(self.writeMemoryButton, container: self.writeMemoryContainer)
                self.animateInButton(self.captureMemoryButton, container: self.captureMemoryContainer)
        }
        
        
    }
    
    func animateOutShadeView() {
        self.animateOutButton(self.addFriendButton, container: self.addFriendButtonContainer)
        self.animateOutButton(self.writeMemoryButton, container: self.writeMemoryContainer)
        self.animateOutButton(self.captureMemoryButton, container: self.captureMemoryContainer)
        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
        UIView.animateWithDuration(0.6, delay: 0, options: nil, animations: { () -> Void in
            self.shadeView.frame = outframe
            }) { (finished) -> Void in
                self.shadeView.removeFromSuperview()
        }
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
    
    @IBAction func addMembersPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("pickFriends", sender: self)
    }
    @IBAction func writeMemoryPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("writeMemory", sender: self)
    }
    
    @IBAction func captureMemoryPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("captureMemory",sender:self)
    }
    // MARK: - WriteViewController Delegate
    
    func loadStandbyPost(notification:NSNotification) {
        let post = notification.object as! Post
        posts.insert(post, atIndex: 0)
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointMake(0,0), animated: false)
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            ServerRequest.sharedManager.createPost(post, completion: { (finished) -> Void in
            })
            dispatch_async(dispatch_get_main_queue()) {
                // update some UI
            }
        
            
        }
    }
    
    //MARK: - Settings

    @IBAction func settingsPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("showGroupSettings", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "writeMemory" {
            let vc = segue.destinationViewController as! WriteMemoryViewController
            vc.group = self.group
            vc.transitioningDelegate = self.transitionManager
        }else if segue.identifier == "captureMemory" {
            let vc = segue.destinationViewController as! CaptureMemoryViewController
            vc.group = self.group
            vc.transitioningDelegate = self.transitionManager
        }else if (segue.identifier == "pickFriends") {
            let vc = segue.destinationViewController as! PickFriendsViewController
            vc.group = self.group
            vc.newGroup = false
            vc.transitioningDelegate = self.transitionManager
        } else if (segue.identifier == "showFullPost") {
            let indexPath = tableView.indexPathForSelectedRow()
            let cell = tableView.cellForRowAtIndexPath(indexPath!) as! PhotoPostCell
            let post = self.posts[indexPath!.row]
            post.image = cell.postImageView.image
            let vc = segue.destinationViewController as! PhotoPostViewController
            vc.post = post
            vc.transitioningDelegate = self.transitionManager
        } else if (segue.identifier == "showGroupSettings") {
            let vc = segue.destinationViewController as! GroupSettingsViewController
            vc.group = self.group
            vc.transitioningDelegate = self.transitionManager
        }

    }
    

}
