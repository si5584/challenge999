//
//  GameVC.swift
//  999challenge
//
//  Created by Simon Lovelock on 16/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//

import UIKit
import iAd
import Social
import Accounts
import CoreData

class GameVC: UIViewController, ADInterstitialAdDelegate {
    
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var livesLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedGame : Int!
    
    var game : Game!
    //var currentLives : Int!
    //var currentLevel : Int!
    //var currentTarget : Double!
    var currentTime : Double = 0.00
    var counter = 0
    
    var gameTimer : NSTimer!
    var delayTimer : NSTimer!
    
    
    var interAd = ADInterstitialAd()
    var interAdView = UIView()
    var closeAdButton = UIButton(type: UIButtonType.System) as UIButton

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.backButton.backgroundColor = UIColor(red: 95/255, green: 151/255, blue: 255/255, alpha: 1)
        self.saveButton.backgroundColor = UIColor(red: 92/255, green: 151/255, blue: 255/255, alpha: 1)
        //self.game = Game(gameType: self.selectedGame)
        
        if !(self.game.chill) {
            self.speedSlider.hidden = true
            self.speedLabel.hidden = true
        }
        
        updateLabels()
        self.canDisplayBannerAds = true
        
    }

    func updateLabels() {
        self.levelLabel.text = "Level: \(self.game.level)"
        
        let target = Double(self.game.currentTarget)
        self.targetLabel.text = String(format: "Target Time: %0.2f", target/100)
        
        if !(self.game.infinite) {
            self.livesLabel.text = "Lives: \(self.game.lives)"
        } else {
            self.livesLabel.text = "Lives: infinite"
        }
    }
    
    @IBAction func gameButtonPressed (sender: UIButton) {
        
        if sender.titleLabel?.text == "Start" {
            self.gameButton.backgroundColor = UIColor.redColor()
            self.gameButton.setTitle("Stop", forState: .Normal)
            startTimer()
        } else if sender.titleLabel?.text == "Stop" {
            self.gameButton.backgroundColor = UIColor(red: 255/255, green: 121/255, blue: 35/255, alpha: 1)
            self.gameButton.setTitle("Reset", forState: .Normal)
            self.gameTimer.invalidate()
            checkResult()
        } else if sender.titleLabel?.text == "Reset"{
                self.gameButton.backgroundColor = UIColor.greenColor()
                self.gameButton.setTitle("Start", forState: .Normal)
                self.resetTimerAndCounter()
                updateLabels()
        } else {
            self.game = Game(gameType: self.selectedGame)
            self.gameButton.backgroundColor = UIColor.greenColor()
            self.gameButton.setTitle("Start", forState: .Normal)
            self.gameOverLabel.hidden = true
            resetTimerAndCounter()
            updateLabels()
        }
        
    }
    
    func gameOverUpdate() {
        updateLabels()
        //loadAd()
        self.gameButton.setTitle("New Game", forState: .Normal)
        self.gameButton.backgroundColor = UIColor.purpleColor()
        self.gameOverLabel.hidden = false
        self.gameOverLabel.layer.masksToBounds = true
        self.gameOverLabel.layer.cornerRadius = 5.0
        self.gameButton.alpha = 1
    }
    
    func updateTimerAndCounter () {
        self.currentTime += 0.01
        self.counter += 1
        
        self.timerLabel.text = String(format: "%0.2f",self.currentTime)
    }
    
    func startTimer () {
        
        let triggerTime = 0.01 / self.game.gameSpeed
        
        self.gameTimer = NSTimer.scheduledTimerWithTimeInterval(triggerTime, target: self, selector: #selector(GameVC.updateTimerAndCounter), userInfo: nil, repeats: true)
        
    }

    func checkResult () {
        
        if self.counter == self.game.currentTarget {

            saveNewGameRecord()
            
            self.game.progressLevel()
            self.game.resetLives()
            
            shareToFacebook()
            
        } else {
            self.game.loseLife()
        }
        
        if gameOver() {
            self.gameButton.alpha = 0
            loadAd()
            self.delayTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(GameVC.gameOverUpdate), userInfo: nil, repeats: false)
        }
    }
    
    func resetTimerAndCounter() {
        self.counter = 0
        self.timerLabel.text = "0.00"
        self.currentTime = 0.00
    }
    
    func gameOver() -> Bool {
        if self.game.lives <= 0 && self.game.title != "infinite"{
            return true
        } else {
            return false
        }
    }
    
    @IBAction func backPressed() {
        
        if self.game.isASavedGame {
        
        // Save updated levels if it was a loaded game
        // Update CoreData Values
         print("updating saved game details")
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let savedLevelsRequest = NSFetchRequest(entityName: "SavedLevels")
            do {
                let savedDetails = try context.executeFetchRequest(savedLevelsRequest) as! [SavedLevels]
                if savedDetails.count != 0 {
                    let data = savedDetails[0]
                    data.setValue(self.game.level, forKey: "\(self.game.title)Level")
                    data.setValue(self.game.lives, forKey: "\(self.game.title)Lives")
                    print("\(data)")
                    do {
                        try context.save()
                    } catch {print("saveButtonPressed catch 1")}
                    
                }
            } catch {print("saveButtonPressed catch 2")}
        }
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func sliderMoved(sender: UISlider) {
        let speedVal = Double(sender.value)
        self.game.gameSpeed = speedVal
        
        self.speedLabel.text = String(format: "%0.1fx", speedVal)
        //print(speedVal)
        
    }
    
    // Interstitial Ad Functions
    
    func close(sender: UIButton) {
        closeAdButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    }
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        closeAdButton.frame = CGRectMake(15, 15, 30, 30)
        closeAdButton.layer.cornerRadius = 15
        closeAdButton.setTitle("X", forState: .Normal)
        closeAdButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        closeAdButton.backgroundColor = UIColor.whiteColor()
        closeAdButton.layer.borderColor = UIColor.blackColor().CGColor
        closeAdButton.layer.borderWidth = 1
        closeAdButton.addTarget(self, action: #selector(GameVC.close(_:)), forControlEvents: UIControlEvents.TouchDown)
        
        
        print("Ad did load")
        
        interAdView = UIView()
        interAdView.frame = self.view.bounds
        self.view.addSubview(interAdView)
        
        interAd.presentInView(interAdView)
        UIViewController.prepareInterstitialAds()
        
        interAdView.addSubview(closeAdButton)
    }
    
    func loadAd() {
        print("Loading Ad")
        interAd = ADInterstitialAd()
        interAd.delegate = self
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        print("Interstitial Ad Failed to Receive")
        print(error.localizedDescription)
        
        closeAdButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        
    }
    
    func shareToFacebook () {
        if (SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook)){
            let facebookSheet : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("BOOM!! Just reached level \(self.game.level) in the 999CHALLENGE #999challenge #pumped")
            facebookSheet.addImage(UIImage(named: "999challenge_blue.png"))
            
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Facebook Account Unavailable", message: "Please add a facebook account to share your success!", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        //Update CoreData Value
        print("save pressed")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let savedLevelsRequest = NSFetchRequest(entityName: "SavedLevels")
        
        do {
            let savedDetails = try context.executeFetchRequest(savedLevelsRequest) as! [SavedLevels]
            if savedDetails.count != 0 {
                let data = savedDetails[0]
                data.setValue(self.game.level, forKey: "\(self.game.title)Level")
                data.setValue(self.game.lives, forKey: "\(self.game.title)Lives")
                print("\(data)")
                do {
                    try context.save()
                } catch {print("saveButtonPressed catch 1")}
                
            }
        } catch {print("saveButtonPressed catch 2")}
    }
    
    func saveNewGameRecord() {
        
        print("new high score saving")
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let savedLevelsRequest = NSFetchRequest(entityName: "SavedLevels")
        
        do {
            let savedDetails = try context.executeFetchRequest(savedLevelsRequest) as! [SavedLevels]
            if savedDetails.count != 0 {
                let data = savedDetails[0]
                data.setValue(self.game.level, forKey: "\(self.game.title)Record")
                //print("\(data)")
                do {
                    try context.save()
                } catch {print("saveNewGameRecord catch 1")}
                
            }
        } catch {print("saveNewGameRecord catch 2")}
    }
    
}
