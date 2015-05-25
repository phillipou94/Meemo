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
    func showAlbum()
}

class CameraViewController: UIImagePickerController{
    
    var menuBar = UIView()
    var bottomView = UIView()
    var topBar = UIView()
    var flashButton = UIButton()
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
        self.cameraFlashMode = .Auto
        
        configureButtons()

        // Do any additional setup after loading the view.
    }

    func configureButtons() {
        let exitButton = UIButton(frame: CGRectMake(5,5,20,20))
        exitButton.setBackgroundImage(UIImage(named: "X-Button@1x"), forState: .Normal)
        exitButton.addTarget(self, action: "exitPressed", forControlEvents: .TouchUpInside)
        topBar.addSubview(exitButton)
        
        let cameraButton = UIButton(frame:CGRectMake(bottomView.frame.size.width/2-50,self.view.frame.size.height-150,100,100))
        cameraButton.backgroundColor = UIColor.blackColor()
        cameraButton.setBackgroundImage(UIImage(named: "CameraButton"), forState: .Normal)
        cameraButton.addTarget(self, action: "takePhoto", forControlEvents: .TouchUpInside)
        self.cameraOverlayView!.addSubview(cameraButton)
        self.cameraOverlayView!.bringSubviewToFront(cameraButton)
        
        let albumButton = UIButton(frame:CGRectMake(50, self.view.frame.size.height-125, 50, 50))
        albumButton.setBackgroundImage(UIImage(named: "Album2"), forState: .Normal) /*PhotoIcon*/
        albumButton.addTarget(self, action: "showAlbum", forControlEvents: .TouchUpInside)
        self.cameraOverlayView!.addSubview(albumButton)
        
        let selfieButton = UIButton(frame:CGRectMake(self.view.frame.size.width - 100,self.view.frame.size.height-125,68,50))
        selfieButton.setBackgroundImage(UIImage(named: "Selfie"), forState: .Normal)
        selfieButton.addTarget(self, action: "toggleSelfie", forControlEvents: .TouchUpInside)
        self.cameraOverlayView!.addSubview(selfieButton)
        self.cameraOverlayView!.bringSubviewToFront(selfieButton)

    
        flashButton = UIButton(frame:CGRectMake(self.topBar.frame.size.width-45,self.topBar.frame.size.height/2 - 15,30,30))
        flashButton.setBackgroundImage(UIImage(named: "AutoFlash"), forState: .Normal)
        flashButton.imageView?.contentMode = .ScaleAspectFill
        flashButton.addTarget(self, action: "toggleFlash", forControlEvents: .TouchUpInside)
        topBar.addSubview(flashButton)

    }
    
    func takePhoto() {
        self.takePicture()
    }
    
    
    func exitPressed() {
        
        self.viewDelegate?.exitCamera()
        //self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showAlbum() {
        self.viewDelegate?.showAlbum()
    }
    
    func toggleSelfie() {
        if self.cameraDevice == .Front {
            self.cameraDevice = .Rear
        } else {
            self.cameraDevice = .Front
        }
    }
    
    func toggleFlash() {
        if self.cameraFlashMode == .Auto {
            self.cameraFlashMode = .Off
            flashButton.setBackgroundImage(UIImage(named: "NoFlash"), forState: .Normal)
            println("here 1")
        } else if self.cameraFlashMode == .Off {
            self.cameraFlashMode = .On
            flashButton.setBackgroundImage(UIImage(named: "Flash"), forState: .Normal)
            println("here 2")
        } else {
            self.cameraFlashMode = .Auto
            flashButton.setBackgroundImage(UIImage(named: "AutoFlash"), forState: .Normal)
            println("here 3")
        }
        
    }
    
    //MARK: - Location 


    
}
