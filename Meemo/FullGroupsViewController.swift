//
//  FullGroupsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/12/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class FullGroupsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var addButton: SpringButton!
    @IBOutlet weak var tableView: UITableView!
    var shadeView: ShadeView = ShadeView()
    var photoCache = NSCache()
    
    
    @IBOutlet var addFriendButtonContainer: SpringView!
    @IBOutlet var addFriendButton: SpringButton!
    
    @IBOutlet var writeMemoryButton: SpringButton!
    @IBOutlet var writeMemoryContainer: SpringView!
    
    @IBOutlet var captureMemoryButton: SpringButton!
    @IBOutlet var captureMemoryContainer: SpringView!
    
    let viewModel = GroupsViewModel()
    var group:Group? = nil
    var posts:[Post] = []
    var page:Int = 1
    
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
        self.viewModel.getPostsFromGroup(page,group:self.group!, completion: { (result) -> Void in
            self.posts = result
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadStandbyPost:", name: "postStandByPost", object: nil)
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        animateOutShadeView()
        self.addButton.selected = false
        setRotation()
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        if post.post_type == "text" {
        
            let cell = tableView.dequeueReusableCellWithIdentifier("TextPostCell") as! TextPostCell
            cell.post = post
            cell.configureCell()
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("PhotoPostCell") as! PhotoPostCell
            cell.post = post
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
        if post.post_type == "photo" {
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
            dispatch_async(dispatch_get_global_queue(priority, 0)) {
                ServerRequest.sharedManager.createPost(post, completion: { (finished) -> Void in
                    NSLog("PHOTOS ARE DONE!!!!")
                    println("PHOTOS ARE DONE!!!!")
                })
                dispatch_async(dispatch_get_main_queue()) {
                    // update some UI
                }
            }
            
        }
       /* self.viewModel.getPostsFromGroup(1,group: self.group!, completion: { (result) -> Void in
            self.posts = result
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPointMake(0,0), animated: false)
        }) */
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "writeMemory" {
            let vc = segue.destinationViewController as! WriteMemoryViewController
            vc.group = self.group
        }else if segue.identifier == "captureMemory" {
            let vc = segue.destinationViewController as! CaptureMemoryViewController

            vc.group = self.group
        }
    }
    

}
