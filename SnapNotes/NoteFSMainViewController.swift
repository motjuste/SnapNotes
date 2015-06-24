//
//  NoteFSMainViewController.swift
//  SnapNotes
//
//  Created by Abdullah on 23/06/15.
//  Copyright (c) 2015 motjuste. All rights reserved.
//

import UIKit

class NoteFSMainViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    private let NoteFSPageViewControllerIdentifier = "NoteFSPageViewController"
    private let NoteFSContentViewControllerIdentifier = "NoteFSContentViewController"
    
    private var pageViewController: UIPageViewController?
    
    var categoryID: String? {
        didSet {
            noteImageFilePathsList = SnapNotesManager.getImageFilePathsListForCategoryID(categoryID)
        }
    }
    var noteImageFilePathsList: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: should be moved somewhere else
        categoryID = nil
        
        createPageViewController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PageViewController stuff
    func createPageViewController() {
        if noteImageFilePathsList.count < 1 {
            println("NoteFSMainViewController.createPageViewController : no notes to display")
            
            // TODO: - Handle empty currentNotesList
        } else {
            let noteFSPageViewController = self.storyboard!.instantiateViewControllerWithIdentifier(NoteFSPageViewControllerIdentifier) as! UIPageViewController
            noteFSPageViewController.dataSource = self
            
            let firstContentController = getContentViewController(0)!
            
            noteFSPageViewController.setViewControllers([firstContentController] as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: self.testSetViewController)
            
            self.pageViewController = noteFSPageViewController
            self.addChildViewController(pageViewController!)
            self.view.addSubview(pageViewController!.view)
            pageViewController?.didMoveToParentViewController(self)
        }
    }
    
    func getContentViewController(contentIdx: Int) -> NoteFSContentViewController? {
        if contentIdx < noteImageFilePathsList.count {
            let contentViewController = self.storyboard!.instantiateViewControllerWithIdentifier(NoteFSContentViewControllerIdentifier) as! NoteFSContentViewController
            
            contentViewController.contentIndex = contentIdx
            contentViewController.imageFilePath = noteImageFilePathsList[contentIdx]
            
            return contentViewController
        } else {
            return nil
        }
        
    }
    
    func testSetViewController(completion: Bool) {
        println("NoteFSMainViewController.testSetViewController")
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex > 0 {
            let prevContentViewController =  getContentViewController(contentViewController.contentIndex - 1)!
            return prevContentViewController
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex + 1 < noteImageFilePathsList.count {
            let nextContentViewController =  getContentViewController(contentViewController.contentIndex + 1)!
            
            return nextContentViewController
        } else {
            return nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}