//
//  CategoryNamesCollectionViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 30/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let reuseIdentifier = "CategoryNameCell"

class CategoryNamesCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var categoriesList: [Category] = SnapNotesManager.getCategories()

    // MARK: - UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Create blank buttons if needed
        let blankCount = 4 - categoriesList.count % 4
        if blankCount < 4 {
            for i in 1...blankCount {
                self.categoriesList.append(Category(id: "nil", name: " ", order: 0))
            }
        }
        
        return categoriesList.count  // should always be multiple of 4
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CategoryNameCollectionViewCell
        
        let category: Category = categoriesList[indexPath.item]
        
        if category.id == "nil" {
            
            // Blank button
            cell.categoryNameButton?.enabled = false
            
        } else {
            
            cell.categoryNameButton?.enabled = true
        }
        
            // Set functionality for the button
            cell.categoryNameButton?.layer.setValue(category.id, forKey: "categoryID")
            cell.categoryNameButton?.addTarget(self, action: "savePhotoForCategoryID:", forControlEvents: .TouchUpInside)
            cell.categoryNameButton?.addTarget(self, action: "buttonDragged:", forControlEvents: UIControlEvents.TouchDragExit)
        
        // Set title of the button
        cell.categoryNameButton?.setAttributedTitle(NSAttributedString(string: category.name), forState: UIControlState.Normal)
        cell.categoryNameButton?.titleLabel?.textAlignment = NSTextAlignment.Center
        cell.categoryNameButton?.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // Set the bg-color of the button
        cell.categoryNameButton?.backgroundColor = category.color
        
    
        return cell
    }
    
    // MARK : - Cell sizes
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionView!.frame.width/4.0, self.collectionView!.frame.width/4.0)
    }
    
    // MARK: - Category Name Button behaviours
    
    func savePhotoForCategoryID(sender: UIButton) {
        let categoryID: String = sender.layer.valueForKey("categoryID") as! String
        let parentVC = self.parentViewController as! MainViewController
        parentVC.saveImageForCategoryID(categoryID)
    }
    
    func buttonDragged(sender: UIButton) {
        SnapNotesManager.setCurrentCategoryID(sender.layer.valueForKey("categoryID") as? String)
        let parentVC = self.parentViewController as! MainViewController
        parentVC.changeViewMode(nil)
    }
    
}
