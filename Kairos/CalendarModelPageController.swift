//
//  CalendarModelPageController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/04/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class CalendarModelPageController: NSObject, UIPageViewControllerDataSource {

    // MARK: - Class Properties
    
    var viewControllers: [String] = []
    var currentIndex: Int
    
    override init() {
        // Create the vcs model.
        self.viewControllers += ["CalendarViewController", "CalendarEditTableViewController"]
        self.currentIndex = 0
        super.init()
    }
    
    
    /// Go to next view controller.
    ///
    /// - parameter pageViewController: The page view controller.
    func nextVC(pageViewController: UIPageViewController) {
        guard let currentViewController = pageViewController.viewControllers?.first else {
            return
        }
        guard let nextViewController = self.pageViewController(pageViewController, viewControllerAfter: currentViewController) else { return
        }
        pageViewController.setViewControllers([nextViewController], direction: .forward, animated: true, completion: nil)
    }
    
    /// Go to previous view controller.
    ///
    /// - parameter pageViewController: The page view controller.
    func previousVC(pageViewController: UIPageViewController) {
        guard let currentViewController = pageViewController.viewControllers?.first else {
            return
        }
        guard let nextViewController = self.pageViewController(pageViewController, viewControllerBefore: currentViewController) else { return
        }
        pageViewController.setViewControllers([nextViewController], direction: .reverse, animated: true, completion: nil)
    }
    
    /// Get the view controller at the specified index.
    ///
    /// - parameter index:      The index position.
    /// - parameter storyboard: The storyboard.
    ///
    /// - returns: The view controller
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> UIViewController? {
        // Return the view controller for the given index.
        if (self.viewControllers.count == 0) || (index >= self.viewControllers.count) {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let viewController = storyboard.instantiateViewController(withIdentifier: self.viewControllers[index])
        return viewController
    }
    
    /// Get the index of the specified view controller.
    ///
    /// - parameter viewController: The index position.
    ///
    /// - returns: The view controller.
    func indexOfViewController(_ viewController: UIViewController) -> Int {
        // Return the index of the given data view controller.
        return viewControllers.index(of: viewController.restorationIdentifier!) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.viewControllers.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }
}
