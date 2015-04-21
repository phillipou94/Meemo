//
//  SignUpViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/20/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import Spring

class SignUpViewController: UIViewController, UITextFieldDelegate {

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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if(true) {
            self.errorBanner.hidden = false
            self.errorBanner.animation = "slideDown"
            self.errorBanner.animate()
        }

        
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
