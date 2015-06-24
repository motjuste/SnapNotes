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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: should be moved somewhere else
        // TODO: currentNotesList should be moved back to nil when segue-ing
        if !SnapNotesManager.isCurrentNotesListLoaded() {
            SnapNotesManager.loadCurrentNotesList()
        }
        
        createPageViewController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - PageViewController stuff
    func createPageViewController() {
        if SnapNotesManager.getCurrentNotesListCount() < 1 {
            println("NoteFSMainViewController.createPageViewController : no notes to display")
            
            // TODO: - Handle empty currentNotesList
        } else {
            let noteFSPageViewController = self.storyboard!.instantiateViewControllerWithIdentifier(NoteFSPageViewControllerIdentifier) as! UIPageViewController
            noteFSPageViewController.dataSource = self
            noteFSPageViewController.delegate = self
            let currentImageIdxAndPath = SnapNotesManager.getNextImageIdxAndPath()
            
            let firstContentController = getContentViewController()
            firstContentController.contentIndex = currentImageIdxAndPath.0
            firstContentController.imageFilePath = currentImageIdxAndPath.1
            
            noteFSPageViewController.setViewControllers([firstContentController] as [AnyObject], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: self.testSetViewController)
            
            self.pageViewController = noteFSPageViewController
            self.addChildViewController(pageViewController!)
            self.view.addSubview(pageViewController!.view)
            pageViewController?.didMoveToParentViewController(self)
        }
    }
    
    func getContentViewController() -> NoteFSContentViewController {
        let contentViewController = self.storyboard!.instantiateViewControllerWithIdentifier(NoteFSContentViewControllerIdentifier) as! NoteFSContentViewController
        
        return contentViewController
    }
    
    func testSetViewController(completion: Bool) {
        println("NoteFSMainViewController.testSetViewController")
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex > 0 {
            let prevContentViewController =  getContentViewController()
            let previousImageIdxAndPath = SnapNotesManager.getPreviousImageIdxAndPath()
            prevContentViewController.contentIndex = previousImageIdxAndPath.0
            prevContentViewController.imageFilePath = previousImageIdxAndPath.1
            
            return prevContentViewController
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let contentViewController = viewController as! NoteFSContentViewController
        
        if contentViewController.contentIndex + 1 < SnapNotesManager.getCurrentNotesListCount() {
            let nextContentViewController =  getContentViewController()
            let nextImageIdxAndPath = SnapNotesManager.getNextImageIdxAndPath()
            nextContentViewController.contentIndex = nextImageIdxAndPath.0
            nextContentViewController.imageFilePath = nextImageIdxAndPath.1
            
            return nextContentViewController
        } else {
            return nil
        }
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        let contentViewControllers = previousViewControllers as! [NoteFSContentViewController]
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
        let contentViewControllers = pendingViewControllers as! [NoteFSContentViewController]
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
