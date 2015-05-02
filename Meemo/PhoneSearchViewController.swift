//
//  PhoneSearchViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/1/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class PhoneSearchViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var numberContainer: UIView!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var backSpaceButton: UIButton!
    var phoneNumber = ""

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phoneTextField.delegate = self;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpButtons()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return false
    }
    
    
    func setUpButtons() {
        let screenRect = UIScreen.mainScreen().bounds
        let buttonWidth = screenRect.size.width/3
        let buttonHeight = self.numberContainer.bounds.size.height/4
        var number = 1
        for (var y = 0; y < 4; y++) {
            for (var x = 0; x < 3; x++) {
                let frame = CGRectMake(CGFloat(x)*buttonWidth,CGFloat(y)*buttonHeight,buttonWidth,buttonHeight)
                let button = UIButton(frame: frame)
                button.setTitle("\(number)", forState: UIControlState.Normal)
               
                button.titleLabel!.font =  UIFont(name:"STHeitiSC-Medium", size: 30)
                switch number {
                    case 1:
                        button.addTarget(self, action: "onePressed:", forControlEvents: .TouchUpInside)
                    case 2:
                        button.addTarget(self, action: "twoPressed:", forControlEvents: .TouchUpInside)
                    case 2:
                        button.addTarget(self, action: "twoPressed:", forControlEvents: .TouchUpInside)
                    case 3:
                        button.addTarget(self, action: "threePressed:", forControlEvents: .TouchUpInside)
                    case 4:
                        button.addTarget(self, action: "fourPressed:", forControlEvents: .TouchUpInside)
                    case 5:
                        button.addTarget(self, action: "fivePressed:", forControlEvents: .TouchUpInside)
                    case 6:
                        button.addTarget(self, action: "sixPressed:", forControlEvents: .TouchUpInside)
                    case 7:
                        button.addTarget(self, action: "sevenPressed:", forControlEvents: .TouchUpInside)
                    case 8:
                        button.addTarget(self, action: "eightPressed:", forControlEvents: .TouchUpInside)
                    case 9:
                        button.addTarget(self, action: "ninePressed:", forControlEvents: .TouchUpInside)
                    case 10:
                        button.setTitle("#", forState: UIControlState.Normal)
                    case 11:
                        button.setTitle("0", forState: UIControlState.Normal)
                        button.addTarget(self, action: "zeroPressed:", forControlEvents: .TouchUpInside)
                    default:
                        button.setTitle("del", forState: UIControlState.Normal)
                        button.addTarget(self, action: "backSpacePressed:", forControlEvents: .TouchUpInside)
                }
                
                
                
                number += 1
                self.numberContainer.addSubview(button)
                
                let float = CGFloat(x)
                println("\(float*buttonWidth)")
                
            }
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
        
        launchApplication()
    }
    
    
    @IBAction func donePressed(sender: AnyObject) {
        var number = self.phoneTextField.text
        number = number.stringByReplacingOccurrencesOfString(" ", withString: "", options: nil)
        number = number.stringByReplacingOccurrencesOfString("-", withString: "", options: nil)
        number = number.stringByReplacingOccurrencesOfString("(", withString: "", options: nil)
        number = number.stringByReplacingOccurrencesOfString(")", withString: "", options: nil)
        
        ServerRequest.sharedManager.getGroupsWithPhoneNumber(number, success: { (wasSuccessful) -> Void in
            //
        })
        
        launchApplication()
    }
    
    
    func launchApplication() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: GroupsViewController = storyboard.instantiateViewControllerWithIdentifier("GroupsViewController") as! GroupsViewController
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(vc, animated: true, completion:nil)
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
