//
//  MainViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let categoryNamesHeight: CGFloat = 100
let minCameraContainerHeight: CGFloat = 50

class MainViewController: UIViewController {
    
    enum embeddedSegueIdentifiers: String {
        case showCameraController = "embeddedSegueToCameraViewController"
        case showCategoryNamesController = "embeddedSegueToCategoryNamesCollectionViewController"
        case showImageNotesController = "embeddedSegueToImageNotesCollectionViewController"
    }
    
    @IBAction func changeViewMode(sender: AnyObject) {
        SnapNotesManager.toggleSnapViewMode()
        imageNotesCollectionViewController?.categoryID = categoryNamesCollectionViewController?.categoriesList.first?.id
        updateAllContainerViews()
    }
    
    // CameraContainerView
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraContainerViewVerticalConstraint: NSLayoutConstraint!
    // TODO: - May be if height constraint is changed, the view will appear to shift up
    var maxCameraContainerViewVerticalConstraintConstant: CGFloat?
    var camerViewController: CameraViewController?
    
    // CategoryNamesContainerView
    @IBOutlet weak var CategoryNamesContainerView: UIView!
    var categoryNamesCollectionViewController: CategoryNamesCollectionViewController?
    
    // ImageNotesContainerView
    @IBOutlet weak var imageNotesContainerView: UIView!
    var imageNotesCollectionViewController: ImageNotesCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController?.hidesBarsOnTap = false
//        navigationController?.navigationBarHidden = true
        
        maxCameraContainerViewVerticalConstraintConstant = self.view.bounds.height - minCameraContainerHeight
        updateAllContainerViews()
        
        
    }
    
    
    // Update the Container Views
    func updateAllContainerViews() {
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture:
            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
                self.cameraContainerViewVerticalConstraint.constant = categoryNamesHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        case .viewNotes:
            UIView.animateWithDuration(0.45, delay: 0.0, options: .CurveEaseOut, animations: {
                self.cameraContainerViewVerticalConstraint.constant = self.maxCameraContainerViewVerticalConstraintConstant!
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        imageNotesCollectionViewController?.collectionView?.reloadData()
    }
    
    // MARK: - Save Image
    func saveImageForCategoryID(categoryID: String) {
        
//        let cam = self.childViewControllers.first as? CameraViewController
//        
//        let imageData = cam!.getImageDataToSave()
//        SnapNotesManager.saveDataForCategoryID(imageData!, categoryID: categoryID, extensionString: "jpg")
        
        camerViewController?.saveImageForCategoryID(categoryID)
        
    }
    
    func changeImageNotesCategory(newCategoryID: String) {
        imageNotesCollectionViewController?.categoryID = newCategoryID
        imageNotesCollectionViewController?.collectionView?.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        
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
            }
        }
        
    }
    
    // MARK: - Status bar and navigation bar stuff
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return UIStatusBarAnimation.Fade
    }


}
