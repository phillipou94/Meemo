//
//  ChooseFriendsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/10/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class ChooseFriendsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, CustomSegmentControlDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentController: CustomSegmentControl!
    @IBOutlet weak var alertViewTextField: UITextField!
    var shadeView = ShadeView()
    var viewModel = GroupsViewModel()
    var allFriends : [String:[User]] = [:]
    var groups: [Group] = []
    var selectedFriends: [User] = []
    var selectedGroup: Group? = nil
    var post:Post? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentController.items = ["Groups","Friends"]
        self.segmentController.delegate = self
        
        setUpTableView()
        self.viewModel.getGroups { (groups) -> Void in
            self.groups = groups
            self.viewModel.getAllFriends { (friends) -> Void in
                self.allFriends = friends
                
                self.tableView.reloadData()
            }
            
            
        }
        

        // Do any additional setup after loading the view.
    }


    //MARK: - TableView
    
    func setUpTableView() {
        let groupNib = UINib(nibName: "GroupPreviewCell", bundle: nil)
        let friendNib = UINib(nibName: "FriendsCell", bundle: nil)
        self.tableView.registerNib(groupNib, forCellReuseIdentifier: "GroupPreviewCell")
        self.tableView.registerNib(friendNib, forCellReuseIdentifier: "FriendsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.segmentController.selectedIndex == 0 {
            return 1
        } else {
            
            return self.viewModel.alphabet.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.segmentController.selectedIndex == 0 {
            return self.groups.count
        }else {
            let letter = self.viewModel.alphabet[section]
            if let users = self.allFriends[letter] {
                return users.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.segmentController.selectedIndex == 0 {
            return 90
        } else {
            return 60
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.segmentController.selectedIndex == 0 {
            let group = self.groups[indexPath.row]
            let cell = tableView.dequeueReusableCellWithIdentifier("GroupPreviewCell") as! GroupPreviewCell
            cell.group = group
            if group == self.selectedGroup {
                cell.accessoryType = .Checkmark
            } else {
                cell.accessoryType = .None
            }
            cell.configureCell()
            return cell
        } else {
            let letter = self.viewModel.alphabet[indexPath.section]
            var user = User()
            if let array = self.allFriends[letter] {
                user = array[indexPath.row]
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as! FriendsCell
            cell.user = user
            cell.configureCell()
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)

        if self.segmentController.selectedIndex == 0 {
            self.selectedGroup = self.groups[indexPath.row]
        } else {
            let letter = self.viewModel.alphabet[indexPath.section]
            let array = self.allFriends[letter]! as [User]
            let  user = array[indexPath.row]
            
            
            if contains(selectedFriends, user) {
                if let index = find(selectedFriends, user) {
                    selectedFriends.removeAtIndex(index)
                    cell?.accessoryType = .None
                }
                
            } else {
                selectedFriends.append(user)
                cell?.accessoryType = .Checkmark
            }
            
            
        }
        self.tableView.reloadData()
        
    }
    
    //MARK: - Alert View
    
//    func showAlertView() {
//        let width = self.view.frame.size.width * 0.75
//        let marginX = self.view.frame.size.width * 0.125
//        let marginY = self.view.frame.size.height * 0.1
//        self.alertView = NSBundle.mainBundle().loadNibNamed("AlertView", owner: self, options: nil).first as! UIView
//        self.alertView.frame = CGRectMake(self.view.frame.size.width+50, marginY, width,width)
//        self.alertView.layer.shadowColor = UIColor.blackColor().CGColor
//        self.alertView.layer.shadowOpacity = 0.8
//        self.alertView.layer.shadowOffset = CGSizeMake(4.0, 4.0);
//        self.alertView.layer.borderColor = UIColor.blackColor().CGColor
//        self.alertView.layer.borderWidth = CGFloat(1.0)
//        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
//        let inframe = CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)
//        self.alertViewTextField.attributedPlaceholder = NSAttributedString(string: "Enter New Group Name", attributes: [NSForegroundColorAttributeName: UIColor(white: 1.0, alpha: 0.6)])
//        
//        self.shadeView = ShadeView(frame: outframe)
//        self.view.addSubview(self.shadeView)
//        self.view.addSubview(self.alertView)
//        
//        UIView .animateWithDuration(0.4, animations: { () -> Void in
//            self.shadeView.frame = inframe
//            self.alertView.frame = CGRectMake(marginX,marginY,width,width)
//        })
//    }
//    
//    func dismissAlertView() {
//        let width = self.view.frame.size.width * 0.75
//        let marginX = self.view.frame.size.width * 0.125
//        let marginY = self.view.frame.size.height * 0.1
//        let outframe = CGRectMake(self.view.frame.size.width,0,self.view.frame.size.width,self.view.frame.size.height)
//        UIView.animateWithDuration(0.4, animations: { () -> Void in
//            self.alertView.frame = CGRectMake(self.view.frame.size.width+50,marginY,width,width)
//            self.shadeView.frame = outframe
//            },completion: { (completed) -> Void in
//                self.alertView.removeFromSuperview()
//                self.shadeView.removeFromSuperview()
//        })
//    }
    // MARK: - Creating Post
    @IBAction func finishPressed(sender: AnyObject) {
        
        if let post = self.post {
                
            if let group =  self.selectedGroup {
                post.group_id = group.object_id
            }
            post.tagged_users = self.selectedFriends
            if let image = post.image {
                post.post_type = "photo"
            } else {
                post.post_type = "text"
            }
            post.file_url = "standby"
            postAndDismissBackToRoot()
  
        }
    }
    
    //MARK: - SegmentControl Delegate
    
    func segmentControlDidChange() {
        self.tableView.reloadData()
        
    }
    

    
    // MARK: - Navigation
    func postAndDismissBackToRoot() {
        let vc: MainViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        if let post = self.post {
            
            if let group =  self.selectedGroup {
                post.group_id = group.object_id
            }
            post.tagged_users = self.selectedFriends
            if let image = post.image {
                post.post_type = "photo"
            } else {
                post.post_type = "text"
            }
            post.file_url = "standby"
            post.user_name = "Me"
            vc.standbyPost = post
            self.modalPresentationStyle = .Custom
            self.modalTransitionStyle = .CrossDissolve
            self.presentViewController(vc, animated: true) { () -> Void in
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    
                    ServerRequest.sharedManager.createPost(post, completion: { (finished) -> Void in
                    })
                    dispatch_async(dispatch_get_main_queue()) {
                        // update some UI
                        // self.canLoadPosts = true
                    }
                }
            }
        }
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
