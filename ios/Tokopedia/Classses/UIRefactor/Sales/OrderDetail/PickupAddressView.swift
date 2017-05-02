//
//  PickupAddressView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PickupAddressView: UIView {
    
    @IBOutlet fileprivate var addressLabel: UILabel!
    
    fileprivate var address = String(){
        didSet{
            addressLabel.text = address;
        }
    }

    static func newView(_ address:String)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("PickupAddressView", owner: nil, options: nil)!
        let view = views.first as! PickupAddressView
        view.address = address
        
        return view
    }
}
