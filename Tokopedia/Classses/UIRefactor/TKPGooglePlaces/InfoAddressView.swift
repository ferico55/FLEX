//
//  InfoAddressView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/22/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

import UIKit

class InfoAddressView: UIView {

    @IBOutlet var receiverNumberLabel: UILabel!
    @IBOutlet var addressStreetLabel: UILabel!
    @IBOutlet var receiverNameLabel: UILabel!
    @IBOutlet var addressNameLabel: UILabel!

    // MARK: Initialization
    init() {
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func newView()-> AnyObject! {
        let views:Array = NSBundle.mainBundle().loadNibNamed("InfoAddressView", owner: nil, options: nil)!
        for view:AnyObject in views{
            return view;
        }
        return nil
    }
    
    func setViewModel(viewModel:AddressViewModel){
        receiverNumberLabel.text = viewModel.receiverNumber;
        addressStreetLabel.text = viewModel.addressStreet;
        receiverNameLabel.text = viewModel.receiverName;
        addressNameLabel.text = viewModel.addressName;
    }

}
