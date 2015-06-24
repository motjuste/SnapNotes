//
//  SnapNotesManager.swift
//  SnapNotes
//
//  Created by Abdullah on 10/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import Foundation

class SnapNotesManager {
    private static var categoriesList: [Categories] = []
    private static var count = 0
    private static var settingsLoaded = false
    
    private static let notesPath = NSBundle.mainBundle().resourcePath!.stringByAppendingPathComponent("TempNoteImages")
    private static var allNotesList: [Note]?
    private static let noteCategorySeparatorString = "_"
    
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
                
                self.settingsLoaded = true
                
            } else {
                println(jsonData["categories"].rawString())
            }
        } else {
            // TODO: handle error when loading settings.json
            println("some Error: SnapNoteManager.loadSettings")
        }
        
//        println("Settings Loaded")
    }
    
    static func isSettingsLoaded() -> Bool {
        return settingsLoaded
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
    
    // MARK: load all notes
    
    static func loadAllNotes() {
        if !settingsLoaded {
            println("SnapNotesManager.loadAllNotes : Settings were not loaded, loading now")
            loadSettings()
        }
        
        var allNotesList_ : [Note] = []
        
        if let imageNamesList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.notesPath, error: nil) as? [String] {
            for imageName in imageNamesList {
                let categoryID = self.getCategoryIDFromImageName(imageName)
                let imageFilePath = notesPath.stringByAppendingPathComponent(imageName)
                
                let note = Note(categoryID: categoryID, imageFilePath: imageFilePath)
                allNotesList_.append(note)
            }
        }
        
        allNotesList = allNotesList_
        
//        self.allNotesLoaded = true
        
        // TODO: Handle error while reading note names
        
    }
    
    private static func getCategoryIDFromImageName(imageName: String) -> String {
        let splittedImageName = imageName.componentsSeparatedByString(noteCategorySeparatorString)
        let categoryID = splittedImageName[1].componentsSeparatedByString(".")[0]
        
        return categoryID
    }
    
    // MARK: NoteFS 
    // MARK: NoteFS : This is getting too complicated; And doesn't work
    
    private static var currentCategoryID: String?
    private static var currentNotesList: [Note]?
    private static var currentImageIdx: Int?
    
    static func isCurrentNotesListLoaded() -> Bool {
        return currentNotesList != nil
    }
    
    static func loadCurrentNotesList() {
        if allNotesList == nil {
            println("SnapNotesManager.loadCurrentNotesList : allNotes not loaded, loading now")
            self.loadAllNotes()
        }
        
        if isEmpty(allNotesList!) {
            self.currentNotesList = []
        } else {
            if self.currentCategoryID == nil {
                self.currentNotesList = self.allNotesList
            } else {
                self.currentNotesList = self.allNotesList!.filter() { ($0 as Note).categoryID == self.currentCategoryID }
            }
            
            if self.currentImageIdx == nil {
                self.currentImageIdx = 0
            }
        }
        
    }
    
    static func getCurrentNotesListCount() -> Int {
        return self.currentNotesList!.count
    }
    
    static func getCurrentImageIdxAndPath() -> (Int, String) {
        return (self.currentImageIdx!, self.currentNotesList![currentImageIdx!].imageFilePath!)
    }
    
    static func getNextImageIdxAndPath() -> (Int, String) {
        println(currentImageIdx!)
        println(getCurrentNotesListCount())
        
        return (self.currentImageIdx! + 1, self.currentNotesList![currentImageIdx! + 1].imageFilePath!)
    }
    
    static func getPreviousImageIdxAndPath() -> (Int, String) {
        println(currentImageIdx!)
        println(getCurrentNotesListCount())
        
        return (self.currentImageIdx! - 1, self.currentNotesList![currentImageIdx! - 1].imageFilePath!)
    }
    
    static func setCurrentImageIdx(newCurrentImageIdx: Int) {
        if self.currentImageIdx != nil {
            self.currentImageIdx = newCurrentImageIdx
        } else {
            println("SnapNotesManager.setCurrentImageIdx : currentImageIdx is nil")
        }
    }
    
    // MARK: NoteFS : Simpler?
    
    static func getImageFilePathsListForCategoryID(categoryID: String?) -> [String] {
        var imageFilePathsList: [String] = []
        var notesListForCategoryID: [Note] = []
        
        
        if (self.allNotesList != nil) {
            if (categoryID == nil) {
                notesListForCategoryID = allNotesList!
            } else {
                notesListForCategoryID = self.allNotesList!.filter() { ($0 as Note).categoryID == categoryID }
            }
        }
        
        for note in notesListForCategoryID {
            imageFilePathsList.append(note.imageFilePath!)
        }
        
        return imageFilePathsList
        
    }
    
    // MARK: - Temporary to rename all images
    
//    static func renameAllImages() {
//        let categoryID = "005"
//        
//        if let imageNamesList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.notesPath, error: nil) as? [String] {
//            for imageName in imageNamesList {
//                let oldFilePath = self.notesPath.stringByAppendingPathComponent(imageName)
//                let fileExtension = imageName.pathExtension
//                
//                let timeInterval = "\(NSDate().timeIntervalSince1970)"
//                var newFileName = timeInterval.stringByAppendingString("_" + categoryID)
//                newFileName = newFileName.stringByAppendingPathExtension(fileExtension)!
//                let newFilePath = self.notesPath.stringByAppendingPathComponent(newFileName)
//                
//                NSFileManager.defaultManager().moveItemAtPath(oldFilePath, toPath: newFilePath, error: nil)
//            }
//        }
//        
//        if let imageNamesList_ = NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.notesPath, error: nil) as? [String] {
//            println(imageNamesList_)
//        }
//
//    }
    
    
}

























