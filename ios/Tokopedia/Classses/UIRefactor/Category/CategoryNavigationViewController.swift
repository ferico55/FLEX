//
//  CategoryNavigationViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 6/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox
import RxSwift

@objc(CategoryNavigationViewController)
class CategoryNavigationViewController: MHVerticalTabBarController {
    
    private var categories: [ListOption]!
    
    private let categoryNavigationNetworkManager = NetworkProvider<HadesTarget>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nil
        
        categoryNavigationNetworkManager.request(.getNavigationCategory(categoryId: "0")).map(to: CategoryResponse.self).subscribe(onNext: { [weak self] result in
                guard let weakSelf = self else { return }
                weakSelf.categories = result.data.categories
                
                var categoryNavigationTableViewControllers: [CategoryNavigationTableViewController] = []
                
                for category in weakSelf.categories where category.child != nil {
                    let rootCategoryForTreeViewHead = ListOption()
                    rootCategoryForTreeViewHead.name = category.name
                    rootCategoryForTreeViewHead.applinks = category.applinks
                    
                    category.child!.insert(rootCategoryForTreeViewHead, at: 0)
                    
                    let categoryNavigationTableViewController = CategoryNavigationTableViewController(categories: category.child!)
                    categoryNavigationTableViewController.tabBarItem.title = category.name
                    
                    if let iconImageUrl = category.iconImageUrl {
                        let imageView = UIImageView()
                        imageView.setImageWith(URL(string: iconImageUrl))
                        categoryNavigationTableViewController.tabBarItem.image = imageView.image
                    }
                    categoryNavigationTableViewControllers.append(categoryNavigationTableViewController)
                }
                
                weakSelf.viewControllers = categoryNavigationTableViewControllers
                weakSelf.tabBarItemHeight = 83
                weakSelf.tabBarWidth = 80
                
                weakSelf.tabBar.tabBarButtons.forEach { (tabBarButtons) in
                    tabBarButtons.isCategoryNavigation = true
                }
                
            }, onError: { error in
                
            }).disposed(by: self.rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
