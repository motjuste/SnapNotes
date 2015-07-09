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
    var color: UIColor
    var colorString: String

    init(id: String, name:String, order: Int, color: UIColor, colorString: String) {
        self.id = id
        self.name = name
        self.order = order
        self.color = color
        self.colorString = colorString
    }

    init(id: String, name:String, order: Int) {
        self.id = id
        self.name = name
        self.order = order
        self.color = UIColor(rgba: "#FFFFFF00")
        self.colorString = "FFFFFF"
    }
    
    func asJSON() -> JSON {
        return JSON(["id": self.id, "name": self.name, "order": self.order, "color": self.colorString])
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
        var newMax = self.maxCategoryID.toInt()! + 1
        
        var x = ""
        
        for i in [100, 10, 1] {
            // !!!- : limited to 999 - 5? categories
            let digit = newMax/i
            x = x + "\(digit)"
            newMax = newMax - digit * i
        }
        self.maxCategoryID = x
        return self.maxCategoryID

    }



    // MARK: - Loading Settings

    private static let pathToSettings = pathToDocumentsFolder.stringByAppendingPathComponent("settings.json")
    private static let bundlePathToSettings = NSBundle.mainBundle().pathForResource("settings", ofType: "json")
    private static var categoriesList: [Category] = []
    private static var count = 0
    private static var settingsLoaded = false
    private static var maxCategoryID = "000"
    private static var settingsVersion = ""

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
            
            if let jversion = jsonData["version"].string {
                self.settingsVersion = jversion
            }
            

            if let catsArray = jsonData["categories"].array {
                for cat in catsArray {
                    let id: String? = cat["id"].string
                    let name: String? = cat["name"].string
                    let order: Int? = cat["order"].int
                    let color = UIColor(rgba: ("#" + cat["color"].string! + "99"))
                    let colorString = cat["color"].string!

                    categoriesList.append(Category(id: id!, name: name!, order: order!, color: color, colorString: colorString))
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

    
    // MARK: - Save Settings
    static func saveSettings() {
        
        
        var categoriesJSONList : [[String: AnyObject]] = []
        
        for category in self.categoriesList {
            categoriesJSONList.append(category.asJSON().dictionaryObject!)
        }
        
        var json = JSON(["name": "SnapNotes",
            "version": self.settingsVersion,
            "count": self.count,
            "categories": categoriesJSONList])
        
        var writeError: NSError?
        json.description.writeToFile(self.pathToSettings, atomically: true, encoding: NSUTF8StringEncoding, error: &writeError)
        // TODO: - handle write error when writing settings
    }
    

    // MARK: - Load All Notes

    private static let pathToNoteImages = pathToDocumentsFolder.stringByAppendingPathComponent("photos")
    private static let pathToNoteThumbs = pathToDocumentsFolder.stringByAppendingPathComponent("thumbs")
    private static var allNotesList: [Note] = []
    private static var allNotesListLoaded = false
    private static let noteCategorySeparatorString = "_"


    private static func getDateAndCategoryIDFromImageName(imageName: String) -> (NSDate, String) {
        let timestampSplitArray: [String] = imageName.componentsSeparatedByString(self.noteCategorySeparatorString)
        let timeinterval: Double = (timestampSplitArray[0] as NSString).doubleValue
        let categoryID = timestampSplitArray[1].stringByDeletingPathExtension

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
        
        if !allNotesList.isEmpty {
            
            allNotesList.sort() { ($0 as Note).date!.greaterThan(($1 as Note).date!) }
        }
        
        self.allNotesListLoaded = true

        // TODO: Handle error while reading note names
    }

    static func isAllNotesListLoaded() -> Bool {
        return self.allNotesListLoaded
    }

    static func getAllNotesCount() -> Int {
        self.allNotesList.count
        return self.allNotesList.count
    }



    // MARK: - NoteFS and Notes Preview

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
    
    static func getCurrentCategory() -> Category? {
        if self.currentCategoryID != nil {
            return self.categoriesList.filter({ ($0 as Category).id == self.currentCategoryID }).first! as Category
        } else {
            return Category(id: "nil", name: "All Notes", order: 99)
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
    
    static func getColorForCurrentCategory() -> UIColor {
        if self.currentCategoryID != nil {
            let currentCategory = self.categoriesList.filter({ ($0 as Category).id == self.currentCategoryID }).first! as Category
            return UIColor(rgba: "#\(currentCategory.colorString)FF")
        } else {
            return UIColor.blackColor()
        }
    }

    static func getImageFilePathsListForCurrentCategoryID() -> [String] {
//        if self.currentNotesList == nil {
            self.loadCurrentNotesList()
//        }

        var imageFilePathsList: [String] = []

        for note in self.currentNotesList! {
            imageFilePathsList.append(note.imageFilePath!)
        }

        return imageFilePathsList
    }


    static func getThumbsFilePathsListForCurrentCategoryID() -> [String] {
//        if self.currentNotesList == nil {
            self.loadCurrentNotesList()
//        }

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

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
            let image = UIImage(data: imageData)
            imageData = nil
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), {
                let data = UIImageJPEGRepresentation(image, 0.75)
                data.writeToFile(filePath!, atomically: true)
            })
            
            dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), {
                let ratio = image!.size.height/image!.size.width
                let thumbSize = CGSizeMake(300, 300 * ratio)
                UIGraphicsBeginImageContextWithOptions(thumbSize, true, 0.0)
                image?.drawInRect(CGRect(origin: CGPointZero, size: thumbSize))
                let thumb = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                let thumbData = UIImageJPEGRepresentation(thumb, 0.8)
                thumbData.writeToFile(thumbnPath!, atomically: true)
        })
        })


        let newNote = Note(date: NSDate(timeIntervalSince1970: timeIntervalSince1970), categoryID: categoryID, imageFilePath: filePath!, thumbnailFilePath: thumbnPath!)
        self.count += 1
        self.allNotesList.insert(newNote, atIndex: 0)

    }

    static func saveImage(fileName: String, image: UIImage, isThumbnail: Bool) {
        let ratio = image.size.height/image.size.width
        var imageSize: CGSize = CGSizeMake(1080, 1080 * ratio)
        var filePath = self.pathToNoteImages.stringByAppendingPathComponent(fileName).stringByAppendingPathExtension("jpg")

        if isThumbnail {
            imageSize = CGSizeMake(300, 300 * ratio)
            filePath = self.pathToNoteThumbs.stringByAppendingPathComponent(fileName).stringByAppendingPathExtension("jpg")
        }

        UIGraphicsBeginImageContextWithOptions(imageSize, true, 0.0)
        image.drawInRect(CGRect(origin: CGPointZero, size: imageSize))
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imgData = UIImageJPEGRepresentation(new_image, 0.75)
        imgData.writeToFile(filePath!, atomically: true)
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
        categoriesList = newCategoriesList
    }

    static func createNewCategoryWithName(newCategoryName: String) {
        let newColor = getRandomCategoryColor()
        let newCategory = Category(id: self.getNewCategoryID(), name: newCategoryName, order: self.categoriesList.count, color: newColor.0, colorString: newColor.1)
        self.categoriesList.append(newCategory)
    }

    private static func getRandomCategoryColor() -> (UIColor, String) {
        let colorsArray = ["F44336","E91E63","9C27B0","673AB7","3F51B5","2196F3","03A9F4","00BCD4","009688","4CAF50","8BC34A","CDDC39","FFEB3B","FFC107","FF9800","FF5722"]
        let randomIndex = Int(arc4random_uniform(UInt32(colorsArray.count)))
        let randomColor = "#\(colorsArray[randomIndex])99"
        return (UIColor(rgba: randomColor), colorsArray[randomIndex])
    }
    
    static func editCategoryNameForCategoryID(categoryID: String, newCategoryName: String) {
        (self.categoriesList.filter({ ($0 as Category).id == categoryID }) as [Category]).first!.name = newCategoryName
    }

}


// MARK: - Utility Extensions

// MARK: NSDate Extension
extension NSDate {
    var calendar: NSCalendar {
        return NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    }
    
    func after(value: Int, calendarUnit:NSCalendarUnit) -> NSDate{
        return calendar.dateByAddingUnit(calendarUnit, value: value, toDate: self, options: NSCalendarOptions(0))!
    }
    
    func minus(date: NSDate) -> NSDateComponents{
        return calendar.components(NSCalendarUnit.CalendarUnitMinute, fromDate: self, toDate: date, options: NSCalendarOptions(0))
    }
    
    func equalsTo(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedSame
    }
    
    func greaterThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    func lessThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedAscending
    }
    
    
    class func parse(dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> NSDate{
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(dateString)!
    }
    
    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String{
        var formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}


// MARK: UIColor Extension
extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = advance(rgba.startIndex, 1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (count(hex)) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
                }
            } else {
                println("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}
