//
//  CategoryFilterViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum CategoryFilterType : Int {
    case Hotlist
    case Category
    case SearchProduct
    case AddProduct
}

@objc enum DirectionArrow : Int {
    case Up
    case Down
}

class FilterTableViewCell: UITableViewCell
{
    var selectedImageView : UIImageView = UIImageView()
    var arrowImageView : UIImageView = UIImageView()
    var leftPading : CGFloat = 0.0
    var label : UILabel = UILabel ()
    var disableSelected :Bool = true
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.numberOfLines = 0
        let font = UIFont.init(name: "GothamBook", size: 13)
        label.font = font
        arrowImageView.contentMode = .ScaleAspectFit
        selectedImageView.contentMode = .ScaleAspectFit
        selectedImageView.hidden = true
        selectedImageView.image = UIImage.init(named: "icon_circle.png")
        arrowImageView.image = UIImage.init(named: "icon_arrow_down.png")

        self.addSubview(selectedImageView)
        self.addSubview(arrowImageView)
        self.addSubview(label)
    }

    func setPading(leftPading: CGFloat) {
        selectedImageView.hidden = disableSelected
        arrowImageView.hidden = !disableSelected

        self.leftPading = leftPading
        arrowImageView.frame = CGRect(origin: CGPoint(x: self.frame.size.width - 25, y: 15), size: CGSize(width: 10, height: 10))
        selectedImageView.frame =  CGRect(origin: CGPoint(x: 0 + leftPading, y: 13), size: CGSize(width: 15, height: 15))
        label.frame = CGRectMake(0 + selectedImageView.frame.width + leftPading + 10, 0, self.frame.size.width - ( selectedImageView.frame.origin.x + selectedImageView.frame.size.width + arrowImageView.frame.size.width + 25), self.frame.size.height)
    }
    
    func setArrowDirection(direction:DirectionArrow) {
        if (direction == .Up) {
            arrowImageView.image = UIImage.init(named: "icon_arrow_up.png")
        } else if (direction == .Down) {
            arrowImageView.image = UIImage.init(named: "icon_arrow_down.png")
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool){
        if (selected) {
            selectedImageView.image = UIImage.init(named: "icon_checkmark_green-01.png")
        } else {
            selectedImageView.image = UIImage.init(named: "icon_circle.png")
        }
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
    }
}

@objc class CategoryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var initialCategories: [CategoryDetail] = []
    private var categories : [CategoryDetail] = []
    private var selectedCategories : [CategoryDetail] = []
    private var filterType : CategoryFilterType?
    
    
    private var tableView : UITableView = UITableView()
    private var lastSelectedIndexPath : NSIndexPath?
    
    
    private var completionHandler:([CategoryDetail])->Void = {(arg:[CategoryDetail]) -> Void in}
    
    private var refreshControl : UIRefreshControl = UIRefreshControl()
    
    init(selectedCategories:[CategoryDetail], filterType:CategoryFilterType, initialCategories:[CategoryDetail], onCompletion: (([CategoryDetail]) -> Void)){
        completionHandler = onCompletion
        self.selectedCategories = selectedCategories
        self.initialCategories = initialCategories
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)

        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.allowsSelection = true
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, 1, 1))
        tableView.registerClass(FilterTableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(tableView)
        
        if (self.initialCategories.count == 0) {
            tableView.setContentOffset(CGPointMake(0, -refreshControl.frame.size.height), animated:true)
            refreshControl.beginRefreshing()

            self.requestCategory()
        } else {
            self.showPresetCategories()
            self.addCategories(self.initialCategories)
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
//
//        self.initialCategories = self.categories;
//        if self.selectedCategories.count > 0
//        {
////            self.expandSelectedCategories()
//        }

    }

    func refresh(sender:AnyObject) {
        self .requestCategory()
    }
    
    func requestCategory() {
        RequestFilterCategory.fetchListFilterCategory({ (categories) in
            self.tableView.setContentOffset(CGPointZero, animated:true)
            self.refreshControl.endRefreshing()
            
            self.addCategories(categories)
            
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
            category.setLastCategory()
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
        if Int(category.tree) > 1 {
            let tree:Int = Int(category.tree)!
            cell.setPading( CGFloat(tree) * 20)
        } else {
            cell.setPading(10.0)
        }
        
        cell.label .setCustomAttributedText( category.name as String )
        
        var selectedIDs : [String] = []
        for object in self.selectedCategories {
            selectedIDs.append(object.categoryId as String)
        }
        
        let customColorView = UIView()
        customColorView.backgroundColor = UIColor.clearColor()
        cell.selectedBackgroundView =  customColorView;
        cell.bringSubviewToFront(cell.selectedBackgroundView!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let category:CategoryDetail = self.categories[indexPath.row]
        
        if category.isExpanded == true {
            self.doCollapseCategory(category)
        } else {
            self.doExpandCategory(category)
        }
        
        category.isSelected = !category.isSelected
        if category.child.count == 0{
            if category.isSelected == false {
                self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
                for (index, selected) in selectedCategories.enumerate() {
                    if selected.categoryId == category.categoryId {
                        selectedCategories .removeAtIndex(index)
                    }
                }
            } else {
                selectedCategories.append(category)
            }
            
            completionHandler(selectedCategories)
        }
    }
    
    func doExpandCategory(selectedCategory:(CategoryDetail)) {
        for category in self.initialCategories {
            if selectedCategory.categoryId == category.categoryId {
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
        if selectedCategory.categoryId == initCategory.categoryId {
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
        for (_,category) in self.categories.enumerate() {
            if category.parent == selectedCategory.categoryId{
                category.isExpanded = false

                self.tableView.beginUpdates()
                let location : Int  = categories.indexOf(category)!
                categories.removeAtIndex(location)
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow:location , inSection: 0)], withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                
                for (_,categoryChild) in category.child.enumerate() {
                    categoryChild.isExpanded = false
                    if categoryChild.parent == category.categoryId {
                        let result = categories.filter { $0==categoryChild }
                        if result.isEmpty == false {
                            self.tableView.beginUpdates()
                            let location : Int  = categories.indexOf(categoryChild)!
                            categories.removeAtIndex(location)
                            self.tableView.deleteRowsAtIndexPaths([NSIndexPath.init(forRow:location , inSection: 0)], withRowAnimation: .Automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }

            }
        }
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedCategories = [CategoryDetail()]
//        self.tableView.reloadData()
    }

}
