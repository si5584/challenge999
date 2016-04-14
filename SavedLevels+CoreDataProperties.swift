//
//  SavedLevels+CoreDataProperties.swift
//  999challenge
//
//  Created by Simon Lovelock on 01/04/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension SavedLevels {

    @NSManaged var challengeLevel: NSNumber?
    @NSManaged var challengeLives: NSNumber?
    @NSManaged var challengeRecord: NSNumber?
    @NSManaged var chillLevel: NSNumber?
    @NSManaged var chillLives: NSNumber?
    @NSManaged var chillRecord: NSNumber?
    @NSManaged var infiniteLevel: NSNumber?
    @NSManaged var infiniteLives: NSNumber?
    @NSManaged var infiniteRecord: NSNumber?
    @NSManaged var randomLevel: NSNumber?
    @NSManaged var randomLives: NSNumber?
    @NSManaged var randomRecord: NSNumber?

}
