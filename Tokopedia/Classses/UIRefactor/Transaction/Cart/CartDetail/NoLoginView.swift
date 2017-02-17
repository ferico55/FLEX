//
//  NoLoginView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(NoLoginView) class NoLoginView: UIView {
    
    var onTapRegister : (()->Void)?
    
    class func newView()-> Any! {
        let views:Array = Bundle.main.loadNibNamed("NoLoginView", owner: nil, options: nil)!
        for view: Any in views{
            return view;
        }
        return nil
    }
    
    @IBAction func tapRegister(_ sender: AnyObject) {
        onTapRegister?()
    }
}
