//
//  SnapNotesManager.swift
//  SnapNotes
//
//  Created by Abdullah on 10/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import ImageIO



// MARK: - Useful data structures

struct Note {
    var date: NSDate?
    var categoryID: String?
    var imageFilePath: String?
    var thumbnailFilePath: String?
}

class Category {
    let id: String
    var name: String
    var order: Int
    
    init(id: String, name:String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
    }
}



// MARK: - The SnapNotesManager Singleton

class SnapNotesManager {
    
    // MARK: - Utility constants and methods
    
    private static let pathToDocumentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
    private static let fileManager = NSFileManager.defaultManager()
    
    private static func checkAndAddMissingFolderAtPath(filePath: String, addIfMissing: Bool?) -> Bool {
        let fileExists = self.fileManager.fileExistsAtPath(filePath)
        if addIfMissing != nil {
            if addIfMissing! {
                fileManager.createDirectoryAtPath(filePath, withIntermediateDirectories: true, attributes: nil, error: nil)
                return true
            }
        }
        return fileExists
    }
    
    private static func getNewCategoryID() -> String {
        let currentMax = self.maxCategoryID.toInt()! + 1
        self.maxCategoryID = "\(currentMax/100)\(currentMax/10)\(currentMax)"
        // !!!- : limited to 999 - 5? categories
        return self.maxCategoryID
        
    }
    
    
    
    // MARK: - Loading Settings
    
    private static let pathToSettings = pathToDocumentsFolder.stringByAppendingPathComponent("settings.json")
    private static let bundlePathToSettings = NSBundle.mainBundle().pathForResource("settings", ofType: "json")
    private static var categoriesList: [Category] = []
    private static var count = 0
    private static var settingsLoaded = false
    private static var maxCategoryID = "000"
    
    static func loadSettings() {
        
        // check if settings.json is in the documents folder, else load from bundle
        if !self.checkAndAddMissingFolderAtPath(pathToSettings, addIfMissing: false) {
            var writeError: NSError?
            fileManager.copyItemAtPath(self.bundlePathToSettings!, toPath: self.pathToSettings, error: &writeError)
            // TODO: - Handle write error
        }
        
        var readError: NSError?
        if let rawData = NSData(contentsOfFile: self.pathToSettings, options: NSDataReadingOptions.DataReadingUncached, error: &readError) {
            let jsonData = JSON(data: rawData)
            
            if let jcount = jsonData["count"].int {
                self.count = jcount
            } else {
                // This may mean an error in reading from the json
//                println(jsonData["count"].rawString())
            }
            
            if let catsArray = jsonData["categories"].array {
                for cat in catsArray {
                    let id: String? = cat["id"].string
                    let name: String? = cat["name"].string
                    let order: Int? = cat["order"].int
                    
                    categoriesList.append(Category(id: id!, name: name!, order: order!))
                    if id! >= self.maxCategoryID {
                        self.maxCategoryID = id!
                    }
                }
                
                // sorting the categories list based on category.id
                categoriesList.sort() { ($0 as Category).order < ($1 as Category).order }
                
                self.settingsLoaded = true
                
            } else {
//                println(jsonData["categories"].rawString())
            }
        } else {
            // TODO: handle error when loading settings.json
//            println("some Error: SnapNoteManager.loadSettings")
        }
    }
    
    static func isSettingsLoaded() -> Bool {
        return self.settingsLoaded
    }
    
    static func getCategories() -> [Category] {
        return self.categoriesList
    }
    
    
    
    // MARK: - Load All Notes
    
