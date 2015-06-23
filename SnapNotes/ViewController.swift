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
    @IBOutlet weak var tempLabel2: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        println("ViewController.viewDidLoad()")
        
//        SnapNotesManager.loadSettings()
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
    
    // MARK: Tapped Category + name generation testing
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let category: Categories = categoriesList[indexPath.row]
        
        let timeInterval = NSDate().timeIntervalSince1970
        let categoryID = category.id
        
        let tempLabelText = "\(timeInterval)_\(categoryID)"
        
        var date: String = ""
        var cat: String = ""
        
        (date, cat) = getDateFromTimeStamp(tempLabelText)
        
        tempLabel.text = tempLabelText
        tempLabel2.text = date + " " + cat
        
        return false
    }
    
    func getDateFromTimeStamp(timestamp: String) -> (date: String, category: String) {
        let timestampSplitArray: [String] = timestamp.componentsSeparatedByString("_")
        
        let timeinterval: Double = (timestampSplitArray[0] as NSString).doubleValue
        let categoryID = timestampSplitArray[1]
        
        // get Date in pretty string
        let date_ = NSDate(timeIntervalSince1970: timeinterval)
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.S"
        
        let date = dateFormatter.stringFromDate(date_)
        
        
        // get name of category
        let categories: [Categories] = categoriesList.filter() {$0.id == categoryID}  // using closures
        
        if categories.count == 1 {
            return (date, categories[0].name)
        } else if categories.count == 0 {
            println("ERROR: Category not found")
        } else {
            // too many matches
            println("ERROR: What is happening")
        }
        
        return (date, "ERROR")
        
    }
    
}

