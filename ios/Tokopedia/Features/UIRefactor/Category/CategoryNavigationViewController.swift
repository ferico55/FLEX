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
import SnapKit

@objc(CategoryNavigationViewController)
class CategoryNavigationViewController: MHVerticalTabBarController {
    
    private var categories: [ListOption]!
    private let categoryNavigationNetworkManager = NetworkProvider<HadesTarget>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.title = "Kategori"
        
    }
    
    init(categoryId: String) {
        super.init(nibName: nil, bundle: nil)
        
        let viewControllerForLoading = UIViewController()
        
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.startAnimating()
        activityIndicatorView.activityIndicatorViewStyle = .gray
        viewControllerForLoading.view.backgroundColor = .white
        viewControllerForLoading.view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.centerX.equalTo(viewControllerForLoading.view.snp.centerX)
            make.top.equalTo(viewControllerForLoading.view.snp.top).offset(20)
        }
        
        self.viewControllers = [viewControllerForLoading]
        self.tabBarItemHeight = tabBarItemHeight()
        self.tabBarWidth = 80
        
        var selectedCategoryAndIndex: (selectedCategory: CategoryNavigationTableViewController?, index: Int?) = (nil, nil)
        
        categoryNavigationNetworkManager.request(.getNavigationCategory(categoryId: categoryId, root: true)).map(to: CategoryResponse.self).flatMap { category -> Observable<CategoryResponse> in
            return Observable<CategoryResponse>.just(category)
        }.subscribe(onNext: { [weak self] result in
            guard let weakSelf = self else { return }
            weakSelf.categories = result.data.categories
            
            var categoryNavigationTableViewControllers: [CategoryNavigationTableViewController] = []
            for (index, category) in weakSelf.categories.enumerated() {
                guard let categoryChild = category.child else { continue }
                
                let categoryNavigationTableViewController = CategoryNavigationTableViewController(categories: categoryChild, rootCategoryId: category.categoryId!)
                categoryNavigationTableViewController.tabBarItem.title = category.name
                
                if category.categoryId == categoryId {
                    selectedCategoryAndIndex = (categoryNavigationTableViewController, index)
                } else {
                    for level2Category in categoryChild {
                        if level2Category.categoryId == categoryId {
                            selectedCategoryAndIndex = (categoryNavigationTableViewController, index)
                            break
                        } else {
                            guard level2Category.child != nil else { continue }
                            for level3Category in level2Category.child! {
                                if level3Category.categoryId == categoryId {
                                    selectedCategoryAndIndex = (categoryNavigationTableViewController, index)
                                    break
                                }
                            }
                        }
                    }
                }
                
                if let iconImageUrlString = category.iconImageUrl, let iconImageUrl = URL(string: iconImageUrlString) {
                    let imageView = UIImageView()
                    imageView.setImageWith(iconImageUrl)
                    categoryNavigationTableViewController.tabBarItem.image = imageView.image
                }
                
                categoryNavigationTableViewControllers.append(categoryNavigationTableViewController)
            }
            
            weakSelf.viewControllers = categoryNavigationTableViewControllers
            
            weakSelf.tabBar.tabBarButtons.forEach { tabBarButton in
                tabBarButton.isCategoryNavigation = true
                tabBarButton.layoutIfNeeded()
            }
            
            weakSelf.selectedViewController = selectedCategoryAndIndex.selectedCategory
            
            guard let selectedIndex = selectedCategoryAndIndex.index else { return }
            let contentOffsetY = min(CGFloat(selectedIndex) * weakSelf.tabBarItemHeight(), weakSelf.tabBar.contentSize.height - weakSelf.tabBar.frame.size.height)
            
            weakSelf.tabBar.setContentOffset(CGPoint(x: 0, y: contentOffsetY)
                                             , animated: true)
        }, onError: { error in
            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
            stickyAlertView?.show()
        }).disposed(by: self.rx_disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func tabBarItemHeight() -> CGFloat {
        return 83
    }
    
}
