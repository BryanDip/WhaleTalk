//
//  Chat+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by Bayan on 9/2/16.
//  Copyright © 2016 Bayan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Chat {

    @NSManaged var lastMessageTime: NSDate?
    @NSManaged var name: String?
    @NSManaged var messages: NSSet?
    @NSManaged var participants: NSSet?

}
