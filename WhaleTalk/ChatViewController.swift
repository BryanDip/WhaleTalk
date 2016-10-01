//
//  ViewController.swift
//  WhaleTalk
//
//  Created by Bayan on 7/28/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit
import CoreData

class ChatViewController: UIViewController {

    
    fileprivate let tableView = UITableView(frame: CGRect.zero, style: .grouped)
    fileprivate let newMessageField = UITextView()
    
    fileprivate var sections = [Date:[Message]]()
    fileprivate var dates = [Date]()
    
    fileprivate var bottomConstraint: NSLayoutConstraint!
    
    fileprivate let cellIdentifier = "Cell"
    
    var context: NSManagedObjectContext?
    
    var chat: Chat?
    
    fileprivate enum Errors: Error {
        case noChat
        case noContext
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "NAMEE"
        
        do {
            guard chat != nil else {throw Errors.noChat}
            guard let context = context else {throw Errors.noContext}
            
            let request: NSFetchRequest<NSFetchRequestResult> = Message.fetchRequest()
            request.predicate = NSPredicate(format: "chat = %@", chat!)
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            if let result = try context.fetch(request) as? [Message] {
                for message in result {
                    addMessage(message)
                }
            }
        }
        catch {
            print("We couldn't fetch it!")
        }
        automaticallyAdjustsScrollViewInsets = false
        
        // ADD MESSAGE AREA/FIELD AND CONSTRAINTS
        let newMessageArea = UIView()
        
        newMessageArea.backgroundColor = UIColor.gray
        newMessageArea.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(newMessageArea)
        
        newMessageField.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(newMessageField)
        
        newMessageField.isScrollEnabled = false
        
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        newMessageArea.addSubview(sendButton)
        
        sendButton.setTitle("Send", for: UIControlState())
        sendButton.addTarget(self, action: #selector(ChatViewController.pressedSend(_:)), for: UIControlEvents.touchUpInside)
        
        
        // STOP BUTTON ENLARGING
        sendButton.setContentHuggingPriority(251, for: UILayoutConstraintAxis.horizontal)
        
        
        // STOP BUTTON SQUISH
        sendButton.setContentCompressionResistancePriority(751, for: UILayoutConstraintAxis.horizontal)
        
        bottomConstraint = newMessageArea.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomConstraint.isActive = true
        
        let messageAreaConstraints: [NSLayoutConstraint] = [
            newMessageArea.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            newMessageArea.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            newMessageField.leadingAnchor.constraint(equalTo: newMessageArea.leadingAnchor,constant:10),
            newMessageField.centerYAnchor.constraint(equalTo: newMessageArea.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: newMessageArea.trailingAnchor, constant:-10),
            newMessageField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor,constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: newMessageField.centerYAnchor),
            newMessageArea.heightAnchor.constraint(equalTo: newMessageField.heightAnchor, constant:20)
        ]
        NSLayoutConstraint.activate(messageAreaConstraints)
        
        
        // AUTO LAYOUT
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // REGISTER CHAT CELL
        tableView.register(MessageCell.self, forCellReuseIdentifier: cellIdentifier)
        
        
        // CONFORM TO PROTOCOL UITABLEVIEWCELLDATASOURCE & DELEGATE
        tableView.dataSource = self
        tableView.delegate = self
        
        
        //ROW HEIGHT
        tableView.estimatedRowHeight = 44
        
        tableView.backgroundView = UIImageView(image: UIImage(named: "MessageBubble"))
        tableView.separatorColor = UIColor.clear
        tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        tableView.estimatedSectionHeaderHeight = 25
        
        let tableViewConstraints: [NSLayoutConstraint] = [
        
            tableView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: newMessageArea.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(tableViewConstraints)
        
        
        // ADDING NSNOTIFICATION LISTENER FOR KEYBOARD
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        // DROP NEW MESSAGE FIELD WHEN KEYBOARD IS HIDDEN
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        if let mainContext = context?.parent ?? context {
            NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.contextUpdated(_:)), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: mainContext)
        }
        
        
        // ADD UITAPGESTURERECOGNIZER
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.handleSingleTap(_:)))
        view.addGestureRecognizer(tapRecognizer)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        tableView.scrollToBottom()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func keyboardWillShow(_ notification: Notification) {
        updateBottomConstraint(notification)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        updateBottomConstraint(notification)
    }
    
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    
    func updateBottomConstraint(_ notification: Notification) {
        if let
            userInfo = (notification as NSNotification).userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
            let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue{
            let newFrame = view.convert(frame, from: (UIApplication.shared.delegate?.window)!)
            bottomConstraint.constant = newFrame.origin.y - view.frame.height
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.layoutIfNeeded()
            })
            tableView.scrollToBottom()
        }
    }
    
    
    
    func pressedSend(_ button: UIButton) {
        guard let text = newMessageField.text , text.characters.count > 0 else {return}
        checkTemporaryContext()
        guard let context = context else {return}
        guard let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as? Message else {return}
        message.text = text
        message.timestamp = Date()
        message.chat = chat
        chat?.lastMessageTime = message.timestamp
        do {
            try context.save()
        }
        catch {
            print("There was a problem saving")
            return
        }
        newMessageField.text = ""
        view.endEditing(true)
        
    }
    
    
    func addMessage(_ message: Message) {
        guard let date = message.timestamp else {return}
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: date as Date)
        
        var messages = sections[startDay]
        if messages == nil {
            dates.append(startDay)
            dates = dates.sorted(by: {($0 as NSDate).earlierDate($1) == $0})
            messages = [Message]()
        }
        messages!.append(message)
        messages?.sort{($0.timestamp! as NSDate).earlierDate($1.timestamp! as Date) == $0.timestamp! as Date}
        sections[startDay] = messages
    }
    
    
    func contextUpdated(_ notification: Notification) {
        guard let set = ((notification as NSNotification).userInfo![NSInsertedObjectsKey] as? NSSet) else {return}
        let objects = set.allObjects
        for obj in objects {
            guard let message = obj as? Message else {continue}
            if message.chat?.objectID == chat?.objectID {
                addMessage(message)
            }
        }
        tableView.reloadData()
        tableView.scrollToBottom()
    }
    
    
    func checkTemporaryContext() {
        if let mainContext = context?.parent, let chat = chat {
            let tempContext = context
            context = mainContext
            do {
                try tempContext?.save()
            } catch {
                print("Error saving tempContext")
            }
            self.chat = mainContext.object(with: chat.objectID) as? Chat
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


extension ChatViewController: UITableViewDataSource {
    
    
    func getMessages(_ section: Int)->[Message]{
        let date = dates[section]
        return sections[date]!
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dates.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return getMessages(section).count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        cell.separatorInset = UIEdgeInsetsMake(0, tableView.bounds.size.width, 0, 0)
        
        let messages = getMessages((indexPath as NSIndexPath).section)
        let message = messages[(indexPath as NSIndexPath).row]
        cell.messageLabel.text = message.text
        
        cell.incoming(message.isIncoming)
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    
    
    private func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let paddingView = UIView()
        view.addSubview(paddingView)
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        let dateLabel = UILabel()
        paddingView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints:[NSLayoutConstraint] = [
            paddingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            paddingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dateLabel.centerXAnchor.constraint(equalTo: paddingView.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: paddingView.centerYAnchor),
            paddingView.heightAnchor.constraint(equalTo: dateLabel.heightAnchor, constant: 5),
            paddingView.widthAnchor.constraint(equalTo: dateLabel.widthAnchor, constant: 10),
            view.heightAnchor.constraint(equalTo: paddingView.heightAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateLabel.text = formatter.string(from: dates[section])
        
        paddingView.layer.cornerRadius = 10
        paddingView.layer.masksToBounds = true
        paddingView.backgroundColor = UIColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1.0)
        
        return view
    }
    
    
    private func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
    private func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}


extension ChatViewController: UITableViewDelegate {
    
    // TURN OFF DEFAULT CELL HIGHLIGHTING
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}




















