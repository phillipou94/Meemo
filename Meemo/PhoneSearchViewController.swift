//
//  PhoneSearchViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/1/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PhoneSearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var backSpaceButton: UIButton!
    var phoneNumber = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneTextField.delegate = self;
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func backSpacePressed(sender: AnyObject) {
        if phoneNumber.length > 0 {
            let lastIndex = phoneNumber.length - 1
            phoneNumber = phoneNumber.substringToIndex(advance(phoneNumber.startIndex, lastIndex))
            phoneTextField.text = phoneNumber
        }
        
    }

    @IBAction func onePressed(sender: AnyObject) {
        formatPhoneString("1")
    }

    @IBAction func twoPressed(sender: AnyObject) {
        formatPhoneString("2")
    }
    
    @IBAction func threePressed(sender: AnyObject) {
        formatPhoneString("3")
    }
    @IBAction func fourPressed(sender: AnyObject) {
        formatPhoneString("4")
    }
    
    @IBAction func fivePressed(sender: AnyObject) {
        formatPhoneString("5")
    }
    
    @IBAction func sixPressed(sender: AnyObject) {
        formatPhoneString("6")
    }
    
    @IBAction func sevenPressed(sender: AnyObject) {
        formatPhoneString("7")
    }
    
    @IBAction func eightPressed(sender: AnyObject) {
        formatPhoneString("8")
    }
    
    @IBAction func ninePressed(sender: AnyObject) {
        formatPhoneString("9")
    }
    
    @IBAction func zeroPressed(sender: AnyObject) {
        formatPhoneString("0")
    }
    
    func formatPhoneString(number:String) {
        if phoneNumber.length < 14 {
            if phoneNumber.length == 0 {
                phoneNumber += "("
            }
            phoneNumber += number
            if phoneNumber.length == 4 {
                phoneNumber += ") "
            }
            if phoneNumber.length == 9 {
                phoneNumber += "-"
            }
            
            phoneTextField.text = phoneNumber
        }
        
        
    }
    
    @IBAction func skipPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func donePressed(sender: AnyObject) {
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
