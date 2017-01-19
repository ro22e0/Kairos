//
//  RouterWrapper.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 10/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import Alamofire

/**
 HTTP method definitions.
 
 See [https://tools.ietf.org/html/rfc7231#section-4.3](https://tools.ietf.org/html/rfc7231#section-4.3)
 */
public enum HTTPMethod: String {
    case GET, HEAD, POST, PUT, PATCH, DELETE, CONNECT, OPTIONS, TRACE
}

/**
 Request use by `RouterWrapper`.
 */
public enum Router: URLRequestConvertible {
    
    /**
     Initialize the host URL of the server.
     
     - returns: A `String` baseURL.
     */
    static let baseURLString = "http://kairos-api-ro22e0.c9users.io/api/v1"
    
    /**
     Determine if the request need credentials in headers.
     
     - returns: A boolean `true` or `false`.
     */
    var needToken: Bool {
        switch self {
        case .authenticate, .createUser:
            return false
        default:
            return true
        }
    }
    
    case signOut
    
    /// Create a new user.
    case createUser(Parameters)
    
    /// Update user.
    case updateUser(Parameters)
    
    /// Get users.
    case getUsers
    
    /// Authenticate a user.
    case authenticate(Parameters)
    
    /// Get friends.
    case getFriends
    
    /// Accept a friend request.
    case acceptFriend(Parameters)
    
    /// Decline a friend request.
    case declineFriend(Parameters)
    
    /// Send a friend request.
    case inviteFriend(Parameters)
    
    /// Block a friend.
    case cancelFriend(Parameters)
    
    /// Remove a friend.
    case removeFriend(Parameters)
    
    
    case getCalendarColors
    case getCalendars
    case getCalendar(Parameters)

    case createCalendar(Parameters)
    case updateCalendar(Parameters)
    case deleteCalendar(Parameters)
    
    case inviteCalendar(Parameters)
    case acceptCalendar(Parameters)
    case refuseCalendar(Parameters)
    case ownerCalendar(Parameters)
    case removeCalendar(Parameters)

    
    case getEvents
    case getEvent(Parameters)
    
    case createEvent(Parameters)
    case updateEvent(Parameters)
    case deleteEvent(Parameters)

    case inviteEvent(Parameters)
    case acceptEvent(Parameters)
    case refuseEvent(Parameters)
    case ownerEvent(Parameters)
    case removeEvent(Parameters)


    case getProjects
    case getProject(Parameters)

    case createProject(Parameters)
    case updateProject(Parameters)
    case deleteProject(Parameters)

    case inviteProject(Parameters)
    case acceptProject(Parameters)
    case refuseProject(Parameters)
    case ownerProject(Parameters)
    case removeProject(Parameters)
    
    case getTasks
    case getTask(Parameters)
    
    case createTask(Parameters)
    case updateTask(Parameters)
    case deleteTask(Parameters)
    
    case inviteTask(Parameters)
    case removeTask(Parameters)
    
    /**
     The method use for the request.
     
     - returns: A `HTTPMethod`.
     */
    var method: HTTPMethod {
        switch self {
        case .createUser, .authenticate, .inviteFriend, .createCalendar, .createEvent, .createProject, .createTask:
            return .POST
        case .getFriends, .getUsers, .getEvents, .getEvent, .getCalendars, .getCalendar, .getCalendarColors, .getProjects, .getProject, .getTasks, .getTask:
            return .GET
        case .updateUser, .acceptFriend, .declineFriend, .updateEvent, .updateCalendar, .inviteCalendar, .acceptCalendar, .refuseCalendar, .ownerCalendar, .removeCalendar, .inviteEvent, .acceptEvent, .refuseEvent, .ownerEvent, .removeEvent, .updateProject, .inviteProject, .acceptProject, .refuseProject, .ownerProject, .removeProject, .updateTask, .inviteTask, .removeTask:
            return .PUT
        case .removeFriend, .cancelFriend, .deleteEvent, .deleteCalendar, .deleteProject, .deleteTask, .signOut:
            return .DELETE
        }
    }
    
