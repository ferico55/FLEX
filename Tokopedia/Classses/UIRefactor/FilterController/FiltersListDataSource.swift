//
//  FiltersListDataSource.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

extension Collection where Indices.Iterator.Element == Index {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

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
        
        let item : ListOption = self.item(indexPath.row)
        
        if item.input_type == self.checkmarType() as String {
            cell = FilterTableViewCell(style: .default, reuseIdentifier: "cellCheckmark")
            (cell as! FilterTableViewCell).label.text =  item.name
            (cell as! FilterTableViewCell).disableSelected = false
            (cell as! FilterTableViewCell).setPading(10)
            for selected in selectedObjects {
                if selected.value == item.value && selected.key == item.key {
                    item.isSelected = true
                    tableView .selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                }
            }
            
            let customColorView = UIView()
            customColorView.backgroundColor = UIColor.white
            cell.selectedBackgroundView =  customColorView;
        }
        if item.input_type == self.textInputType() as String {
            cell = TextFieldCell(style: .default, reuseIdentifier: "cellTextField")
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
            
            cell.selectionStyle = .none
        }
        
        return cell
    }
    
    func textInputType() -> NSString {
        return "textbox"
    }
    
    func checkmarType() -> NSString {
        return "checkbox"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item : ListOption = self.item(indexPath.row)
        
        if item.input_type != textInputType() as String {
            if item.isSelected {
                item.isSelected = false
                self.tableView!.deselectRow(at: indexPath, animated: false)
                for (index, selected) in selectedObjects.enumerated() {
                    if selected == item{
                        selectedObjects.remove(at: index)
                    }
                }
            } else{
                item.isSelected = true
                selectedObjects.append(item)
            }
            completionHandler(selectedObjects)
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
    
    fileprivate func item(_ index:Int) -> ListOption {
        var item : ListOption = items[index]
        
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
        let item : ListOption = self.item(indexPath.row)
        
        if item.input_type == self.textInputType() as String {
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
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if Int(string) == nil && string != "" {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        let item : ListOption = self.item(textField.tag)
        
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

}
