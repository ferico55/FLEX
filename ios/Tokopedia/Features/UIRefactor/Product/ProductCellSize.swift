//
//  ProductCellSize.swift
//  Tokopedia
//
//  Created by Tonito Acen on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class ProductCellSize: NSObject {
    class func sizeWithType(_ cellType : Int) -> CGSize {
        var numberOfCell: CGFloat
        var cellHeight: CGFloat
        let screenWidth = UIScreen.main.bounds.size.width
        let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
    
        var cellWidth: CGFloat;
        if(cellType == 1) {
            numberOfCell = isPad ? 4 : 2
            cellWidth = screenWidth/numberOfCell
            cellHeight = cellWidth + 135
        } else if(cellType == 2) {
            numberOfCell = isPad ? 2 : 1
            cellWidth = screenWidth/numberOfCell
            cellHeight = 140
        } else {
            numberOfCell = isPad ? 2 : 1
            cellWidth = screenWidth/numberOfCell
            cellHeight = cellWidth + 90
        }
        
        return CGSize(width: cellWidth, height: cellHeight);
    }
    
    class func sizeWishlistCell() -> CGSize {
        var numberOfCell: CGFloat
        var cellHeight: CGFloat
        var cellWidth: CGFloat
        let screenWidth = UIScreen.main.bounds.size.width
        let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
        
        numberOfCell = isPad ? 4 : 2
        cellWidth = screenWidth/numberOfCell
        cellHeight = cellWidth + 182
        
        return CGSize(width: cellWidth, height: cellHeight);
    }
}
