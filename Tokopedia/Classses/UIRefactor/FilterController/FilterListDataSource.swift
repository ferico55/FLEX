//
//  FilterListDataSource.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterListDataSource: NSObject, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private var tableView: UITableView?
    private var searchBar: UISearchBar = UISearchBar()
    private var items: [FilterObject] = []
    private var showSearchBar: Bool = false
    var selectedObjects : [FilterObject] = []
    
    private var filteredItem:[FilterObject] = []
    private var searchActive : Bool = false
    var searchBarPlaceholder = "Cari"

    
    private var completionHandler:([FilterObject])->Void = {(arg:[FilterObject]) -> Void in}
    
    init(tableView:UITableView, showSearchBar:Bool, onCompletion: (([FilterObject]) -> Void)) {
        super.init()
        
        completionHandler = onCompletion
        self.showSearchBar = showSearchBar
        
        self.tableView = tableView
        
        self.tableView!.delegate      =   self
        self.tableView!.dataSource    =   self
        
        self.tableView!.registerClass(FilterTableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView!.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        self.tableView!.keyboardDismissMode = .Interactive
        
        searchBar = UISearchBar.init(frame: CGRectMake(0, 0, tableView.frame.size.width, 44))
        searchBar.delegate = self
        let image = UIImage()
        searchBar.setBackgroundImage(image, forBarPosition: .Any, barMetrics: .Default)
        searchBar.scopeBarBackgroundImage = image
        searchBar.placeholder = searchBarPlaceholder
        searchBar.translucent = true
        searchBar.backgroundColor = UIColor.whiteColor()
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        
        searchBar.tintColor = UIColor.grayColor()
        
        self.tableView!.allowsMultipleSelection = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        let cell:FilterTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! FilterTableViewCell
        
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
        
        cell.label.text =  item.title as String
        cell.disableSelected = false
        cell.setPading(10)
        
        var selectedIDs : [String] = [""]
        for object in selectedObjects {
            selectedIDs.append(object.filterID as String)
        }
        if selectedIDs.contains(item.filterID as String) {
            tableView .selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Bottom)
        }
        
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.whiteColor()
        cell.selectedBackgroundView =  customColorView;
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        items[indexPath.row].isSelected = !items[indexPath.row].isSelected
        
        if items[indexPath.row].isSelected {
            selectedObjects.append(items[indexPath.row])
        } else{
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: false)
            for (index, selected) in selectedObjects.enumerate() {
                if selected.filterID == items[indexPath.row].filterID {
                    selectedObjects.removeAtIndex(index)
                }
            }
        }
        completionHandler(selectedObjects)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showSearchBar && items.count > 0 {
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
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
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
            
        } else {
            searchActive = true;
            
        }
        self.tableView!.reloadData()
        
    }

    func addItems(items:[FilterObject]){
        self.items.removeAll()
        
        var indexPaths : [NSIndexPath] = []
        for (index,item) in items.enumerate() {
            self.items.append(item)
            indexPaths.append(NSIndexPath.init(forRow:index , inSection: 0))
        }

        self.tableView!.beginUpdates()
        self.tableView!.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        self.tableView!.endUpdates()
    }
}
