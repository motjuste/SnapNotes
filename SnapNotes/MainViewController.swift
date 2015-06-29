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

    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var cameraContainerViewVerticalConstraint: NSLayoutConstraint!
    
    var cameraContainerViewBounds: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
//        let parentViewBounds = self.view.bounds
//        cameraContainerViewBounds = CGRect(x: 0, y: 0,
//            width: parentViewBounds.width,
//            height: parentViewBounds.height - categoryNamesHeight)
        
        updateCameraViewBounds()
    }
    
    func updateCameraViewBounds() {
//        cameraContainerView.bounds = cameraContainerViewBounds
        cameraContainerViewVerticalConstraint.constant = categoryNamesHeight
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