    private static let pathToNoteImages = pathToDocumentsFolder.stringByAppendingPathExtension("photos")!
    private static let pathToNoteThumbs = pathToDocumentsFolder.stringByAppendingPathExtension("thumbs")!
    private static var allNotesList: [Note] = []
    private static var allNotesListLoaded = false
    private static let noteCategorySeparatorString = "_"
    
    
    private static func getDateAndCategoryIDFromImageName(imageName: String) -> (NSDate, String) {
        let timestampSplitArray: [String] = imageName.componentsSeparatedByString(self.noteCategorySeparatorString)
        let timeinterval: Double = (timestampSplitArray[0] as NSString).doubleValue
        let categoryID = timestampSplitArray[1]

        return (NSDate(timeIntervalSince1970: timeinterval), categoryID)
    }
    
    
    static func loadAllNotes() {
        if !settingsLoaded {
            println("SnapNotesManager.loadAllNotes : Settings were not loaded, loading now")
            loadSettings()
        }
        
        self.checkAndAddMissingFolderAtPath(self.pathToNoteImages, addIfMissing: true)
        self.checkAndAddMissingFolderAtPath(self.pathToNoteThumbs, addIfMissing: true)
        
        if let imageNamesList = self.fileManager.contentsOfDirectoryAtPath(self.pathToNoteImages, error: nil) as? [String] {
            
            for imageName in imageNamesList {
                let dateAndCategoryID = self.getDateAndCategoryIDFromImageName(imageName)
                let date = dateAndCategoryID.0
                let categoryID = dateAndCategoryID.1
                let imageFilePath = pathToNoteImages.stringByAppendingPathComponent(imageName)
                let thumbnailFilePath = pathToNoteThumbs.stringByAppendingPathComponent(imageName)
                
                let note = Note(date: date, categoryID: categoryID, imageFilePath: imageFilePath, thumbnailFilePath: thumbnailFilePath)
                self.allNotesList.append(note)
            }
        }
        
        self.allNotesListLoaded = true
        
        // TODO: Handle error while reading note names
    }
    
    static func isAllNotesListLoaded() -> Bool {
        return self.allNotesListLoaded
    }
    
    static func getAllNotesCount() -> Int {
        return self.allNotesList.count
    }
    
    
    
    // MARK: - NoteFS
    
    private static var currentCategoryID: String?
    private static var currentNotesList: [Note]?
    private static var currentImageIdx: Int?
    
    static func isCurrentNotesListLoaded() -> Bool {
        return currentNotesList != nil
    }
    
    static func loadCurrentNotesList() {
        if !self.isAllNotesListLoaded() {
            println("SnapNotesManager.loadCurrentNotesList : allNotes not loaded, loading now")
            self.loadAllNotes()
        }
        
        if isEmpty(allNotesList) {
            self.currentNotesList = []
        } else {
            if self.currentCategoryID == nil {
                self.currentNotesList = self.allNotesList
            } else {
                self.currentNotesList = self.allNotesList.filter() { ($0 as Note).categoryID == self.currentCategoryID }
            }
            
            if self.currentImageIdx == nil {
                self.currentImageIdx = 0
            }
        }
    }
    
    static func getCurrentCategoryID() -> String? {
        return self.currentCategoryID
    }
    
    static func setCurrentCategoryID(newCategoryID: String?) {
        self.currentCategoryID = newCategoryID
    }
    
    static func getCurrentImageIdx() -> Int? {
        return self.currentImageIdx
    }
    
    static func getCurrentNotesListCount() -> Int {
        return self.currentNotesList!.count
    }
    
    static func setCurrentImageIdx(newCurrentImageIdx: Int) {
        self.currentImageIdx = newCurrentImageIdx
        self.loadCurrentNotesList()
    }
    
    static func getCurrentNotesList() -> [Note] {
        if self.currentNotesList == nil {
            self.loadCurrentNotesList()
        }
        return self.currentNotesList!
    }
    
    static func getImageFilePathsListForCurrentCategoryID() -> [String] {
        if self.currentNotesList == nil {
            self.loadCurrentNotesList()
        }
        
        var imageFilePathsList: [String] = []
        
        for note in self.currentNotesList! {
            imageFilePathsList.append(note.imageFilePath!)
        }
        
        return imageFilePathsList
    }
    
    
    static func getThumbsFilePathsListForCurrentCategoryID() -> [String] {
        if self.currentNotesList == nil {
            self.loadCurrentNotesList()
        }
        
        var thumbsFilePathsList: [String] = []
        
        for note in self.currentNotesList! {
            thumbsFilePathsList.append(note.thumbnailFilePath!)
        }
        
        return thumbsFilePathsList
    }

    
    
