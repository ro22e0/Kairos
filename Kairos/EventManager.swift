//
//  EventManager.swift
//  Kairos
//
//  Created by rba3555 on 16/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON

class EventManager {
    
    static let shared = EventManager()
    private init() {}
    
    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchEvents() { (status) in
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
    
    func all() -> [Event] {
        if let events = Event.all() as? [Event] {
            return events
        } else {
            return [Event]()
        }
    }
    
    func events(withStatus status: UserStatus) -> [Event] {
        var events = [Event]()
        guard let user = UserManager.shared.current.user else {
            return events
        }

        switch status {
        case .Invited:
            if let eventObjs = user.invitedEvents {
                events = eventObjs.allObjects as! [Event]
            }
        case .Owner:
            if let eventObjs = user.ownedEvents {
                events = eventObjs.allObjects as! [Event]
            }
        case .Participating:
            if let eventObjs = user.events, let ownedEventObjs = user.ownedEvents {
                events = eventObjs.allObjects as! [Event]
                events += ownedEventObjs.allObjects as! [Event]
            }
        case .Refused:
            if let calendarObjs = user.refusedEvents {
                events = calendarObjs.allObjects as! [Event]
            }
        default: break
        }
        return events
    }
    
    func allUsers(forEvent event: Event) -> [User] {
        var users: [User] = event.invitedUsers?.allObjects as! [User]
        users += event.owners?.allObjects as! [User]
        users += event.participatingUsers?.allObjects as! [User]
        users += event.refusedUsers?.allObjects as! [User]
        return users
    }
    
    func users(withStatus status: UserStatus, forEvent event: Event) -> [User] {
        var users: [User]
        
        switch status {
        case .Invited:
            users = event.invitedUsers?.allObjects as! [User]
        case .Owner:
            users = event.owners?.allObjects as! [User]
        case .Participating:
            users = event.participatingUsers?.allObjects as! [User]
        case .Refused:
            users = event.refusedUsers?.allObjects as! [User]
        default:
            users = []
        }
        return users
    }
    
    func delete(user: User, fromEvent event: Calendar) {
        var users = event.invitedUsers?.allObjects as! [User]
        if users.contains(user) {
            event.removeFromInvitedUsers(user)
        }
        users = event.owners?.allObjects as! [User]
        if users.contains(user) {
            event.removeFromOwners(user)
        }
        users = event.participatingUsers?.allObjects as! [User]
        if users.contains(user) {
            event.removeFromParticipatingUsers(user)
        }
        users = event.refusedUsers?.allObjects as! [User]
        if users.contains(user) {
            event.removeFromRefusedUsers(user)
        }
    }
    
    func create(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.createEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.updateEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.inviteEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.acceptEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.refuseEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.removeEvent(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncEvents(json) {
                            completionHandler(.success(nil))
                        }
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
        RouterWrapper.shared.request(.deleteEvent(parameters)) { (response) in
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
