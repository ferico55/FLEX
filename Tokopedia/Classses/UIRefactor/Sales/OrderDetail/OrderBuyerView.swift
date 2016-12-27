//
//  OrderBuyerView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderBuyerView: UIView {
    
    @IBOutlet private var dayLeftViews: [UILabel]!
    @IBOutlet private var dayLeftLabel: UILabel!
    @IBOutlet private var invoiceLabel: UILabel!
    @IBOutlet private var orderDateLabel: UILabel!
    @IBOutlet private var buyerNameLabel: UILabel!
    @IBOutlet private var automaticallyRejectedLabel: UILabel!
    @IBOutlet private var buyerThumbnail: UIImageView!
    
    var order: OrderTransaction!
    
    var didTapInvoice : ((OrderTransaction?) -> Void)?
    var didTapBuyer : ((OrderTransaction?) -> Void)?
    
    static func newView(order : OrderTransaction, showDaysLeft: Bool)-> UIView {
        let views:Array = NSBundle.mainBundle().loadNibNamed("OrderBuyerView", owner: nil, options: nil)!
        let view = views.first as! OrderBuyerView
        view.setOrder(order, showDaysLeft: showDaysLeft)
        return view
    }
    
    private func setLabelDayLeft(dayLeft:NSInteger){
        if (dayLeft == 1) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 145.0/255.0, blue: 0/255.0, alpha: 1)
            dayLeftLabel.text = "Besok"
            
        } else if (dayLeft == 0) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1)
            dayLeftLabel.text = "Hari ini"
            
        } else if (dayLeft < 0) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1)
            dayLeftLabel.text = "Expired"
            
            automaticallyRejectedLabel.hidden = true;
            
        } else {
            
            dayLeftLabel.text = "\(dayLeft) Hari lagi"
            dayLeftLabel.backgroundColor = UIColor(red: 0/255.0, green: 121.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
    }
    
    func setOrder(order: OrderTransaction, showDaysLeft:Bool){
        self.order = order
        buyerNameLabel.text = order.order_customer.customer_name;
        invoiceLabel.text = order.order_detail.detail_invoice;
        buyerThumbnail.setImageWithUrl(NSURL(string: order.order_customer.customer_image)!)
        buyerThumbnail.layer.cornerRadius = buyerThumbnail.frame.size.width/2
        orderDateLabel.text = order.order_payment.payment_verify_date
        if !(showDaysLeft) {
            self.dayLeftViews.forEach{$0.hidden = true}
        }
        self.setLabelDayLeft(order.order_payment.payment_process_day_left)
    }
    
    @IBAction private func onTapInvoice(sender:UITapGestureRecognizer){
        
        if didTapInvoice != nil {
            didTapInvoice!(order)
        }
    }
    
    @IBAction private func onTapBuyer(sender:UITapGestureRecognizer){
        
        if didTapBuyer != nil {
            didTapBuyer!(order)
        }
    }
}
