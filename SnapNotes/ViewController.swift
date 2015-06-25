//
//  ViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 09/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var categoriesList: [Categories] = []
    
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var tempLabel2: UILabel!
    
    @IBAction func viewLastPhoto(sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        println("ViewController.viewDidLoad()")
        
//        SnapNotesManager.loadSettings()
        categoriesList = SnapNotesManager.getCategories()
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBarHidden = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: CategoriesCollectionView methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoriesCell", forIndexPath: indexPath) as! CategoriesCollectionViewCell
        
        let category: Categories = categoriesList[indexPath.row]
        categoryCell.categoriesLabel.text = category.name
        categoryCell.categoryID = category.id
        
        return categoryCell
        
    }
    
    // MARK: Tapped Category + name generation testing
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        collectionView.cellForItemAtIndexPath(indexPath)?.highlighted = true
        
        let category: Categories = categoriesList[indexPath.row]
        
//        let timeInterval = NSDate().timeIntervalSince1970
        let categoryID = category.id
        
//        let tempLabelText = "\(timeInterval)_\(categoryID)"
//        
//        var date: String = ""
//        var cat: String = ""
        
//        (date, cat) = getDateFromTimeStamp(tempLabelText)
//        
//        tempLabel.text = tempLabelText
//        tempLabel2.text = date + " " + cat
        
        
        if let videoConnection = stillImageOutput!.connectionWithMediaType(AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
                    
                    var image = UIImage(CGImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    SnapNotesManager.saveDataForCategoryID(UIImageJPEGRepresentation(image, 0.75), categoryID: categoryID, extensionString: "jpg")
                    
                    // TODO: - Choose proper image quality
                }
            })
            
            
        }

        
        collectionView.cellForItemAtIndexPath(indexPath)?.highlighted = false
        
        
        return false
    }
    
    func getDateFromTimeStamp(timestamp: String) -> (date: String, category: String) {
        let timestampSplitArray: [String] = timestamp.componentsSeparatedByString("_")
        
        let timeinterval: Double = (timestampSplitArray[0] as NSString).doubleValue
        let categoryID = timestampSplitArray[1]
        
        // get Date in pretty string
        let date_ = NSDate(timeIntervalSince1970: timeinterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S"
        
        let date = dateFormatter.stringFromDate(date_)
        
        
        // get name of category
        let categories: [Categories] = categoriesList.filter() {$0.id == categoryID}  // using closures
        
        if categories.count == 1 {
            return (date, categories[0].name)
        } else if categories.count == 0 {
            println("ERROR: Category not found")
        } else {
            // too many matches
            println("ERROR: What is happening")
        }
        
        return (date, "ERROR")
        
    }
    
    // MARK: - Camera Capture
    var captureSession: AVCaptureSession?
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBarHidden = true
        
        
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
                    cameraContainerView.layer.addSublayer(previewLayer)
                    
                    captureSession!.startRunning()
                }
            } else if (error != nil) {
                tempLabel.text = "Error in AVCaptureDeviceInput"
            }

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = cameraContainerView.bounds
    }
    
    // MARK: - View Last NoteFS
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let noteFSViewController = segue.destinationViewController as! NoteFSMainViewController
        noteFSViewController.categoryID = nil
        SnapNotesManager.setCurrentImageIdx(SnapNotesManager.getAllNotesCount()! - 1)
        // TODO: - Handle for no notes / optionals
        
        self.captureSession!.stopRunning()
        
    }
    
    // MARK: - Status bar and navigation bar stuff
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }

    
    
}

