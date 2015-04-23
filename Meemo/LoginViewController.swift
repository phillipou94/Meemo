//
//  LoginViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate{

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
   
    @IBAction func facebookLoginPressed(sender: AnyObject) {
        
        let permissions = [ "public_profile", "email" , "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions, block: { (user, error) -> Void in
            if let user = user {
                ServerRequest.sharedManager.signInWithFacebook(user)
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
