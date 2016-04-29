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
    var textFieldMin : UITextField = UITextField()
    var textFieldMax : UITextField = UITextField()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textFieldMin = UITextField(frame: CGRect(x: 15, y: 0, width: self.frame.size.width/2 - 50, height: 30));
        self.textFieldMax = UITextField(frame: CGRect(x: textFieldMin.frame.size.width + textFieldMin.frame.origin.x + 5, y: 0, width: self.frame.size.width/2 - 50, height: 30));
        
        let font = UIFont.init(name: "GothamBook", size: 13)
        self.textFieldMin.font = font
        self.textFieldMax.font = font
        
        self.textFieldMin.placeholder = "Minimum"
        self.textFieldMax.placeholder = "Maximum"
        
        textFieldMin.borderStyle = .RoundedRect
        textFieldMax.borderStyle = .RoundedRect
        
        textFieldMin.tag = 0
        textFieldMax.tag = 1
        
        //Add TextField to SubView
        self.addSubview(self.textFieldMin)
        self.addSubview(self.textFieldMax)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}

class switchCell: UITableViewCell
{
    var switchView : UISwitch = UISwitch()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.switchView = UISwitch.init(frame: CGRectZero)
        
        self.accessoryView = self.switchView
        
        let line : UIView = UIView.init(frame: CGRectMake(15, 0, self.frame.size.width, 1))
        line.backgroundColor = UIColor.init(colorLiteralRed: 188/255, green: 187/255, blue: 193/255, alpha: 1)

        self .addSubview(line)
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
        
        tableView.registerClass(entryCell.self, forCellReuseIdentifier: "defaultCell")
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.registerClass(switchCell.self, forCellReuseIdentifier: "switchCell")
        
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.keyboardDismissMode = .OnDrag
        tableView.separatorStyle = .None
        
        self.view.addSubview(tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = UITableViewCell.init(style: .Default, reuseIdentifier: "defaultCell")
            let font = UIFont.init(name: "GothamBook", size: 13)
            cell.textLabel?.font = font

            cell.textLabel?.text = "Harga Barang"
        } else if indexPath.row == 1 {
            cell = entryCell.init(style: .Default, reuseIdentifier: "cell")
        } else if indexPath.row == 2 {
            cell = switchCell.init(style: .Default, reuseIdentifier: "switchCell")
            cell.textLabel?.text = "Harga Grosir"
            let font = UIFont.init(name: "GothamBook", size: 13)
            cell.textLabel?.font = font
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
    
    func resetSelectedFilter() -> Void {
        price = FilterPrice()
        tableView.reloadData()
    }
    
}



