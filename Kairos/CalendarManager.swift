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
    
    func all() -> [UserCalendar] {
        if let calendars = UserCalendar.all() as? [UserCalendar] {
            return calendars
        } else {
            return [UserCalendar]()
        }
    }

    func calendars(withStatus status: UserStatus) -> [UserCalendar] {
//        if var calendars = UserManager.shared.current.userCalendars?.allObjects as? [UserCalendar] {
//            calendars = calendars.filter({ (uCalendar) -> Bool in
//                if status == .Participating {
//                    return uCalendar.status == UserStatus.Owner.rawValue || uCalendar.status == status.rawValue
//                }
//                return uCalendar.status == status.rawValue
//            })
//            return calendars
//        } else {
//            return [UserCalendar]()
//        }
        return [UserCalendar]()
    }

        func userIsIn(_ calendar: Calendar, user: User) -> Bool {
//            let users = calendar.calendarUsers?.allObjects as? [UserCalendar]
//            var isIn = false
//            isIn = (users?.contains({ (u) -> Bool in
//                return u.userId == user.id
//            }))!
//    //        users?.forEach({ (u) in
//    //            if u.userId == user.id {
//    //                isIn = true
//    //            }
//    //        })
//            return isIn
            return true
        }
    
    func users(forCalendar calendar: Calendar) -> [UserCalendar] {
//        if let users = calendar.calendarUsers?.allObjects as? [UserCalendar] {
//            return users
//        } else {
//            return [UserCalendar]()
//        }
        return [UserCalendar]()
    }

    func deleteUser(_ user: User, forCalendar calendar: Calendar) {
        if let user = UserCalendar.find("userId == %@ AND calendarId == %@", args: user.id!, calendar.id!) {
            user.delete()
            UserCalendar.save()
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
                        DataSync.syncCalendars([json])
                    }
                    completionHandler(.success(nil))
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
