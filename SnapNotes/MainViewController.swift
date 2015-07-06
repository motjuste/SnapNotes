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

class MainViewController: UIViewController {
    
    enum embeddedSegueIdentifiers: String {
        case showCameraController = "embeddedSegueToCameraViewController"
        case showCategoryNamesController = "embeddedSegueToCategoryNamesCollectionViewController"
        case showImageNotesController = "embeddedSegueToImageNotesCollectionViewController"
        case showLastPhoto = "segueToLastPhoto"
    }
    
    @IBOutlet weak var changeViewModeButton: UIButton!
    
    @IBAction func changeViewMode(sender: AnyObject?) {
        SnapNotesManager.toggleSnapViewMode()
        
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture :
            changeViewModeButton.setTitle("View Notes", forState: .Normal)
            SnapNotesManager.setCurrentCategoryID(nil)
        case .viewNotes :
            changeViewModeButton.setTitle("Camera", forState: .Normal)
        }
        
        if SnapNotesManager.getCurrentCategoryID() == nil {
            SnapNotesManager.setCurrentCategoryID(SnapNotesManager.getCategories().first!.id)

            // TODO: - Check this please. Change if you're paginating the categoriesNamesList
        }
        updateAllContainerViews()
        
        
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
    
    // ImageNotesContainerView
    @IBOutlet weak var imageNotesContainerView: UIView!
    var imageNotesCollectionViewController: ImageNotesCollectionViewController?
    
    // LastPhotoButton
    
    @IBOutlet weak var lastPhotoButton: UIButton!
    
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
            lastPhotoButton.hidden = true
            camerViewController?.captureSession?.stopRunning()
            
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.categoryNamesFromLayoutBottomConstraint.constant = maxCategoryBottomFromLayoutBottom   
                self.view.layoutIfNeeded()
                }, completion: (reloadNotesCollectionData))
            
        }
        
    }
    
    func reloadNotesCollectionData(Bool) {
        if let categoryID = SnapNotesManager.getCurrentCategoryID() {
            self.imageNotesCollectionViewController?.updatePathLists()
            self.imageNotesCollectionViewController?.collectionView?.reloadData()
        }
    }
    
    // MARK: - Save Image
    func saveImageForCategoryID(categoryID: String) {
        
        camerViewController?.saveImageForCategoryID(categoryID)
        lastPhotoButton.hidden = false
        
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
            case .showImageNotesController:
                imageNotesCollectionViewController = segue.destinationViewController as? ImageNotesCollectionViewController
//                switch SnapNotesManager.currentSnapViewMode {
//                case .takePicture:
//                    break
//                    // TODO: Wut M8 ?
//                case .viewNotes:
//                    imageNotesCollectionViewController?.categoryID = categoryNamesCollectionViewController?.categoriesList.first?.id
//                }
            case .showLastPhoto:
                let noteFSViewController = segue.destinationViewController as! NoteFSMainViewController
                SnapNotesManager.setCurrentCategoryID(nil)
                SnapNotesManager.setCurrentImageIdx(SnapNotesManager.getAllNotesCount() - 1)
                // TODO: - Handle for no notes / optionals
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


}
