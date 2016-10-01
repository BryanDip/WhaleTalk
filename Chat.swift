//
//  Chat.swift
//  WhaleTalk
//
//  Created by Bayan on 8/8/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class Chat: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    var isGroupChat: Bool {
        return participants?.count > 1
    }
    
    var lastMessage: Message? {
        let request: NSFetchRequest<NSFetchRequestResult> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chat = %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        request.fetchLimit = 1
        do {
            guard let results = try self.managedObjectContext?.fetch(request) as? [Message] else {return nil}
            return results.first
        }
        catch {
            print("Error for Request")
        }
        return nil
    }
    
    
    func add(participant contact: Contact) {
        mutableSetValue(forKey: "participants").add(contact)
    }
    
    
    static func existing(directWith contact: Contact, inContext context: NSManagedObjectContext) -> Chat? {
        
        let request: NSFetchRequest<NSFetchRequestResult> = Chat.fetchRequest()
        request.predicate = NSPredicate(format: "ANY participants = %@ AND participants.@count = 1", contact)
        do {
            guard let results = try context.fetch(request) as? [Chat] else {return nil}
            return results.first
        } catch {
            print("Error Fetching")
            return nil
        }
    }
    
    
    static func new(directWith contact: Contact, inContext context: NSManagedObjectContext) -> Chat {
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as! Chat
        chat.add(participant: contact)
        return chat
    }
    
    
    
    
    
}
















