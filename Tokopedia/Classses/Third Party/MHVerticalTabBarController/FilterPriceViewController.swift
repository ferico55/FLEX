//
//  FilterPriceViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class entryCell: UITableViewCell
{
    //Locals
    var textField : UITextField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        //First Call Super
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        //Initialize Text Field
        self.textField = UITextField(frame: CGRect(x: 15, y: 0, width: self.frame.size.width, height: self.frame.size.height));
        
        //Add TextField to SubView
        self.addSubview(self.textField)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        //Just Call Super
        super.init(coder: aDecoder)!
    }
}

class FilterPriceViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private var tableView: UITableView = UITableView()
    var price : FilterObject = FilterObject()
    
    private var lastSelectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
    var completionHandler:(FilterObject)->Void = {(arg:FilterObject) -> Void in}
    
    func createFilterPrice(price: FilterObject, onCompletion: ((FilterObject) -> Void)) {
        completionHandler = onCompletion
        self.price = price
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(entryCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.keyboardDismissMode = .OnDrag


        self.view.addSubview(tableView)
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:entryCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! entryCell
        let font = UIFont.init(name: "GothamBook", size: 13)
        cell.textField.font = font
        cell.textField.delegate = self
        
        if indexPath.row == 0 {
            cell.textField.placeholder = "Harga Minimum"
            cell.textField.tag = 0
        } else {
            cell.textField.placeholder = "Harga Maximum"
            cell.textField.tag = 1
        }
        
        return cell
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 0{
            price.priceMin = textField.text!
        }
        if textField.tag == 1 {
            price.priceMax = textField.text!
        }
        completionHandler(price)
    }
    
}



