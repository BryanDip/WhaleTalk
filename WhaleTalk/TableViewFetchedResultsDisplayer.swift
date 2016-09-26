//
//  TableViewFetchedResultsDisplayer.swift
//  WhaleTalk
//
//  Created by Bayan on 9/16/16.
//  Copyright © 2016 Bayan. All rights reserved.
//

import Foundation
import UIKit



protocol TableViewFetchedResultsDisplayer {
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
}