//
//  OrderProductView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderProductView: UIView {
    
    @IBOutlet fileprivate var productNameLabel: UILabel!
    @IBOutlet fileprivate var productPriceLabel: UILabel!
    @IBOutlet fileprivate var productWeightLabel: UILabel!
    @IBOutlet fileprivate var productTotalPriceLabel: UILabel!
    @IBOutlet fileprivate var productNote: UILabel!
    @IBOutlet fileprivate var productImageView: UIImageView!
    
    var didTapProduct:(() -> Void)?
    
    fileprivate var product = OrderProduct() {
        didSet{
            productNameLabel.text = product.product_name;
            productImageView.setImageWith(URL(string: product.product_picture))
            productPriceLabel.text = product.product_price;
            productWeightLabel.text = "\(product.product_quantity) Barang (\(product.product_weight) kg)"
            productTotalPriceLabel.text = product.order_subtotal_price_idr
            if product.product_notes != "0" {
                productNote.text = product.product_notes;
            }
        }
    }
    
    static func newView(_ product: OrderProduct)-> UIView {
        let views:Array = Bundle.main.loadNibNamed("OrderProductView", owner: nil, options: nil)!
        for view in views{
            let view = view as! OrderProductView;
            view.product = product
            return view
        }
        
        return OrderProductView()
    }
    
    @IBAction fileprivate func onTapProduct(){
        didTapProduct?()
    }
}
