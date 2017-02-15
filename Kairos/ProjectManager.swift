//
//  ProjectManager.swift
//  Kairos
//
//  Created by rba3555 on 17/01/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: Singleton
class ProjectManager {

    static let shared = ProjectManager()
    fileprivate init() {}

    func fetch(_ handler: (() -> Void)? = nil) {
        DataSync.fetchProjects() { (status) in
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
    
    func all() -> [Project] {
        if let projects = Project.all() as? [Project] {
            return projects
        } else {
            return [Project]()
        }
    }
    
    func projects(withStatus status: UserStatus) -> [Project] {
        var projects = [Project]()
        guard let user = UserManager.shared.current.user else {
            return projects
        }
        
        if let test = user.projects?.allObjects as? [Project] {
            print(test)
        }
        
        switch status {
        case .Invited:
            if let projectObjs = user.invitedProjects {
                projects = projectObjs.allObjects as! [Project]
            }
        case .Owner:
            if let projectObjs = user.ownedProjects {
                projects = projectObjs.allObjects as! [Project]
            }
        case .Participating:
            if let projectObjs = user.projects, let ownedProjectObjs = user.ownedProjects {
                projects = projectObjs.allObjects as! [Project]
                projects += ownedProjectObjs.allObjects as! [Project]
            }
        case .Refused:
            if let projectObjs = user.refusedProjects {
                projects = projectObjs.allObjects as! [Project]
            }
        default: break
        }
        return projects
    }
    
    func userIsIn(_ project: Project, user: User) -> Bool {
        //            let users = project.projectUsers?.allObjects as? [UserProject]
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
    
    func allUsers(forProject project: Project) -> [User] {
        var users: [User] = project.invitedUsers?.allObjects as! [User]
        users += project.owners?.allObjects as! [User]
        users += project.participatingUsers?.allObjects as! [User]
        users += project.refusedUsers?.allObjects as! [User]
        return users
    }
    
    func users(withStatus status: UserStatus, forProject project: Project) -> [User] {
        var users: [User]
        
        switch status {
        case .Invited:
            users = project.invitedUsers?.allObjects as! [User]
        case .Owner:
            users = project.owners?.allObjects as! [User]
        case .Participating:
            users = project.participatingUsers?.allObjects as! [User]
        case .Refused:
            users = project.refusedUsers?.allObjects as! [User]
        default:
            users = []
        }
        return users
    }
    
    func delete(user: User, fromProject project: Project) {
        var users = project.invitedUsers?.allObjects as! [User]
        if users.contains(user) {
            project.removeFromInvitedUsers(user)
        }
        users = project.owners?.allObjects as! [User]
        if users.contains(user) {
            project.removeFromOwners(user)
        }
        users = project.participatingUsers?.allObjects as! [User]
        if users.contains(user) {
            project.removeFromParticipatingUsers(user)
        }
        users = project.refusedUsers?.allObjects as! [User]
        if users.contains(user) {
            project.removeFromRefusedUsers(user)
        }
    }
    
    func create(_ parameters: [String: Any], completionHandler: @escaping (StatusRequest) -> Void) {
        RouterWrapper.shared.request(.createProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncProjects(json) {
                            
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
        RouterWrapper.shared.request(.updateProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        print(json)
                        DataSync.syncProjects(json) {
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
        RouterWrapper.shared.request(.inviteProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncProjects(json) {
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
        RouterWrapper.shared.request(.acceptProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncProjects(json) {
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
        RouterWrapper.shared.request(.refuseProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncProjects(json) {
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
        RouterWrapper.shared.request(.removeProject(parameters)) { (response) in
            switch response.result {
            case .success:
                switch response.response!.statusCode {
                case 200...203:
                    if let value = response.result.value {
                        let json = JSON(value)
                        DataSync.syncProjects(json) {
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
        RouterWrapper.shared.request(.deleteProject(parameters)) { (response) in
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
