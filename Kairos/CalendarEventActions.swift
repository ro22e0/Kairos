//
//  CalendarEventActions.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 29/03/2017.
//  Copyright © 2017 Kairos-app. All rights reserved.
//

import UIKit

class CalendarEventActions: UITableViewCell {

    var cancelAction: (() -> Void)?
    var updateStatus: (() -> Void)?
    var editParticipants: (() -> Void)?
    var addParticipant: (() -> Void)?
    var delete: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func updateStatus(_ sender: Any) {
        cancelAction?()
        updateStatus?()
    }

    @IBAction func editParticipants(_ sender: Any) {
        cancelAction?()
        editParticipants?()
    }

    @IBAction func addParticipant(_ sender: Any) {
        cancelAction?()
        addParticipant?()
    }

    @IBAction func deleteMod(_ sender: Any) {
        cancelAction?()
        delete?()
    }
}
