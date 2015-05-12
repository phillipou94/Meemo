//
//  LoginViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Parse
import Spring

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate{

    @IBOutlet var facebookFrame: UIButton!
    @IBOutlet weak var meemoLabel: SpringLabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: SpringView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitleLabel()
        setUpTextFields()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(tap)
        

    
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setUpFacebookButton()
    }
    
    func setUpFacebookButton() {
        let loginView : FBSDKLoginButton = FBSDKLoginButton()
        loginView.frame = self.facebookFrame.frame
        self.view.addSubview(loginView)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpTitleLabel() {
        var attributedString: NSMutableAttributedString = self.meemoLabel.attributedText as! NSMutableAttributedString
        let spacing = 9.0
        
        attributedString.addAttribute(NSKernAttributeName, value: spacing, range: NSMakeRange(0, attributedString.length))
        self.meemoLabel.attributedText = attributedString

    }
    

    
    @IBAction func signInPressed(sender: AnyObject) {
        ServerRequest.sharedManager.loginUser(self.emailTextField.text, password: self.passwordTextField.text) { (wasSuccessful) -> Void in
            if wasSuccessful {
                self.launchApplication()
            } else {
                self.errorMessage.hidden = false
                self.errorMessage.animation = "slideDown"
                self.errorMessage.animate()
            }
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if error == nil {
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                let userName : NSString = result.valueForKey("name") as! NSString
                let userEmail : NSString = result.valueForKey("email") as! NSString
                let facebook_id: NSString = result.valueForKey("id") as! NSString
                
                var user = User()
                user.name = userName as String
                user.email = userEmail as String
                user.facebook_id = facebook_id as String
                ServerRequest.sharedManager.signInWithFacebook(user, success: { (successful) -> Void in
                    if successful {
                        self.launchApplication()
                    }
                })
                
            })

        }
        
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
   
    @IBAction func facebookLoginPressed(sender: AnyObject) {
        
        let permissions = [ "public_profile", "email" , "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user, error) -> Void in
            if let user = user {
                
                
                
            } else {
                println("Uh oh. The user cancelled the Facebook login.")
            }

        })
    
        
    }
    
    func launchApplication() {
        let vc: GroupsViewController = self.storyboard?.instantiateViewControllerWithIdentifier("GroupsViewController") as! GroupsViewController
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        
        
    }
    
    // MARK: - TextField
    
    func setUpTextFields() {
        let color = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:color])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:color])
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
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
