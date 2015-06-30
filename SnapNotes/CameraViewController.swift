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
                    
                    captureSession!.startRunning()
                }
            } else if (error != nil) {
                println("Error in AVCaptureDeviceInput")
            }
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = cameraView.bounds
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.captureSession!.stopRunning()
    }
    
    func getImageDataToSave() -> NSData? {
        var imageData: NSData?
        
        if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer: CMSampleBuffer!, error) in
//                if (sampleBuffer != nil) {
                    imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
//                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
//                    
//                    image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
//                } else {
//                    println(error)
//                }
            })
            
        }
        return imageData
    }
    
    func saveImageForCategoryID(categoryID: String) {
        if let videoConnection = self.stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer: CMSampleBuffer!, error) in
                    if (sampleBuffer != nil) {
                        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                        SnapNotesManager.saveDataForCategoryID(imageData, categoryID: categoryID, extensionString: "jpg")
                }
            })
            
        }

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
