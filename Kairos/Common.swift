//
//  Common.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 17/03/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import UIKit

enum StoryboardID: String {
    case Main
    case Calendar
    case Login
    case Board
    case Friends
    case Profile
    case Settings
}

// Detele replace by StoryboardID enum
let MainStoryboardID = "Main"
let CalendarStoryboardID = "Calendar"
let LoginStoryboardID = "Login"
let BoardStoryboardID = "Board"
let MenuStoryboardID = "Menu"
let FriendsStoryboardID = "Friends"
let ProfileStoryboardID = "Profile"
let SettingsStoryboardID = "Settings"

let kUSER_GOOGLE_AUTH_NOTIFICATION = "kUserGoogleAuth"

let kEventWillSaveNotification = "EventWillSave"
let kCalendarWillSaveNotification = "CalendarWillSave"

enum Notifications: String {
    case CalendarDidChange
}

let userLoginKey = "userLoginKey"
let userTokenKey = "userTokenKey"
let userClientKey = "userClientKey"
let userUIDKey = "userUIDKey"

enum LoginSDK: String {
    case Facebook = "Facebook"
    case Google = "Google"
}

enum FriendStatus: String {
    case Pending = "pending"
    case Requested = "requested"
    case Accepted = "accepted"
}

enum UserStatus: String {
    case Owner = "owner"
    case Participating = "participating"
    case Invited = "invited"
    case Refused = "refused"
    case Removed = "removed"
}

enum CustomStatus {
    case success
    case error(String)
}

enum StatusRequest {
    case success(Any?)
    case error(String)
}
