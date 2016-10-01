//
//  ChatCell.swift
//  WhaleTalk
//
//  Created by Bayan on 7/29/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {

    let messageLabel: UILabel = UILabel()
    
    // AUTO LAYOUT CONSTRAINT PROPERTIES
    fileprivate var outgoingConstraints: [NSLayoutConstraint]!
    fileprivate var incomingConstraints: [NSLayoutConstraint]!
    
    fileprivate let bubbleImageView = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // TURN ON AUTO LAYOUT AND TURN OFF RESIZING MASK
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleImageView)
        bubbleImageView.addSubview(messageLabel)
        
        // CENTER UILable IN THE MIDDLE OF UIImageView
        messageLabel.centerXAnchor.constraint(equalTo: bubbleImageView.centerXAnchor).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: bubbleImageView.centerYAnchor).isActive = true
        
        // GROW BUBBLE IMAGE WITH TEXT USING CONSTRAINTS
        bubbleImageView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 50).isActive = true
        bubbleImageView.heightAnchor.constraint(equalTo: messageLabel.heightAnchor, constant: 20).isActive = true
        
        //constraintEqualToAnchor(messageLabel.heightAnchor).active = true
        
        // PLACE BUBBLE AT LEFT OR RIGHT OF SCREEN
        outgoingConstraints = [
        bubbleImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        //bubbleImageView.leadingAnchor.constraintGreaterThanOrEqualToAnchor(contentView.centerXAnchor)
        bubbleImageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.80)
        ]
        
        incomingConstraints = [
        bubbleImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
        //bubbleImageView.trailingAnchor.constraintLessThanOrEqualToAnchor(contentView.centerXAnchor)
            bubbleImageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.80)
        ]
        
        bubbleImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        bubbleImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        
        // CONFIGURE UILable
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.numberOfLines = 0
        
        
    }
    
    // REQUIRED INITIALIZER DUE TO CUSTOM INITIALIZER
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    // ACTIVATE INCOMING / OUTGOING ANCHOR CONSTRAINTS AND BUBBLE ORIENTATION & COLOR
    func incoming(_ incoming: Bool) {
        if incoming {
            NSLayoutConstraint.deactivate(outgoingConstraints)
            NSLayoutConstraint.activate(incomingConstraints)
            bubbleImageView.image = bubble.incoming
        }
        else {
            NSLayoutConstraint.deactivate(incomingConstraints)
            NSLayoutConstraint.activate(outgoingConstraints)
            bubbleImageView.image = bubble.outgoing
        }
    }

}


// OREINT BUBBLE AND ASSIGN COLORS
let bubble = makeBubble()

func makeBubble() -> (incoming: UIImage, outgoing: UIImage) {
    let image = UIImage(named: "MessageBubble")!
    
    // FIX DISTORTED BUBBLE
    let insetsIncoming = UIEdgeInsets(top: 17, left: 26.5, bottom: 17.5, right: 21)
    let insetsOutgoing = UIEdgeInsets(top: 17, left: 21, bottom: 17.5, right: 26.5)
    
    // rendering mode .AlwaysTemplate doesn't work when changing the orientation
    let outgoing = coloredImage(image, red: 0/255, green: 122/255, blue: 255/255, alpha: 1).resizableImage(withCapInsets: insetsOutgoing)
    
    let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: UIImageOrientation.upMirrored)
    
    let incoming = coloredImage(flippedImage, red: 229/255, green: 229/255, blue: 229/255, alpha: 1).resizableImage(withCapInsets: insetsIncoming)
    
    return (incoming, outgoing)
}

func coloredImage(_ image: UIImage, red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIImage! {
    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(in: rect)
    
    context?.setFillColor(red: red, green: green, blue: blue, alpha: alpha)
    context?.setBlendMode(CGBlendMode.sourceAtop)
    context?.fill(rect)
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result
}














