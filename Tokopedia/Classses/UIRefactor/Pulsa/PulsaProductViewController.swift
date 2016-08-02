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

        self.tableView.registerNib(UINib(nibName: "PulsaProductCell", bundle: nil), forCellReuseIdentifier: "PulsaProductCellId")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView .dequeueReusableCellWithIdentifier("PulsaProductCellId") as! PulsaProductCell
        
        let product = self.products[indexPath.row]
        cell.productName.text = product.attributes.desc
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.didSelectProduct!(products[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }

}
