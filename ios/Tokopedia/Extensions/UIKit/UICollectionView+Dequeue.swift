//
//  UICollectionView+Dequeue.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 13/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

public extension UICollectionView {
    public func dequeueReusableCellOrDie<CellType: UICollectionViewCell>(withIdentifier identifier: String, for indexPath: IndexPath) -> CellType {
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? CellType else {
            fatalError("Cannot dequeue reusable cell with identifier '\(identifier)' and type \(type(of: CellType.self))")
        }
        
        return cell
    }
}
