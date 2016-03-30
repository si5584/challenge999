//
//  GameType+CoreDataProperties.swift
//  999challenge
//
//  Created by Simon Lovelock on 25/03/2016.
//  Copyright © 2016 haloApps. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension GameType {

    @NSManaged var title: String?
    @NSManaged var purchased: NSNumber?
    @NSManaged var inAppPurchaseID: String?

}
