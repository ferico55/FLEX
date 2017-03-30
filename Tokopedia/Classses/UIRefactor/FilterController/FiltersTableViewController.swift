//
//  FiltersTableViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/3/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FiltersTableViewController: UIViewController {

    fileprivate var tableView: UITableView = UITableView()
    fileprivate var filtersDatasource : FiltersListDataSource = FiltersListDataSource()
    fileprivate var items: [ListOption] = []
    fileprivate var showSearchBar: Bool = false
    var selectedObjects : [ListOption] = []
    fileprivate var searchBarPlaceholder : String = ""
    
    fileprivate var completionHandler:([ListOption])->Void = {(arg:[ListOption]) -> Void in}
    
    init(items:[ListOption],selectedObjects:[ListOption], showSearchBar:Bool, searchBarPlaceholder:String, onCompletion: @escaping (([ListOption]) -> Void)){
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
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)
        
        tableView.dataSource = filtersDatasource
        tableView.delegate = filtersDatasource
        
        filtersDatasource =   FiltersListDataSource(tableView: tableView, showSearchBar: self.showSearchBar, selectedObjects:self.selectedObjects, searchBarPlaceholder: self.searchBarPlaceholder) { (selectedObjects) in
            self.selectedObjects = selectedObjects
            self.completionHandler(selectedObjects)
        }
        filtersDatasource.addItems(self.items)
        self.view.addSubview(self.tableView)
        
        self.tableView.mas_makeConstraints { (make) in
            make?.edges.equalTo()(self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        self.selectedObjects = []
        filtersDatasource.resetSelectedFilter()
        tableView.reloadData()
    }

}
