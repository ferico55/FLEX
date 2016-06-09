//
//  FiltersController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FiltersController: NSObject, MHVerticalTabBarControllerDelegate {
    
    private var filterResponse : FilterResponse = FilterResponse()
    private var selectedCategories: [CategoryDetail] = []
    private var selectedFilters:[ListOption] = []
    private var listControllers : [UIViewController] = []
    private var completionHandlerFilter:([CategoryDetail], [ListOption])->Void = {(CategoryDetail, ListOption) -> Void in}
    private var categories: [CategoryDetail] = []
    private let tabBarController:MHVerticalTabBarController = MHVerticalTabBarController()
    private var presentedController : UIViewController = UIViewController()
    
    private var selectedSort : ListOption = ListOption()
    private var completionHandlerSort:(ListOption)->Void = {_ in }
    
    private var completionHandlerResponse:(FilterResponse)->Void = {_ in }
    
    init(filterResponse:FilterResponse, categories: [CategoryDetail], selectedCategories:[CategoryDetail], selectedFilters:[ListOption], presentedVC:(UIViewController), onCompletion: ((selectedCategories:[CategoryDetail], selectedFilters:[ListOption]) -> Void), response:((FilterResponse) -> Void)){
        
        self.filterResponse = filterResponse
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.selectedFilters = selectedFilters
        self.completionHandlerFilter = onCompletion
        self.presentedController = presentedVC
        completionHandlerResponse = response
        
        super.init()
        
        self .presentControllerFilter()
    }
    
    init(sortResponse:FilterResponse, selectedSort: ListOption, presentedVC:(UIViewController), onCompletion: ((selectedSort:ListOption) -> Void), response:((FilterResponse) -> Void)){
        
        self.selectedSort = selectedSort
        self.completionHandlerSort = onCompletion
        self.presentedController = presentedVC
        
        self.filterResponse = sortResponse
        completionHandlerResponse = response
        
        super.init()
        
        self .presentControllerSort()
    }
    
    private func requestFilter(){
        RequestFilter .fetchFilter({ (response) in
                self.filterResponse = response
                self.completionHandlerResponse(response)
                self.adjustControllers()
                self.setTabbarViewController(self.listControllers)
            }) { (error) in
                let vc : UIViewController = UIViewController()
                vc.view.backgroundColor = UIColor.whiteColor()
                self.setTabbarViewController([vc])
        }
    }
    
    private func setTabbarViewController(viewControllers:[UIViewController]){
        tabBarController.viewControllers = viewControllers as [AnyObject]
    }
    
    private func presentControllerFilter(){
        
        tabBarController.delegate = self
        tabBarController.title = "Filter"
        tabBarController.tabBarWidth = 110
        tabBarController.tabBarItemHeight = 44
        tabBarController.showResetButton = true
        tabBarController.selectedIndex = 0
        let vc : UIViewController = UIViewController()
        vc.view.backgroundColor = UIColor.whiteColor()
        let loading : UIActivityIndicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .Gray)
        loading.frame.origin.y = 10
        loading.frame.origin.x = vc.view.frame.size.width/2 - tabBarController.tabBarWidth/2 - loading.frame.size.width/2
        loading.startAnimating()
        vc.view .addSubview(loading)
        self.setTabbarViewController([vc]);
        
        let navigation: UINavigationController = UINavigationController.init(rootViewController: tabBarController)
        navigation.navigationBar.translucent = false
        presentedController.navigationController!.presentViewController(navigation, animated: true, completion: nil)
        
        if filterResponse.filter.isEmpty {
            self.requestFilter()
        } else {
            self.adjustControllers()
            self.setTabbarViewController(self.listControllers)
        }
    }
    
    private func presentControllerSort(){
        let controller : FilterSortViewController = FilterSortViewController.init(items: filterResponse.sort, selectedObject: selectedSort, onCompletion: { (selectedSort) in
                self.selectedSort = selectedSort
                self.completionHandlerSort(self.selectedSort)
            }) { (response) in
                self.filterResponse = response
                self.completionHandlerResponse(response)
        }

        let navigation: UINavigationController = UINavigationController.init(rootViewController: controller)
        navigation.navigationBar.translucent = false
        presentedController.navigationController!.presentViewController(navigation, animated: true, completion: nil)
    }
    
    private func adjustControllers(){
        for filter in filterResponse.filter {
            if filter.title == categoryTitle() {
                let controller : CategoryFilterViewController = CategoryFilterViewController.init(selectedCategories: selectedCategories, initialCategories:categories) { (selectedCategory) in
                    self.selectedCategories = selectedCategory
                    self .adjustImageTabBarButton((self.selectedCategories.count>0), filter: filter)
                }
                
                if (self.selectedCategories.count>0) {
                    controller.tabBarItem.image = UIImage.init(named: "icon_unread.png")
                }
                else {
                    controller.tabBarItem.image = UIImage()
                }
                
                controller.tabBarItem.title = filter.title;
                
                listControllers .append(controller)
            } else {
                let controller: FiltersTableViewController = FiltersTableViewController.init(items: filter.options , selectedObjects: selectedFilters, showSearchBar: false) { (selectedFilters) in
                    self.selectedFilters = selectedFilters
                    self.listControllers.forEach({ (controller) in
                        if controller.isKindOfClass(FiltersTableViewController){
                            (controller as! FiltersTableViewController).selectedObjects = selectedFilters
                        }
                    })
                    self .adjustImageTabBarButton(self.filterIsActive(filter.options, selectedFilters: selectedFilters), filter: filter)
                }

                if (self.filterIsActive(filter.options, selectedFilters: selectedFilters)) {
                    controller.tabBarItem.image = UIImage.init(named: "icon_unread.png")
                }
                else {
                    controller.tabBarItem.image = UIImage()
                }
                controller.tabBarItem.title = filter.title
                
                listControllers .append(controller)
            }
        }
    }
    
    private func filterIsActive(ListFilters:[ListOption],selectedFilters:[ListOption]) -> Bool{
        var textFieldIsActive: Bool = false
        
        let listSet = Set(ListFilters)
        let findListSet = Set(selectedFilters)
        let allElemsContained = findListSet.intersect(listSet)
        
        let listKeyFilters = ListFilters.map({$0.key})
        for selectedFilter in selectedFilters {
            if selectedFilter.type == "textinput" {
                if listKeyFilters .contains(selectedFilter.key) {
                    textFieldIsActive = true
                }
            }
        }
            
        return ((allElemsContained.count>0) || textFieldIsActive)
    }
    
    private func categoryTitle() -> NSString{
        return "Kategori"
    }
    
    private func adjustImageTabBarButton(isActive:Bool, filter:ListFilter){
        if isActive {
            var index : Int = Int(self.tabBarController.selectedIndex)
            if index == Int(UInt8.max){
                index = 0
            }
            if self.tabBarController.tabBar.tabBarButtons?.isEmpty == false {
                let button : MHVerticalTabBarButton = self.tabBarController.tabBar.tabBarButtons[Int(self.tabBarController.selectedIndex)];
                button.imageView.image = UIImage.init(named: "icon_unread.png")
                filter.isActiveFilter = true
            }
        }
        else {
            var index : Int = Int(self.tabBarController.selectedIndex)
            if index == Int(UInt8.max){
                index = 0
            }
            if self.tabBarController.tabBar.tabBarButtons?.isEmpty == false {
                let button : MHVerticalTabBarButton = self.tabBarController.tabBar.tabBarButtons[index];
                button.imageView.image = UIImage()
                filter.isActiveFilter = false
            }
        }
    }
    
    // MARK: - MHVerticalTabBarController Delegate
    func done() {
        completionHandlerFilter(selectedCategories, selectedFilters)
    }
    func didTapResetButton(button: UIButton!) {
        selectedCategories = []
        selectedFilters = []
        //        listControllers.forEach { $0.resetSelectedFilter() }
    }
    
    func tabBarController(tabBarController: MHVerticalTabBarController!, didSelectViewController viewController: UIViewController!) {
    }
    
}
