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
    
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var previewLayerBoundsSet = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
//        navigationController?.hidesBarsOnTap = false
//        navigationController?.navigationBarHidden = true
        
        
        if captureSession != nil {
            captureSession?.startRunning()
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
                    
                    startCamera()
                }
            } else if (error != nil) {
                println("Error in AVCaptureDeviceInput")
            }
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !previewLayerBoundsSet {
            // set frame of preview layer only once
            previewLayer!.frame = cameraView.bounds
            previewLayerBoundsSet = true
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        stopCamera()
    }
    
    
    // MARK: - Camera Start/Stop
    func startCamera() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            self.captureSession?.startRunning()
        })
    }
    
    func stopCamera() {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), {
            self.captureSession?.stopRunning()
        })
    }
    
    // MARK: - Save Image
    
    func saveImageForCategoryID(categoryID: String) {
        if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer: CMSampleBuffer!, error) in
                    if (sampleBuffer != nil) {
                        self.captureSession!.stopRunning()
                        SnapNotesManager.saveDataForCategoryID(sampleBuffer, categoryID: categoryID)
                        self.captureSession!.startRunning()
                }
            })
            
        }

    }

}
