//
//  FilterSortViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterSortViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var items : [ListOption] = []
    fileprivate weak var selectedObject : ListOption? = ListOption()
    fileprivate var completionHandler:(ListOption, [String:String])->Void = {_ in}
    fileprivate var completionHandlerResponse:(FilterData)->Void = {_ in}
    fileprivate var tableView: UITableView = UITableView()
    fileprivate var source : String = ""
    fileprivate var refreshControl : UIRefreshControl = UIRefreshControl()
    fileprivate var rootCategoryID : String = String()
    
    /*
        The designated initializer for sorting list view controller called from FitersController. Items is list of sorting option. E.g:Sorting by promotion, best match, etc.
     */
    init(source: String, items:[ListOption],selectedObject:ListOption, rootCategoryID:String, onCompletion: @escaping ((ListOption, [String:String]) -> Void), response:@escaping ((FilterData) -> Void)){
        
        completionHandler = onCompletion
        completionHandlerResponse = response
        self.items = items
        self.selectedObject = selectedObject
        self.source = source
        self.rootCategoryID = rootCategoryID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        let barButtonBack : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close_white.png"), style: .plain, target: self, action: #selector(FilterSortViewController.dissmissViewcontroller))
        self.navigationItem.leftBarButtonItem = barButtonBack
        
        let barButtonDone : UIBarButtonItem = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(MHVerticalTabBarControllerDelegate.done))
        self.navigationItem.rightBarButtonItem = barButtonDone
        
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height), style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(red: 231.0/255.0, green: 231.0/255.0, blue: 231.0/255.0, alpha: 1)
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        self.view.addSubview(self.tableView)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        refreshControl.addTarget(self, action: #selector(requestFilter), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        if items.count == 0 {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated:true)
            refreshControl.beginRefreshing()
            
            self .requestFilter()
        }

        self.title = "Urutkan"
    }
    
    func dissmissViewcontroller(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func done(){
        if (selectedObject != nil) {
            completionHandler(selectedObject!, [(selectedObject?.key)!:(selectedObject?.value)!])
        }
        self.dissmissViewcontroller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        
        let item : ListOption = items[indexPath.row]
        
        cell.textLabel?.font = UIFont.title2Theme()
        cell.textLabel?.text = item.name
        cell.tintColor = UIColor(red: 66/255.0, green: 189/255.0, blue: 65/255.0, alpha: 1)

        cell.selectionStyle = .none
        
        if (selectedObject != nil) {
            if item.value == selectedObject!.value {
                cell.accessoryType = .checkmark
                tableView .selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        items[indexPath.row].isSelected = true
        self.selectedObject = items[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        items[indexPath.row].isSelected = false

        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }

    func requestFilter(){
        RequestFilter.fetchFilter(source,
                                  departmentID: self.rootCategoryID,
                                  success: { (response) in
            self.items.removeAll()
            self.tableView.reloadData()
            
            var indexPaths : [IndexPath] = []
            for (index,item) in response.sort.enumerated() {
                self.items.append(item)
                indexPaths.append(IndexPath(row:index , section: 0))
            }
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indexPaths as [IndexPath], with: .automatic)
            self.tableView.endUpdates()
            
            self.tableView.setContentOffset(CGPoint.zero, animated:true)
            self.refreshControl.endRefreshing()
            
            self.completionHandlerResponse(self.addFilterCategory(response))
            self.tableView.reloadData()
            
        }) { (error) in
            self.tableView.setContentOffset(CGPoint.zero, animated:true)
            self.refreshControl.endRefreshing()
        }
    }
    
    fileprivate func addFilterCategory(_ response:FilterData) -> FilterData{
        if self.source == Source.directory.description() {
            let filter : ListFilter = ListFilter()
            filter.title = "Kategori"
            filter.isMultipleSelect = false
            response.filter.insert(filter, at: 0)
            return response
        }
        return response
    }
}
