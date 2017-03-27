//
//  CalendarManager.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 07/10/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: Singleton
class CalendarManager {

    static let shared = CalendarManager()
    fileprivate init() {colors = [:]}
    
    var colors: [String: String]
    
    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchCalendars() { (status) in
            switch status {
            case .success:
                if handler != nil {
                    handler!()
                }
            case .error(let error):
                print(error)
            }
        }
    }
    
    func all() -> [Calendar] {
        if let calendars = Calendar.all() as? [Calendar] {
            return calendars
        } else {
            return [Calendar]()
        }
    }
    
    func calendars(withStatus status: UserStatus) -> [Calendar] {
        var calendars = [Calendar]()
        guard let user = UserManager.shared.current.user else {
            return calendars
        }
        
        if let test = user.calendars?.allObjects as? [Calendar] {
            print(test)
        }
        
        switch status {
        case .Invited:
            if let calendarObjs = user.invitedCalendars {
                calendars = calendarObjs.allObjects as! [Calendar]
            }
        case .Owner:
            if let calendarObjs = user.ownedCalendars {
                calendars = calendarObjs.allObjects as! [Calendar]
            }
        case .Participating:
            if let calendarObjs = user.calendars, let ownedCalendarObjs = user.ownedCalendars {
                calendars = calendarObjs.allObjects as! [Calendar]
                calendars += ownedCalendarObjs.allObjects as! [Calendar]
            }
        case .Refused:
            if let calendarObjs = user.refusedCalendars {
                calendars = calendarObjs.allObjects as! [Calendar]
            }
        default: break
        }
        return calendars
    }
    
    func allUsers(forCalendar calendar: Calendar) -> [User] {
        var users: [User] = calendar.invitedUsers?.allObjects as! [User]
        users += calendar.owners?.allObjects as! [User]
        users += calendar.participatingUsers?.allObjects as! [User]
        users += calendar.refusedUsers?.allObjects as! [User]
        return users
    }
    
    func users(withStatus status: UserStatus, forCalendar calendar: Calendar) -> [User] {
        var users: [User]

        switch status {
        case .Invited:
            users = calendar.invitedUsers?.allObjects as! [User]
        case .Owner:
            users = calendar.owners?.allObjects as! [User]
        case .Participating:
            users = calendar.participatingUsers?.allObjects as! [User]
        case .Refused:
            users = calendar.refusedUsers?.allObjects as! [User]
        default:
            users = []
        }
        return users
    }
    
    func delete(user: User, fromCalendar calendar: Calendar) {
        var users = calendar.invitedUsers?.allObjects as! [User]
        if users.contains(user) {
            calendar.removeFromInvitedUsers(user)
        }
        users = calendar.owners?.allObjects as! [User]
        if users.contains(user) {
            calendar.removeFromOwners(user)
        }
        users = calendar.participatingUsers?.allObjects as! [User]
        if users.contains(user) {
            calendar.removeFromParticipatingUsers(user)
        }
        users = calendar.refusedUsers?.allObjects as! [User]
        if users.contains(user) {
            calendar.removeFromRefusedUsers(user)
        }
    }
    
    func create(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.createCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
//                        DataSync.syncCalendars(json) {
//                            
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func update(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.updateCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
//                        DataSync.syncCalendars(json) {
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func invite(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.inviteCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
//                        DataSync.syncCalendars(json) {
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func accept(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.acceptCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
//                        DataSync.syncCalendars(json) {
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func refuse(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.refuseCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
//                        DataSync.syncCalendars(json) {
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
    
    func remove(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.removeCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
//                        DataSync.syncCalendars(json) {
//                            completionHandler(.success(nil))
//                        }
                    }
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }

    func delete(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.deleteCalendar(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...299:
                    completionHandler(.success(nil))
                default:
                    completionHandler(.error("kFail"))
                }
            case .failure(let error):
                completionHandler(.error(error.localizedDescription))
            }
        }
    }
}
