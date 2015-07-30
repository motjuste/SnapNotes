//
//  CameraViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    var captureFeedbackView: UIView?
    var doubleArrowImageView: UIImageView!
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var previewLayerBoundsSet = false
    var cameraAuthorized = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.backgroundColor = UIColor.blackColor()
        
        captureFeedbackView = UIView()
        captureFeedbackView!.frame = cameraView.frame
        captureFeedbackView!.backgroundColor = UIColor.whiteColor()
        captureFeedbackView!.alpha = 0
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.cameraAuthorized = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == AVAuthorizationStatus.Authorized
        authorizeCamera()
        
        captureFeedbackView!.alpha = 0
            
            // Setup and/or start camera view
            
            if captureSession != nil {
                startCamera()
            } else {
                captureSession = AVCaptureSession()
                captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
                
                var backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                
                var error: NSError?
                var input = AVCaptureDeviceInput(device: backCamera, error: &error)
                
                if error == nil && captureSession!.canAddInput(input) {
                    captureSession!.addInput(input)
                    
                    stillImageOutput = AVCaptureStillImageOutput()
                    stillImageOutput!.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                    if captureSession!.canAddOutput(stillImageOutput) {
                        captureSession!.addOutput(stillImageOutput)
                        
                        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                        previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
                        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
                        cameraView.layer.addSublayer(previewLayer)
                        cameraView.addSubview(captureFeedbackView!)
                        
                        doubleArrowImageView = UIImageView(frame: CGRectMake(0.0, (cameraView.frame.height - cameraView.frame.width/2.0), cameraView.frame.width/4.0, cameraView.frame.width/4.0))
                        let doubleArrowImage = UIImage(named: "dragUpIcon.png")
                        doubleArrowImageView.image = doubleArrowImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                        doubleArrowImageView!.alpha = 0
                        
                        cameraView.addSubview(doubleArrowImageView)
                        
                        startCamera()
                    }
                } else if (error != nil) {
                    println("Error in AVCaptureDeviceInput")
                }
            }
        
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !previewLayerBoundsSet && cameraAuthorized {
            
            // set frame of preview layer only once
            previewLayer!.frame = cameraView.bounds
            previewLayerBoundsSet = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if cameraAuthorized { stopCamera() }
    }
    
    func authorizeCamera() {
        if (!cameraAuthorized) {
            let alertController = UIAlertController(
                title: "Could not access camera!",
                message: "This application does not have permission to use camera. Please update your privacy settings.",
                preferredStyle: .Alert)
            let okayAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
            alertController.addAction(okayAction)
            self.parentViewController!.presentViewController(alertController, animated: true, completion: nil)
        }
	}

    
    // MARK: - Camera Start/Stop
    func startCamera() {
        if cameraAuthorized {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            self.captureSession?.startRunning()
        })}
    }
    
    func stopCamera() {
        if cameraAuthorized {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            self.captureSession?.stopRunning()
        })}
    }
    
    // MARK: - Save Image
    
    func saveImageForCategoryID(categoryID: String, positionIndex: Int) {
        if cameraAuthorized {
        if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            self.captureFeedbackView!.alpha = 1
            self.doubleArrowImageView!.frame.origin.y = (cameraView.frame.height - cameraView.frame.width/2.0)
            self.doubleArrowImageView!.frame.origin.x = cameraView.frame.width/4.0 * CGFloat(positionIndex)
            self.doubleArrowImageView!.tintColor = SnapNotesManager.getCategoryByID(categoryID).color
            self.doubleArrowImageView!.alpha = 1
            
            UIView.animateWithDuration(0.70, animations: {
                self.captureFeedbackView!.alpha = 0
            })
            
            UIView.animateWithDuration(0.50, animations: {
                self.doubleArrowImageView!.alpha = 0
                self.doubleArrowImageView!.frame.origin.y -= 40.0
            } , completion: nil)
            
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer: CMSampleBuffer!, error) in
                    if (sampleBuffer != nil) {
                        SnapNotesManager.saveDataForCategoryID(sampleBuffer, categoryID: categoryID)
                }
            })
            
        }
        } else {
            authorizeCamera()
        }
    }

}
