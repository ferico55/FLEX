//
//  CategoryNavigationTableViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 6/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RATreeView
import RxSwift
import Moya

class CategoryNavigationTableViewController: UIViewController {
    
    fileprivate let raTreeView = RATreeView()
    fileprivate let kCategoryNavigationTableViewCell = "CategoryNavigationTableViewCell"
    fileprivate let kLoadingTableViewCell = "LoadingTableViewCell"
    fileprivate var categories: [ListOption]!
    fileprivate var categoryNavigationNetworkManager = NetworkProvider<HadesTarget>()
    fileprivate var firstTimeLoad = true
    fileprivate var rootCategoryId: String!
    
    init(categories: [ListOption], rootCategoryId: String) {
        super.init(nibName: nil, bundle: nil)
        self.categories = categories
        self.rootCategoryId = rootCategoryId
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
        raTreeView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        // make inset for avoiding bad user experience when user tap on most bottom unexpanded tableview cell
        raTreeView.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        raTreeView.dataSource = self
        raTreeView.delegate = self
        initRefreshControl()
    }
    
    private func initRefreshControl() {
        let refreshControl: UIRefreshControl = UIRefreshControl()
        refreshControl.bk_addEventHandler({ [weak self] _ in
            guard let weakSelf = self else { return }
            weakSelf.categoryNavigationNetworkManager.request(.getNavigationCategory(categoryId: weakSelf.rootCategoryId, root: false)).map(to: CategoryResponse.self).flatMap { category -> Observable<CategoryResponse> in
                return Observable<CategoryResponse>.just(category)
            }.subscribe(onNext: { [weak self] result in
                refreshControl.endRefreshing()
                guard let weakSelf = self else { return }
                weakSelf.categories = result.data.categories
                weakSelf.raTreeView.reloadData()
            }, onError: { [weak self] error in
                refreshControl.endRefreshing()
                guard let weakSelf = self else { return }
                let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: weakSelf)
                stickyAlertView?.show()
            }).disposed(by: weakSelf.rx_disposeBag)
        }, for: .valueChanged)
        
        raTreeView.scrollView.addSubview(refreshControl)
        
        if categories.count == 0 {
            refreshControl.beginRefreshing()
            refreshControl.sendActions(for: .valueChanged)
        }
    }
    
    private func hideDefaultSeparator() {
        raTreeView.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0)
    }
    
    fileprivate func reloadTable() {
        categories.forEach { category in
            category.isExpanded = false
        }
        
        raTreeView.reloadData()
        
    }
    
}

extension CategoryNavigationTableViewController: RATreeViewDataSource, RATreeViewDelegate {
    func treeView(_ treeView: RATreeView, numberOfChildrenOfItem item: Any?) -> Int {
        
        guard let item = item as? ListOption else { return categories.count }
        
        guard let itemChild = item.child else { return 0 }
        
        return itemChild.count
        
    }
    
    func treeView(_ treeView: RATreeView, cellForItem item: Any?) -> UITableViewCell {
        let cell = treeView.dequeueReusableCell(withIdentifier: kCategoryNavigationTableViewCell) as! CategoryNavigationTableViewCell
        
        guard let item = item else {
            return cell
        }
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
        } else if let item = item as? ListOption, let itemChild = item.child {
            return itemChild[index]
        }
        
        fatalError()
    }
    
    func treeView(_ treeView: RATreeView, didSelectRowForItem item: Any) {
        guard item is ListOption, let categoryDetailChild = (item as! ListOption).child else { return }
        let categoryDetail = item as! ListOption
        if categoryDetailChild.count == 0 && categoryDetail.hasChildCategories == false {
            dismiss(animated: true, completion: {
                guard let categoryDetailApplinks = URL(string: categoryDetail.applinks) else { return }
                TPRoutes.routeURL(categoryDetailApplinks)
            })
        } else if categoryDetailChild.count == 0 && categoryDetail.hasChildCategories == true {
            categoryNavigationNetworkManager.request(.getNavigationCategory(categoryId: categoryDetail.categoryId!, root: false)).map(to: CategoryResponse.self).flatMap { category -> Observable<CategoryResponse> in
                Observable<CategoryResponse>.just(category)
            }.subscribe(onNext: { [weak self] result in
                if let weakSelf = self {
                    categoryDetail.child = result.data.categories
                    weakSelf.reloadTable()
                    categoryDetail.isExpanded = true
                    weakSelf.raTreeView.expandRow(forItem: categoryDetail)
                }
            }, onError: { error in
                let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
                stickyAlertView?.show()
            }).disposed(by: rx_disposeBag)
        } else {
            let categoryDetailTempIsExpanded = !categoryDetail.isExpanded
            reloadTable()
            categoryDetail.isExpanded = categoryDetailTempIsExpanded
        }
    }
    
    func treeView(_ treeView: RATreeView, editingStyleForRowForItem item: Any) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTimeLoad {
            for category in categories {
                if (category.hasChildCategories != nil) && (category.child?.count)! > 0 {
                    raTreeView.scrollToRow(forItem: category, at: RATreeViewScrollPositionNone, animated: false)
                    
                    category.isExpanded = true
                    let categoryNavigationTableViewCell: CategoryNavigationTableViewCell = raTreeView.cell(forItem: category) as! CategoryNavigationTableViewCell
                    categoryNavigationTableViewCell.setListOption(listOption: category)
                    raTreeView.expandRow(forItem: category)
                    break
                }
            }
            firstTimeLoad = false
        }
        
    }
    
}
