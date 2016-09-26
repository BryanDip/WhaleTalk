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
    
    private var fetchedResultsController:
    NSFetchedResultsController?
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    private let cellIdentifier = "ContactCell"
    
    private var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    var chatCreationDelegate: ChatCreationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "New Chat"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancel")
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)

        tableView.dataSource = self
        tableView.delegate = self

        fillViewWith(tableView)
        
        
        if let context = context {
            let request = NSFetchRequest(entityName: "Contact")
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
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func configureCell(cell:UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact else {return}
        cell.textLabel?.text = contact.fullName
    }

}


extension NewChatViewController: UITableViewDataSource {
    
    // numberOfSectionsInTableView - We are required to return an integer. If the fetchedResulsController does not have any sections we return 0.
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    // numberOfRowsInSection - To determine the number of rows in a given section we first need the section. We access the section from the fetchedResultsController. We then determine the number of rows in the given section using the numberOfObjects attribute.
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections
            else {return 0}
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    
    // cellForRowAtIndexPath - We need to return a reusable UITableViewCell to populate our tableView. We first generate this cell and then use our hand configureCell method to populate information in the cell.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    
    // titleForHeaderInSection - This will give each section a title header. We use the fetchedResultsController and the section parameter to get the currentSection. We then use the currentSection's name parameter to add a title for the section.
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = fetchedResultsController?.sections
            else {return nil}
        let currentSection = sections[section]
        return currentSection.name
    }
    
    
    // canEditRowAtIndexPath - Returning true from this method will make cells editable. Simply put we will be able to swipe on the cell to delete it in the future.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}



extension NewChatViewController: UITableViewDelegate {
    
    // We only add the didSelectRowAtIndexPath method. This method is called when the user selects a row in the tableView. Inside the method we only setup the current Contact for the selected row. We access this from the fetchedResultsController using the objectAtIndexPath method. We also use a guard statement to confirm that the returned type is in fact a Contact instance. This is a good check when fetching information from Core Data.
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let contact = fetchedResultsController?.objectAtIndexPath(indexPath) as? Contact
            else {return}
        
        guard let context = context else {return}
        let chat = Chat.existing(directWith: contact, inContext: context) ?? Chat.new(directWith: contact, inContext: context)
        
        chatCreationDelegate?.created(chat: chat, inContext: context)
        dismissViewControllerAnimated(false, completion: nil)
    }
}

    /* REFACTORED IN TABLEVIEWFETCHEDRESULTSDELEGATE
 
 
extension NewChatViewController: NSFetchedResultsControllerDelegate {
    
    
    //The first one alerts us when the controller's data is about to change. We tell the tableView since the data is about to change it can expect changes to occur. We use the beginUpdates method for this purpose.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    
    //Onto the actual section changes. We accomplish this in the didChangeSection method. Since different types of changes can occur we use a switch statement to account for each of these changes. For now we will account for insertions and deletions.
        //Insert - In this case we need to add an additional section into our tableView. We use the insertSections method to accomplish this.
        //Delete - In this case we need to remove a section. We use the deleteSections method to accomplish this.
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            case .Insert:
                tableView.insertSections(NSIndexSet(index: sectionIndex) , withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default: break
        }
    }
    //In both cases we manually tell the tableView to update or delete a specific section which is more efficent then simply having the tableView refresh all of its' data.
    
    
    //While we have accounted for changes in the sections in our tableView we have not yet accounted for changes in specific rows in our tableView. To accomplish this we use the didChangeObject method. We use a switch statement on the type parameter. Now we can account for row insertions, updates, moves and deletions.
    
    //Insert - We simply add a new row with the insertRowsAtIndexPaths method.
    //Update - We first need to figure out which cell needs to be updated. Then we call configureCell to update the information in the cell.
    //Move - We start by deleting the row using the indexPath parameter to identify the proper row. We then insert it into the spot it has been moved to using the newIndexPath parameter.
    //Delete - We simply delete the row that is no longer used using the deleteRowsAtIndexPaths method.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Update:
                let cell = tableView.cellForRowAtIndexPath(indexPath!)
                configureCell(cell!, atIndexPath: indexPath!)
                tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        }
    }
    
    //Once we have properly updated the rows and/or sections using our fetchedResultsController we need to tell our tableView that we are done making changes. This will allow our tableView to efficently update. To accomplish this we are told when the fetchedResultsController's content is done changing. We use the controllerDidChangeContent method and inside of it we tell the tableView we are done making changes using endUpdates method.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
}

 */


































