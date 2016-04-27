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
    var price : FilterPrice = FilterPrice()
    
    private var lastSelectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
    var completionHandler:(FilterPrice)->Void = {(arg:FilterPrice) -> Void in}
    
    init(price: FilterPrice, onCompletion: ((FilterPrice) -> Void)){
        completionHandler = onCompletion
        self.price = price
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        
        tableView.delegate      =   self
        tableView.dataSource    =   self
        
        tableView.registerClass(entryCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.keyboardDismissMode = .OnDrag
        
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

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
            cell.textField.text = price.priceMin
            cell.textField.tag = 0
        } else {
            cell.textField.placeholder = "Harga Maximum"
            cell.textField.text = price.priceMax
            cell.textField.tag = 1
        }
        
        return cell
    }
    
    func  textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if textField.tag == 0{
            price.priceMin = "\(newString)"
        }
        if textField.tag == 1 {
            price.priceMax = "\(newString)"
        }
        completionHandler(price)
        
        return true
    }
    
}



