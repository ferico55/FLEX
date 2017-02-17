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
        super.init(frame: CGRect(x: 0, y: 0, width: 280, height: 80))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func newView()-> Any! {
        let views:Array = Bundle.main.loadNibNamed("TKPInfoWindowMapView", owner: nil, options: nil)!
        for view:Any in views{
            return view;
        }
        return nil
    }

}
