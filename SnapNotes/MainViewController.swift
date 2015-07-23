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
        
        // if this is not being called from the buttonDragged function
        if sender != nil {
            // Set current category so that the last note is shown
            SnapNotesManager.setCurrentCategoryID(nil)
        }
        camerViewController?.stopCamera()
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
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(true)
        
        categoryNamesHeight = self.view.bounds.width / 4
        categoryNamesHeightConstraint.constant = categoryNamesHeight
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBarHidden = true
        
        maxCameraContainerHeight = self.view.bounds.height
        self.cameraContainerViewHeightConstraint.constant = maxCameraContainerHeight
        
        maxCategoryBottomFromLayoutBottom = maxCameraContainerHeight - minCameraContainerHeight - categoryNamesHeight
        
        // If coming back from the settings view
        if categoryNamesCollectionViewController != nil {
            categoryNamesCollectionViewController?.categoriesList = SnapNotesManager.getCategories()
            categoryNamesCollectionViewController?.collectionView?.reloadData()
        }
        
        updateAllContainerViews()
        
        
    }
    
    
    // Update the Container Views
    func updateAllContainerViews() {
        
        if camerViewController != nil {
            camerViewController?.captureSession?.startRunning()
        }
        
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.categoryNamesFromLayoutBottomConstraint.constant = minCategoryBottomFromLayoutBottom
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    // MARK: - Save Image
    func saveImageForCategoryID(categoryID: String) {
        
        camerViewController?.saveImageForCategoryID(categoryID)
        
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
    
    var notesList: [Note]?
    var photoBrowser: MWPhotoBrowser?
    
    func showPhotoGallery() {
        
        notesList = SnapNotesManager.getCurrentNotesList()
        
        photoBrowser = MWPhotoBrowser(delegate: self)
        photoBrowser?.enableGrid = true
        photoBrowser?.startOnGrid = (SnapNotesManager.getCurrentCategoryID() != nil)
        photoBrowser?.browserColor = SnapNotesManager.getColorForCurrentCategory()
        photoBrowser?.gridColor = SnapNotesManager.getColorForCurrentCategory()
        photoBrowser?.gridTitle = SnapNotesManager.getCurrentCategory()?.name
        photoBrowser?.reloadData()
        
        photoBrowser?.displaySelectionButtons = true
//        photoBrowser?.displayActionButton = true
        
        photoBrowser?.enableSwipeToDismiss = true
        
        let navController = UINavigationController(rootViewController: photoBrowser!)
        navController.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        self.presentViewController(navController, animated: true, completion: nil)
        
//        self.navigationController?.pushViewController(photoBrowser!, animated: true)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(notesList!.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        return MWPhoto(URL: NSURL(fileURLWithPath: notesList![Int(index)].thumbnailFilePath!))
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        let photo = MWPhoto(URL: NSURL(fileURLWithPath: notesList![Int(index)].imageFilePath!))
        let date = notesList![Int(index)].date!
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        
        photo.caption = "\(notesList![Int(index)].categoryID!): \(dateFormatter.stringFromDate(date) )"
        
        return photo
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, isPhotoSelectedAtIndex index: UInt) -> Bool {
//        println(index)
        return false
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt, selectedChanged selected: Bool) {
        println(index)
    }
    
    
//    func photoBrowser(photoBrowser: MWPhotoBrowser!, actionButtonPressedForPhotoAtIndex index: UInt) {
//        println("action: \(index)")
//    }
    
    func trashGridButtonPressed(photoBrowser: MWPhotoBrowser!) {
        println("\nACTION WORKS")
    }
    
}
