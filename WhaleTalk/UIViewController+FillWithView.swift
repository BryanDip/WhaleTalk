//
//  UIViewController+FillWithView.swift
//  WhaleTalk
//
//  Created by Bayan on 8/17/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    func fillViewWith(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        
        let viewConstraints: [NSLayoutConstraint] = [
            subview.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        ]
        NSLayoutConstraint.activate(viewConstraints)
    }
    
}
