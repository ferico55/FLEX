//
//  FiltersTableViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FiltersTableViewController: UIViewController {

    private var tableView: UITableView = UITableView()
    private var filtersDatasource : FiltersListDataSource = FiltersListDataSource()
    private var items: [ListOption] = []
    private var showSearchBar: Bool = false
    var selectedObjects : [ListOption] = []
    private var searchBarPlaceholder : String = ""
    
    private var completionHandler:([ListOption])->Void = {(arg:[ListOption]) -> Void in}
    
    init(items:[ListOption],selectedObjects:[ListOption], showSearchBar:Bool, searchBarPlaceholder:String, onCompletion: (([ListOption]) -> Void)){
        completionHandler = onCompletion
        self.items = items
        self.selectedObjects = selectedObjects
        self.showSearchBar = showSearchBar
        self.searchBarPlaceholder = searchBarPlaceholder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        
        tableView.dataSource = filtersDatasource
        tableView.delegate = filtersDatasource
        
        filtersDatasource =   FiltersListDataSource.init(tableView: tableView, showSearchBar: self.showSearchBar, selectedObjects:self.selectedObjects, searchBarPlaceholder: self.searchBarPlaceholder) { (selectedObjects) in
            self.selectedObjects = selectedObjects
            self.completionHandler(selectedObjects)
        }
        filtersDatasource.addItems(self.items)
        self.view.addSubview(self.tableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        self.selectedObjects = []
        filtersDatasource.resetSelectedFilter()
        tableView.reloadData()
    }

}
