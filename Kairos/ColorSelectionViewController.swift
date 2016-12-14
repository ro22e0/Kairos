//
//  ColorSelectionViewController.swift
//  Kairos
//
//  Created by Ronaël Bajazet on 24/11/2016.
//  Copyright © 2016 Kairos-app. All rights reserved.
//

import UIKit
import DynamicColor

class ColorSelectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var colorCollectionView: UICollectionView!

    var onSelected: ((String)->Void)?

    var colors: [String: String] = [:]
    let colorStrings = ["purple", "red", "green", "orange", "cyan", "yellow", "blue"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        contentView.layer.cornerRadius = 25
        colors = CalendarManager.sharedInstance.colors
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorItem", forIndexPath: indexPath)

        // Configure the cell
        cell.backgroundColor = DynamicColor(hexString: colors[colorStrings[indexPath.row]]!)
        cell.round()
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        onSelected!(colorStrings[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
