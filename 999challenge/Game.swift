//
//  Game.swift
//  999challenge
//
//  Created by Simon Lovelock on 16/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//

import Foundation

class Game {
    var level = 1
    var lives = 10
    var targets = [111, 222, 333, 444, 555, 666, 777, 888, 999]
    var chill = false
    var infinite = false
    var gameSpeed : Double = 1.00
    var gameType : GameType?
    var title : String!
    var currentRecord : Int?
    
    var currentTarget : Int {
        get {
            return self.targets[self.level - 1]
        }
    }
    
    init (gameType: Int) {
        
        if gameType == 2 {
            self.lives = -1
            self.infinite = true
            self.gameType?.title = "infinite"
            self.title = "infinite"
        } else if gameType == 3 {
            generateRandomTargets()
            self.gameType?.title = "random"
            self.title = "random"
        } else if gameType == 4 {
            self.chill = true
            self.gameType?.title = "chill"
            self.title = "chill"
        } else {
            self.gameType?.title = "challenge"
            self.title = "challenge"
        }
    }
    
    func progressLevel() {
        self.level += 1
    }
    
    func loseLife() {
        self.lives -= 1
    }
    
    func resetLives() {
        self.lives = 10
    }
    
    func generateRandomTargets() {
        
        self.targets.removeAll()
        
        for _ in 0 ..< 10 {
            let randomNum = Int(arc4random_uniform(999))
            self.targets.append(randomNum)
        }
        print(self.targets)
    }
}