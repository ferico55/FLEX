//
//  OrderInfoView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderInfoView: UIView {
    
    @IBOutlet private var infoLabel: UILabel!
    
    private var info = NSAttributedString(){
        didSet{
            infoLabel.attributedText = info
        }
    }
    
    static func newView(info: NSAttributedString)-> UIView {
        let views:Array = NSBundle.mainBundle().loadNibNamed("OrderInfoView", owner: nil, options: nil)!
        let view = views.first as! OrderInfoView
        view.info = info
        
        return view
    }
    
}
