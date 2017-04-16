//
//  CalendarRootViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/04/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import SwiftMessages

class CalendarRootViewController: UIViewController {

    // MARK: - Class Properties
    
    var pageViewController: UIPageViewController?
    var selectedIndex: Int = 0
    
    lazy var modelPageController: CalendarModelPageController = {
        let _modelPageController = CalendarModelPageController()
        return _modelPageController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurePageVC()
    }
    
    /// Set up the page view controller.
    private func configurePageVC() {
        // Configure the page view controller and add it as a child view controller.
        
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageVC.delegate = self
        
        guard let detailsViewController = self.modelPageController.viewControllerAtIndex(selectedIndex, storyboard: self.storyboard!) else {
            return
        }
        let viewControllers = [detailsViewController]
        pageVC.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        pageVC.dataSource = self.modelPageController
        self.addChildViewController(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParentViewController: self)
        pageViewController = pageVC
    }
    
    // MARK: - Actions
    
    @IBAction func moreActions(_ sender: Any) {
        let view: CalendarRequestsActions = try! SwiftMessages.viewFromNib()
        view.configureDropShadow()
        view.cancelAction = { SwiftMessages.hide() }
        view.createEvent = {
            self.performSegue(withIdentifier: "createEventSegue", sender: self)
        }
        view.createCalendar = {
            self.performSegue(withIdentifier: "createCalendarSegue", sender: self)
        }
        view.calendarsRequests = {
            self.performSegue(withIdentifier: "showCalendarRequestsSegue", sender: self)
        }
        view.eventsRequests = {
            self.performSegue(withIdentifier: "showEventRequestsSegue", sender: self)
        }
        var config = SwiftMessages.defaultConfig
        config.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: true)
        SwiftMessages.show(config: config, view: view)
    }
    
    @IBAction func changeVC(_ sender: UISegmentedControl) {
        self.modelPageController.currentIndex = sender.selectedSegmentIndex
        if pageViewController != nil {
            if selectedIndex > sender.selectedSegmentIndex {
                self.modelPageController.previousVC(pageViewController: self.pageViewController!)
            } else if selectedIndex < sender.selectedSegmentIndex {
                self.modelPageController.nextVC(pageViewController: self.pageViewController!)
            }
        }
        selectedIndex = sender.selectedSegmentIndex
    }
    
    // MARK: - Navigation
}

// MARK: - RootViewController extention
extension CalendarRootViewController: UIPageViewControllerDelegate {
    
    // MARK: - UIPageViewController delegate methods
    
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            
            let currentViewController = pageViewController.viewControllers![0]
            let viewControllers = [currentViewController]
            pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
            
            pageViewController.isDoubleSided = false
            return .min
        }
        
        let currentViewController = pageViewController.viewControllers![0]
        var viewControllers = [UIViewController]()
        
        let indexOfCurrentViewController = self.modelPageController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            if let nextViewController = self.modelPageController.pageViewController(pageViewController, viewControllerAfter: currentViewController) {
                viewControllers = [currentViewController, nextViewController]
            }
        } else {
            if let previousViewController = self.modelPageController.pageViewController(pageViewController, viewControllerBefore: currentViewController) {
                viewControllers = [previousViewController, currentViewController]
            }
        }
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })
        return .mid
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        selectedIndex = modelPageController.indexOfViewController(pageViewController.viewControllers!.last!)
    }
}
