//
//  CategoryFilterViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum DirectionArrow : Int {
    case up
    case down
}

@objc class CategoryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var initialCategories: [CategoryDetail] = []
    fileprivate var categories : [CategoryDetail] = []
    fileprivate var selectedCategories : [CategoryDetail] = []
    fileprivate var tableView : UITableView = UITableView()
    fileprivate var lastSelectedIndexPath : IndexPath?
    fileprivate var completionHandler:([CategoryDetail])->Void = {(arg:[CategoryDetail]) -> Void in}
    fileprivate var refreshControl : UIRefreshControl = UIRefreshControl()
    fileprivate var rootCategoryID :String = ""
    fileprivate var isMultipleSelect : Bool = true
    
    init(rootCategoryID:String, selectedCategories:[CategoryDetail], initialCategories:[CategoryDetail], isMultipleSelect:Bool, onCompletion: @escaping (([CategoryDetail]) -> Void)){
        self.rootCategoryID = rootCategoryID;
        completionHandler = onCompletion
        self.selectedCategories =  selectedCategories.map { ($0.copy() as! CategoryDetail) }
        self.initialCategories = initialCategories.map { ($0.copy() as! CategoryDetail) }
        self.isMultipleSelect = isMultipleSelect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)

        tableView.allowsMultipleSelection = isMultipleSelect
        tableView.allowsMultipleSelectionDuringEditing = isMultipleSelect
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        if (self.initialCategories.count == 0) {
            refreshControl.addTarget(self, action: #selector(CategoryFilterViewController.refresh), for: UIControlEvents.valueChanged)
            tableView.addSubview(refreshControl)
            
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated:true)
            refreshControl.beginRefreshing()

            self.refresh()
        } else {
            self.showPresetCategories()
            self.addCategories(self.initialCategories)
            if selectedCategories.count>0 {
                self.expandSelectedCategories()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectedCategories.count>0 {
            self.completionHandler(self.selectedCategories)
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    func showPresetCategories() {
        for category in self.initialCategories {
            for childCategory in category.child {
                childCategory.parent = category.categoryId;
                for lastCategory in childCategory.child {
                    lastCategory.parent = childCategory.categoryId;
                }
            }
        }
    }

    func refresh() {
        if isMultipleSelect {
            self.requestCategory(rootCategoryID)
        } else {
            self.requestCategory("")
        }
    }
    
    func requestCategory(_ CategoryID:String) {
        RequestFilterCategory.fetchListFilterCategory(CategoryID, success: { (categories) in
            
            self.categories.removeAll()
            self.tableView.reloadData()
            
            self.tableView.setContentOffset(.zero, animated:true)
            self.refreshControl.endRefreshing()
            
            var newCategory :[CategoryDetail] = []
            newCategory = self.categoryWithAddingAllTypeChildFromCategory(categories)
            self.addCategories(newCategory)
            
            if self.selectedCategories.count > 0{
                self.expandSelectedCategories()
            }
            
        }) { (error) in
                self.tableView.setContentOffset(.zero, animated:true)
                self.refreshControl.endRefreshing()
        }
    }
    
    func setSelectedCategory(_ categories:[CategoryDetail]) {
        self.selectedCategories = categories
        completionHandler(self.selectedCategories)
    }
    
    func categoryWithAddingAllTypeChildFromCategory(_ categories:[CategoryDetail]) -> [CategoryDetail]{
        //kasi "Semua <kategory>" ke masing child kalo request dari hades..
        for category in categories {
            for categoryChild in category.child {
                if categoryChild.tree != "3" {
                    categoryChild.child.insert(self.newAllCategory(categoryChild), at: 0)
                }
            }
            if category.tree != "3" {
                category.child.insert(self.newAllCategory(category), at: 0)
            }
        }
        
        return categories
    }
    
    func newAllCategory(_ category:CategoryDetail) -> CategoryDetail {
        let newCategory : CategoryDetail = CategoryDetail();
        newCategory.categoryId = category.categoryId;
        newCategory.name = "Semua \(category.name)"
        let tree: Int = Int(category.tree)!
        newCategory.tree = "\(tree+1)"
        newCategory.child = []
        newCategory.parent = category.categoryId
        return newCategory
    }
    
    func addCategories(_ categories:[CategoryDetail]) {
        self.initialCategories.removeAll()
        self.initialCategories = categories
        
        var indexPaths : [IndexPath] = []
        
        for (index,category) in self.initialCategories.enumerated() {
            category.isExpanded = false
            self.categories.append(category)
            indexPaths.append(IndexPath(row:index , section: 0))
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: indexPaths, with: .automatic)
        self.tableView.endUpdates()
    }
    
    //Mark: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let category : CategoryDetail = categories[indexPath.row]
        if self.selectedCategories .contains(category) {
            cell.setSelected(true, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FilterTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! FilterTableViewCell
        
        let category : CategoryDetail = categories[indexPath.row]
        
        if category.child.count > 0 {
            cell.disableSelected = true
            if category.isExpanded {
                cell.setArrowDirection(.up)
            } else {
                cell.setArrowDirection(.down)
            }
        } else {
            cell.disableSelected = false
        }
        
        cell.frame.size.width = tableView.frame.size.width

        let tree:Int = Int(category.tree)!
        cell.setPading(CGFloat(tree-1) * 20)
        
        cell.label .setCustomAttributedText( category.name as String )
        
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView =  customColorView;
        cell.bringSubview(toFront: cell.selectedBackgroundView!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell:FilterTableViewCell = tableView.cellForRow(at: indexPath) as! FilterTableViewCell
        
        let category:CategoryDetail = self.categories[indexPath.row]
        
        if category.child.count > 0 {
            if category.isExpanded == true {
                self.doCollapseCategory(category)
            } else {
                self.doExpandCategory(category)
            }
        } else {
            if self.isMultipleSelect{
                category.isSelected = !category.isSelected
                if category.isSelected == false {
                    self.tableView.deselectRow(at: indexPath, animated: false)
                    for (index, selected) in selectedCategories.enumerated() {
                        if selected.categoryId == category.categoryId && category.tree == selected.tree{
                            selectedCategories .remove(at: index)
                        }
                    }
                } else {
                    selectedCategories.append(category)
                }
            } else{
                category.isSelected = self.isSelectedCategory(category)
                category.isSelected = !category.isSelected
                if selectedCategories.count > 0 {
                    let selectedCategory :CategoryDetail = self.selectedCategories.first!
                    for (index, categoryShow) in self.categories.enumerated() {
                        if selectedCategory.categoryId == categoryShow.categoryId{
                            selectedCategories.removeAll()
                            self.tableView.beginUpdates()
                            self.tableView.reloadRows(at:[IndexPath(row: index, section: 0)], with: .none)
                            self.tableView.endUpdates()
                        }
                    }
                }
                if category.isSelected == true {
                    selectedCategories.append(category)
                    cell.setSelected(true, animated: false)
                }
            }
            
            completionHandler(selectedCategories)
        }
        
        if category.isExpanded {
            cell.setArrowDirection(.up)
        } else {
            cell.setArrowDirection(.down)
        }
    }
    
    func isSelectedCategory(_ category:CategoryDetail) -> Bool {
        if self.selectedCategories .contains(category) {
            return true
        } else  {
            return false
        }
    }
    
    func doExpandCategory(_ selectedCategory:(CategoryDetail)) {
        for category in self.initialCategories {
            if selectedCategory.categoryId == category.categoryId{
                self.expand(selectedCategory, initCategory: category)
            } else  {
                for childCategory in category.child {
                    if selectedCategory.categoryId == childCategory.categoryId {
                        self.expand(selectedCategory, initCategory: childCategory)
                    }
                }
            }
        }
    }
    
    func expand(_ selectedCategory:(CategoryDetail), initCategory:(CategoryDetail)) {
        if selectedCategory.categoryId == initCategory.categoryId{
            initCategory.isExpanded = true
            
            let location : Int  = self.categories.index(of: initCategory)! + 1
            var indexPaths : [IndexPath] = []
            
            self.tableView.beginUpdates()
            
            for (index, categoryChildChild) in initCategory.child.enumerated() {
                categoryChildChild.isExpanded = false
                self.categories.insert(categoryChildChild, at: location + index)
                indexPaths.append(IndexPath(row:location+index , section: 0))
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
            tableView.endUpdates()
        }
    }
    
    func doCollapseCategory(_ selectedCategory:(CategoryDetail)) {
        selectedCategory.isExpanded = false
        for (index,category) in self.categories.enumerated() where category.parent == selectedCategory.categoryId {
            
            self.tableView.beginUpdates()
            categories.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row:index , section: 0)], with: .automatic)
            self.tableView.endUpdates()
            self.doCollapseCategory(category)
            self.doCollapseCategory(selectedCategory)
            break
            
        }
    }
    
    func expandSelectedCategories(){
        for category in self.initialCategories {
            for selectedCategory in self.selectedCategories {
                if category.categoryId == selectedCategory.categoryId && category.tree == selectedCategory.tree {
                    category.isSelected = true
                    category.isExpanded = true
                } else {
                    self.expandChildCategory(category)
                }
            }
        }
    }
    
    func expandChildCategory(_ category:(CategoryDetail)) {
        for childCategory in category.child {
            for selectedCategory in self.selectedCategories {
                if childCategory.categoryId == selectedCategory.categoryId && childCategory.tree == selectedCategory.tree {
                    childCategory.isSelected = true
                    self.addCategoryChild(category)
                } else {
                    self.expandLastCategory(childCategory, parentCategory: category)
                }
            }
        }

    }
    
    func expandLastCategory(_ category:(CategoryDetail), parentCategory:(CategoryDetail)) {
        for lastCategory in category.child {
            for selectedCategory in self.selectedCategories {
                if lastCategory.categoryId == selectedCategory.categoryId && lastCategory.tree == selectedCategory.tree {
                    lastCategory.isSelected = true
                    self.addCategoryChild(parentCategory)
                    self.addCategoryChild(category)
                }
            }
        }
    }
    
    
    func addCategoryChild(_ parentCategory:(CategoryDetail)) {
        parentCategory.isExpanded = true
        
        let location : Int  = self.categories.index(of: parentCategory)! + 1
        var indexPaths : [IndexPath] = []
        self.tableView.beginUpdates()
        for (index, categorychild) in parentCategory.child.enumerated() {
            if self.categories.contains(categorychild) == false {
                categorychild.isExpanded = false
                self.categories.insert(categorychild, at: location + index)
                indexPaths.append(IndexPath(row:location+index , section: 0))
            }
        }
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedCategories = []
        categories.forEach({$0.isSelected = false})
        self.tableView.reloadData()
    }

}
