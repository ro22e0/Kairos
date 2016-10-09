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
        if let calendars = UserCalendar.all() as? [UserCalendar] {
            return calendars
        } else {
            return [UserCalendar]()
        }
    }

    func calendars(withStatus status: UserStatus) -> [UserCalendar] {
        if var calendars = UserManager.sharedInstance.current.userCalendars?.allObjects as? [UserCalendar] {
            calendars = calendars.filter({ (uCalendar) -> Bool in
                return uCalendar.status == UserStatus.Owner.rawValue || uCalendar.status == status.rawValue
            })
            return calendars
        } else {
            return [UserCalendar]()
        }
    }

    func users(forCalendar calendar: Calendar) -> [UserCalendar] {
        if let users = calendar.calendarUsers?.allObjects as? [UserCalendar] {
            return users
        } else {
            return [UserCalendar]()
        }
    }
    
    func isOwner(calendar: Calendar) -> Bool {
        return true
    }
    
    func userIsIn(calendar: Calendar, user: User) -> Bool {
        let users = calendar.calendarUsers?.allObjects as? [UserCalendar]
        var isIn = false
        users?.forEach({ (u) in
            if u.userId == user.id {
                isIn = true
            }
        })
        return isIn
    }
    
    func create(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.CreateCalendar(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func update(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.UpdateCalendar(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func invite(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.InviteCalendar(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }

    func accept(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.AcceptCalendar(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }

    func cancel(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
//        RouterWrapper.sharedInstance.request(.CancelCalendar(parameters)) { (response) in
//            switch response.result {
//            case .Success:
//                switch response.response!.statusCode {
//                case 200...203:
//                    completionHandler(.Success)
//                default:
//                    completionHandler(.Error("kFail"))
//                }
//            case .Failure(let error):
//                completionHandler(.Error(error.localizedDescription))
//            }
//        }
    }
    
    func refuse(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
        RouterWrapper.sharedInstance.request(.RefuseCalendar(parameters)) { (response) in
            switch response.result {
            case .Success:
                switch response.response!.statusCode {
                case 200...203:
                    completionHandler(.Success)
                default:
                    completionHandler(.Error("kFail"))
                }
            case .Failure(let error):
                completionHandler(.Error(error.localizedDescription))
            }
        }
    }
    
    func remove(parameters: [String: AnyObject], completionHandler: (CustomStatus) -> Void) {
//        RouterWrapper.sharedInstance.request(.RemoveFriend(parameters)) { (response) in
//            switch response.result {
//            case .Success:
//                switch response.response!.statusCode {
//                case 200...203:
//                    completionHandler(.Success)
//                default:
//                    completionHandler(.Error("kFail"))
//                }
//            case .Failure(let error):
//                completionHandler(.Error(error.localizedDescription))
//            }
//        }
    }
}