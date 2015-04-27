//
//  CameraViewController.swift
//  Meemo
//
//  Created by Phillip Ou on 4/25/15.
//  Copyright (c) 2015 Phillip Ou. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var device: AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    @IBOutlet var previewView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        previewView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)
        captureSession = AVCaptureSession()
        captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        var error: NSError?
        var input = AVCaptureDeviceInput(device: device, error: &error)
        
        if error == nil && captureSession!.canAddInput(input) {
            captureSession!.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession!.canAddOutput(stillImageOutput) {
                captureSession!.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                previewView.layer.addSublayer(previewLayer)
                
                captureSession!.startRunning()
                
            }
        }
    }


    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        previewLayer!.frame = previewView.frame
        let bounds = previewView.layer.bounds
        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill;
        previewLayer!.bounds=bounds;
        previewLayer!.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func flipCameraPressed(sender: AnyObject) {
        if let session = captureSession {
            captureSession!.beginConfiguration()
            var currentCameraInput = session.inputs[0] as! AVCaptureDeviceInput
            var newCamera:AVCaptureDevice? = nil
            if currentCameraInput.device.position == AVCaptureDevicePosition.Back {
                newCamera = cameraWithPosition(AVCaptureDevicePosition.Front)
            } else {
                cameraWithPosition(AVCaptureDevicePosition.Back)
            }
            if let newVideoInput = AVCaptureDeviceInput(device: newCamera, error: nil) {
                var error: NSError?
                var originalInput = AVCaptureDeviceInput(device: device, error: &error)
                captureSession!.removeInput(originalInput)
                captureSession!.addInput(newVideoInput)
                captureSession!.beginConfiguration()
            }
            
            
        }
        
        
        
        
        /* 
        //Change camera source
        if(_captureSession)
        {
        //Indicate that some changes will be made to the session
        [_captureSession beginConfiguration];
        
        //Remove existing input
        AVCaptureInput* currentCameraInput = [_captureSession.inputs objectAtIndex:0];
        [_captureSession removeInput:currentCameraInput];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
        }
        else
        {
        newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
        }
        
        //Add input to session
        NSError *err = nil;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&err];
        if(!newVideoInput || err)
        {
        NSLog(@"Error creating capture device input: %@", err.localizedDescription);
        }
        else
        {
        [_captureSession addInput:newVideoInput];
        }
        
        //Commit all the configuration changes at once
        [_captureSession commitConfiguration];
        }
        }
        
        // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
        - (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
        {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices)
        {
        if ([device position] == position) return device;
        }
        return nil;
        }



    */
    }
    
    func cameraWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    @IBAction func exitPressed(sender: AnyObject) {
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
