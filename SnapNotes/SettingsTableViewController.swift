//
//  SettingsTableViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 02/07/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

let itemsPerSection = 4
let cellIdentifier = "settingsTableViewCell"
let uncategorizedID = "000"

class SettingsTableViewController: UITableViewController {
    
    var categoriesList: [Category] = SnapNotesManager.getCategories()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        navigationController?.navigationBarHidden = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // Our table is always in editing mode
        self.tableView.editing = true
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addNewCategory:"))
        
    }
    
    func addNewCategory(sender: AnyObject?) {
        
        let alertController = UIAlertController(title: "New Category", message: "Add name for a new category", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.placeholder = "Donuts"
        }
        let submitAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default, handler: {
            [weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields {
                let theTextFields = textFields as! [UITextField]
                if let enteredText = theTextFields.first!.text {
                    SnapNotesManager.createNewCategoryWithName(enteredText)
                    self!.categoriesList = SnapNotesManager.getCategories()
                    self!.tableView.reloadData()
                }
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let minNumSections = categoriesList.count / itemsPerSection
        return categoriesList.count % itemsPerSection == 0 ? minNumSections : minNumSections + 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemsLeft = categoriesList.count - itemsPerSection * section
        return itemsLeft > itemsPerSection ? itemsPerSection : itemsLeft
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = categoriesList[indexPath.section * itemsPerSection + indexPath.item].name

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return String(section + 1)
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return categoriesList[indexPath.section * itemsPerSection + indexPath.item].id != uncategorizedID
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            let saneIndexPath = indexPath.section * itemsPerSection + indexPath.row
            let currentCategory = categoriesList[saneIndexPath] as Category
            if currentCategory.id == "000" {
                let alertController = UIAlertController(
                                    title: "Sorry",
                                    message: "Cannot delete \(currentCategory.name) as it is a default category",
                                    preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(cancelAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                categoriesList.removeAtIndex(saneIndexPath)
                SnapNotesManager.reorderAndSaveCategoriesList(categoriesList)
                categoriesList = SnapNotesManager.getCategories()
                self.tableView.reloadData()
                // TODO: Animated deleting doesn't work?
//                if tableView.numberOfRowsInSection(indexPath.section) == 0 {
//                    tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Automatic)
//                }
//                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentCategory = self.categoriesList[indexPath.section * itemsPerSection + indexPath.item]
        let alertController = UIAlertController(title: "Edit Category", message: "Rename category", preferredStyle: .Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField: UITextField!) in
            textField.text = currentCategory.name
        }
        let submitAction = UIAlertAction(title: "Submit", style: .Default, handler: {
            [weak self]
            (paramAction:UIAlertAction!) in
            if let textFields = alertController.textFields {
                let theTextFields = textFields as! [UITextField]
                if let enteredText = theTextFields.first!.text {
                    if enteredText != "" && enteredText != currentCategory.name {
                        SnapNotesManager.editCategoryNameForCategoryID(currentCategory.id, newCategoryName: enteredText)
                        self!.categoriesList = SnapNotesManager.getCategories()
                        self!.tableView.reloadData()
                    }
                }
            }
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let saneFromIndexPath = fromIndexPath.section * itemsPerSection + fromIndexPath.item
        let movedObject = categoriesList[saneFromIndexPath]
        categoriesList.removeAtIndex(saneFromIndexPath)
        categoriesList.insert(movedObject, atIndex: toIndexPath.section * itemsPerSection + toIndexPath.item)
        SnapNotesManager.reorderAndSaveCategoriesList(categoriesList)
        categoriesList = SnapNotesManager.getCategories()
        tableView.reloadData()
    }
}
