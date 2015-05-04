//
//  PickFriendsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/2/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PickFriendsViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var tableView: UITableView!
    var collectionView: UICollectionView? = nil
    var allFriends:[String:[User]] = [:]
    var selectedFriends: [User] = []
    var group:Group? = nil
    let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z", "#"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName:"FriendsCell",bundle:nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendsCell")
        loadFriends()
        setUpCollectionView()

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
    
    //MARK: - TableView
    
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
        self.collectionView!.reloadData()
        if selectedFriends.count == 1 {
            animateCollectionView(true)
        } else if selectedFriends.count == 0 {
            animateCollectionView(false)
        }
        
    }
    
    //MARK: - Collectionview
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSizeMake(50, 50)
        layout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15)
        
        self.collectionView = UICollectionView(frame: CGRectMake(0,self.view.frame.size.height,self.view.bounds.size.width,60), collectionViewLayout: layout)
        if let collectionView = self.collectionView {
            collectionView.backgroundColor = UIColor(red: 62/255.0, green: 61/255.0, blue: 83/255.0, alpha: 1.0)
            self.view.addSubview(collectionView)
            collectionView.delegate = self
            collectionView.dataSource = self
            
            let nib = UINib(nibName: "FriendsPreviewCell", bundle: nil)
            collectionView.registerNib(nib, forCellWithReuseIdentifier: "FriendsPreviewCell")
            collectionView.bounces = true
            collectionView.alwaysBounceHorizontal = true
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectedFriends.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let user = self.selectedFriends[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FriendsPreviewCell", forIndexPath: indexPath) as! FriendsPreviewCell
        cell.user = user
        cell.configureCell()
        return cell
        
    }
    
    func animateCollectionView(show:Bool) {
        if let collectionView = self.collectionView {
            if show {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    collectionView.frame.origin = CGPointMake(0,self.view.frame.size.height - 60)
                    
                })
            } else {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    collectionView.frame.origin = CGPointMake(0,self.view.frame.size.height)
                })
            }

        }
    }
    

    @IBAction func backPressed(sender: AnyObject) {
    }
    @IBAction func checkPressed(sender: AnyObject) {
        let group = Group()
        if  let currentUser = CoreDataRequest.sharedManager.getUserCredentials() {
            group.user_ids = [currentUser.object_id]
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
