//
//  TKPInfoWindowMapView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/9/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit

class TKPInfoWindowMapView: UIView {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var whiteLocationInfoView: UIView!

    // MARK: Initialization
    init() {
        super.init(frame: CGRectMake(0, 0, 280, 80))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func newView()-> AnyObject! {
        let views:Array = NSBundle.mainBundle().loadNibNamed(NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!, owner: nil, options: nil)
        for view:AnyObject in views{
            return view;
        }
        return nil
    }

}
