//
//  EventNotesTableViewCell.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 05/05/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class EventNotesTableViewCell: BaseEventTableViewCell, UITextViewDelegate {

    @IBOutlet weak var notesTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        notesTextView.delegate = self
        notesTextView.text = "Description"
        notesTextView.textColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(_ event: Event) {
        super.configure(event)
        
        notesTextView.textColor = UIColor.black
        notesTextView.text = event.notes
    }
    
    override func updateEvent(_ notification: Notification) {
        let event = notification.userInfo!["event"] as! Event
        
        event.notes = notesTextView.text

        super.updateEvent(notification)
    }

    // MARK: UITextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
