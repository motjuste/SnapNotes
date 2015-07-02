//
//  ImageNotesCollectionViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let imageNoteCellReuseIdentifier = "ImageNoteCell"

class ImageNotesCollectionViewController: UICollectionViewController {
    
    var categoryID: String? {
        didSet {
            switch SnapNotesManager.currentSnapViewMode {
            case .takePicture :
                notesImageFilePathList = []
            case .viewNotes :
                notesImageFilePathList = SnapNotesManager.getImageFilePathsListForCategoryID(categoryID)
            }
        }
    }
    
    var notesImageFilePathList: [String] = []
    
    enum segueIdentifiers: String {
        case showImageNoteInFS = "segueToShowSelectedImageInFS"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: imageNoteCellReuseIdentifier)

        // Do any additional setup after loading the view.
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
//        self.collectionView?.addGestureRecognizer(panGestureRecognizer)
        
//        let collectionViewPanGestureRecognizer = self.collectionView?.panGestureRecognizer
//        let point = collectionViewPanGestureRecognizer?.locationInView(self.collectionView)
//        println(point)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segueID = segueIdentifiers(rawValue: segue.identifier!) {
            switch segueID {
            case .showImageNoteInFS :
                let selectedNoteInFSViewController = segue.destinationViewController as! NoteFSMainViewController
                let selectedImageCellIdx: NSIndexPath = self.collectionView!.indexPathForCell(sender as! ImageNoteCollectionViewCell)!
                
                selectedNoteInFSViewController.categoryID = self.categoryID
                SnapNotesManager.setCurrentImageIdx(selectedImageCellIdx.item)
                // TODO: - Handle when there will be segments in the gallery view
                
            }
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture:
            return 0
        case .viewNotes:
            return 1
        }
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture:
            return 0
        case .viewNotes:
            return notesImageFilePathList.count
        }
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageNoteCellReuseIdentifier, forIndexPath: indexPath) as! ImageNoteCollectionViewCell
        
        cell.imageView.image = UIImage(contentsOfFile: notesImageFilePathList[indexPath.item])
    
        return cell
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        let point: CGPoint = sender.locationInView(self.collectionView)
        
        println(point)
    }
    
    
    
    

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
