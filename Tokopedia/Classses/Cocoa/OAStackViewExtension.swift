//
//  OAStackViewExtension.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import OAStackView

extension OAStackView {
    
    func setAttribute(axis: UILayoutConstraintAxis ,alignment: OAStackViewAlignment, distribution: OAStackViewDistribution, spacing: CGFloat) {
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }
}
