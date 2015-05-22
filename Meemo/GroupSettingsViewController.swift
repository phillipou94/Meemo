//
//  GroupSettingsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/22/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var group:Group? = nil
    let viewModel = GroupsViewModel()
    var members: [User] = []
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "FriendsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendsCell")
        if let group = self.group {
            self.groupNameLabel.text = group.name
            self.viewModel.getMembers(group, completion: { (members) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return members.count
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 280
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.headerView = NSBundle.mainBundle().loadNibNamed("GroupSettingsHeader", owner: self, options: nil).first as! UIView
        if let image = self.group?.image {
            self.groupImageView.image = image
        }
        return self.headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsCell
        return cell
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
