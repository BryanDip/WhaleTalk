//
//  ContactImporter.swift
//  WhaleTalk
//
//  Created by Bayan on 9/3/16.
//  Copyright © 2016 Bayan. All rights reserved.
//



    // FETCH CONTACTS

import Foundation
import CoreData
import Contacts

class ContactImporter: NSObject {
    
    fileprivate var context: NSManagedObjectContext
    fileprivate var lastCNNotificationTime: Date?
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    func listenForChanges() {
        CNContactStore.authorizationStatus(for: .contacts)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactImporter.addressBookDidChange(_:)), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    
    func addressBookDidChange(_ notification: Notification) {
        let now = Date()
        
        guard lastCNNotificationTime == nil || now.timeIntervalSince(lastCNNotificationTime!) > 1 else {return}
        lastCNNotificationTime = now
        
        fetch()
        //fetchExisting()
    }
    
    
    func formatPhoneNumber(_ number: CNPhoneNumber) -> String {
        return number.stringValue.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
    }
    
    
    func fetchExisting() -> (contacts: [String:Contact], phoneNumbers: [String:PhoneNumber]) {
        var contacts = [String:Contact]()
        var phoneNumbers = [String:PhoneNumber]()
        
        do {
            let request: NSFetchRequest<Contact>
          
                request = Contact.fetchRequest() as! NSFetchRequest<Contact>
            //} else {
              //  request = NSFetchRequest(entityName: "Contact")
            //}
            //request: NSFetchRequest<Animal> = Animal.fetchRequest
            request.relationshipKeyPathsForPrefetching = ["phoneNumbers"]
            if let contactsResult = try self.context.fetch(request) as? [Contact] {
                for contact in contactsResult {
                    contacts[contact.contactId!] = contact
                    for phoneNumber in contact.phoneNumbers! {
                        phoneNumbers[(phoneNumber as AnyObject).value] = phoneNumber as? PhoneNumber
                    }
                }
            }
        } catch {print("Error")}
        return (contacts, phoneNumbers)
    }
    
    

    func fetch() {
        let store = CNContactStore()
        store.requestAccess(for: .contacts, completionHandler: {
            granted, error in
            
            self.context.perform {
                if granted {
                    do {
                        let (contacts, phoneNumbers) = self.fetchExisting()
                        let req = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor])
                        
                        try store.enumerateContacts(with: req, usingBlock: {cnContact, stop in
                            
                            guard let contact = contacts[cnContact.identifier] ??  NSEntityDescription.insertNewObject(forEntityName: "Contact", into: self.context) as? Contact else {return}
                            contact.firstName = cnContact.givenName
                            contact.lastName = cnContact.familyName
                            contact.contactId = cnContact.identifier
                            
                            for cnVal in cnContact.phoneNumbers {
                                guard let cnPhoneNumber = cnVal.value as CNPhoneNumber? else {continue}
                                guard let phoneNumber = phoneNumbers[cnPhoneNumber.stringValue] ??  NSEntityDescription.insertNewObject(forEntityName: "PhoneNumber", into: self.context) as? PhoneNumber else {continue}
                                phoneNumber.kind = CNLabeledValue<NSString>.localizedString(forLabel: cnVal.label!) as String!
                                //CNLabeledValue.localizedString(forLabel: cnVal.label!) as String?
                                
                                //let localizedLabel = CNLabeledValue<NSString>.localizedString(forLabel: phoneNumber.label!)
                                phoneNumber.value = self.formatPhoneNumber(cnPhoneNumber)
                                phoneNumber.contact = contact
                            }
                            if contact.isInserted {
                                contact.favorite = true
                            }
                        })
                        try self.context.save()
                    } catch let error as NSError {
                        print("HERE IS THE ERROR!!!!!!!!\(error)")
                    } catch {
                        
                    }
                }
            }

        })
    }
}





/*

*/

