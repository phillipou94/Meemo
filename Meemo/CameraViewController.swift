//
//  CameraViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/27/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

class CameraViewController: UIImagePickerController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modalPresentationStyle = .CurrentContext
        self.sourceType = .Camera
        self.showsCameraControls = false
        self.navigationBarHidden = true
        self.allowsEditing = true
        self.cameraCaptureMode = .Photo
        
        let topBar = UIView(frame: CGRectMake(0,0,self.view.frame.size.width,40))
        topBar.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        let bottomView = UIView(frame:CGRectMake(0,self.view.frame.size.width+40,self.view.frame.size.width,self.view.frame.size.width-40))
        bottomView.backgroundColor = UIColor.blackColor()
        
        let menuBar = UIView(frame:CGRectMake(0,40,self.view.frame.size.width,40))
        menuBar.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
        
        self.cameraOverlayView?.addSubview(topBar)
        self.cameraOverlayView?.addSubview(bottomView)
        bottomView.addSubview(menuBar)
        
        let pictureFrame = CGRectMake(0,40,self.view.frame.size.width,self.view.frame.size.width)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
