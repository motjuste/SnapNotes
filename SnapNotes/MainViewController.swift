//
//  MainViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let categoryNamesHeight:CGFloat = 100

class MainViewController: UIViewController {
    
    enum embeddedSegueIdentifiers: String {
        case showCameraController = "embeddedSegueToCameraViewController"
        case showCategoryNamesController = "embeddedSegueToCategoryNamesCollectionViewController"
    }
    
    // CameraContainerView
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraContainerViewVerticalConstraint: NSLayoutConstraint!
    // TODO: - May be if height constraint is changed, the view will appear to shift up
    var camerViewController: CameraViewController?
    
    // CategoryNamesContainerView
    @IBOutlet weak var CategoryNamesContainerView: UIView!
    var categoryNamesCollectionViewController: CategoryNamesCollectionViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        self.presentedViewController
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        updateCameraViewBounds()
    }
    
    func updateCameraViewBounds() {
        cameraContainerViewVerticalConstraint.constant = categoryNamesHeight
    }
    
    // MARK: - Save Image
    func saveImageForCategoryID(categoryID: String) {
        if let image = camerViewController?.getImageToSave() {
            SnapNotesManager.saveDataForCategoryID(UIImageJPEGRepresentation(image, 0.75), categoryID: categoryID, extensionString: "jpg")
        }
        
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//         Get the new view controller using segue.destinationViewController.
//         Pass the selected object to the new view controller.
        
        if let segueIdentifier = embeddedSegueIdentifiers(rawValue: segue.identifier!) {
            switch segueIdentifier {
            case embeddedSegueIdentifiers.showCameraController:
                camerViewController = segue.destinationViewController as? CameraViewController
            case embeddedSegueIdentifiers.showCategoryNamesController:
                categoryNamesCollectionViewController = segue.destinationViewController as? CategoryNamesCollectionViewController
            }
        }
        
    }


}
