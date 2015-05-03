//
//  PickFriendsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/2/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PickFriendsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tableView: UITableView!
    var allFriends:[String:[User]] = [:]
    var selectedFriends: [User] = []
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName:"FriendsCell",bundle:nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendsCell")
        loadFriends()

        // Do any additional setup after loading the view.
    }
    
    func loadFriends() {
        ServerRequest.sharedManager.getAllFriends { (friendsDict) -> Void in
            self.allFriends = friendsDict
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.alphabet.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let letter = self.alphabet[section]
        if let array = allFriends[letter] {
            
            return array.count
        }
        return 0
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let letter = self.alphabet[indexPath.section]
        var user = User()
        if let array = self.allFriends[letter] {
             user = array[indexPath.row]
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell", forIndexPath: indexPath) as! FriendsCell
        cell.user = user
        cell.configureCell()
        if contains(selectedFriends, user) {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let letter = self.alphabet[indexPath.section]
        let array = self.allFriends[letter]! as [User]
        let  user = array[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if contains(selectedFriends, user) {
            if let index = find(selectedFriends, user) {
                selectedFriends.removeAtIndex(index)
                cell?.accessoryType = .None
            }
            
        } else {
            selectedFriends.append(user)
            cell?.accessoryType = .Checkmark
        }
        
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
