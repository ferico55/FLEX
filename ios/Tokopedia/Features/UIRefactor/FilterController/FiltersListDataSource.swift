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
    fileprivate var searchBar: UISearchBar = UISearchBar()
    fileprivate var items: [ListOption] = []
    fileprivate var showSearchBar: Bool = false
    var selectedObjects : [ListOption] = []
    
    fileprivate var filteredItem:[ListOption] = []
    fileprivate var searchActive : Bool = false
    fileprivate var searchBarPlaceholder = ""
    
    fileprivate var completionHandler:([ListOption])->Void = {(arg:[ListOption]) -> Void in}
    fileprivate var timer : Timer?
    
    override init() {
        super.init()
    }
    
    init(tableView:UITableView, showSearchBar:Bool,selectedObjects:[ListOption], searchBarPlaceholder: String, onCompletion: @escaping (([ListOption]) -> Void)) {
        super.init()
        
        completionHandler = onCompletion
        self.showSearchBar = showSearchBar
        self.selectedObjects = selectedObjects
        
        self.tableView = tableView
        
        self.tableView!.delegate      =   self
        self.tableView!.dataSource    =   self
        
        self.tableView!.register(FilterTableViewCell.self, forCellReuseIdentifier: "cellCheckmark")
        self.tableView!.register(TextFieldCell.self, forCellReuseIdentifier: "cellTextField")
        self.tableView!.tableFooterView = UIView(frame: CGRect(x:0, y:0, width:1, height:1))
        self.tableView!.keyboardDismissMode = .interactive
        
        searchBar = UISearchBar(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:44))
        searchBar.delegate = self
        let image = UIImage()
        searchBar.setBackgroundImage(image, for: .any, barMetrics: .default)
        searchBar.scopeBarBackgroundImage = image
        searchBar.placeholder = searchBarPlaceholder
        searchBar.isTranslucent = true
        searchBar.backgroundColor = UIColor.white
        searchBar.searchBarStyle = UISearchBarStyle.minimal
        
        searchBar.tintColor = UIColor.gray
        
        self.tableView!.allowsMultipleSelection = true
        self.tableView!.reloadData()
        
    }
    
    func reloadDataAfterFilter() {
        self.tableView!.reloadData()
        searchBar.becomeFirstResponder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = UITableViewCell()
        
        let item = self.items(at: indexPath.row)
        
        if item.input_type == self.textInputType() {
            cell = TextFieldCell(style: .default, reuseIdentifier: "cellTextField")
            (cell as! TextFieldCell).titleLabel.text = item.name
            
            for selected in selectedObjects {
                if selected.key == item.key {
                    if Int(selected.value!) == 0 {
                        selected.value = ""
                    }
                    (cell as! TextFieldCell).textField.text = selected.value
                    break
                } else {
                    (cell as! TextFieldCell).textField.text = ""
                }
            }

            (cell as! TextFieldCell).textField.tag = indexPath.row
            (cell as! TextFieldCell).textField.delegate = self
            
            cell.selectionStyle = .none
        } else {
            cell = FilterTableViewCell(style: .default, reuseIdentifier: "cell")
            
            if let _ = item.child {
                (cell as! FilterTableViewCell).disableSelected = true
                if item.isExpanded {
                    (cell as! FilterTableViewCell).setArrowDirection(.up)
                } else {
                    (cell as! FilterTableViewCell).setArrowDirection(.down)
                }
            } else {
                (cell as! FilterTableViewCell).disableSelected = false
            }
            
            if let itemTree = item.tree {
                let tree = Int(itemTree)!
                (cell as! FilterTableViewCell).setPading(CGFloat(tree) * 20)
            }
            
            (cell as! FilterTableViewCell).label.text = item.name
            
            let customColorView = UIView()
            customColorView.backgroundColor = UIColor.clear
            cell.selectedBackgroundView =  customColorView;
            cell.bringSubview(toFront: cell.selectedBackgroundView!)
        }
        return cell
    }
    
    func textInputType() -> String {
        return "textbox"
    }
    
    func checkmarType() -> String {
        return "checkbox"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.items(at: indexPath.row)
        
        guard item.input_type != textInputType() else { return }
        
        let cell:FilterTableViewCell = tableView.cellForRow(at: indexPath) as! FilterTableViewCell

        if item.child != nil && item.input_type != textInputType(){
            if item.isExpanded == true {
                self.doCollapseItem(item)
            } else {
                self.doExpandItem(item)
            }
        } else {
            if self.isMultipleSelect{
                item.isSelected = !item.isSelected
                if item.isSelected == false {
                    self.tableView?.deselectRow(at: indexPath, animated: false)
                    selectedObjects = selectedObjects.filter({ $0 != item })
                } else {
                    selectedObjects.append(item)
                }
            } else{
                item.isSelected = self.isSelectedCategory(item)
                item.isSelected = !item.isSelected
                if selectedObjects.count > 0 {
                    let selectedItem :ListOption = self.selectedObjects.first!
                    for (index, itemShow) in self.items.enumerated() {
                        if selectedItem == itemShow {
                            selectedObjects.removeAll()
                            self.tableView?.beginUpdates()
                            self.tableView?.reloadRows(at:[IndexPath(row: index, section: 0)], with: .none)
                            self.tableView?.endUpdates()
                        }
                    }
                }
                if item.isSelected == true {
                    selectedObjects.append(item)
                    cell.setSelected(true, animated: false)
                }
            }
            
            completionHandler(selectedObjects)
        }
    
        if item.isExpanded {
            cell.setArrowDirection(.up)
        } else {
            cell.setArrowDirection(.down)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if showSearchBar && items.count > 0 {
            return 44
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.searchBar;
    }
    
    fileprivate func items(at index:Int) -> ListOption {
        var item = items[index]
        
        if(searchActive){
            if searchBar.text == "" {
                item = items[index];
            } else {
                if let filtered = filteredItem[safe:index]{
                    item = filtered
                }
            }
        } else {
            item = items[index];
        }
        return item
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = self.items(at: indexPath.row)
        
        if item.input_type == self.textInputType() {
            return 55
        } else {
            return 44
        }
    }
    
    //MARK: - SearchBar Delegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        timer?.invalidate()
        timer = nil
        searchActive = (searchBar.text != "");
        searchBar.resignFirstResponder()
        tableView?.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredItem = items.filter({ (object) -> Bool in
            let tmp: ListOption = object
            
            return tmp.name.lowercased().range(of:searchBar.text!.lowercased()) != nil
        })
        if(filteredItem.count == 0){
            searchActive = false;
            
        } else {
            searchActive = true;
            
        }
        
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(FiltersListDataSource.reloadDataAfterFilter), userInfo: nil, repeats: false)

    }
    
    func addItems(_ items:[ListOption]){
        self.items.removeAll()
        
        var indexPaths : [IndexPath] = []
        for (index,item) in items.enumerated() {
            self.selectedObjects.forEach({ (selectedItem) in
                if item == selectedItem {
                    item.isSelected = true;
                }
            })
            self.items.append(item)
            indexPaths.append(IndexPath(row:index , section: 0))
        }
        
        self.tableView!.beginUpdates()
        self.tableView!.insertRows(at: indexPaths, with: .automatic)
        self.tableView!.endUpdates()
        
        expandSelectedItem()

    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Int(string) == nil && string != "" {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let item = self.items(at: textField.tag)
        
        let selectedObject = item.copy() as! ListOption
        selectedObject.value = "\(newString)"
        
        for (index, selected) in selectedObjects.enumerated() {
            if selected.key == selectedObject.key {
                selectedObjects.remove(at: index)
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
    }
    
    fileprivate var lastSelectedIndexPath : IndexPath?
    fileprivate var refreshControl : UIRefreshControl = UIRefreshControl()
    fileprivate var rootCategoryID :String = ""
    fileprivate var isMultipleSelect : Bool = true

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let option = self.items(at: indexPath.row)
        if self.selectedObjects.contains(option) {
            cell.setSelected(true, animated: false)
        }
    }
    
    func isSelectedCategory(_ category:ListOption) -> Bool {
        if self.selectedObjects.contains(category) {
            return true
        } else  {
            return false
        }
    }
    
    func doExpandItem(_ selectedItem:(ListOption)) {
        for item in self.items {
            if selectedItem.value == item.value{
                self.expand(selectedItem, initItem: item)
            } else  {
                for childItem in item.child ?? [] {
                    if selectedItem.value == childItem.value {
                        self.expand(selectedItem, initItem: childItem)
                    }
                }
            }
        }
    }
    
    func expand(_ selectedItem:(ListOption), initItem:(ListOption)) {
        if selectedItem.value == initItem.value {
            initItem.isExpanded = true
            
            let location : Int  = self.items.index(of: initItem)! + 1
            var indexPaths : [IndexPath] = []
            
            self.tableView?.beginUpdates()
            initItem.child?.forEach { child in
                let index = initItem.child?.index(of: child) ?? 0
                child.isExpanded = false
                if !self.items.contains(child) {
                    self.items.insert(child, at: location + index)
                    indexPaths.append(IndexPath(row:location+index , section: 0))
                }
            }
            tableView?.insertRows(at: indexPaths, with: .automatic)
            tableView?.endUpdates()
        }
    }
    
    func doCollapseItem(_ selectedItem:(ListOption)) {
        selectedItem.isExpanded = false
        for (index,item) in self.items.enumerated() where item.parent == selectedItem.value {
            
            self.tableView?.beginUpdates()
            items.remove(at: index)
            self.tableView?.deleteRows(at: [IndexPath(row:index , section: 0)], with: .automatic)
            self.tableView?.endUpdates()
            self.doCollapseItem(item)
            self.doCollapseItem(selectedItem)
            break
            
        }
    }
    
    func expandSelectedItem(){
        for item in self.items {
            for selectedItem in selectedObjects {
                if selectedItem.isEqual(item) {
                    item.isSelected = true
                    item.isExpanded = true
                } else {
                    self.expandChildItem(item)
                }
            }
        }
    }
    
    func expandChildItem(_ item:(ListOption)) {
        guard let childs = item.child else { return }
        for childItem in childs {
            for selectedItem in selectedObjects {
                if childItem.isEqual(selectedItem) {
                    childItem.isSelected = true
                    self.addItemChild(item)
                } else {
                    self.expandLastItem(childItem, parentItem: item)
                }
            }
        }
    }
    
    func expandLastItem(_ item:(ListOption), parentItem:(ListOption)) {
        guard let childs = item.child else { return }
        for lastItem in childs {
            for selectedItem in selectedObjects {
                if lastItem.isEqual(selectedItem){
                    lastItem.isSelected = true
                    self.addItemChild(parentItem)
                    self.addItemChild(item)
                }
            }
        }
    }
    
    func addItemChild(_ parentItem:(ListOption)) {
        parentItem.isExpanded = true
        
        let location : Int  = self.items.index(of: parentItem)! + 1
        var indexPaths : [IndexPath] = []
        self.tableView?.beginUpdates()
        parentItem.child?.forEach { child in
            let index = parentItem.child?.index(of: child) ?? 0
            if self.items.contains(child) == false {
                child.isExpanded = false
                self.items.insert(child, at: location + index)
                indexPaths.append(IndexPath(row:location+index , section: 0))
            }
        }
        tableView?.insertRows(at: indexPaths, with: .automatic)
        tableView?.endUpdates()
    }

}
