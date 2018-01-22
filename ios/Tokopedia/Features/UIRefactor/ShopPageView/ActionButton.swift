//
//  ActionButton.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 29/12/17.
//  Copyright © 2017 Hans Arijanto. All rights reserved.
//

import UIKit

class ActionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel?.textColor = UIColor(white: 0x6f/255.0, alpha: 1.0)
        self.titleLabel?.font      = UIFont.largeTheme()
        self.backgroundColor       = .white
        self.layer.borderWidth     = 1.0
        self.layer.cornerRadius    = 4.0
        self.layer.borderColor     = UIColor.gray.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
