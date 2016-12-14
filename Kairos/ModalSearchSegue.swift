//
//  ModalSearchSegue.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 25/09/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit

class ModalSearchSegue: UIStoryboardSegue {
    override func perform() {
        let src = self.sourceViewController as UIViewController
        let dst = self.destinationViewController as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransformMakeTranslation(0, -src.view.frame.size.height)
        
        UIView.animateWithDuration(0.3, animations: {
            dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
            
        }) { (Finished) in
            src.presentViewController(dst, animated: false, completion: nil)
        }
    }
}