//
//  OrderDateView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderDateView: UIView {

    @IBOutlet private var orderDate: UILabel!
    @IBOutlet private var dueDate: UILabel!
    
    var order = OrderTransaction(){
        didSet {
            orderDate.text = order.order_detail.detail_order_date
            dueDate.text = order.order_payment.payment_shipping_due_date
        }
    }
    
    static func newView()-> UIView? {
        let views:Array = NSBundle.mainBundle().loadNibNamed("OrderDateView", owner: nil, options: nil)!
        for view in views{
            return view as? UIView;
        }
        return nil
    }
}
