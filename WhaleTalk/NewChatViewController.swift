//
//  NewChatViewController.swift
//  WhaleTalk
//
//  Created by Bayan on 8/9/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit
import CoreData

class NewChatViewController: UIViewController, TableViewFetchedResultsDisplayer {

    var context: NSManagedObjectContext?
    
    fileprivate var fetchedResultsController:
    NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    fileprivate let cellIdentifier = "ContactCell"
    
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    var chatCreationDelegate: ChatCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "New Chat"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewChatViewController.cancel))
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        tableView.dataSource = self
        tableView.delegate = self

        fillViewWith(tableView)
        
        
        if let context = context {
            let request: NSFetchRequest<NSFetchRequestResult> = Contact.fetchRequest()

            request.sortDescriptors = [
                NSSortDescriptor(key: "lastName", ascending: true),
                NSSortDescriptor(key: "firstName", ascending: true)
            ]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request,managedObjectContext: context, sectionNameKeyPath: "sortLetter", cacheName: "NewChatViewController")
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            
            
            do {
                try fetchedResultsController?.performFetch()
            } catch {
                print("There was a problem fetching!")
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func configureCell(_ cell:UITableViewCell, atIndexPath indexPath: IndexPath) {
        guard let contact = fetchedResultsController?.object(at: indexPath) as? Contact else {return}
        cell.textLabel?.text = contact.fullName
    }

}


extension NewChatViewController: UITableViewDataSource {
    
    // numberOfSectionsInTableView - We are required to return an integer. If the fetchedResulsController does not have any sections we return 0.
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    // numberOfRowsInSection - To determine the number of rows in a given section we first need the section. We access the section from the fetchedResultsController. We then determine the number of rows in the given section using the numberOfObjects attribute.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections
            else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    
    // cellForRowAtIndexPath - We need to return a reusable UITableViewCell to populate our tableView. We first generate this cell and then use our hand configureCell method to populate information in the cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    // titleForHeaderInSection - This will give each section a title header. We use the fetchedResultsController and the section parameter to get the currentSection. We then use the currentSection's name parameter to add a title for the section.
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections
            else {return nil}
        let currentSection = sections[section]
        return currentSection.name
    }
    
    
    // canEditRowAtIndexPath - Returning true from this method will make cells editable. Simply put we will be able to swipe on the cell to delete it in the future.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}



extension NewChatViewController: UITableViewDelegate {
    
    // We only add the didSelectRowAtIndexPath method. This method is called when the user selects a row in the tableView. Inside the method we only setup the current Contact for the selected row. We access this from the fetchedResultsController using the objectAtIndexPath method. We also use a guard statement to confirm that the returned type is in fact a Contact instance. This is a good check when fetching information from Core Data.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = fetchedResultsController?.object(at: indexPath) as? Contact
            else {return}
        
        guard let context = context else {return}
        let chat = Chat.existing(directWith: contact, inContext: context) ?? Chat.new(directWith: contact, inContext: context)
        
        chatCreationDelegate?.created(chat: chat, inContext: context)
        dismiss(animated: false, completion: nil)
    }
}




































