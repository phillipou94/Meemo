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
    let viewModel = GroupsViewModel()
    var group:Group? = nil
    var posts:[Post] = []
    
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
        self.viewModel.getPostsFromGroup(self.group!, completion: { (result) -> Void in
            self.posts = result
            self.tableView.reloadData()
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
            cell.configureCell()
            return cell
            
        }

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
