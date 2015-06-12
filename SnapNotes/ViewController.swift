//
//  ViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 09/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var categoriesList: [Categories] = []
    
    @IBOutlet weak var cameraContainerView: UIView!
    @IBOutlet weak var categoriesCollectionView: UICollectionView!
    
    @IBOutlet weak var tempLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        SnapNotesManager.loadSettings()
        categoriesList = SnapNotesManager.getCategories()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: CategoriesCollectionView methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let categoryCell = collectionView.dequeueReusableCellWithReuseIdentifier("CategoriesCell", forIndexPath: indexPath) as! CategoriesCollectionViewCell
        
        let category: Categories = categoriesList[indexPath.row]
        categoryCell.categoriesLabel.text = category.name
        categoryCell.categoryID = category.id
        
        return categoryCell
        
    }
    
    // MARK: Testing
//    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
//        let category: Categories = categoriesList[indexPath.row]
//        
//        let timeInterval = NSTimeIntervalSince1970
//        let categoryID = category.id
//        
//        let tempLabelText = "\(timeInterval)_\(categoryID)"
//        
//        tempLabel.text = tempLabelText
//        
//    }
    
//    func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject!) {
//        let category: Categories = categoriesList[indexPath.row]
//        
//        let timeInterval = NSTimeIntervalSince1970
//        let categoryID = category.id
//        
//        let tempLabelText = "\(timeInterval)_\(categoryID)"
//        
//        tempLabel.text = tempLabelText
//    }
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let category: Categories = categoriesList[indexPath.row]
        
        let timeInterval = NSDate().timeIntervalSince1970
//        let timeInterval = getTimeStampAsString()
        let categoryID = category.id
        
        let tempLabelText = "\(timeInterval)_\(categoryID)"
        
        tempLabel.text = tempLabelText
        
        return false
    }
    
    func getTimeStampAsString() -> String {
        return String(stringInterpolationSegment: NSDate().timeIntervalSince1970)
    }
    
}

