//
//  CalendarRequestsActions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 28/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit
import SwiftMessages

class CalendarRequestsActions: MessageView {

    var cancelAction: (() -> Void)?
    var createEvent: (() -> Void)?
    var createCalendar: (() -> Void)?
    var eventsRequests: (() -> Void)?
    var calendarsRequests: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func createEvent(_ sender: Any) {
        cancelAction?()
        createEvent?()
    }

    @IBAction func createCalendar(_ sender: Any) {
        cancelAction?()
        createCalendar?()
    }

    @IBAction func eventsRequests(_ sender: Any) {
        cancelAction?()
        eventsRequests?()
    }

    @IBAction func calendarsRequests(_ sender: Any) {
        cancelAction?()
        calendarsRequests?()
    }
}
