//
//  SettingsController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class SettingsController: UITableViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var numberOfMemoriesLabel: UILabel!
    @IBOutlet weak var numberOfGroupsLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = CoreDataRequest.sharedManager.getUserCredentials()?.name
        ServerRequest.sharedManager.getCurrentUser { (user) -> Void in
            
            if let email = user.email {
                self.emailLabel.text = email
            }
            
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpFacebookButtons()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 2 {
            if row == 0 {
                let vc = LinkFacebookViewController(nibName: "LinkFacebookViewController", bundle: nil)
                self.presentViewController(vc, animated: true, completion: nil)
            }
            if row == 1 {
                logout()
            }
        }
    }
    
    //MARK:- FACEBOOK BUTTON DELEGATE
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                let userName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                if let facebook_id: NSString = result.valueForKey("id") as? NSString {
                    CoreDataRequest.sharedManager.updateFacebookID(facebook_id as String)
                }
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                
            })
            
        }
        
    }
    
    
    //logs out of facebook and then calls app logout method
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
       logout()
    }
    
    func logout() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(vc, animated: true) { () -> Void in
            ServerRequest.sharedManager.logout({ () -> Void in
                
            })
        }
    }

    
    func setUpFacebookButtons() {
        if CoreDataRequest.sharedManager.getUserCredentials()?.facebook_id != nil {
            let loginView : FBSDKLoginButton = FBSDKLoginButton()
            loginView.readPermissions = ["public_profile", "email", "user_friends"]
            loginView.sizeToFit()
            loginView.frame = self.logoutCell.frame
            loginView.delegate = self
            self.view.addSubview(loginView)
        }
    }


    
}
