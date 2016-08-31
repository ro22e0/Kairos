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
        notesTextView.textColor = UIColor.lightGrayColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func configure(event: Event) {
        super.configure(event)
        
        notesTextView.textColor = UIColor.blackColor()
        notesTextView.text = event.notes
    }
    
    override func updateEvent(notification: NSNotification) {
        super.updateEvent(notification)
        
        let event = notification.userInfo!["event"] as! Event
        
        event.notes = notesTextView.text
    }

    // MARK: UITextViewDelegate

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Description"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}
