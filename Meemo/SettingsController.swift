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
    
    let transitionManager = TransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameLabel.text = CoreDataRequest.sharedManager.getUserCredentials()?.name
        ServerRequest.sharedManager.getCurrentUser { (user) -> Void in
            
            if let email = user.email {
                self.emailLabel.text = email
            }
            if let posts = user.number_of_posts {
                self.numberOfMemoriesLabel.text = "\(posts)"
            }
            if let groups = user.number_of_groups {
                self.numberOfGroupsLabel.text = "\(groups)"
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
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerTitle = ""
        if section == 0 {
            headerTitle = "My Account"
        } else if section == 1 {
            headerTitle = "More Information"
        } else {
            headerTitle = "Account Actions"
        }
        
        let header = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        header.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        let label = UILabel(frame: CGRectMake(18, 0, self.view.frame.size.width-18, 40))
        label.font = UIFont(name: "STHeitiSC-Medium", size: 13)
        label.textColor = UIColor(hex: "3F3D52")
        label.text = headerTitle
        header.addSubview(label)
        return header
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTerms" || segue.identifier == "showPrivacy" {
            let vc = segue.destinationViewController as! UIViewController
            vc.transitioningDelegate = self.transitionManager
        }
    }


    
}
