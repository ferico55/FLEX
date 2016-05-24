//
//  LocationFilterViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class LocationFilterViewController: UIViewController {
    
    var items: [FilterObject] = []
    private var selectedObjects : [FilterObject] = []
    
    private var completionHandler:([FilterObject])->Void = {(arg:[FilterObject]) -> Void in}
    
    private var tableView: UITableView = UITableView()
    private var filterDatasource : FilterListDataSource!
    
    private var refreshControl : UIRefreshControl = UIRefreshControl()

    
    init(selectedObjects:[FilterObject], onCompletion: (([FilterObject]) -> Void)){
        completionHandler = onCompletion
        self.selectedObjects = selectedObjects
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        tableView = UITableView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height), style: .Plain)
        tableView.dataSource = filterDatasource
        tableView.delegate = filterDatasource

        self.view.addSubview(self.tableView)
        
        filterDatasource =   FilterListDataSource.init(tableView: tableView, showSearchBar: true, selectedObjects:self.selectedObjects) { (selectedLocation) in
            
            self.completionHandler(selectedLocation)
        }

        filterDatasource.searchBarPlaceholder = "Cari \(self.tabBarItem!.title!)"
        
        refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.setContentOffset(CGPointMake(0, -refreshControl.frame.size.height), animated:true)
        refreshControl.beginRefreshing()
        
        self.requestCity()
    }
    
    func refresh(sender:AnyObject) {
        self .requestCity()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if selectedObjects.count>0 {
            self.completionHandler(self.selectedObjects)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        
    }

    func requestCity() {

        RequestShippingCity.fetchListShippingCity({ (cities) in
            
            var items : [FilterObject] = []
            let object : FilterObject = FilterObject()
            object.filterID = "2210,2228,5573,1940,1640,2197"
            object.title = "Jabodetabek"
            items.append(object)
            for city in cities{
                let object : FilterObject = FilterObject()
                object.filterID = city.district_id
                object.title = city.district_name
                
                items.append(object)
            }
            
            self.filterDatasource.addItems(items)
            self.filterDatasource.selectedObjects = self.selectedObjects
            
            self.tableView.setContentOffset(CGPointZero, animated:true)
            self.refreshControl.endRefreshing()
            
        }){ (error) in

            self.tableView.setContentOffset(CGPointZero, animated:true)
            self.refreshControl.endRefreshing()
        
        }
    }
    
    //Mark: - reset Filter
    func resetSelectedFilter() -> Void {
        selectedObjects = [FilterObject()]
        self.tableView.reloadData()
    }
}
