//
//  FiltersListDataSource.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FiltersListDataSource:  NSObject, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate  {

    var tableView: UITableView?
    private var searchBar: UISearchBar = UISearchBar()
    private var items: [ListOption] = []
    private var showSearchBar: Bool = false
    var selectedObjects : [ListOption] = []
    
    private var filteredItem:[ListOption] = []
    private var searchActive : Bool = false
    private var searchBarPlaceholder = ""
    
    private var completionHandler:([ListOption])->Void = {(arg:[ListOption]) -> Void in}
    
    override init() {
        super.init()
    }
    
    init(tableView:UITableView, showSearchBar:Bool,selectedObjects:[ListOption], searchBarPlaceholder: String, onCompletion: (([ListOption]) -> Void)) {
        super.init()
        
        completionHandler = onCompletion
        self.showSearchBar = showSearchBar
        self.selectedObjects = selectedObjects
        
        self.tableView = tableView
        
        self.tableView!.delegate      =   self
        self.tableView!.dataSource    =   self
        
        self.tableView!.registerClass(FilterTableViewCell.self, forCellReuseIdentifier: "cellCheckmark")
        self.tableView!.registerClass(TextFieldCell.self, forCellReuseIdentifier: "cellTextField")
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
        
        var cell:UITableViewCell = UITableViewCell()
        
        let item : ListOption = self.item(indexPath.row)
        
        if item.input_type == self.checkmarType() {
            cell = FilterTableViewCell.init(style: .Default, reuseIdentifier: "cellCheckmark")
            (cell as! FilterTableViewCell).label.text =  item.name
            (cell as! FilterTableViewCell).disableSelected = false
            (cell as! FilterTableViewCell).setPading(10)
            for selected in selectedObjects {
                if selected == item {
                    tableView .selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .Bottom)
                }
            }
            
            let customColorView = UIView()
            customColorView.backgroundColor = UIColor.whiteColor()
            cell.selectedBackgroundView =  customColorView;
        }
        if item.input_type == self.textInputType() {
            cell = TextFieldCell.init(style: .Default, reuseIdentifier: "cellTextField")
            (cell as! TextFieldCell).titleLabel.text = item.name
            
            for selected in selectedObjects {
                if selected.key == item.key {
                    
                    if Int(selected.value) == 0 {
                        selected.value = ""
                    }
                    (cell as! TextFieldCell).textField.text = selected.value
                    break;
                } else {
                    (cell as! TextFieldCell).textField.text = ""
                }
            }

            (cell as! TextFieldCell).textField.tag = indexPath.row
            (cell as! TextFieldCell).textField.delegate = self
            
            cell.selectionStyle = .None
        }
        
        return cell
    }
    
    func textInputType() -> NSString {
        return "textbox"
    }
    
    func checkmarType() -> NSString {
        return "checkbox"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let item : ListOption = self.item(indexPath.row)
        
        if item.isSelected {
            item.isSelected = false
            self.tableView!.deselectRowAtIndexPath(indexPath, animated: false)
            for (index, selected) in selectedObjects.enumerate() {
                if selected == item{
                    selectedObjects.removeAtIndex(index)
                }
            }
        } else{
            item.isSelected = true
            selectedObjects.append(item)
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
    
    private func item(index:Int) -> ListOption {
        var item : ListOption = items[index]
        
        if(searchActive){
            if searchBar.text == "" {
                item = items[index];
            } else {
                item = filteredItem[index]
            }
        } else {
            item = items[index];
        }
        return item
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let item : ListOption = self.item(indexPath.row)
        
        if item.input_type == self.textInputType() {
            return 55
        } else {
            return 44
        }
    }
    
    //MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
        
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredItem = items.filter({ (object) -> Bool in
            let tmp: ListOption = object
            
            return tmp.name.lowercaseString.rangeOfString(searchBar.text!.lowercaseString) != nil
        })
        if(filteredItem.count == 0){
            searchActive = false;
            
        } else {
            searchActive = true;
            
        }
        self.tableView!.reloadData()
        searchBar.becomeFirstResponder()
        
    }
    
    func addItems(items:[ListOption]){
        self.items.removeAll()
        
        var indexPaths : [NSIndexPath] = []
        for (index,item) in items.enumerate() {
            self.selectedObjects.forEach({ (selectedItem) in
                if item == selectedItem {
                    item.isSelected = true;
                }
            })
            self.items.append(item)
            indexPaths.append(NSIndexPath.init(forRow:index , inSection: 0))
        }
        
        self.tableView!.beginUpdates()
        self.tableView!.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        self.tableView!.endUpdates()
        
    }
    
    func  textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        let item : ListOption = self.item(textField.tag)
        
        let selectedObject = item.copy() as! ListOption
        selectedObject.value = "\(newString)"
        
        for (index, selected) in selectedObjects.enumerate() {
            if selected.key == selectedObject.key || selected.value == ""{
                selectedObjects.removeAtIndex(index)
            }
        }
        if selectedObject.value != "" {
            selectedObjects .append(selectedObject)
        }
        completionHandler(selectedObjects)
        return true
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedObjects = []
        items.forEach({$0.isSelected = false})
        self.tableView!.reloadData()
    }

}
