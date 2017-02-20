//
//  OrderDetailDropshipView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderDetailDropshipView: UIView {
    
    @IBOutlet fileprivate var dropshipperPhone: UILabel!
    @IBOutlet fileprivate var dropshipperName: UILabel!
    
    fileprivate var order = OrderTransaction(){
        didSet{
            dropshipperName.text = order.order_detail.detail_dropship_name;
            dropshipperPhone.text = order.order_detail.detail_dropship_telp;
        }
    }
    
    static func newView(_ order: OrderTransaction)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("OrderDetailDropshipView", owner: nil, options: nil)!
        let view = views.first as! OrderDetailDropshipView
        
        view.order = order
        
        return view
    }


}
