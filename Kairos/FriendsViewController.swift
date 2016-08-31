//
//  FriendsViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 24/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class FriendsViewController: ButtonBarPagerTabStripViewController {
    
    // MARK: - Class Properties
    let blackCustomColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.8)
    let darkGreyCustomColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.6)
    
    // MARK: - Methods
    override func viewDidLoad() {
        DataSync.fetchFriends()
        DataSync.fetchUsers()

        setButtonBar()
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setButtonBar() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .whiteColor()
        settings.style.buttonBarItemBackgroundColor = .whiteColor()
        settings.style.selectedBarBackgroundColor = darkGreyCustomColor
        settings.style.buttonBarItemFont = .systemFontOfSize(20, weight: UIFontWeightThin)
        settings.style.selectedBarHeight = 1.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = darkGreyCustomColor
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = self?.darkGreyCustomColor
            newCell?.label.textColor = self?.blackCustomColor
        }
    }
    
    
    // MARK: - PagerTabStripDataSource
    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let friendsTableVC = FriendsEmbeddedTableViewController(style: .Plain, itemInfo: "Friends")
        let invitationsTableVC = InvitationsEmbeddedTableViewController(style: .Plain, itemInfo: "Requests")
        let usersTableVC = SearchUsersEmbeddedTableViewController(style: .Plain, itemInfo: "Search")
        
        return [invitationsTableVC, friendsTableVC, usersTableVC]
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