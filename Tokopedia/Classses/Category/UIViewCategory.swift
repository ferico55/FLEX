//
//  UIViewCategory.swift
//  Tokopedia
//
//  Created by Tonito Acen on 12/10/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

extension UIView {
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable var shadowColor : UIColor {
        get {
            return UIColor.clearColor()
        } set {
            layer.shadowColor = newValue.CGColor
        }
    }
    
    @IBInspectable var shadowOpacity : Float {
        get {
            return layer.shadowOpacity
        } set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowRadius : CGFloat {
        get {
            return layer.shadowRadius
        } set {
            layer.shadowRadius = newValue
        }
    }
    
    func removeAllSubviews() {
        subviews.forEach({view in
            view.removeFromSuperview();
        });
    }
}
