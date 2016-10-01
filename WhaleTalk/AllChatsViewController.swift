//
//  AllChatsViewController.swift
//  WhaleTalk
//
//  Created by Bayan on 8/9/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit
import CoreData

class AllChatsViewController: UIViewController, TableViewFetchedResultsDisplayer, ChatCreationDelegate, ContextViewController {

    var context: NSManagedObjectContext?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    fileprivate let cellIdentifier = "MessageCell"
    
    fileprivate var fetchedResultsDelegate: NSFetchedResultsControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "Chats"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_chat"), style: .plain, target: self, action: #selector(AllChatsViewController.newChat))
        
        automaticallyAdjustsScrollViewInsets = false
        
        tableView.register(ChatCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableHeaderView = createHeader()
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        fillViewWith(tableView)

        
        if let context = context {
            let request: NSFetchRequest<NSFetchRequestResult> = Chat.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "lastMessageTime", ascending: false)]
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsDelegate = TableViewFetchedResultsDelegate(tableView: tableView, displayer: self)
            fetchedResultsController?.delegate = fetchedResultsDelegate
            do {
                try fetchedResultsController?.performFetch()
            }
            catch {
                print("There was a problem fetching.")
            }
        }
        
        fakeData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //In the newChat method we will write the code to display the NewChatViewController.
    //Here we embed our NewChatViewController inside of a UINavigationController. We then display it using the presentViewController method.
    func newChat() {
        
        let vc = NewChatViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
        
    }


    func fakeData() {
        guard let context = context else {return}
        let chat = NSEntityDescription.insertNewObject(forEntityName: "Chat", into: context) as? Chat
    }
    
    
    func configureCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        
        let cell = cell as! ChatCell
        guard let chat = fetchedResultsController?.object(at: indexPath) as? Chat else {return}
        
        guard let contact = chat.participants?.anyObject() as? Contact else {return}
        guard let lastMessage = chat.lastMessage, let timestamp = lastMessage.timestamp, let text = lastMessage.text else {return}
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/YY"
        cell.nameLabel.text = contact.fullName
        cell.dateLabel.text = formatter.string(from: timestamp)
        cell.messageLabel.text = text
    }
    
    
    func created(chat: Chat, inContext context: NSManagedObjectContext) {
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    fileprivate func createHeader() -> UIView {
        
        let header = UIView()
        let newGroupButton = UIButton()
        newGroupButton.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(newGroupButton)
        
        newGroupButton.setTitle("New Group", for: UIControlState())
        newGroupButton.setTitleColor(view.tintColor, for: UIControlState())
        newGroupButton.addTarget(self, action: #selector(AllChatsViewController.pressedNewGroup), for: .touchUpInside)
        
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        header.addSubview(border)
        
        border.backgroundColor = UIColor.lightGray
        
        
        
        let constraints: [NSLayoutConstraint] = [
            newGroupButton.heightAnchor.constraint(equalTo: header.heightAnchor),
            newGroupButton.trailingAnchor.constraint(equalTo: header.layoutMarginsGuide.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: header.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        header.setNeedsLayout()
        header.layoutIfNeeded()
        
        let height = header.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        var frame = header.frame
        frame.size.height = height
        header.frame = frame

        return header
        
    }
    
    
    func pressedNewGroup() {
        
        let vc = NewGroupViewController()
        let chatContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        chatContext.parent = context
        vc.context = chatContext
        vc.chatCreationDelegate = self
        
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    
    
}


extension AllChatsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections
            else {return 0}
        
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
}


extension AllChatsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let chat = fetchedResultsController?.object(at: indexPath) as? Chat else
        {return}
        
        let vc = ChatViewController()
        vc.context = context
        vc.chat = chat
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
}


