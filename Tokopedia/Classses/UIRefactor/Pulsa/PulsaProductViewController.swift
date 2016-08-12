//
//  PulsaProductViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var products: [PulsaProduct]!
    var didSelectProduct: (PulsaProduct -> Void)?
    
    init() {
        super.init(nibName: "PulsaProductViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pilih Nominal"

        self.tableView.registerNib(UINib(nibName: "PulsaProductCell", bundle: nil), forCellReuseIdentifier: "PulsaProductCellId")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("PulsaProductCellId") as! PulsaProductCell
        
        let product = self.products[indexPath.row]
        cell.productName.text = product.attributes.desc
        cell.productDesc.text = product.attributes.detail
        cell.productStatus.layer.masksToBounds = true
        
        if let promo = product.attributes.promo {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: product.attributes.price)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))

            cell.promoPrice.text = promo.new_price
            cell.currentPrice.attributedText = attributeString
            cell.promoPrice.hidden = false
        } else {
            cell.promoPrice.hidden = true
            cell.currentPrice.text = product.attributes.price
        }
        
        if(product.attributes.status == 1) {
            cell.productStatus.hidden = true
            cell.userInteractionEnabled = true
        } else {
            cell.productStatus.hidden = false
            cell.userInteractionEnabled = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 98
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectProduct!(products[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

}
