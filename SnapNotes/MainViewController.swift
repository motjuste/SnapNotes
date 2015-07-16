//
//  MainViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

var categoryNamesHeight: CGFloat = 100
let minCameraContainerHeight: CGFloat = 50
var maxCameraContainerHeight: CGFloat = 800 // will be set based on bounds of cameraContainer
let minCategoryBottomFromLayoutBottom: CGFloat = 0
var maxCategoryBottomFromLayoutBottom: CGFloat = 500 // will be changed based on bounds later

class MainViewController: UIViewController, MWPhotoBrowserDelegate {
    
    enum embeddedSegueIdentifiers: String {
        case showCameraController = "embeddedSegueToCameraViewController"
        case showCategoryNamesController = "embeddedSegueToCategoryNamesCollectionViewController"
    }
    
    @IBOutlet weak var changeViewModeButton: UIButton!
    
    @IBAction func changeViewMode(sender: AnyObject?) {
//        SnapNotesManager.toggleSnapViewMode()
        
//        switch SnapNotesManager.currentSnapViewMode {
//        case .takePicture :
//            changeViewModeButton.setTitle("View Notes", forState: .Normal)
////            SnapNotesManager.setCurrentCategoryID(nil)
//        case .viewNotes :
//            changeViewModeButton.setTitle("Camera", forState: .Normal)
//            camerViewController?.stopCamera()
//        }
        
//        if SnapNotesManager.getCurrentCategoryID() == nil {
//            SnapNotesManager.setCurrentCategoryID(SnapNotesManager.getCategories().first!.id)
//
//            // TODO: - Check this please. Change if you're paginating the categoriesNamesList
//        }
//        updateAllContainerViews()
        if sender != nil {
            SnapNotesManager.setCurrentCategoryID(nil)
        }
        showPhotoGallery()
        
        
    }
    
    // CameraContainerView
    @IBOutlet weak var cameraContainerView: UIView!
    var camerViewController: CameraViewController?
    @IBOutlet weak var cameraContainerViewHeightConstraint: NSLayoutConstraint!
    
    // CategoryNamesContainerView
    @IBOutlet weak var CategoryNamesContainerView: UIView!
    var categoryNamesCollectionViewController: CategoryNamesCollectionViewController?
    @IBOutlet weak var categoryNamesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryNamesFromLayoutBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        categoryNamesHeight = self.view.bounds.width / 4
        categoryNamesHeightConstraint.constant = categoryNamesHeight
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBarHidden = true
        
        maxCameraContainerHeight = self.view.bounds.height
        self.cameraContainerViewHeightConstraint.constant = maxCameraContainerHeight
        
        maxCategoryBottomFromLayoutBottom = maxCameraContainerHeight - minCameraContainerHeight - categoryNamesHeight
        
        if categoryNamesCollectionViewController != nil {
            categoryNamesCollectionViewController?.categoriesList = SnapNotesManager.getCategories()
            categoryNamesCollectionViewController?.collectionView?.reloadData()
        }
        
        updateAllContainerViews()
        
        
    }
    
    
    // Update the Container Views
    func updateAllContainerViews() {
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture:
            if camerViewController != nil {
                camerViewController?.captureSession?.startRunning()
            }
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                self.categoryNamesFromLayoutBottomConstraint.constant = minCategoryBottomFromLayoutBottom
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        case .viewNotes:
            
            camerViewController?.captureSession?.stopRunning()
//
//            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
//                self.categoryNamesFromLayoutBottomConstraint.constant = maxCategoryBottomFromLayoutBottom   
//                self.view.layoutIfNeeded()
//                }, completion: (reloadNotesCollectionData))
//            
        }
        
    }
    
    // MARK: - Save Image
    func saveImageForCategoryID(categoryID: String) {
        
        camerViewController?.saveImageForCategoryID(categoryID)
//        lastPhotoButton.hidden = false
        
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let segueIdentifier = embeddedSegueIdentifiers(rawValue: segue.identifier!) {
            switch segueIdentifier {
            case .showCameraController:
                camerViewController = segue.destinationViewController as? CameraViewController
            case .showCategoryNamesController:
                categoryNamesCollectionViewController = segue.destinationViewController as? CategoryNamesCollectionViewController
            }
        }
        
    }
    
    // MARK: - Status bar and navigation bar stuff
    override func prefersStatusBarHidden() -> Bool {
        return navigationController?.navigationBarHidden == true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }
    
    // MARK: - Photo Browser
    
    var imagePaths: [String]?
    var thumbPaths: [String]?
    var photoBrowser: MWPhotoBrowser?
    
    func showPhotoGallery() {
        imagePaths = SnapNotesManager.getImageFilePathsListForCurrentCategoryID()
        thumbPaths = SnapNotesManager.getThumbsFilePathsListForCurrentCategoryID()
        photoBrowser = MWPhotoBrowser(delegate: self)
        photoBrowser?.enableGrid = true
        photoBrowser?.startOnGrid = (SnapNotesManager.getCurrentCategoryID() != nil)
        photoBrowser?.browserColor = SnapNotesManager.getColorForCurrentCategory()
        photoBrowser?.gridColor = SnapNotesManager.getColorForCurrentCategory()
        photoBrowser?.gridTitle = SnapNotesManager.getCurrentCategory()?.name
        photoBrowser?.reloadData()
        
        photoBrowser?.enableSwipeToDismiss = true
        
        let navController = UINavigationController(rootViewController: photoBrowser!)
        navController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(navController, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(photoBrowser!, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(imagePaths!.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return MWPhoto(URL: NSURL(fileURLWithPath: thumbPaths![Int(index)]))
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        return MWPhoto(URL: NSURL(fileURLWithPath: imagePaths![Int(index)]))
    }

}
