//
//  UIView+SafeArea.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 19/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UIView {
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.rightAnchor
        } else {
            return self.rightAnchor
        }
    }
    
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11, *) {
            return self.safeAreaLayoutGuide.leftAnchor
        } else {
            return self.leftAnchor
        }
    }
}
