//
//  CategoryNamesCollectionViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let reuseIdentifier = "CategoryNameCell"

class CategoryNamesCollectionViewController: UICollectionViewController {
    
    var categoriesList: [Category] = SnapNotesManager.getCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
//        self.collectionView!.registerClass(CategoryNameCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // !!! - Why the Fuck is this thing fucking up stuff!!?

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesList.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryNameCollectionViewCell
        
        let category: Category = categoriesList[indexPath.item]
        
        cell.categoryNameButton?.layer.setValue(category.id, forKey: "categoryID")
        cell.categoryNameButton?.layer.setValue(cell.categoryNameButton?.tintColor, forKey: "highlightedColor")
        cell.categoryNameButton?.layer.setValue(UIColor.groupTableViewBackgroundColor(), forKey: "normalColor")
        cell.categoryNameButton?.addTarget(self, action: "savePhotoForCategoryID:", forControlEvents: .TouchUpInside)
        cell.categoryNameButton?.setTitle(category.name, forState: .Normal)
        cell.categoryNameButton?.setTitleColor(cell.categoryNameButton.tintColor, forState: .Normal)
        cell.categoryNameButton?.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
        
//        cell.categoryNameButton?.addTarget(self, action: "highlightButton:", forControlEvents: UIControlEvents.TouchDown)
//        cell.categoryNameButton?.addTarget(self, action: "unHightlightButton:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.categoryNameButton?.addTarget(self, action: "buttonDragged:", forControlEvents: UIControlEvents.TouchDragExit)
    
        return cell
    }
    
    func savePhotoForCategoryID(sender: UIButton) {
        let categoryID: String = sender.layer.valueForKey("categoryID") as! String
        
        let parentVC = self.parentViewController as! MainViewController
        
        switch SnapNotesManager.currentSnapViewMode {
        case .takePicture :
            parentVC.saveImageForCategoryID(categoryID)
        case .viewNotes :
//            parentVC.changeImageNotesCategory(categoryID)
            SnapNotesManager.setCurrentCategoryID(categoryID)
        }
    }
    
    func highlightButton(sender: UIButton) {
        let highlightColor = sender.layer.valueForKey("highlightedColor") as! UIColor
        sender.backgroundColor = highlightColor
    }
    
    func unHightlightButton(sender: UIButton) {
        let unHighlightColor = sender.layer.valueForKey("normalColor") as! UIColor
        sender.backgroundColor = unHighlightColor
    }
    
    func buttonDragged(sender: UIButton) {
        SnapNotesManager.setCurrentCategoryID(sender.layer.valueForKey("categoryID") as? String)
        let unHighlightColor = sender.layer.valueForKey("normalColor") as! UIColor
        sender.backgroundColor = unHighlightColor
        let parentVC = self.parentViewController as! MainViewController
        parentVC.changeViewMode(nil)
    }
}
