//
//  ShopTabChild.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 1/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc
protocol ShopTabChild {
    func refreshContent()
    
    @objc optional func tabWillChange(to: UIViewController)
}
