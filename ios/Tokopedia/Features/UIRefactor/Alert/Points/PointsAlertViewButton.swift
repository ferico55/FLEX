//
//  PointsAlertViewButton.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class PointsAlertViewButton: UIButton {
    
    var callback: (() -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initialize(title: String?, titleColor: UIColor, image: UIImage?, alignment: NSTextAlignment, callback: (() -> Void)?) {
        
        self.setTitle(title, for: .normal)
        self.setTitleColor(titleColor, for: .normal)
        self.setImage(image, for: .normal)
        self.titleLabel?.textAlignment = alignment
        self.callback = callback
        
        self.titleLabel?.font = .largeThemeSemibold()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
