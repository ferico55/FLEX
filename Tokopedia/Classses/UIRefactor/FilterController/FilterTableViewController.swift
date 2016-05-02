//
//  FilterTableViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterTableViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var tableView: UITableView = UITableView()
    private var searchBar: UISearchBar = UISearchBar()
    var items: [FilterObject] = []
    var showSearchBar: Bool = false
    private var selectedObject : FilterObject = FilterObject()
    
    private var filteredItem:[FilterObject] = []
    private var searchActive : Bool = false
    
    private var lastSelectedIndexPath : NSIndexPath = NSIndexPath.init(forRow: 0, inSection: 0)
    
    private var completionHandler:(FilterObject)->Void = {(arg:FilterObject) -> Void in}
    
    init(items:[FilterObject],selectedObject:FilterObject, showSearchBar:Bool, onCompletion: ((FilterObject) -> Void)){
        completionHandler = onCompletion
        self.items = items
        self.selectedObject = selectedObject.copy() as! FilterObject
        self.showSearchBar = showSearchBar
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
        tableView.keyboardDismissMode = .OnDrag

        self.view.addSubview(tableView)
        
        searchBar = UISearchBar.init(frame: CGRectMake(0, 0, self.view.frame.size.width, 44))
        searchBar.delegate = self
        let image = UIImage()
        searchBar.setBackgroundImage(image, forBarPosition: .Any, barMetrics: .Default)
        searchBar.scopeBarBackgroundImage = image
        let placeholder = "Cari \(self.tabBarItem!.title!)"
        searchBar.placeholder = placeholder
        searchBar.translucent = true
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        
        searchBar.tintColor = UIColor.grayColor()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44)

    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchActive && searchBar.text == "" {
            return 0
        }
        
        if(searchActive){
            if searchBar.text == "" {
                return self.items.count
            } else {
                return self.filteredItem.count
            }
        } else {
            return self.items.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        var item : FilterObject = FilterObject()
        
        if(searchActive){
            if searchBar.text == "" {
                item = items[indexPath.row];
            } else {
                item = filteredItem[indexPath.row]
            }
        } else {
            item = items[indexPath.row];
        }
        
        let font = UIFont.init(name: "GothamBook", size: 13)
        cell.textLabel?.font = font
        cell.textLabel?.text = item.title as String
        cell.tintColor = UIColor.init(colorLiteralRed: 66/255, green: 189/255, blue: 65/255, alpha: 1)
        
        if (Int(item.filterID as String) == Int(selectedObject.filterID as String)) {
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
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showSearchBar {
            return 44
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchBar;
    }
    
    //MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        searchBar.setShowsCancelButton(true, animated: true)

    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.setShowsCancelButton(false, animated: true)

    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar .resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItem = items.filter({ (object) -> Bool in
            let tmp: FilterObject = object
            
            let range = tmp.title.rangeOfString(searchBar.text!, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filteredItem.count == 0){
            searchActive = false;
            searchBar.setShowsCancelButton(true, animated: true)

        } else {
            searchActive = true;
            searchBar.setShowsCancelButton(true, animated: true)

        }
        self.tableView.reloadData()

    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedObject = FilterObject()
        self.tableView.reloadData()
    }
}
