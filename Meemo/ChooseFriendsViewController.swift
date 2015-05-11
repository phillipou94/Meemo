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
    var viewModel = GroupsViewModel()
    var allFriends : [String:[User]] = [:]
    var groups: [Group] = []
    var selectedFriends: [User] = []
    var selectedGroups: [Group] = []
    var post:Post? = nil
    var alertViewTextField:UITextField? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.segmentController.items = ["Groups","Friends"]
        self.segmentController.delegate = self
        
        setUpTableView()
        self.viewModel.getGroups { (groups) -> Void in
            self.groups = groups
            self.viewModel.getAllFriends { (friends) -> Void in
                self.allFriends = friends
                
            }
            
            self.tableView.reloadData()
        }
        

        // Do any additional setup after loading the view.
    }


    //MARK: - TableView
    
    func setUpTableView() {
        let groupNib = UINib(nibName: "GroupTableViewCell", bundle: nil)
        let friendNib = UINib(nibName: "FriendsCell", bundle: nil)
        self.tableView.registerNib(groupNib, forCellReuseIdentifier: "GroupTableViewCell")
        self.tableView.registerNib(friendNib, forCellReuseIdentifier: "FriendsCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.segmentController.selectedIndex == 0 {
            return 1
        } else {
            return self.allFriends.count
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
            let cell = tableView.dequeueReusableCellWithIdentifier("GroupTableViewCell") as! GroupTableViewCell
            cell.group = group
            cell.configureCell()
            cell.dateLabel.text = self.viewModel.formatDate(group.last_updated)
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
            let group = self.groups[indexPath.row]
            if contains(selectedGroups, group) {
                if let index = find(selectedGroups, group) {
                    selectedGroups.removeAtIndex(index)
                    cell?.accessoryType = .None
                }
                
            } else {
                selectedGroups.append(group)
                cell?.accessoryType = .Checkmark
            }

            
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

    @IBAction func finishPressed(sender: AnyObject) {
        if let post = self.post {
            
            if selectedGroups.count == 0 {
                if selectedFriends.count != 0 {
                    postToNewGroup()
                } else {
                    ServerRequest.sharedManager.createPost(post)
                }
               
            } else {
                for group:Group in selectedGroups {
                    post.group_id = group.object_id
                    ServerRequest.sharedManager.createPost(post)
                }
                
            }
            
        }
        /*let vc: GroupsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GroupsViewController") as! GroupsViewController
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)*/
    }
    
    func showAlertView() {
        
        
    }
    
    func postToNewGroup() {
        let group = Group()
        group.name = "test post with new group"
        group.members = selectedFriends
        
        ServerRequest.sharedManager.createGroup(group, completion: { (json) -> Void in
            if let post = self.post {
                post.group_id = json["response"]["id"].number!
                ServerRequest.sharedManager.createPost(post)
            }
            
        })
    }
    
    //MARK: - SegmentControl Delegate
    
    func segmentControlDidChange() {
        self.tableView.reloadData()
        
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
