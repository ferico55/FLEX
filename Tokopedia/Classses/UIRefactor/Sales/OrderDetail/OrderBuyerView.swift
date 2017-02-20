//
//  OrderBuyerView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderBuyerView: UIView {
    
    @IBOutlet fileprivate var dayLeftViews: [UILabel]!
    @IBOutlet fileprivate var dayLeftLabel: UILabel!
    @IBOutlet fileprivate var invoiceLabel: UILabel!
    @IBOutlet fileprivate var orderDateLabel: UILabel!
    @IBOutlet fileprivate var buyerNameLabel: UILabel!
    @IBOutlet fileprivate var automaticallyRejectedLabel: UILabel!
    @IBOutlet fileprivate var buyerThumbnail: UIImageView!
    
    var order: OrderTransaction!
    
    var didTapInvoice : ((OrderTransaction?) -> Void)?
    var didTapBuyer : ((OrderTransaction?) -> Void)?
    
    static func newView(_ order : OrderTransaction, showDaysLeft: Bool)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("OrderBuyerView", owner: nil, options: nil)!
        let view = views.first as! OrderBuyerView
        view.setOrder(order, showDaysLeft: showDaysLeft)
        return view
    }
    
    fileprivate func setLabelDayLeft(_ dayLeft:NSInteger){
        if (dayLeft == 1) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 145.0/255.0, blue: 0/255.0, alpha: 1)
            dayLeftLabel.text = "Besok"
            
        } else if (dayLeft == 0) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 255.0/255.0, green: 59.0/255.0, blue: 48.0/255.0, alpha: 1)
            dayLeftLabel.text = "Hari ini"
            
        } else if (dayLeft < 0) {
            
            dayLeftLabel.backgroundColor = UIColor(red: 158.0/255.0, green: 158.0/255.0, blue: 158.0/255.0, alpha: 1)
            dayLeftLabel.text = "Expired"
            
            automaticallyRejectedLabel.isHidden = true;
            
        } else {
            
            dayLeftLabel.text = "\(dayLeft) Hari lagi"
            dayLeftLabel.backgroundColor = UIColor(red: 0/255.0, green: 121.0/255.0, blue: 255.0/255.0, alpha: 1)
        }
    }
    
    func setOrder(_ order: OrderTransaction, showDaysLeft:Bool){
        self.order = order
        buyerNameLabel.text = order.order_customer.customer_name;
        invoiceLabel.text = order.order_detail.detail_invoice;
        buyerThumbnail.setImageWithUrl(URL(string: order.order_customer.customer_image)!)
        buyerThumbnail.layer.cornerRadius = buyerThumbnail.frame.size.width/2
        orderDateLabel.text = order.order_payment.payment_verify_date
        if !(showDaysLeft) {
            self.dayLeftViews.forEach{$0.isHidden = true}
        }
        self.setLabelDayLeft(order.order_payment.payment_process_day_left)
    }
    
    @IBAction fileprivate func onTapInvoice(_ sender:UITapGestureRecognizer){
        
        if didTapInvoice != nil {
            didTapInvoice!(order)
        }
    }
    
    @IBAction fileprivate func onTapBuyer(_ sender:UITapGestureRecognizer){
        
        if didTapBuyer != nil {
            didTapBuyer!(order)
        }
    }
}
