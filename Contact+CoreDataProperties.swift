//
//  Contact+CoreDataProperties.swift
//  WhaleTalk
//
//  Created by Bayan on 9/19/16.
//  Copyright © 2016 Bayan. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Contact {

    @NSManaged var contactId: String?
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var favorite: Bool
    @NSManaged var status: String?
    @NSManaged var chats: NSSet?
    @NSManaged var messages: NSSet?
    @NSManaged var phoneNumbers: NSSet?

}
