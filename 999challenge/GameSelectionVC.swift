//
//  GameSelectionVC.swift
//  999challenge
//
//  Created by Simon Lovelock on 16/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//

import UIKit
import StoreKit
import CoreData
import iAd

class GameSelectionVC: UIViewController, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    @IBOutlet weak var challengeButton : UIButton!
    @IBOutlet weak var infiniteButton : UIButton!
    @IBOutlet weak var randomButton : UIButton!
    @IBOutlet weak var timeChillButton : UIButton!
    
    var selectedGameTag : Int!
    var products : [SKProduct] = []
    var gameTypes = [GameType]()
    var savedLevels = [SavedLevels]()
    var loadSavedLevel : Bool = false
    var loadedGame : Game?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let gameTypesRequest = NSFetchRequest(entityName: "GameType")
        let savedLevelsRequest = NSFetchRequest(entityName: "SavedLevels")
        do {
            try self.gameTypes = context.executeFetchRequest(gameTypesRequest) as! [GameType]
            if self.gameTypes.count == 0 {
                generateGameTypes()
            }
            try self.savedLevels = context.executeFetchRequest(savedLevelsRequest) as! [SavedLevels]
        } catch {
            print("No game types to store")
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        self.canDisplayBannerAds = true
        
        setupButtons()
        prepareForPurchase()
        
    }
    
    func prepareForPurchase() {
        let productSet : Set<String> = ["com.halo22.999challenge.infinite","com.halo22.999challenge.timechill"]
        let request = SKProductsRequest(productIdentifiers: productSet)
        request.delegate = self
        request.start()
    }
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Available Products:\(response.products.count)")
        print("Invalid Products:\(response.invalidProductIdentifiers.count)")
        self.products = response.products
        setupButtons()
    }
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                print("payment queue - Purchased")
                giveProductForPayment(transaction.payment.productIdentifier)
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                break
            case .Failed:
                print("payment queue - Failed")
                break
            case .Restored:
                print("payment queue - Restored")
                break
            case .Purchasing:
                print("payment queue - Purchasing")
                break
            case .Deferred:
                print("payment queue - Deferred")
                break
            }
        }
    }
    
    func giveProductForPayment(productID:String) {
        for game in gameTypes {
            if productID == game.inAppPurchaseID {
                game.purchased = true
                setupButtons()
                
                //Update CoreData Value
                let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
                let gameTypesRequest = NSFetchRequest(entityName: "GameType")
                gameTypesRequest.predicate = NSPredicate(format: "inAppPurchaseID = %@", game.inAppPurchaseID!)
                
                do {
                    let gameType = try context.executeFetchRequest(gameTypesRequest) as! [GameType]
                    if gameType.count != 0 {
                        let game = gameType[0]
                        game.setValue(true, forKey: "purchased")
                        
                        do {
                            try context.save()
                        } catch {}
                        
                    }
                } catch {}
            }
        }
    }
    
    
    @IBAction func gameModeSelected(sender: UIButton) {
        self.selectedGameTag = sender.tag
        updateLoadedDate()
        
        var infinitePurchased = false
        var timechillPurchased = false
        for game in self.gameTypes {
            if ((game.title! == "infinite") && (game.purchased!.boolValue)){
                infinitePurchased = true
            } else if ((game.title! == "infinite") && (game.purchased!.boolValue)){
                timechillPurchased = true
            }
        }
        
        if self.selectedGameTag == 2 {
            //infinite lives selected
            if !infinitePurchased {
                // Perform Purchase
                for product in self.products {
                    print(product)
                    if product.productIdentifier == "com.halo22.999challenge.infinite" {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.defaultQueue().addPayment(payment)
                    }
                }
            } else {
                SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
                self.performSegueWithIdentifier("showGameSegue", sender: nil)
                
            }
        } else if self.selectedGameTag == 4 {
            //time chill selected
            if !timechillPurchased {
                for product in self.products {
                    if product.productIdentifier == "com.halo22.999challenge.timechill" {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.defaultQueue().addPayment(payment)
                    }
                }
            } else {
                SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
                self.performSegueWithIdentifier("showGameSegue", sender: nil)
            }
        } else {
            SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
            self.performSegueWithIdentifier("showGameSegue", sender: nil)
        }
    }
    
    
    func setupButtons() {
        
        self.infiniteButton.alpha = 1
        self.infiniteButton.setTitle("Infinite Lives", forState: .Normal)
        self.timeChillButton.alpha = 1
        self.timeChillButton.setTitle("Time Chill", forState: .Normal)
        self.challengeButton.alpha = 1
        self.challengeButton.setTitle("999 Challenge", forState: .Normal)
        self.randomButton.alpha = 1
        self.randomButton.setTitle("Random Target", forState: .Normal)
        
        for game in self.gameTypes {
            if ((game.title! == "infinite") && (!(game.purchased!.boolValue))){
                self.infiniteButton.alpha = 0.4
                //self.infiniteButton.enabled = false
                for product in self.products {
                    if product.productIdentifier == game.inAppPurchaseID {
                        let formattedPrice = formatPrice(product)
                        self.infiniteButton.setTitle("Infinite Lives \(formattedPrice)", forState: .Normal)
                    }
                }
            } else if ((game.title! == "chill") && (!(game.purchased!.boolValue))){
                self.timeChillButton.alpha = 0.4
                //self.timeChillButton.enabled = false
                for product in self.products {
                    if product.productIdentifier == game.inAppPurchaseID {
                        let formattedPrice = formatPrice(product)
                        self.timeChillButton.setTitle("Time Chill \(formattedPrice)", forState: .Normal)
                    }
                }
            }
        }
    }
    
    func formatPrice(product: SKProduct) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .CurrencyStyle
        formatter.locale = product.priceLocale
        let priceString = formatter.stringFromNumber(product.price)
        
        return priceString!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let gameVC = segue.destinationViewController as! GameVC;
        gameVC.selectedGame = self.selectedGameTag
        gameVC.game = self.loadedGame
    }
    
    func generateGameTypes() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let gameTypeDescription = NSEntityDescription.entityForName("GameType", inManagedObjectContext: context)
        
        let standardGame = GameType(entity: gameTypeDescription!, insertIntoManagedObjectContext: context)
        standardGame.title = "challenge"
        standardGame.purchased = true
        
        let infiniteGame = GameType(entity: gameTypeDescription!, insertIntoManagedObjectContext: context)
        infiniteGame.title = "infinite"
        infiniteGame.purchased = false
        infiniteGame.inAppPurchaseID = "com.halo22.999challenge.infinite"
        
        let randomGame = GameType(entity: gameTypeDescription!, insertIntoManagedObjectContext: context)
        randomGame.title = "random"
        randomGame.purchased = true
        
        let chillGame = GameType(entity: gameTypeDescription!, insertIntoManagedObjectContext: context)
        chillGame.title = "chill"
        chillGame.purchased = false
        chillGame.inAppPurchaseID = "com.halo22.999challenge.timechill"
        
        let savedDataDescription = NSEntityDescription.entityForName("SavedLevels", inManagedObjectContext: context)
        let savedData = SavedLevels(entity: savedDataDescription!, insertIntoManagedObjectContext: context)
        savedData.challengeLevel = 1
        savedData.challengeLives = 10
        savedData.infiniteLevel = 1
        savedData.infiniteLives = -1
        savedData.chillLevel = 1
        savedData.chillLives = 10
        savedData.randomLevel = 1
        savedData.randomLives = 10
        
        do {
            try context.save()
        } catch {}
        
        // Load gameTypes here
        loadGameTypes()
    }
    
    func loadGameTypes() {
        let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let gameTypesRequest = NSFetchRequest(entityName: "GameType")
        do {
            try self.gameTypes = context.executeFetchRequest(gameTypesRequest) as! [GameType]
        } catch {
            
        }
    }
    
    func updateLoadedDate(){
        if self.loadSavedLevel {
            switch self.selectedGameTag {
            case 1 :
                self.loadedGame = Game(gameType: selectedGameTag)
                if !self.savedLevels.isEmpty {
                    if self.savedLevels[0].challengeLevel != nil && self.savedLevels[0].challengeLives != nil {
                        self.loadedGame?.level = Int(self.savedLevels[0].challengeLevel!)
                        self.loadedGame?.lives = Int(self.savedLevels[0].challengeLives!)
                        self.loadedGame?.currentRecord = Int(self.savedLevels[0].challengeRecord!)
                    }
                }
                break
            case 2 :
                self.loadedGame = Game(gameType: selectedGameTag)
                if !self.savedLevels.isEmpty {
                    if self.savedLevels[0].infiniteLevel != nil && self.savedLevels[0].infiniteLives != nil {
                        self.loadedGame?.level = Int(self.savedLevels[0].infiniteLevel!)
                        self.loadedGame?.lives = Int(self.savedLevels[0].infiniteLives!)
                        self.loadedGame?.currentRecord = Int(self.savedLevels[0].infiniteRecord!)
                    }
                }
                break
            case 3 :
                self.loadedGame = Game(gameType: selectedGameTag)
                if !self.savedLevels.isEmpty {
                    if self.savedLevels[0].randomLevel != nil && self.savedLevels[0].randomLives != nil {
                        self.loadedGame?.level = Int(self.savedLevels[0].randomLevel!)
                        self.loadedGame?.lives = Int(self.savedLevels[0].randomLives!)
                        self.loadedGame?.currentRecord = Int(self.savedLevels[0].randomRecord!)
                    }
                }
                break
            case 4 :
                self.loadedGame = Game(gameType: selectedGameTag)
                if !self.savedLevels.isEmpty {
                    if self.savedLevels[0].chillLevel != nil && self.savedLevels[0].chillLives != nil {
                        self.loadedGame?.level = Int(self.savedLevels[0].chillLevel!)
                        self.loadedGame?.lives = Int(self.savedLevels[0].chillLives!)
                        self.loadedGame?.currentRecord = Int(self.savedLevels[0].chillRecord!)
                    }
                }
                break
            default :
                break
            }
        } else {
            self.loadedGame = Game(gameType: selectedGameTag)
            self.loadedGame?.currentRecord = Int(self.savedLevels[0].challengeRecord!)
            
            switch self.selectedGameTag {
            case 1:
                self.loadedGame?.currentRecord = Int(self.savedLevels[0].challengeRecord!)
                break
            case 2:
                self.loadedGame?.currentRecord = Int(self.savedLevels[0].infiniteRecord!)
                break
            case 3:
                self.loadedGame?.currentRecord = Int(self.savedLevels[0].randomRecord!)
                break
            case 4:
                self.loadedGame?.currentRecord = Int(self.savedLevels[0].chillRecord!)
                break
            default:
                break
            }
        }
    }
    
    
    
}
