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
        
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad) {
            //two column
            var cellWidth: CGFloat
            if(cellType == 1) {
                numberOfCell = 4
                cellWidth = screenWidth/numberOfCell - 15
                cellHeight = cellWidth + 105
            } else if(cellType == 2) {
                numberOfCell = 2
                cellHeight = 93
            } else {
                numberOfCell = 2
                cellWidth = screenWidth/numberOfCell - 15
                cellHeight = cellWidth + 90
            }
        } else {
            if(cellType == 1) {
                numberOfCell = 2
                let cellWidth = screenWidth/numberOfCell - 15
                cellHeight = cellWidth + 105
                
            } else if(cellType == 2) {
                numberOfCell = 1
                cellHeight = 93
            } else {
                numberOfCell = 1
                cellHeight = UIScreen.mainScreen().bounds.size.width + 70
            }
        }
        
        
        let cellWidth = screenWidth/numberOfCell - 15
        
        
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
