//
//  PickupAddressView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PickupAddressView: UIView {
    
    @IBOutlet private var addressLabel: UILabel!
    
    private var address = String(){
        didSet{
            addressLabel.text = address;
        }
    }

    static func newView(address:String)-> UIView {
        let views:Array = NSBundle.mainBundle().loadNibNamed("PickupAddressView", owner: nil, options: nil)!
        let view = views.first as! PickupAddressView
        view.address = address
        
        return view
    }
}
