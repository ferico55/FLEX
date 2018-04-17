//
//  UIView+AnchorPoint.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 16/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UIView {
    internal func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)
        
        var position : CGPoint = self.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.translatesAutoresizingMaskIntoConstraints = true
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
}
