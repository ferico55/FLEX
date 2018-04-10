//
//  SimpleOnOffListObject.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 07/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class SimpleOnOffListObject: NSObject {
    internal var title: String = ""
    internal var isSelected: Bool = false
    
    internal init(title: String, isSelected: Bool) {
        self.title = title
        self.isSelected = isSelected
    }
}
