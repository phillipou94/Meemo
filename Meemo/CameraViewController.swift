//
//  CameraViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/27/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit

protocol CameraViewControllerDelegate {
    func exitCamera()
}

class CameraViewController: UIImagePickerController{
    
    var menuBar = UIView()
    var bottomView = UIView()
    var topBar = UIView()
    var sourceViewController: UIViewController? = nil
    var viewDelegate:CameraViewControllerDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .CurrentContext
        self.sourceType = .Camera
        self.showsCameraControls = false
        self.navigationBarHidden = true
        self.cameraCaptureMode = .Photo
        
        topBar = UIView(frame: CGRectMake(0,0,self.view.frame.size.width,40))
        topBar.backgroundColor=UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        bottomView = UIView(frame:CGRectMake(0,self.view.frame.size.width+80,self.view.frame.size.width,self.view.frame.size.width-80))
        bottomView.backgroundColor = UIColor.blackColor()
        
        menuBar = UIView(frame:CGRectMake(0,40+self.view.frame.size.width,self.view.frame.size.width,40))
        menuBar.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.65)
        self.cameraOverlayView?.addSubview(topBar)
        self.cameraOverlayView?.addSubview(bottomView)
        self.cameraOverlayView?.addSubview(menuBar)
        
        configureButtons()

        // Do any additional setup after loading the view.
    }

    func configureButtons() {
        let exitButton = UIButton(frame: CGRectMake(5,5,20,20))
        exitButton.setBackgroundImage(UIImage(named: "X-Button@1x"), forState: .Normal)
        exitButton.addTarget(self, action: "exitPressed", forControlEvents: .TouchUpInside)
        
        
        let cameraButton = UIButton(frame:CGRectMake(bottomView.frame.size.width/2-50,self.view.frame.size.height-150,100,100))
        cameraButton.backgroundColor = UIColor.blackColor()
        cameraButton.setBackgroundImage(UIImage(named: "CameraButton"), forState: .Normal)
        cameraButton.addTarget(self, action: "takePhoto", forControlEvents: .TouchUpInside)
        
        let albumButton = UIButton(frame:CGRectMake(50, self.view.frame.size.height-125, 50, 50))
        albumButton.backgroundColor = UIColor.whiteColor()
        albumButton.addTarget(self, action: "showAlbum", forControlEvents: .TouchUpInside)
        topBar.addSubview(exitButton)
        self.cameraOverlayView!.addSubview(cameraButton)
        self.cameraOverlayView!.bringSubviewToFront(cameraButton)
        self.cameraOverlayView!.addSubview(albumButton)
        
    }
    
    func takePhoto() {
        
        self.takePicture()
       // self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func exitPressed() {
        
        self.viewDelegate?.exitCamera()
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlbum() {
        let viewController = PhotoAlbumViewController(nibName: "PhotoAlbumViewController", bundle: nil)
        self.presentViewController(viewController, animated: true, completion: nil)
    }
    
    //MARK: - Location 


    
}
