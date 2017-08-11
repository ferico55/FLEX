//
//  OrderTotalView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/22/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderTotalView: UIView {
    
    @IBOutlet fileprivate var totalProduct: UILabel!
    @IBOutlet fileprivate var subtotal: UILabel!
    @IBOutlet fileprivate var additionalFee: UILabel!
    @IBOutlet fileprivate var shipmentFee: UILabel!
    @IBOutlet fileprivate var totalPayment: UILabel!
    @IBOutlet fileprivate var additionalFeeTitleLabel: UILabel!
    @IBOutlet fileprivate var infoButton: UIButton!
    @IBOutlet fileprivate var courierAgentGesture: UITapGestureRecognizer!
    
    var onTapInfoButton:(() -> Void)?
    
    fileprivate var order = OrderTransaction(){
        didSet{
            totalProduct.text = "\(order.order_detail.detail_quantity) Barang (\(order.order_detail.detail_total_weight) kg)"
            subtotal.text = order.order_detail.detail_product_price_idr
            additionalFee.text = order.order_detail.additionalFee
            additionalFeeTitleLabel.text = order.order_detail.additionalFeeTitle
            shipmentFee.text = order.order_detail.detail_shipping_price_idr
            infoButton.isHidden = (Int(order.order_detail.detail_additional_fee)==0)
            totalPayment.text = order.order_detail.detail_open_amount_idr;
        }
    }
    
    static func newView(_ order: OrderTransaction)-> UIView {
        
        let views:Array = Bundle.main.loadNibNamed("OrderTotalView", owner: nil, options: nil)!
        let view = views.first as! OrderTotalView
        
        view.order = order
        
        return view
    }
    
    @IBAction func tapInfoButton(_ sender: AnyObject) {
        onTapInfoButton?()
    }
}
