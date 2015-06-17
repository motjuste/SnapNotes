//
//  SnapNotesManager.swift
//  SnapNotes
//
//  Created by Abdullah on 10/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import Foundation

class SnapNotesManager {
    static var categoriesList: [Categories] = []
    static var count = 0
    
    // MARK: playing with settings.json
    static func loadSettings() {
        
//        dispatch_async_f(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            // Background Thread
//            
//        }) // TODO: multithreading while importing data ??
        
        let filePath = NSBundle.mainBundle().pathForResource("settings", ofType: "json")
        var readError: NSError?
        
        
        if let rawData = NSData(contentsOfFile: filePath!, options: NSDataReadingOptions.DataReadingUncached, error: &readError) {
            
            // load data
            let jsonData = JSON(data: rawData)
            
            // import
            if let jcount = jsonData["count"].int {
                count = jcount
            } else {
                println(jsonData["count"].rawString())
            }
            
            if let catsArray = jsonData["categories"].array {
                for cat in catsArray {
                    let id: String? = cat["id"].string
                    let name: String? = cat["name"].string
                    let order: Int? = cat["order"].int
                    
                    categoriesList.append(Categories(id: id!, name: name!, order: order!))
                }
            } else {
                println(jsonData["categories"].rawString())
            }
        } else {
            // TODO: handle error when loading settings.json
            println("some Error: SnapNoteManager.loadSettings")
        }
        
//        println("Settings Loaded")
    }
    
    static func updateSettings() {
        // TODO: Update the settings.json
    }
    
    static func recoverSettings() {
        // TODO: Recover the settings.json in case of error
    }
    
    // Notes manager functionality
    static func getCategories() -> [Categories] {
        return self.categoriesList
    }
    
    static func getCategoryByID(categoryID: String) -> Categories? {
        let categories: [Categories] = categoriesList.filter() {$0.id == categoryID}
        if categories.count == 1 {
            return categories[0]
        } else if categories.count == 0 {
            println("ERROR: Category not found")
        } else {
            // too many matches
            println("ERROR: What is happening")
        }
        return nil

    }
}