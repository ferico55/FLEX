//
//  FilterPriceViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class textFieldCell: UITableViewCell
{
    var textField : UITextField = UITextField()
    var titleLabel : UILabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel = UILabel.init(frame: CGRect(x:15, y:10, width: self.frame.size.width, height:15))
        self.textField = UITextField(frame: CGRect(x: 20, y: self.titleLabel.frame.size.height+self.titleLabel.frame.origin.y, width: self.frame.size.width-100, height: 30));
        
        let fontTextField = UIFont.init(name: "GothamBook", size: 13)
        self.textField.font = fontTextField
        
        let fontTitle = UIFont.init(name: "GothamBook", size: 13)
        self.titleLabel.font = fontTitle
        self.titleLabel.textColor = UIColor.grayColor()
        
        self.textField.borderStyle = UITextBorderStyle.None
        self.textField.keyboardType = UIKeyboardType.NumberPad
        
        //Add TextField to SubView
        self.addSubview(self.textField)
        self.addSubview(self.titleLabel)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}

class switchCell: UITableViewCell
{
    var switchView : UISwitch = UISwitch()
    var completionHandler:(Bool)->Void = {(arg:Bool) -> Void in}
    
    init(style: UITableViewCellStyle, reuseIdentifier: String!, isSelected:Bool, onCompletion: ((Bool) -> Void))
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        completionHandler = onCompletion
        
        self.switchView = UISwitch.init(frame: CGRectZero)
        self.switchView.on = isSelected
        self.switchView.addTarget(self, action: "switchChanged:", forControlEvents: UIControlEvents.ValueChanged)
        
        self.accessoryView = self.switchView
        
        let font = UIFont.init(name: "GothamBook", size: 13)
        self.textLabel?.font = font
    }
    
    func switchChanged(sender:UISwitch) -> Void {
        completionHandler(sender.on)
    }
    
    required init(coder aDecoder: NSCoder)
    {
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
        self.price = price.copy() as! FilterPrice
        
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
        
        tableView.registerClass(textFieldCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(switchCell.self, forCellReuseIdentifier: "switchCell")
        
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.tableHeaderView = UIView.init(frame: CGRectMake(0, 0, 1, 10))
        tableView.keyboardDismissMode = .OnDrag
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 55;
        case 1:
            return 55;
        default:
            return 44;
        }
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = textFieldCell.init(style: .Default, reuseIdentifier: "cell")
            (cell as! textFieldCell).titleLabel.text = "Harga Minimum"
            var priceMin = price.priceMin;
            if Int(price.priceMin) == 0 {
                priceMin = ""
            }
            (cell as! textFieldCell).textField.text = priceMin
            (cell as! textFieldCell).textField.tag = 0
            (cell as! textFieldCell).textField.delegate = self
        } else if indexPath.row == 1 {
            cell = textFieldCell.init(style: .Default, reuseIdentifier: "cell")
            (cell as! textFieldCell).titleLabel.text = "Harga Maximum"
            var priceMax = price.priceMax;
            if Int(price.priceMax) == 0 {
                priceMax = ""
            }
            (cell as! textFieldCell).textField.text = priceMax
            (cell as! textFieldCell).textField.tag = 1
            (cell as! textFieldCell).textField.delegate = self
        } else if indexPath.row == 2 {
            cell = switchCell.init(style: .Default, reuseIdentifier: "switchCell",isSelected:self.price.priceWholesale, onCompletion: { (switchOn) in
                self.price.priceWholesale = switchOn
                self.completionHandler(self.price)
            })
            cell.textLabel?.text = "Harga Grosir"
        }
        cell.selectionStyle = .None
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
    
    func resetSelectedFilter() -> Void {
        price = FilterPrice()
        tableView.reloadData()
    }
    
}



