//
//  LinkFacebookViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/18/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class LinkFacebookViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var linkFacebookButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpFacebookButton()
    }
    
    func setUpFacebookButton() {
        let loginView : FBSDKLoginButton = FBSDKLoginButton()

        self.view.addSubview(loginView)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.sizeToFit()
        loginView.frame = self.linkFacebookButton.frame
        loginView.delegate = self
        
        for loginObject in loginView.subviews {
            
            if loginObject.isKindOfClass(UILabel) {
                var label = loginObject as! UILabel
                label.font = UIFont(name: "STHeitiSC-Medium", size: 20)
                label.text = "Yes"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func noPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
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
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
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
