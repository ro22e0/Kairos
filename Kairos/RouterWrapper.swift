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
    static let baseURL = "http://kairos-api-ro22e0.c9users.io/api/v1"
    
    /**
     Determine if the request need credentials in headers.
     
     - returns: A boolean `true` or `false`.
     */
    static var needToken: Bool = true
    
    case SignOut
    
    /// Create a new user.
    case CreateUser([String: AnyObject])
    
    /// Update user.
    case UpdateUser([String: AnyObject])
    
    /// Get users.
    case GetUsers
    
    /// Authenticate a user.
    case Authenticate([String: AnyObject])
    
    /// Get friends.
    case GetFriends
    
    /// Accept a friend request.
    case AcceptFriend([String: AnyObject])
    
    /// Decline a friend request.
    case DeclineFriend([String: AnyObject])
    
    /// Send a friend request.
    case InviteFriend([String: AnyObject])
    
    /// Block a friend.
    case CancelFriend([String: AnyObject])
    
    /// Remove a friend.
    case RemoveFriend([String: AnyObject])
    
    
    case GetEvents
    
    case GetEvent([String: AnyObject])
    
    case CreateEvent([String: AnyObject])
    
    case UpdateEvent([String: AnyObject])
    
    case DeleteEvent([String: AnyObject])
    
    
    case GetCalendarColors
    case GetCalendars
    
    case GetCalendar([String: AnyObject])
    
    case CreateCalendar([String: AnyObject])
    
    case UpdateCalendar([String: AnyObject])
    
    case DeleteCalendar([String: AnyObject])
    
    case InviteCalendar([String: AnyObject])
    case AcceptCalendar([String: AnyObject])
    case RefuseCalendar([String: AnyObject])
    case OwnerCalendar([String: AnyObject])
    case RemoveCalendar([String: AnyObject])
    
    /**
     The method use for the request.
     
     - returns: A `HTTPMethod`.
     */
    var method: HTTPMethod {
        switch self {
        case .CreateUser, .Authenticate, .InviteFriend, .CreateCalendar, .CreateEvent:
            return .POST
        case .GetFriends, .GetUsers, .GetEvents, .GetEvent, .GetCalendars, .GetCalendar, GetCalendarColors:
            return .GET
        case .UpdateUser, .AcceptFriend, .DeclineFriend, .UpdateEvent, .UpdateCalendar, .InviteCalendar, .AcceptCalendar, .RefuseCalendar, .OwnerCalendar, .RemoveCalendar:
            return .PUT
        case .RemoveFriend, .CancelFriend, .DeleteEvent, .DeleteCalendar, .SignOut:
            return .DELETE
        }
    }
    
    /**
     The endpoint of the request.
     
     - returns: A string represent the endpoint.
     */
    var path: String {
        switch self {
        case .CreateUser:
            return "/auth"
        case .Authenticate:
            return "/auth/sign_in"
        case .GetFriends:
            return "/friends"
        case .InviteFriend:
            return "/friends/invite"
        case .CancelFriend:
            return "/friends/cancel"
        case .AcceptFriend:
            return "/friends/accept"
        case .DeclineFriend:
            return "/friends/refuse"
        case .RemoveFriend:
            return "/friends/remove"
            
        case .GetUsers:
            return "/users"
        case .UpdateUser(let parameters):
            return "/users/\(parameters["id"]!)"
            
        case .CreateEvent, .GetEvents:
            return "/events"
        case .UpdateEvent(let parameters):
            return "/events/\(parameters["id"]!)"
        case .GetEvent(let parameters):
            return "/events/\(parameters["id"]!)"
        case .DeleteEvent(let parameters):
            return "/events/\(parameters["id"]!)"
            
        case .CreateCalendar, .GetCalendars:
            return "/calendars"
        case .GetCalendarColors:
            return "/calendars/colors"
        case .UpdateCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .GetCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .DeleteCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)"
        case .InviteCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/invite"
        case .AcceptCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/accept"
        case .RefuseCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/refuse"
        case .OwnerCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/set_owner"
        case .RemoveCalendar(let parameters):
            return "/calendars/\(parameters["id"]!)/remove"
        case .SignOut:
            return "/auth/sign_out"
        }
    }
    
    // MARK: URLRequestConvertible
    
    /**
     The request.
     
     - returns: The request as `NSMutableURLRequest` use by `RouterWrapper`.
     */
    public var URLRequest: NSMutableURLRequest {
        let URL = NSURL(string: Router.baseURL)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        print(Router.needToken)
        
        if Router.needToken {
            let credentials = UserManager.sharedInstance.getCredentials()
            mutableURLRequest.setValue(credentials["access-token"], forHTTPHeaderField: "access-token")
            mutableURLRequest.setValue(credentials["client"], forHTTPHeaderField: "client")
            mutableURLRequest.setValue(credentials["uid"], forHTTPHeaderField: "uid")
        }
        
        switch self {
        case .CreateUser(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateUser(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .Authenticate(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .InviteFriend(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .CancelFriend(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .AcceptFriend(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .DeclineFriend(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .RemoveFriend(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
        case .GetFriends, .GetUsers, .GetEvents, .GetEvent, .DeleteEvent, .GetCalendars, .GetCalendarColors, .GetCalendar, .AcceptCalendar, .RefuseCalendar, .DeleteCalendar, .SignOut:
            return mutableURLRequest
        case .CreateEvent(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateEvent(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .CreateCalendar(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .UpdateCalendar(let parameters):
            return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
        case .InviteCalendar(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["user_id": parameters["user_id"]!]).0
        case .OwnerCalendar(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["user_id": parameters["user_id"]!]).0
        case .RemoveCalendar(let parameters):
            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: ["user_id": parameters["user_id"]!]).0
        }
    }
}

/**
 Responsible for creating and managing `RouterWrapper` requests, as well as their underlying `URLRequestConvertible`.
 */
class RouterWrapper: NSObject, NSURLSessionTaskDelegate {
    
    // MARK: - Singleton
    
    /**
     Initialize the shared instance of RouterWrapper.
     
     - returns: The instance created.
     */
    static let sharedInstance = RouterWrapper()
    
    private override init() {}
    
    /**
     Initialize the manager use by Alamofire.
     
     - returns: The created manager.
     */
    private lazy var manager: Manager = {
        let config: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 15.0
        
        return Alamofire.Manager(configuration: config)
    }()
    
    /**
     Creates a request for the specified URL request.
     
     - parameters:
     - route: The request define in enum Router
     - completionHandler: A closure to be executed once the request has finished.
     */
    func request(request: Router, completionHandler: Response<AnyObject, NSError> -> Void) {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager!.listener = { (status) in
            print("Network Status Changed: \(status)")
            switch status {
            case .Reachable(.WWAN):
                break
            case .Reachable(.EthernetOrWiFi):
                break
            case .NotReachable:
                manager!.startListening()
            default:
                break
            }
        }
        manager!.startListening()
        RouterWrapper.sharedInstance.manager.request(request).responseJSON(completionHandler: completionHandler)
        //RouterWrapper.sharedInstance.manager.request(request).responseJSON(queue: queue, options: .AllowFragments, completionHandler: completionHandler)
    }
}
