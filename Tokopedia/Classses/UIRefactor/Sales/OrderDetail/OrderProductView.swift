//
//  OrderProductView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/23/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderProductView: UIView {
    
    @IBOutlet private var productNameLabel: UILabel!
    @IBOutlet private var productPriceLabel: UILabel!
    @IBOutlet private var productWeightLabel: UILabel!
    @IBOutlet private var productTotalPriceLabel: UILabel!
    @IBOutlet private var productNote: UILabel!
    @IBOutlet private var productImageView: UIImageView!
    
    var didTapProduct:(() -> Void)?
    
    private var product = OrderProduct() {
        didSet{
            productNameLabel.text = product.product_name;
            productImageView.setImageWithURL(NSURL(string: product.product_picture))
            productPriceLabel.text = product.product_price;
            productWeightLabel.text = "\(product.product_quantity) Barang (\(product.product_weight) kg)"
            productTotalPriceLabel.text = product.order_subtotal_price_idr
            if product.product_notes != "0" {
                productNote.text = product.product_notes;
            }
        }
    }
    
    static func newView(product: OrderProduct)-> UIView {
        let views:Array = NSBundle.mainBundle().loadNibNamed("OrderProductView", owner: nil, options: nil)!
        for view in views{
            let view = view as! OrderProductView;
            view.product = product
            return view
        }
        
        return OrderProductView()
    }
    
    @IBAction private func onTapProduct(){
        didTapProduct?()
    }
}
