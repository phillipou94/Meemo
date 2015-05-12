//
//  SignUpViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class SignUpViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    
    @IBOutlet var errorBanner: SpringView!
    @IBOutlet var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        loginView.frame = self.facebookButton.frame
        self.view.addSubview(loginView)
        loginView.readPermissions = ["public_profile", "email", "user_friends"]
        loginView.delegate = self
    }
    
    func setUpTextFields() {
        let color = UIColor.whiteColor().colorWithAlphaComponent(0.6)
        self.emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSForegroundColorAttributeName:color])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSForegroundColorAttributeName:color])
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName:color])
        self.confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSForegroundColorAttributeName:color])
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        self.nameTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.emailTextField.becomeFirstResponder()
        } else if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField{
            self.confirmPasswordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        if(self.passwordTextField.text != self.confirmPasswordTextField.text) {
            animateWarningWithMessage("Passwords Do Not Match")
            
        } else if self.passwordTextField.text.length == 0 || self.nameTextField.text.length == 0 || self.emailTextField.text.length == 0 {
            animateWarningWithMessage("Not All Fields Have Been Filled Out")
        } else if (self.passwordTextField.text.length < 6) {
            animateWarningWithMessage("Password Must Be At Least 6 Characters Long")
        }
        else {
           /* ServerRequest.sharedManager.signupUser(self.nameTextField.text, email: self.emailTextField.text, password: self.passwordTextField.text, success: { (wasSuccessful) -> Void in
                if wasSuccessful {*/
                    let phoneSearchController = PhoneSearchViewController(nibName: "PhoneSearchViewController", bundle: nil) as PhoneSearchViewController
                    self.presentViewController(phoneSearchController, animated: true, completion: nil)
    /*
                } else {
                    self.animateWarningWithMessage("This Email Has Already Been Taken")
                }
            })*/
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
                        let phoneSearchController = PhoneSearchViewController(nibName: "PhoneSearchViewController", bundle: nil) as PhoneSearchViewController
                        self.presentViewController(phoneSearchController, animated: true, completion: nil)

                    }
                })
                
            })
            
        }
        
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        println("User Logged Out")
    }
    
    
    func animateWarningWithMessage(message:String) {
        self.errorMessage.text = message
        self.errorBanner.hidden = false
        self.errorBanner.animation = "slideDown"
        self.errorBanner.animate()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    @IBAction func dismissPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
