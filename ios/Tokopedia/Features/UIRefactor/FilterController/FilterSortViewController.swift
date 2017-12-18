//
//  FilterSortViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/7/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FilterSortViewController: UIViewController {
    
    fileprivate var items: Variable<[ListOption]> = Variable([])
    fileprivate var selectedObject: ListOption = ListOption()
    fileprivate var completionHandler: (ListOption, [String: String]) -> Void = { _ in }
    fileprivate var tableView: UITableView = UITableView()
    fileprivate var source: Source!
    fileprivate var refreshControl: UIRefreshControl = UIRefreshControl()
    fileprivate var rootCategoryID: String = String()
    fileprivate lazy var cache = SortCache()
    
    /*
        The designated initializer for sorting list view controller called from FitersController. Items is list of sorting option. E.g:Sorting by promotion, best match, etc.
     */
    init(source: Source, selectedObject: ListOption, rootCategoryID: String, onCompletion: @escaping ((ListOption, [String: String]) -> Void)) {
        
        completionHandler = onCompletion
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
        view.backgroundColor = UIColor.white
        setupNavigationLayout()
        setupTableViewLayout()
        setupTableViewData()
        setupTableViewSelection()
    }
    
    @objc private func dissmissViewcontroller() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func done() {
        guard let value = selectedObject.value else {
            dissmissViewcontroller()
            return
        }
        
        completionHandler(selectedObject, [selectedObject.key: value])
        dissmissViewcontroller()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Setup Layout
    
    private func setupNavigationLayout() {
        let barButtonBack: UIBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close_white"), style: .plain, target: self, action: #selector(FilterSortViewController.dissmissViewcontroller))
        navigationItem.leftBarButtonItem = barButtonBack
        
        let barButtonDone: UIBarButtonItem = UIBarButtonItem(title: "Selesai", style: .plain, target: self, action: #selector(FilterSortViewController.done))
        navigationItem.rightBarButtonItem = barButtonDone
        
        title = "Urutkan"
    }
    
    private func setupTableViewLayout() {
        tableView = UITableView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height), style: .plain)
        tableView.backgroundColor = UIColor(red: 231.0 / 255.0, green: 231.0 / 255.0, blue: 231.0 / 255.0, alpha: 1)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        view.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        refreshControl.addTarget(self, action: #selector(FilterSortViewController.requestFilter), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    // MARK: Table View Rx
    
    private func setupTableViewData() {
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
        
        requestFilter()
    
        items.asDriver().drive(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { [weak self] row, item, cell in
            guard let `self` = self else { return }
            cell.textLabel?.font = UIFont.title2Theme()
            cell.textLabel?.text = item.name
            cell.tintColor = UIColor(red: 66 / 255.0, green: 189 / 255.0, blue: 65 / 255.0, alpha: 1)
            
            cell.selectionStyle = .none
            
            if item.value == self.selectedObject.value {
                self.tableView.selectRow(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: .none)
                cell.accessoryType = .checkmark
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    private func setupTableViewSelection() {
        tableView
            .rx
            .itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                
                self.items.value[indexPath.row].isSelected = true
                self.selectedObject = self.items.value[indexPath.row]
                
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .checkmark
            }).addDisposableTo(rx_disposeBag)
        
        tableView
            .rx
            .itemDeselected
            .subscribe(onNext: { [weak self] indexPath in
                guard let `self` = self else { return }
                
                self.items.value[indexPath.row].isSelected = false
                
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.accessoryType = .none
            }).addDisposableTo(rx_disposeBag)
    }
    
    // MARK: Request
    @objc private func requestFilter() {
        cache.loadSortData(source: source, callBack: { [weak self] sort in
            guard let `self` = self else { return }
            if let sort = sort {
                self.items.value = sort
                self.refreshControl.endRefreshing()
            } else {
                let requestFilter = RequestFilter()
                requestFilter.fetchFilter(self.source,
                                          departmentID: self.rootCategoryID,
                                          onSuccess: { response in
                                              self.items.value = response.sort
                                              self.refreshControl.endRefreshing()
                                              if CacheTweaks.shouldCacheSortRequest() {
                                                  self.cache.storeSortData(response.sort, source: self.source)
                                              }
                                            
                                          }, onFailure: {
                                              self.tableView.setContentOffset(CGPoint.zero, animated: true)
                                              self.refreshControl.endRefreshing()
                })
            }
        }
        )
    }
}

