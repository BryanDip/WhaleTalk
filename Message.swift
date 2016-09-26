//
//  Message.swift
//  WhaleTalk
//
//  Created by Bayan on 8/8/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import CoreData


class Message: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var isIncoming: Bool {
        return sender != nil
    }
    
}
