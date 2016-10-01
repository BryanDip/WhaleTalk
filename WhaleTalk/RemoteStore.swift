//
//  RemoteStore.swift
//  WhaleTalk
//
//  Created by Bayan on 9/19/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import CoreData

protocol RemoteStore {
    func signUp(phoneNumber:String,email:String, password:String, success:()->(), error:(_ errorMessage:String)->())
    
    func startSyncing()
    
    func store(_ inserted: [NSManagedObject], updated: [NSManagedObject], deleted: [NSManagedObject])
}




