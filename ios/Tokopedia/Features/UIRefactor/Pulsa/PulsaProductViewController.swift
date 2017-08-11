//
//  PulsaProductViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

public enum ProductStatus : Int {
    case active = 1
    case inactive = 2
    case outOfStock = 3
}

class PulsaProductViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var products: [PulsaProduct]!
    var selectedOperator: PulsaOperator!
    var didSelectProduct: ((PulsaProduct) -> Void)?
    
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
        
        self.tableView.register(UINib(nibName: "PulsaProductCell", bundle: nil), forCellReuseIdentifier: "PulsaProductCellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
        
        AnalyticsManager.trackScreenName("Recharge Product Page from Widget")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCell(withIdentifier: "PulsaProductCellId") as! PulsaProductCell
        
        let product = self.products[indexPath.row]
        cell.productName.text = product.attributes.desc
        cell.productName.translatesAutoresizingMaskIntoConstraints = true
        let frame = CGRect(x: cell.productName.frame.origin.x, y: cell.productName.frame.origin.y, width: cell.productName.intrinsicContentSize.width, height: cell.productName.frame.size.height)
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
                cell.promoPrice.isHidden = false
            } else {
                cell.promoPrice.isHidden = true
                cell.currentPrice.text = product.attributes.price
            }
            
            if(promo.tag != "") {
                cell.productTag.isHidden = false
                cell.productTag.text = promo.tag
            } else {
                cell.productTag.isHidden = true
            }
        } else {
            cell.promoPrice.isHidden = true
            cell.productTag.isHidden = true
            if(self.selectedOperator.attributes.rule.show_price == true) {
                cell.currentPrice.isHidden = false
                cell.currentPrice.text = product.attributes.price
            } else {
                cell.currentPrice.isHidden = true
            }
            
        }
        
        if(product.attributes.status == ProductStatus.active.rawValue) {
            cell.productStatus.isHidden = true
            cell.isUserInteractionEnabled = true
            cell.isHidden = false
        } else if (product.attributes.status == ProductStatus.inactive.rawValue) {
            cell.productStatus.isHidden = true
            cell.isUserInteractionEnabled = false
            cell.isHidden = true
        } else if (product.attributes.status == ProductStatus.outOfStock.rawValue) {
            cell.productStatus.isHidden = false
            cell.isUserInteractionEnabled = false
            cell.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let product = self.products[indexPath.row]
        
        if(product.attributes.status == ProductStatus.inactive.rawValue) {
            return 0
        } else {
            return UITableViewAutomaticDimension
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectProduct!(products[indexPath.row])
        self.navigationController?.popViewController(animated: true)
    }

}
