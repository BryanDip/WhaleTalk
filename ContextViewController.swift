//
//  ContextViewController.swift
//  WhaleTalk
//
//  Created by Bayan on 9/15/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import CoreData

protocol ContextViewController {
    var context: NSManagedObjectContext? {get set}
}