//
//  CategoryNavigationTableViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 6/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RATreeView

class CategoryNavigationTableViewController: UIViewController{
    
    private let raTreeView = RATreeView()
    fileprivate let kCategoryNavigationTableViewCell = "CategoryNavigationTableViewCell"
    
    fileprivate var categories: [ListOption]!
    
    init(categories: [ListOption]) {
        super.init(nibName: nil, bundle: nil)
        self.categories = categories
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table View Setup
    
    private func setupTableView() {
        hideDefaultSeparator()
        raTreeView.backgroundColor = .white
        raTreeView.register(UINib(nibName: kCategoryNavigationTableViewCell, bundle: nil), forCellReuseIdentifier: kCategoryNavigationTableViewCell)
        
        self.view.addSubview(raTreeView)
        raTreeView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        raTreeView.dataSource = self
        raTreeView.delegate = self

    }
    
    private func hideDefaultSeparator() {
        raTreeView.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
    }

}

extension CategoryNavigationTableViewController: RATreeViewDataSource, RATreeViewDelegate {
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if let item = item as? ListOption {
            if let child = item.child {
                
                let parentCategoryForChild = ListOption()
                
                parentCategoryForChild.name = item.name
                parentCategoryForChild.applinks = item.applinks

                item.child?.insert(parentCategoryForChild, at: 0)
                return item.child!.count
            } else {
                return 0
            }
        } else {
            return categories.count
        }
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: kCategoryNavigationTableViewCell) as! CategoryNavigationTableViewCell
        
        let level = treeView.levelForCell(forItem: item) + 1
        let listOption = item as! ListOption
        cell.setListOption(listOption: listOption)
        
        cell.setCategoryNameIndentation(level: level)
        cell.selectionStyle = .none

        return cell
    }
    
    func treeView(_ treeView: RATreeView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return categories[index]
        } else if let item = item as? ListOption {
            return item.child![index]
        }
        
        fatalError()
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        if item is ListOption {
            let categoryDetail = item as! ListOption
            if categoryDetail.child == nil && categoryDetail.hasChildCategories == false {
                self.dismiss(animated: true, completion: {
                    let categoryNameHTMLEscape = categoryDetail.name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                    TPRoutes.routeURL(URL(string: "\(categoryDetail.applinks)?categoryName=\(categoryNameHTMLEscape!)")!)
                })
            }
        }
    }
}
