//
//  CalendarManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 07/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation

// MARK: Singleton
class CalendarManager {

    static let sharedInstance = CalendarManager()
    private init() {}

    func all() -> [UserCalendar] {
        if let calendars = UserManager.sharedInstance.current.userCalendars?.allObjects as? [UserCalendar] {
            calendars.filter({ (uCalendar) -> Bool in
                return uCalendar.status == UserStatus.Owner.rawValue || uCalendar.status == UserStatus.Participating.rawValue
            })
            return calendars
        } else {
            return [UserCalendar]()
        }
    }
}