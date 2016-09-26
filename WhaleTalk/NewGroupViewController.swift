//
//  NewGroupViewController.swift
//  WhaleTalk
//
//  Created by Bayan on 9/2/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit
import CoreData

class NewGroupViewController: UIViewController {

    
    var context: NSManagedObjectContext?
    var chatCreationDelegate: ChatCreationDelegate?
    
    private let subjectField = UITextField()
    private let characterNumberLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "New Group"
    
        view.backgroundColor = UIColor.whiteColor()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: "next")
        updateNextButton(forCharCount: 0)
        
        subjectField.placeholder = "Group Subject"
        subjectField.delegate = self
        subjectField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subjectField)
        
        updateCharacterLabel(forCharCount: 0)
        
        characterNumberLabel.textColor = UIColor.lightGrayColor()
        characterNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(characterNumberLabel)
        
        let bottomBorder = UIView()
        bottomBorder.backgroundColor = UIColor.lightGrayColor()
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        subjectField.addSubview(bottomBorder)
        
        let constraints: [NSLayoutConstraint] = [
            subjectField.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 20),
            subjectField.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
            subjectField.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
            bottomBorder.widthAnchor.constraintEqualToAnchor(subjectField.widthAnchor),
            bottomBorder.bottomAnchor.constraintEqualToAnchor(subjectField.bottomAnchor),
            bottomBorder.leadingAnchor.constraintEqualToAnchor(subjectField.leadingAnchor),
            bottomBorder.heightAnchor.constraintEqualToConstant(1),
            characterNumberLabel.centerYAnchor.constraintEqualToAnchor(subjectField.centerYAnchor),
            characterNumberLabel.trailingAnchor.constraintEqualToAnchor(subjectField.layoutMarginsGuide.trailingAnchor)
        ]
        NSLayoutConstraint.activateConstraints(constraints)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func next() {
        guard let context = context, chat = NSEntityDescription.insertNewObjectForEntityForName("Chat", inManagedObjectContext: context) as? Chat else {return}
        chat.name = subjectField.text
        
        let vc = NewGroupParticipantsViewController()
        vc.context = context
        vc.chat = chat
        vc.chatCreationDelegate = chatCreationDelegate
        
        navigationController?.pushViewController(vc, animated: true)
    }

    
    func updateCharacterLabel(forCharCount length: Int) {
        characterNumberLabel.text = String(25 - length)
    }
    
    
    func updateNextButton(forCharCount length:Int) {
        if length == 0 {
            navigationItem.rightBarButtonItem?.tintColor = UIColor.lightGrayColor()
            navigationItem.rightBarButtonItem?.enabled = false
        } else {
            navigationItem.rightBarButtonItem?.tintColor = view.tintColor
            navigationItem.rightBarButtonItem?.enabled = true
        }
    }

}

extension NewGroupViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let currentCharacterCount = textField.text?.characters.count ?? 0
        let newLength = currentCharacterCount + string.characters.count - range.length
        
        if newLength <= 25 {
            updateCharacterLabel(forCharCount: newLength)
            updateNextButton(forCharCount: newLength)
            return true
        }
        return false
    }
}










/*
 Code:
 
 extension NewGroupViewController: UITextFieldDelegate{
 func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
 
 let newLength = currentCharacterCount + string.characters.count - range.length
 
 if newLength <= 25 {
 updateCharacterLabel(forCharCount:newLength)
 updateNextButton(forCharCount:newLength)
 return true
 }
 return false
 }
 }
 This method is called when the user changes the text in the UITextField. When this occurs we get the length of the currentCharacterCount and add the string the user is adding's count and subtract the range to get the newLength. What we need to decide is wether or not to accept the text changes and update with the new text. If the newLength is less than or equal to our max length we call the updateCharacterLabel method to show the number of characters. We also call the updateNextButton method again showing our character length. We finish by returning true which will allow the textField to update to the new text. If the character count is greater than 25 we return false and do not allow the textField to update.
 */