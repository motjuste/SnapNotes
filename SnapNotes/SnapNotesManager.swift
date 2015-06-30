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
                
                categoriesList.sort() { ($0 as Categories).order < ($1 as Categories).order }
                
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
        
//        if let imageNamesList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.notesPath, error: nil) as? [String] {
//            for imageName in imageNamesList {
//                let categoryID = self.getCategoryIDFromImageName(imageName)
//                let imageFilePath = notesPath.stringByAppendingPathComponent(imageName)
//                
//                let note = Note(categoryID: categoryID, imageFilePath: imageFilePath)
//                allNotesList_.append(note)
//            }
//        }
        
//        let fileManager = NSFileManager.defaultManager()
//        
//        if !fileManager.fileExistsAtPath(self.saveNotesPath) {
//            fileManager.createDirectoryAtPath(saveNotesPath, withIntermediateDirectories: true, attributes: nil, error: nil)
//            // TODO: - Handle any errors creating directories
//            
//        }
        
//        println(NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSBundle.mainBundle().resourcePath!, error: nil) as! [String])
        
        self.addPhotoNotesFolder()
        
        if let imageNamesList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(self.saveNotesPath, error: nil) as? [String] {
            
//            println(imageNamesList)
            
            for imageName in imageNamesList {
                let categoryID = self.getCategoryIDFromImageName(imageName)
                let imageFilePath = saveNotesPath.stringByAppendingPathComponent(imageName)
                
                let note = Note(categoryID: categoryID, imageFilePath: imageFilePath)
                allNotesList_.append(note)
            }
        }
        
//        println(allNotesList_)
        
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
    
    static func getCurrentImageIdx() -> Int? {
        return self.currentImageIdx
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
//        if self.currentImageIdx != nil {
            self.currentImageIdx = newCurrentImageIdx
//        } else {
//            println("SnapNotesManager.setCurrentImageIdx : currentImageIdx is nil")
//        }
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
    
    // MARK: - Save image Notes
    
    private static let saveNotesPath = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String).stringByAppendingPathComponent("photos")
    // TODO: - Do better notesPath naming and stuff
    
    
    static func saveDataForCategoryID(data: NSData, categoryID: String, extensionString: String) {
        let fileManager = NSFileManager.defaultManager()
        
        if !fileManager.fileExistsAtPath(self.saveNotesPath) {
            fileManager.createDirectoryAtPath(saveNotesPath, withIntermediateDirectories: true, attributes: nil, error: nil)
            // TODO: - Handle any errors creating directories
            
        }
        let timeIntervalString = "\(NSDate().timeIntervalSince1970)"
        let fileName = (timeIntervalString.stringByAppendingString("_" + categoryID)).stringByAppendingPathExtension(extensionString)
        let filePath = saveNotesPath.stringByAppendingPathComponent(fileName!)
        data.writeToFile(filePath, atomically: true)
        
        self.loadAllNotes()
        
    }
    
    static func getAllNotesCount() -> Int? {
        return self.allNotesList?.count
    }
    
    private static func addPhotoNotesFolder() {
        if !NSFileManager.defaultManager().fileExistsAtPath(saveNotesPath) {
            NSFileManager.defaultManager().createDirectoryAtPath(saveNotesPath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
        
        // TODO: - Handle Errors
    }
    
    enum snapViewMode {
        case takePicture
        case viewNotes
        
        func toggleMode() -> snapViewMode {
            if self.hashValue == 0 {
                return snapViewMode.viewNotes
            } else {
                return snapViewMode.takePicture
            }
        }
    }
    
    static var currentSnapViewMode = snapViewMode.takePicture
    
    static func toggleSnapViewMode() {
        self.currentSnapViewMode = currentSnapViewMode.toggleMode()
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

























