//
//  FilterTableViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit



class FilterTableViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView = UITableView()
    var items: [FilterObject] = []
    var selectedObject : FilterObject = FilterObject()
    
    private var lastSelectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
    var completionHandler:(FilterObject)->Void = {(arg:FilterObject) -> Void in}
    
    init(items:[FilterObject],selectedObject:FilterObject, onCompletion: ((FilterObject) -> Void)){
        completionHandler = onCompletion
        self.items = items
        self.selectedObject = selectedObject
        
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
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        self.view.addSubview(tableView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let font = UIFont.init(name: "GothamBook", size: 13)
        cell.textLabel?.font = font
        cell.textLabel?.text = self.items[indexPath.row].title as String
        
        if (Int(self.items[indexPath.row].filterID as String) == Int(selectedObject.filterID as String)) {
            cell.accessoryType = .Checkmark
            lastSelectedIndexPath = indexPath
        } else {
            cell.accessoryType = .None
        }
        
        cell.selectionStyle = .None
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedObject = self.items[indexPath.row]

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row != lastSelectedIndexPath.row {
            let oldCell = tableView.cellForRowAtIndexPath(lastSelectedIndexPath)
            oldCell?.accessoryType = .None
            
            let newCell = tableView.cellForRowAtIndexPath(indexPath)
            newCell?.accessoryType = .Checkmark
            
            lastSelectedIndexPath = indexPath
        }

        completionHandler(self.items[indexPath.row])
    }
}
