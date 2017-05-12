//
//  UICollectionViewFlowLayoutExtension.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension UICollectionViewFlowLayout {
    @objc func setEstimatedSize(cellType: CollectionViewCellType) {
        if cellType == .typeThreeColumn, #available(iOS 10.0, *), UI_USER_INTERFACE_IDIOM() == .phone  {
            self.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        } else {
            self.estimatedItemSize = .zero
        }
    }
}