    // MARK: - Save image Notes
    
    static func saveDataForCategoryID(data: NSData, categoryID: String, extensionString: String) {

        let timeIntervalString = "\(NSDate().timeIntervalSince1970)"
        let fileName = (timeIntervalString.stringByAppendingString("_" + categoryID)).stringByAppendingPathExtension(extensionString)
        let filePath = self.pathToNoteImages.stringByAppendingPathComponent(fileName!)
        data.writeToFile(filePath, atomically: true)
        
        self.loadAllNotes()
        
    }
    
    static func saveDataForCategoryID(sampleBuffer: CMSampleBuffer, categoryID: String) {
        
        let timeIntervalSince1970 = NSDate().timeIntervalSince1970
        let timeIntervalString = "\(timeIntervalSince1970)"
        let fileName = timeIntervalString.stringByAppendingString("_" + categoryID)
        let filePath = self.pathToNoteImages.stringByAppendingPathComponent(fileName).stringByAppendingPathExtension("jpg")
        let thumbnPath = self.pathToNoteThumbs.stringByAppendingPathComponent(fileName).stringByAppendingPathExtension("jpg")
        var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
//        var dataProvider = CGDataProviderCreateWithCFData(imageData)
//        var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, kCGRenderingIntentDefault)
        
//        var image = UIImage(CGImage: cgImageRef, scale: 0.5, orientation: UIImageOrientation.Right)
//        var thumb = UIImage(CGImage: cgImageRef, scale: 0.01, orientation: UIImageOrientation.Right)
//        
//        let data = UIImageJPEGRepresentation(image, 0.5)
//        // TODO: - better quality??
//        let thumbData = UIImageJPEGRepresentation(thumb, 0.0)
        
//        if let imageSrc = CGImageSourceCreateWithData(imageData, nil) {
//                let options = [
//                    kCGImageSourceCreateThumbnailFromImageAlways: kCFBooleanTrue,
//                    kCGImageSourceThumbnailMaxPixelSize: 480,
//                    kCGImageSourceCreateThumbnailWithTransform: kCFBooleanTrue
//                    ] as CFDictionary
//                let thumb = CGImageSourceCreateThumbnailAtIndex(imageSrc, 0, options)
//            
//            }
        
        let image = UIImage(data: imageData)
        let data = UIImageJPEGRepresentation(image, 0.9)
        
        let thumbSize = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.10, 0.10))
        UIGraphicsBeginImageContextWithOptions(thumbSize, true, 0.0)
        image?.drawInRect(CGRect(origin: CGPointZero, size: thumbSize))
        let thumb = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let thumbData = UIImageJPEGRepresentation(thumb, 0.8)
        
        
//        println(image?.size)
//        println(thumb?.size)
        
        data.writeToFile(filePath!, atomically: true)
        thumbData.writeToFile(thumbnPath!, atomically: true)
        
        let newNote = Note(date: NSDate(timeIntervalSince1970: timeIntervalSince1970), categoryID: categoryID, imageFilePath: filePath!, thumbnailFilePath: thumbnPath!)
        
        self.allNotesList.append(newNote)
        
    }
    
    
    
    // MARK: - SnapView Modes
    
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
    
    
    
    // MARK: - SettingsView
    
    static func reorderAndSaveCategoriesList(newCategoriesList: [Category]) {
        for i in 0...newCategoriesList.count-1 {
            newCategoriesList[i].order = i
        }
        
        if newCategoriesList.count == categoriesList.count {
            categoriesList = newCategoriesList
        } else {
            println("SnapNotesManager.reorderAnsSaveCategoriesList : count mismatch")
        }
    }
    
    static func createNewCategoryWithName(newCategoryName: String) {
//        let newCategory = Categories(id: , name: newCategoryName, order: 0)
        println("Will Add New Category \(newCategoryName)")
        // TODO: - 
        
    }
    
}

























