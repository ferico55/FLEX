//
//  CategoryFilterViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum DirectionArrow : Int {
    case Up
    case Down
}

@objc class CategoryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var initialCategories: [CategoryDetail] = []
    private var categories : [CategoryDetail] = []
    private var selectedCategories : [CategoryDetail] = []
    private var tableView : UITableView = UITableView()
    private var lastSelectedIndexPath : NSIndexPath?
    private var completionHandler:([CategoryDetail])->Void = {(arg:[CategoryDetail]) -> Void in}
    private var refreshControl : UIRefreshControl = UIRefreshControl()
    private var rootCategoryID :String = ""
    private var isMultipleSelect : Bool = true
    
    init(rootCategoryID:String, selectedCategories:[CategoryDetail], initialCategories:[CategoryDetail], isMultipleSelect:Bool, onCompletion: (([CategoryDetail]) -> Void)){
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
        
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)

        tableView.allowsMultipleSelection = isMultipleSelect
        tableView.allowsMultipleSelectionDuringEditing = isMultipleSelect
        tableView.allowsSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.registerClass(FilterTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        if (self.initialCategories.count == 0) {
            refreshControl.addTarget(self, action: #selector(CategoryFilterViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            tableView.addSubview(refreshControl)
            
            tableView.setContentOffset(CGPointMake(0, -refreshControl.frame.size.height), animated:true)
            refreshControl.beginRefreshing()

            self.requestCategory()
        } else {
            self.showPresetCategories()
            self.addCategories(self.initialCategories)
            if selectedCategories.count>0 {
                self.expandSelectedCategories()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if selectedCategories.count>0 {
            self.completionHandler(self.selectedCategories)
        }
    }
    
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
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

    func refresh(sender:AnyObject) {
        self .requestCategory()
    }
    
    func requestCategory() {
        RequestFilterCategory.fetchListFilterCategory(rootCategoryID, success: { (categories) in
            
            self.categories.removeAll()
            self.tableView.reloadData()
            
            self.tableView.setContentOffset(CGPointZero, animated:true)
            self.refreshControl.endRefreshing()
            
            self.addCategories(categories)
            if self.selectedCategories.count>0 {
                self.expandSelectedCategories()
            }
            
        }) { (error) in
                self.tableView.setContentOffset(CGPointZero, animated:true)
                self.refreshControl.endRefreshing()
        }
    }
    
    func addCategories(categories:[CategoryDetail]) {
        self.initialCategories.removeAll()
        self.initialCategories = categories
        
        var indexPaths : [NSIndexPath] = []
        
        for (index,category) in self.initialCategories.enumerate() {
            category.isExpanded = false
            self.categories.append(category)
            indexPaths.append(NSIndexPath.init(forRow:index , inSection: 0))
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        self.tableView.endUpdates()
    }
    
    //Mark: - Table view data source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.categories.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let category : CategoryDetail = categories[indexPath.row]
        if self.selectedCategories .contains(category) {
            cell.setSelected(true, animated: false)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:FilterTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as! FilterTableViewCell
        
        let category : CategoryDetail = categories[indexPath.row]
        
        if category.child.count > 0 {
            cell.disableSelected = true
            if category.isExpanded {
                cell.setArrowDirection(.Up)
            } else {
                cell.setArrowDirection(.Down)
            }
        } else {
            cell.disableSelected = false
        }
        
        cell.frame.size.width = tableView.frame.size.width

        let tree:Int = Int(category.tree)!
        cell.setPading(CGFloat(tree-1) * 20)
        
        cell.label .setCustomAttributedText( category.name as String )
        
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView =  customColorView;
        cell.bringSubviewToFront(cell.selectedBackgroundView!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell:FilterTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! FilterTableViewCell
        
        let category:CategoryDetail = self.categories[indexPath.row]
        
        if category.child.count > 0 {
            if category.isExpanded == true {
                self.doCollapseCategory(category)
            } else {
                self.doExpandCategory(category)
            }
        } else {
            category.isSelected = self.isSelectedCategory(category)
            category.isSelected = !category.isSelected
            if self.isMultipleSelect{
                if category.isSelected == false {
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
                    for (index, selected) in selectedCategories.enumerate() {
                        if selected.categoryId == category.categoryId && category.tree == selected.tree{
                            selectedCategories .removeAtIndex(index)
                        }
                    }
                } else {
                    selectedCategories.append(category)
                }
            } else{
                if selectedCategories.count > 0 {
                    let selectedCategory :CategoryDetail = self.selectedCategories.first!
                    for (index, categoryShow) in self.categories.enumerate() {
                        if selectedCategory.categoryId == categoryShow.categoryId && categoryShow.tree == selectedCategory.tree{
                            selectedCategories.removeAll()
                            self.tableView.beginUpdates()
                            self.tableView.reloadRowsAtIndexPaths([NSIndexPath.init(forRow: index, inSection: 0)], withRowAnimation: .None)
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
            cell.setArrowDirection(.Up)
        } else {
            cell.setArrowDirection(.Down)
        }
    }
    
    func isSelectedCategory(category:CategoryDetail) -> Bool {
        if self.selectedCategories .contains(category) {
            return true
        } else  {
            return false
        }
    }
    
    func doExpandCategory(selectedCategory:(CategoryDetail)) {
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
    
    func expand(selectedCategory:(CategoryDetail), initCategory:(CategoryDetail)) {
        if selectedCategory.categoryId == initCategory.categoryId{
            initCategory.isExpanded = true
            
            let location : Int  = self.categories.indexOf(initCategory)! + 1
            var indexPaths : [NSIndexPath] = []
            
            self.tableView.beginUpdates()
            
            for (index, categoryChildChild) in initCategory.child.enumerate() {
                categoryChildChild.isExpanded = false
                self.categories.insert(categoryChildChild, atIndex: location + index)
                indexPaths.append(NSIndexPath.init(forRow:location+index , inSection: 0))
            }
            tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            tableView.endUpdates()
        }
    }
    
    func doCollapseCategory(selectedCategory:(CategoryDetail)) {
        selectedCategory.isExpanded = false
        for (index,category) in self.categories.enumerate() where category.parent == selectedCategory.categoryId {
            
            self.tableView.beginUpdates()
            categories.removeAtIndex(index)
            self.tableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow:index , inSection: 0)], withRowAnimation: .Automatic)
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
                } else {
                    self.expandChildCategory(category)
                }
            }
        }
    }
    
    func expandChildCategory(category:(CategoryDetail)) {
        for childCategory in category.child {
            for selectedCategory in self.selectedCategories {
                if childCategory.categoryId == selectedCategory.categoryId && childCategory.tree == selectedCategory.tree{
                    childCategory.isSelected = true
                    self.addCategoryChild(category)
                } else {
                    self.expandLastCategory(childCategory, parentCategory: category)
                }
            }
        }

    }
    
    func expandLastCategory(category:(CategoryDetail), parentCategory:(CategoryDetail)) {
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
    
    
    func addCategoryChild(parentCategory:(CategoryDetail)) {
        parentCategory.isExpanded = true
        
        let location : Int  = self.categories.indexOf(parentCategory)! + 1
        var indexPaths : [NSIndexPath] = []
        self.tableView.beginUpdates()
        for (index, categorychild) in parentCategory.child.enumerate() {
            if self.categories.contains(categorychild) == false {
                categorychild.isExpanded = false
                self.categories.insert(categorychild, atIndex: location + index)
                indexPaths.append(NSIndexPath.init(forRow:location+index , inSection: 0))
            }
        }
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedCategories = []
        categories.forEach({$0.isSelected = false})
        self.tableView.reloadData()
    }

}
