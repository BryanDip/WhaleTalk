//
//  ChatCreationDelegate.swift
//  WhaleTalk
//
//  Created by Bayan on 8/17/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import CoreData

protocol ChatCreationDelegate {
    func created(chat: Chat, inContext context: NSManagedObjectContext)
}
