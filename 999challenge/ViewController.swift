//
//  ViewController.swift
//  999challenge
//
//  Created by Simon Lovelock on 16/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//

import UIKit
import iAd
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var star1: UIImageView!
    @IBOutlet weak var star2: UIImageView!
    @IBOutlet weak var star3: UIImageView!
    @IBOutlet weak var star4: UIImageView!
    @IBOutlet weak var star5: UIImageView!
    @IBOutlet weak var star6: UIImageView!
    @IBOutlet weak var star7: UIImageView!
    @IBOutlet weak var star8: UIImageView!
    @IBOutlet weak var star9: UIImageView!
    
    var starArray : [UIImageView]!
    var savedLevels = [SavedLevels]()
    var challengeRecord : Int = 0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.starArray = [star1,star2,star3,star4,star5,star6,star7,star8]
        
        loadChallengeRecord()
        

        
        self.canDisplayBannerAds = true
    }
    
    override func viewWillAppear(animated: Bool) {
        loadChallengeRecord()
        
        //Loop through starArray and show the number corresponding to challenge record
        
        for i in 0 ..< self.challengeRecord {
            self.starArray[i].alpha = 1
        }
        
//        if challengeRecord == 1 {
//            self.star1.alpha = 1
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func loadSavedGames(sender: UIButton) {
        let loadGame = true
        self.performSegueWithIdentifier("segueToGameSelector", sender: loadGame)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destVC = segue.destinationViewController as! GameSelectionVC
        let loadGame = sender as? Bool
        if ((loadGame?.boolValue) != nil) {
            destVC.loadSavedLevel = true
        }
    }
    
    func loadChallengeRecord() {
        
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let savedLevelsRequest = NSFetchRequest(entityName: "SavedLevels")
        do {
            try self.savedLevels = context.executeFetchRequest(savedLevelsRequest) as! [SavedLevels]
        } catch {
            print("No saved levels")
        }
        
        if !savedLevels.isEmpty{
            self.challengeRecord = Int(savedLevels[0].challengeRecord!)
        }
    }
    
    
}

