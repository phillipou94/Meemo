//
//  GroupSettingsViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/22/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Photos

class GroupSettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,  UICollectionViewDelegate, UICollectionViewDataSource {
    var group:Group? = nil
    let viewModel = GroupsViewModel()
    var members: [User] = []
    var albumViewController = PhotoAlbumViewController()
    var images:PHFetchResult = PHFetchResult()
    var collectionViewContainer =  UIView()
    var selectedIndex = -1
    
    var bottomState:CGFloat = CGFloat()
    var middleState:CGFloat = CGFloat()
    var topState:CGFloat = CGFloat()
    var currentState:CGFloat = CGFloat()
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupImageView: UIImageView!
    
    @IBOutlet weak var membersCountLabel: UILabel!
    @IBOutlet weak var memoriesCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        let nib = UINib(nibName: "FriendsCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "FriendsCell")
        fetchPhotos()
        if let group = self.group {
            self.groupNameLabel.text = group.name
            self.viewModel.getMembers(group, completion: { (members) -> Void in
                self.tableView.reloadData()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpCollectionView()
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
        if let memories = self.group?.number_of_memories {
            self.memoriesCountLabel.text = "\(memories)"
        }
        self.membersCountLabel.text = "\(members.count)"
        return self.headerView
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendsCell") as! FriendsCell
        return cell
    }

    @IBAction func cameraPressed(sender: AnyObject) {
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.currentState = self.middleState
        self.collectionViewContainer.frame = CGRectMake(0,self.middleState,self.view.frame.size.width,self.view.frame.size.height - 40)
      })
    }
    
    //MARK: - CollectionView
    
    func setUpCollectionView() {
        
        bottomState = self.view.frame.height
        topState = 90
        middleState = CGRectGetMaxY(self.groupImageView.frame) + 40
        currentState = bottomState
        
        self.collectionViewContainer.frame = CGRectMake(0,bottomState,self.view.frame.size.width,self.view.frame.size.height - 40)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
        let frame = CGRectMake(0, 40, self.view.frame.size.width, self.collectionViewContainer.frame.size.height)
        var collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.registerNib(UINib(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: "PhotoCell")
        
        self.collectionViewContainer.addSubview(collectionView)
        self.collectionViewContainer.backgroundColor = UIColor(white: 0, alpha: 0.6)
        let pan = UIPanGestureRecognizer(target: self, action: "draggedCollectionView:")
        self.collectionViewContainer.addGestureRecognizer(pan)
        collectionView.alwaysBounceVertical = true
        
        self.view.addSubview(self.collectionViewContainer)
        self.collectionViewContainer.bringSubviewToFront(collectionView)
        

    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.images.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = self.view.frame.size.width/3 - 8
        return CGSize(width: width, height: width)
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 1, 1, 1)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        if (indexPath.row == 0) {
            let camera = UIImage(named: "camera_L")
            cell.imageView.hidden = true
            cell.accessoryView.image = camera
            cell.accessoryView.hidden = false
            cell.imageView.backgroundColor = UIColor.redColor()
        } else{
            let asset = self.images[indexPath.row-1] as! PHAsset
            loadThumbnailFrom(asset, completionHandler: { (image) -> Void in
                let thumbnail: UIImage = image as UIImage
                cell.imageView.image = thumbnail
                cell.imageView.hidden = false
                cell.accessoryView.hidden = true
            })
            let checkmark = UIImage(named:"Checkmark")
            cell.accessoryView.image = checkmark
            if indexPath.row != selectedIndex {
                cell.accessoryView.hidden = true
            } else {
                cell.accessoryView.hidden = false
            }
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
            self.selectedIndex = indexPath.row
            let asset = self.images[indexPath.row-1] as! PHAsset
            loadImageFrom(asset, completionHandler: { (image) -> Void in
                self.groupImageView.image = image
                collectionView.reloadData()
            })
        } else {
            
        }
        
    }
    
    //MARK: - Animate CollectionView
    
    func draggedCollectionView(recognizer:UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(self.view)
        self.collectionViewContainer.center = CGPoint(x:self.collectionViewContainer.center.x,
            y:self.collectionViewContainer.center.y + translation.y)
        
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            let closestPosition = roundToNearestState(self.collectionViewContainer.frame.origin.y)
            animateCollectionView(closestPosition, delay: 0.0)
        }
        
    }
    
    func animateCollectionView(state:CGFloat, delay: NSTimeInterval) {
        
        UIView.animateWithDuration(0.6, delay: delay, options: nil, animations: { () -> Void in
            self.collectionViewContainer.frame = CGRectMake(0,state,self.view.frame.size.width, self.view.frame.size.height)
            }) { (completed) -> Void in
                
        }
        
        
    }
    
    func roundToNearestState(y:CGFloat) -> CGFloat {
        
        if y > self.view.frame.size.height*0.6 {
            currentState = bottomState
        } else if y < self.view.frame.size.height*0.25 {
            currentState = topState
        } else {
            currentState = middleState
        }
        
        return currentState
    }
    
    
    
    
    //MARK: - ALAssets
    
    func fetchPhotos () {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        // Sort the images by creation date
        var fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        
        if let fetchResult = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Image, options: fetchOptions) {
            self.images = fetchResult
            
            
        }
        
    }
    
    
    func loadImageFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(CGFloat(asset.pixelHeight),CGFloat(asset.pixelWidth)),
            contentMode: PHImageContentMode.AspectFit,
            options: requestOptions,
            resultHandler: { (image, _) in
                
                completionHandler(image:image)
        })
    }
    
    func loadThumbnailFrom(asset:PHAsset,completionHandler:(image:UIImage) -> Void) {
        let imgManager = PHImageManager.defaultManager()
        var requestOptions = PHImageRequestOptions()
        requestOptions.synchronous = true
        
        imgManager.requestImageForAsset(asset,
            targetSize: CGSizeMake(200.0,200.0),
            contentMode: PHImageContentMode.AspectFit,
            options: requestOptions,
            resultHandler: { (image, _) in
                
                completionHandler(image:image)
        })
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
