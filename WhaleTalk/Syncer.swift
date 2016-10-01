//
//  Syncer.swift
//  WhaleTalk
//
//  Created by Bayan on 9/16/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit
import CoreData


class Syncer: NSObject {

    fileprivate var mainContext: NSManagedObjectContext
    fileprivate var backgroundContext: NSManagedObjectContext
    
    var remoteStore: RemoteStore?
    
    init(mainContext: NSManagedObjectContext, backgroundContext: NSManagedObjectContext) {
        self.mainContext = mainContext
        self.backgroundContext = backgroundContext
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(Syncer.mainContextSaved(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: mainContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(Syncer.backgroundContextSaved(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: backgroundContext)
    }
    
    
    func mainContextSaved(_ notification: Notification) {
        backgroundContext.perform{
             let inserted = self.objectsForKey(NSInsertedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            let updated = self.objectsForKey(NSUpdatedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            let deleted = self.objectsForKey(NSDeletedObjectsKey, dictionary: notification.userInfo! as NSDictionary, context: self.backgroundContext)
            
            self.backgroundContext.mergeChanges(fromContextDidSave: notification)
            
            self.remoteStore?.store(inserted, updated: updated, deleted: deleted)
        }
    }
    
    
    func backgroundContextSaved(_ notification: Notification) {
        mainContext.perform{
            
            //self.objectsForKey(NSUpdatedObjectsKey, dictionary: (notification as NSNotification).userInfo! as NSDictionary, context: self.mainContext).forEach{$0.willAccessValue(forKey: nil)}
            self.mainContext.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    
    fileprivate func objectsForKey(_ key: String, dictionary: NSDictionary, context: NSManagedObjectContext) -> [NSManagedObject] {
        guard let set = (dictionary[key] as? NSSet) else {return []}
        guard let objects = set.allObjects as? [NSManagedObject] else {return []}
        return objects.map{context.object(with: $0.objectID)}
    }

    
}















