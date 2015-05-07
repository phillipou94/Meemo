//
//  CaptureMemoryViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 5/7/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class CaptureMemoryViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var firstTime:Bool = true
     var cameraViewController = CameraViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (firstTime) {
            showCamera()
            firstTime = false
        }
    }
    
    func showCamera() {
        
        cameraViewController.delegate = self
        self.modalPresentationStyle = .Custom
        self.modalTransitionStyle = .CrossDissolve
        self.presentViewController(cameraViewController, animated: false, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.view.backgroundColor = UIColor(red: 63/255.0, green: 61/255.0, blue: 82/255.0, alpha: 1.0)
        cameraViewController.dismissViewControllerAnimated(true, completion: nil)
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
