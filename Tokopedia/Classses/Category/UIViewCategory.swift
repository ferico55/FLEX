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

    @IBInspectable var borderWidth : CGFloat {
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor : UIColor {
        get {
            return UIColor(CGColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue.CGColor
        }
    }
    
    func removeAllSubviews() {
        subviews.forEach({view in
            view.removeFromSuperview();
        });
    }
}
