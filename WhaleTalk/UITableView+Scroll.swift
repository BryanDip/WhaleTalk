//
//  File.swift
//  WhaleTalk
//
//  Created by Bayan on 8/3/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func scrollToBottom() {
        if self.numberOfSections > 1{
            let lastSection = self.numberOfSections - 1
            self.scrollToRow(at: IndexPath(row:self.numberOfRows(inSection: lastSection) - 1, section: lastSection), at: .bottom, animated: true)
        }
        else if self.numberOfSections == 1 && self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: 0)-1, section: 0), at: .bottom, animated: true)
        }
    }
}
