//
//  UIScrollViewCategory.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scrollToBottomAnimated(_ animated: Bool) {
        if contentSize.height > bounds.size.height {
            let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height);
            setContentOffset(bottomOffset, animated: animated);
        }
    }
    
    func scrollToTop() {
        let inset = self.contentInset
        self.setContentOffset(CGPoint(x:-inset.left, y:-inset.top), animated:true)
    }
}
