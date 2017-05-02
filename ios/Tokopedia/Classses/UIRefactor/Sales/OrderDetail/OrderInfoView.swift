//
//  OrderInfoView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderInfoView: UIView {
    
    @IBOutlet fileprivate var infoLabel: UILabel!
    
    fileprivate var info = NSAttributedString(){
        didSet{
            infoLabel.attributedText = info
        }
    }
    
    static func newView(_ info: NSAttributedString)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("OrderInfoView", owner: nil, options: nil)!
        let view = views.first as! OrderInfoView
        view.info = info
        
        return view
    }
    
}
