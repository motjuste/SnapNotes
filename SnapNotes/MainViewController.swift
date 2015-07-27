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
    
    var screenEdgeGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
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
        
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBarHidden = true
        
        // If coming back from the settings view
        if categoryNamesCollectionViewController != nil {
            categoryNamesCollectionViewController?.categoriesList = SnapNotesManager.getCategories()
            categoryNamesCollectionViewController?.collectionView?.reloadData()
        }
        
        layoutStuffToSize(self.view.bounds.size)
        updateAllContainerViews()
    }
    
    func layoutStuffToSize(size: CGSize) {
        categoryNamesHeight = size.width / 4
        categoryNamesHeightConstraint.constant = categoryNamesHeight
        
        maxCameraContainerHeight = size.height
        self.cameraContainerViewHeightConstraint.constant = maxCameraContainerHeight
        
        maxCategoryBottomFromLayoutBottom = maxCameraContainerHeight - minCameraContainerHeight - categoryNamesHeight

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenEdgeGestureRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: "handleEdgeGesture:")
        screenEdgeGestureRecognizer.edges = .Left
        self.view.addGestureRecognizer(screenEdgeGestureRecognizer)
        
    }
    
    func handleEdgeGesture(sender: UIGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            self.changeViewMode(sender)
        }
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
    func saveImageForCategoryID(categoryID: String, positionIndex: Int) {
        
        camerViewController?.saveImageForCategoryID(categoryID, positionIndex: positionIndex)
        
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
    var currentCategory: Category?
    var photoBrowser: MWPhotoBrowser?
    var navController: UINavigationController?
    let transitionManager = TransitionManager()
    
    func showPhotoGallery() {
        notesList = SnapNotesManager.getCurrentNotesList()
        currentCategory = SnapNotesManager.getCurrentCategory()
        
        photoBrowser = MWPhotoBrowser(delegate: self)
        photoBrowser?.enableGrid = true
        
        if currentCategory?.id == "nil" {
            photoBrowser?.startOnGrid = false
            photoBrowser?.setCurrentPhotoIndex(UInt(notesList!.count - 1))
        } else {
            photoBrowser?.startOnGrid = true
            photoBrowser?.setCurrentPhotoIndex(0)
        }
        photoBrowser?.browserColor = UIColor(rgba: "#\(currentCategory!.colorString)FF")
        photoBrowser?.gridColor = UIColor(rgba: "#\(currentCategory!.colorString)FF")
        photoBrowser?.gridTitle = currentCategory?.name
        
        photoBrowser?.displaySelectionButtons = false
        
        photoBrowser?.enableSwipeToDismiss = true
        
        navController = UINavigationController(rootViewController: photoBrowser!)
        
        if currentCategory?.id == "nil" {
            navController!.transitioningDelegate = transitionManager
        } else {
            navController!.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        }
        
        self.presentViewController(navController!, animated: true, completion: nil)
        
    }
    
    func photoBrowserDidFinishModalPresentation(photoBrowser: MWPhotoBrowser!) {
        self.dismissViewControllerAnimated(true, completion: nil)
        navController = nil
        notesList = nil
        currentCategory = nil
        self.photoBrowser = nil
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
        dateFormatter.dateFormat = "MMMM d, yyyy h:mm a"
        
        photo.caption = "\(SnapNotesManager.getCategoryByID(notesList![Int(index)].categoryID!).name)\n\(dateFormatter.stringFromDate(date))"
        
        return photo
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, isPhotoSelectedAtIndex index: UInt) -> Bool {
        return notesList![Int(index)].selected!
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt, selectedChanged selected: Bool) {
        notesList![Int(index)].selected! = !(notesList![Int(index)].selected!)
        
        // As long as there is one note selected, stay in selection mode, else change
        if (notesList!.filter() { ($0 as Note).selected! }).count < 1 {
            photoBrowser?.displaySelectionButtons = false
            photoBrowser?.disableSelectionMode()
        }
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, trashButtonPressedForPhotoAtIndex index: UInt) {
        
        let alertController = UIAlertController(title: "Delete this note?", message: "Only this note will be deleted", preferredStyle: .Alert)
        let submitAction = UIAlertAction(title: "Yes", style: .Default, handler: {
            [](paramAction:UIAlertAction!) in
                let notesToBeDeleted = [self.notesList![Int(index)]]
                self.notesList?.removeAtIndex(Int(index))
                SnapNotesManager.deleteNotes(notesToBeDeleted)
                photoBrowser?.reloadData()
            })
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        photoBrowser!.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func trashGridButtonPressed(photoBrowser: MWPhotoBrowser!) {

        let notesToBeDeleted = notesList!.filter() { ($0 as Note).selected! }
        let newNotesList = notesList!.filter() { !($0 as Note).selected! }
        
        // TODO: - Show warning
        SnapNotesManager.deleteNotes(notesToBeDeleted)
        notesList?.removeAll(keepCapacity: false)
        notesList? = newNotesList
        
        photoBrowser?.displaySelectionButtons = false
        photoBrowser?.disableSelectionMode()
        photoBrowser?.reloadData()
    }
    
    func longPressDetectedAtIndexPath(indexPath: NSIndexPath!) {
        
        // TODO: probably not need
        photoBrowser?.displaySelectionButtons = true
        
        // TODO: Future bug; Assuming only one section in the gridView;
        let index = indexPath.item
        
        notesList![index].selected = true
        photoBrowser?.enableSelectionMode()
    }
}
