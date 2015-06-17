//
//  NoteFSPageViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 17/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

class NoteFSPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var category: Categories?
    var notesList: [Note]?
    
    private let path = NSBundle.mainBundle().resourcePath! + "/TempNoteImages/"
    
    override func viewDidLoad() {
        SnapNotesManager.loadSettings()
        category = SnapNotesManager.getCategoryByID("005")!
        // MARK: get temp image names
        let noteImageNamesList = NSFileManager.defaultManager().contentsOfDirectoryAtPath(path, error: nil)
        
        for img in noteImageNamesList! {
            let note = Note()
            note.imageFileName = path + (img as! String)
            note.categoryID = category!.id
            category!.notesList.append(note)
        }
        
        notesList = category?.notesList
        
        dataSource = self
        
        if notesList!.count > 0 {
            let firstContentController = getContentController(0)
            setViewControllers([firstContentController] as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        }
        
        
    }
    
    func getContentController(contentIndex: Int) -> NoteFSContentViewController {
        let contentViewController = self.storyboard!.instantiateViewControllerWithIdentifier("NoteFSContentViewController") as! NoteFSContentViewController
        
        contentViewController.contentIndex = contentIndex
        contentViewController.note = notesList![contentIndex]
        
        return contentViewController
    }
    
    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex > 0 {
            return getContentController(contentViewController.contentIndex - 1)
        }
        
        return nil
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex + 1 < notesList?.count {
            return getContentController(contentViewController.contentIndex + 1)
        }
        
        return nil
    }
}
