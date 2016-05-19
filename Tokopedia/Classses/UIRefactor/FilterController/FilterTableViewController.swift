//
//  FilterTableViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterTableViewController: UIViewController {
    
    private var tableView: UITableView = UITableView()
    private var filterDatasource : FilterListDataSource!
    var items: [FilterObject] = []
    var showSearchBar: Bool = false
    private var selectedObjects : [FilterObject] = []
        
    private var completionHandler:([FilterObject])->Void = {(arg:[FilterObject]) -> Void in}
    
    init(items:[FilterObject],selectedObjects:[FilterObject], showSearchBar:Bool, onCompletion: (([FilterObject]) -> Void)){
        completionHandler = onCompletion
        self.items = items
        self.selectedObjects = selectedObjects
        self.showSearchBar = showSearchBar
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        
        tableView.dataSource = filterDatasource
        tableView.delegate = filterDatasource
        
        filterDatasource =   FilterListDataSource.init(tableView: tableView, showSearchBar: self.showSearchBar) { (selectedLocation) in
            
            self.completionHandler(selectedLocation)
        }
        filterDatasource.addItems(self.items)
        filterDatasource.selectedObjects = self.selectedObjects
        filterDatasource.searchBarPlaceholder = "Cari \(self.tabBarItem!.title!)"
        
        self.view.addSubview(self.tableView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)

    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedObjects = [FilterObject()]
        self.tableView.reloadData()
    }
}
