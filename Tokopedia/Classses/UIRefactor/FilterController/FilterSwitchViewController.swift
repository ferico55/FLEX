//
//  FilterSwitchViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterSwitchViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private var tableView: UITableView = UITableView()
    private var searchBar: UISearchBar = UISearchBar()
    var items: [FilterObject] = []
    private var selectedObjects : [FilterObject] = []
    
    private var filteredItem:[FilterObject] = []
    private var searchActive : Bool = false
    
    private var lastSelectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
    private var completionHandler:([FilterObject])->Void = {(arg:[FilterObject]) -> Void in}
    
    init(items:[FilterObject],selectedObjects:[FilterObject], onCompletion: (([FilterObject]) -> Void)){
        completionHandler = onCompletion
        self.items = items.map { ($0.copy() as! FilterObject) }
        self.selectedObjects = selectedObjects.map { ($0.copy() as! FilterObject) }
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
        
        tableView.registerClass(switchCell.self, forCellReuseIdentifier: "switchCell")
        
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.tableHeaderView = UIView.init(frame: CGRectMake(0, 0, 1, 10))
        tableView.keyboardDismissMode = .OnDrag
        
        self.view.addSubview(tableView)
        
        self.items.forEach { (item) in
            self.selectedObjects.forEach({ (selectedItem) in
                if item.filterID == selectedItem.filterID {
                    item.isSelected = true;
                }
            })
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:switchCell = switchCell.init(style: .Default, reuseIdentifier: "switchCell",isSelected:self.items[indexPath.row].isSelected, onCompletion: { (switchOn) in
            if switchOn{
                self.items[indexPath.row].isSelected = true;
                self.selectedObjects.append(self.items[indexPath.row])
            } else {
                var removedIndex : Int = 0
                for (index, element) in self.selectedObjects.enumerate(){
                    if element.filterID == self.items[indexPath.row].filterID {
                        self.items[indexPath.row].isSelected = false
                        removedIndex = index
                    }
                }
                self.selectedObjects.removeAtIndex(removedIndex)
            }
            self.completionHandler(self.selectedObjects)
        })
        cell.textLabel?.text = items[indexPath.row].title as String
        cell.selectionStyle = .None
        return cell
    }

    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedObjects = [FilterObject()]
        self.tableView.reloadData()
    }
    
}