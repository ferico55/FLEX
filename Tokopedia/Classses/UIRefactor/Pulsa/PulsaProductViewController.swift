//
//  PulsaProductViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

public enum ProductStatus : Int {
    case Active = 1
    case Inactive = 2
    case OutOfStock = 3
}

class PulsaProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var products: [PulsaProduct]!
    var selectedOperator: PulsaOperator!
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
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 68
        
        self.tableView.registerNib(UINib(nibName: "PulsaProductCell", bundle: nil), forCellReuseIdentifier: "PulsaProductCellId")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("PulsaProductCellId") as! PulsaProductCell
        
        let product = self.products[indexPath.row]
        cell.productName.text = product.attributes.desc
        cell.productName.translatesAutoresizingMaskIntoConstraints = true
        let frame = CGRectMake(cell.productName.frame.origin.x, cell.productName.frame.origin.y, cell.productName.intrinsicContentSize().width, cell.productName.frame.size.height)
        cell.productName.frame = frame
        
        if(product.attributes.detail == "") {
            cell.descriptionHeightConstraint.constant = 10
        } else {
            cell.descriptionHeightConstraint.constant = 50
        }
        
        cell.productDesc.text = NSString.convertHTML(product.attributes.detail)
        cell.productStatus.layer.masksToBounds = true
        
        if let promo = product.attributes.promo {
            if(promo.new_price != product.attributes.price) {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: product.attributes.price)
                attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
                
                cell.promoPrice.text = promo.new_price
                cell.currentPrice.attributedText = attributeString
                cell.promoPrice.hidden = false
            } else {
                cell.promoPrice.hidden = true
                cell.currentPrice.text = product.attributes.price
            }
            
            if(promo.tag != "") {
                cell.productTag.hidden = false
                cell.productTag.text = promo.tag
            } else {
                cell.productTag.hidden = true
            }
        } else {
            cell.promoPrice.hidden = true
            cell.productTag.hidden = true
            if(self.selectedOperator.attributes.rule.show_price == true) {
                cell.currentPrice.hidden = false
                cell.currentPrice.text = product.attributes.price
            } else {
                cell.currentPrice.hidden = true
            }
            
        }
        
        if(product.attributes.status == ProductStatus.Active.rawValue) {
            cell.productStatus.hidden = true
            cell.userInteractionEnabled = true
            cell.hidden = false
        } else if (product.attributes.status == ProductStatus.Inactive.rawValue) {
            cell.productStatus.hidden = true
            cell.userInteractionEnabled = false
            cell.hidden = true
        } else if (product.attributes.status == ProductStatus.OutOfStock.rawValue) {
            cell.productStatus.hidden = false
            cell.userInteractionEnabled = false
            cell.hidden = false
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let product = self.products[indexPath.row]
        
        if(product.attributes.status == ProductStatus.Inactive.rawValue) {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectProduct!(products[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

}