    /**
     The endpoint of the request.
     
     - returns: A string represent the endpoint.
     */
    var path: String {
        switch self {
        case .createUser:
            return "/auth"
        case .authenticate:
            return "/auth/sign_in"
        case .getFriends:
            return "/friends"
        case .inviteFriend:
            return "/friends/invite"
        case .cancelFriend:
            return "/friends/cancel"
        case .acceptFriend:
            return "/friends/accept"
        case .declineFriend:
            return "/friends/refuse"
        case .removeFriend:
            return "/friends/remove"
            
        case .getUsers:
            return "/users"
        case .updateUser(let parameters):
            return "/users/\(parameters["id"]!)"
            
        case .createEvent, .getEvents:
            return "/events"
        case .updateEvent(let parameters):
            return "/events/\(parameters["id"]!)"
        case .getEvent(let parameters):
            return "/events/\(parameters["id"]!)"
        case .deleteEvent(let parameters):
            return "/events/\(parameters["id"]!)"
        case .inviteEvent(let parameters):
            return "/events/\(parameters["id"]!)/invite"
        case .acceptEvent(let parameters):
            return "/events/\(parameters["id"]!)/accept"
        case .refuseEvent(let parameters):
            return "/events/\(parameters["id"]!)/refuse"
        case .ownerEvent(let parameters):
            return "/events/\(parameters["id"]!)/set_owner"
        case .removeEvent(let parameters):
            return "/events/\(parameters["id"]!)/remove"
            
        case .createCalendar, .getCalendars:
            return "/calendars"
        case .getCalendarColors:
            return "/calendars/colors"
        case .updateCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .getCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .deleteCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .inviteCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/invite"
        case .acceptCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/accept"
        case .refuseCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/refuse"
        case .ownerCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/set_owner"
        case .removeCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/remove"
            
        case .createProject, .getProjects:
            return "/projects"
        case .updateProject(let parameters):
            return "/projects/\(parameters["id"]!)"
        case .getProject(let parameters):
            return "/projects/\(parameters["id"]!)"
        case .deleteProject(let parameters):
            return "/projects/\(parameters["id"]!)"
        case .inviteProject(let parameters):
            return "/projects/\(parameters["id"]!)/invite"
        case .acceptProject(let parameters):
            return "/projects/\(parameters["id"]!)/accept"
        case .refuseProject(let parameters):
            return "/projects/\(parameters["id"]!)/refuse"
        case .ownerProject(let parameters):
            return "/projects/\(parameters["id"]!)/set_owner"
        case .removeProject(let parameters):
            return "/projects/\(parameters["id"]!)/remove"
            
        case .createTask, .getTasks:
            return "/tasks"
        case .updateTask(let parameters):
            return "/tasks/\(parameters["id"]!)"
        case .getTask(let parameters):
            return "/tasks/\(parameters["id"]!)"
        case .deleteTask(let parameters):
            return "/tasks/\(parameters["id"]!)"
        case .inviteTask(let parameters):
            return "/tasks/\(parameters["id"]!)/add"
        case .removeTask(let parameters):
            return "/tasks/\(parameters["id"]!)/remove"

        case .signOut:
            return "/auth/sign_out"
        }
    }
    
    // MARK: URLRequestConvertible
    
    /**
     The request.
     
     - returns: The request as `NSMutableURLRequest` use by `RouterWrapper`.
     */
    public func asURLRequest() throws -> URLRequest {
        let url = try Router.baseURLString.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue

        print(needToken)
        
        if needToken {
            let credentials = UserManager.shared.getCredentials()
            urlRequest.setValue(credentials["access-token"], forHTTPHeaderField: "access-token")
            urlRequest.setValue(credentials["client"], forHTTPHeaderField: "client")
            urlRequest.setValue(credentials["uid"], forHTTPHeaderField: "uid")
        }

        switch self {
        case .createUser(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateUser(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .authenticate(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .inviteFriend(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .cancelFriend(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .acceptFriend(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .declineFriend(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .removeFriend(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        case .createEvent(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateEvent(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .inviteEvent(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .ownerEvent(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .removeEvent(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .createCalendar(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateCalendar(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .inviteCalendar(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .ownerCalendar(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .removeCalendar(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .createProject(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateProject(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .inviteProject(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .ownerProject(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .removeProject(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .createTask(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .updateTask(let parameters):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: parameters)
        case .inviteTask(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .removeProject(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["user_id": parameters["user_id"]!])
        case .getTask(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["project_id": parameters["project_id"]!])
        case .deleteTask(let parameters):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["project_id": parameters["project_id"]!])

        default:
            break;
        }
        return urlRequest
    }
}

/**
 Responsible for creating and managing `RouterWrapper` requests, as well as their underlying `URLRequestConvertible`.
 */
class RouterWrapper: NSObject, URLSessionTaskDelegate {
    
    // MARK: - Singleton
    
    /**
     Initialize the shared instance of RouterWrapper.
     
     - returns: The instance created.
     */
    static let shared = RouterWrapper()
    
    private override init() {}
    
    /**
     Initialize the manager use by Alamofire.
     
     - returns: The created manager.
     */
    private lazy var manager: SessionManager = {
        let config: URLSessionConfiguration = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        
        return SessionManager(configuration: config)
    }()
    
    /**
     Creates a request for the specified URL request.
     
     - parameters:
     - route: The request define in enum Router
     - completionHandler: A closure to be executed once the request has finished.
     */
    func request(_ request: Router, completionHandler: @escaping (DataResponse<Any>) -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager!.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .reachable(.wwan):
                break
            case .reachable(.ethernetOrWiFi):
                break
            case .notReachable:
                manager!.startListening()
            case .unknown:
                break
            }
        }
        manager!.startListening()
        self.manager.request(request).responseJSON(completionHandler: completionHandler)
        //RouterWrapper.shared.manager.request(request).responseJSON(queue: queue, options: .AllowFragments, completionHandler: completionHandler)
    }
}
