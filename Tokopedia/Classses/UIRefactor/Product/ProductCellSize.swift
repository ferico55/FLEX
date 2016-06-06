//
//  ProductCellSize.swift
//  Tokopedia
//
//  Created by Tonito Acen on 3/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class ProductCellSize: NSObject {
    class func sizeWithType(cellType : Int) -> CGSize {
        var numberOfCell: CGFloat
        var cellHeight: CGFloat
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let isPad = (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
    
        var cellWidth: CGFloat;
        if(cellType == 1) {
            numberOfCell = isPad ? 4 : 2
            cellWidth = screenWidth/numberOfCell
            cellHeight = cellWidth + 85
        } else if(cellType == 2) {
            numberOfCell = isPad ? 2 : 1
            cellWidth = screenWidth/numberOfCell
            cellHeight = 120
        } else {
            numberOfCell = isPad ? 2 : 1
            cellWidth = screenWidth/numberOfCell
            cellHeight = cellWidth + 90
        }
        
        return CGSizeMake(cellWidth, cellHeight);
    }
    
    class func sizeWishlistCell() -> CGSize {
        var numberOfCell: CGFloat
        var cellHeight: CGFloat
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            numberOfCell = 4
            cellHeight = 300
        } else {
            numberOfCell = 2
            cellHeight = (UIScreen.mainScreen().bounds.size.width / numberOfCell) - 15 + 100
        }
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let cellWidth = screenWidth/numberOfCell - 15
        
        
        return CGSizeMake(cellWidth, cellHeight);
    }
}
