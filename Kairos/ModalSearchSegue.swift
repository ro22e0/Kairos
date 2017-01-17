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
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
        
        UIView.animate(withDuration: 0.3, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
            
        }, completion: { (Finished) in
            src.present(dst, animated: false, completion: nil)
        }) 
    }
}
