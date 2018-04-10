//
//  UITableView+Dequeue.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 13/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public extension UITableView {
    public func dequeueReusableCellOrDie<CellType: UITableViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CellType else {
            fatalError("Cannot dequeue reusable cell with identifier '\(identifier)' and type \(type(of: CellType.self))")
        }
        
        return cell
    }
    
    public func dequeueReusableCellOrDie<CellType: UITableViewCell>(withIdentifier identifier: String) -> CellType {
        guard let cell = dequeueReusableCell(withIdentifier: identifier) as? CellType else {
            fatalError("Cannot dequeue reusable cell with identifier '\(identifier)' and type \(type(of: CellType.self))")
        }
        
        return cell
    }
}
