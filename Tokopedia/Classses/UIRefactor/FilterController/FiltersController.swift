//
//  FiltersController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum Source :Int {
    case hotlist, product, catalog, catalogProduct, shop, directory, `default`
    func description() -> String {
        switch self {
        case .hotlist:
            return "hot_product"
        case .product:
            return "search_product"
        case .catalog:
            return "search_catalog"
        case .catalogProduct:
            return "catalog_product"
        case .shop:
            return "search_shop"
        case .directory:
            return "directory"
        case .default:
            return ""
        }
    }
}

class FiltersController: NSObject, MHVerticalTabBarControllerDelegate {
    
    fileprivate var filterResponse : FilterData = FilterData()
    fileprivate var selectedCategories: [CategoryDetail] = []
    fileprivate var selectedFilters:[ListOption] = []
    fileprivate var listControllers : [UIViewController] = []
    fileprivate var completionHandlerFilter:([CategoryDetail], [ListOption], [String:String])->Void = {(CategoryDetail, ListOption, param) -> Void in}
    fileprivate var categories: [CategoryDetail] = []
    fileprivate let tabBarController:MHVerticalTabBarController = MHVerticalTabBarController()
    fileprivate var presentedController : UIViewController = UIViewController()
    
    fileprivate var selectedSort : ListOption = ListOption()
    fileprivate var completionHandlerSort:(ListOption, [String:String])->Void = {_ in }
    
    fileprivate var source : String = ""
    
    fileprivate var completionHandlerResponse:(FilterData)->Void = {_ in }
    
    fileprivate var rootCategoryID : String = ""
    
    /*
        The designated initializer for filter option view controller. filterResponse (optional) is data option filter from previous fetch dynamic attibute. 
     */
    init(searchDataSource: Source, filterResponse:FilterData?, rootCategoryID:String, categories: [CategoryDetail], selectedCategories:[CategoryDetail], selectedFilters:[ListOption], presentedVC:(UIViewController), onCompletion: @escaping ((_ selectedCategories:[CategoryDetail], _ selectedFilters:[ListOption], _ paramFilter:[String : String]) -> Void), onReceivedFilterDataOption:@escaping ((FilterData) -> Void)){
        
        if filterResponse != nil { self.filterResponse = filterResponse! }
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.selectedFilters = selectedFilters
        self.completionHandlerFilter = onCompletion
        self.presentedController = presentedVC
        self.source = searchDataSource.description()
        self.rootCategoryID = rootCategoryID
        completionHandlerResponse = onReceivedFilterDataOption
        super.init()
        
        self .presentControllerFilter()
    }
    
    /*
        The designated initializer for sorting list view controller. sortResponse (optional) is list sort option from previous fetch dynamic attibute.
     */
    init(source:Source, sortResponse:FilterData?, selectedSort: ListOption, presentedVC:(UIViewController), rootCategoryID:String, onCompletion: @escaping ((_ selectedSort:ListOption, _ paramSort:[String:String]) -> Void), onReceivedFilterDataOption:@escaping ((FilterData) -> Void)){
        
        self.selectedSort = selectedSort
        self.completionHandlerSort = onCompletion
        self.presentedController = presentedVC
        self.source = source.description()
        self.rootCategoryID = rootCategoryID
        
        if sortResponse != nil { self.filterResponse = sortResponse! }
        completionHandlerResponse = onReceivedFilterDataOption
        
        super.init()
        
        self .presentControllerSort()
    }
    
    fileprivate func requestFilter(){
        RequestFilter.fetchFilter(source,
                                  departmentID: self.rootCategoryID,
                                  success: { (response) in
            if(response.filter.count == 0){
                let vc : UIViewController = UIViewController()
                vc.view.backgroundColor = UIColor.white
                self.setTabbarViewController([vc])
            } else {
                self.filterResponse = self.addFilterCategory(response)
                self.completionHandlerResponse(self.filterResponse)
                self.adjustControllers()
                self.setTabbarViewController(self.listControllers)
            }
            }) { (error) in
                let vc : UIViewController = UIViewController()
                vc.view.backgroundColor = UIColor.white
                self.setTabbarViewController([vc])
        }
    }
    
    fileprivate func setTabbarViewController(_ viewControllers:[UIViewController]){
        tabBarController.viewControllers = viewControllers as [AnyObject]
    }
    
    fileprivate func getTitle() -> String{
        return "Filter"
    }
    
    fileprivate func presentControllerFilter(){
        
        tabBarController.delegate = self
        tabBarController.title = self.getTitle()
        tabBarController.tabBarWidth = 110
        tabBarController.tabBarItemHeight = 44
        tabBarController.showResetButton = true
        tabBarController.selectedIndex = 0
        let vc : UIViewController = UIViewController()
        vc.view.backgroundColor = UIColor.white
        let loading : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        loading.frame.origin.y = 10
        loading.frame.origin.x = vc.view.frame.size.width/2 - tabBarController.tabBarWidth/2 - loading.frame.size.width/2
        loading.startAnimating()
        vc.view .addSubview(loading)
        self.setTabbarViewController([vc]);
        
        let navigation: UINavigationController = UINavigationController(rootViewController: tabBarController)
        navigation.navigationBar.isTranslucent = false
        presentedController.navigationController!.present(navigation, animated: true, completion: nil)
        
        if filterResponse.filter.isEmpty {
            self.requestFilter()
        } else {
            self.adjustControllers()
            self.setTabbarViewController(self.listControllers)
        }
    }
    
    fileprivate func presentControllerSort(){
        let controller : FilterSortViewController = FilterSortViewController(source:source, items: filterResponse.sort, selectedObject: selectedSort, rootCategoryID: self.rootCategoryID, onCompletion: { (selectedSort: ListOption, paramSort:[String:String]) in
            self.selectedSort = selectedSort
            if selectedSort.name != "" {
                AnalyticsManager.trackEventName("clickSort", category: GA_EVENT_CATEGORY_SORT, action: GA_EVENT_ACTION_CLICK, label: selectedSort.name)
            }
            self.completionHandlerSort(self.selectedSort, paramSort)
        }) { (response) in
            self.filterResponse = response
            self.completionHandlerResponse(response)
        }
        
        let navigation: UINavigationController = UINavigationController(rootViewController: controller)
        navigation.navigationBar.isTranslucent = false
        presentedController.navigationController!.present(navigation, animated: true, completion: nil)
    }
    
    fileprivate func addFilterCategory(_ response:FilterData) -> FilterData{
        if self.source == Source.directory.description() {
            let filter : ListFilter = ListFilter()
            filter.title = self.categoryTitle()
            filter.isMultipleSelect = false
            response.filter.insert(filter, at: 0)
            return response
            
        }
        return response
    }
    
    fileprivate func adjustControllers(){
        for filter in filterResponse.filter {
            if filter.title == categoryTitle() {
                let controller : CategoryFilterViewController = CategoryFilterViewController(rootCategoryID:rootCategoryID, selectedCategories: selectedCategories, initialCategories:categories, isMultipleSelect: filter.isMultipleSelect) { (selectedCategory) in
                    self.selectedCategories = selectedCategory
                    self .adjustImageTabBarButton((self.selectedCategories.count>0))
                }
                
                if (self.selectedCategories.count>0) {
                    controller.tabBarItem.image = UIImage(named: "icon_unread.png")
                }
                else {
                    controller.tabBarItem.image = UIImage()
                }
                
                controller.tabBarItem.title = filter.title;
                
                listControllers .append(controller)
            } else {
                let controller: FiltersTableViewController = FiltersTableViewController(items: filter.options , selectedObjects: selectedFilters, showSearchBar: (filter.search.searchable.integerValue == 1), searchBarPlaceholder: filter.search.placeholder as String) { (selectedFilters) in
                    self.selectedFilters = selectedFilters
                    self.listControllers.forEach({ (controller) in
                        if controller is FiltersTableViewController {
                            (controller as! FiltersTableViewController).selectedObjects = selectedFilters
                        }
                    })
                    self .adjustImageTabBarButton(self.filterIsActive(filter.options, selectedFilters: selectedFilters))
                }

                if (self.filterIsActive(filter.options, selectedFilters: selectedFilters)) {
                    controller.tabBarItem.image = UIImage(named: "icon_unread.png")
                }
                else {
                    controller.tabBarItem.image = UIImage()
                }
                controller.tabBarItem.title = filter.title
                
                listControllers .append(controller)
            }
        }
    }
    
    fileprivate func filterIsActive(_ ListFilters:[ListOption],selectedFilters:[ListOption]) -> Bool{
        var textFieldIsActive: Bool = false
        
        let listSet = Set(ListFilters)
        let findListSet = Set(selectedFilters)
        let allElemsContained = findListSet.intersection(listSet)
        
        let listKeyFilters = ListFilters.map({$0.key})
        for selectedFilter in selectedFilters {
            if selectedFilter.input_type == self.textInputType() {
                guard let value = Int(selectedFilter.value) else {
                    textFieldIsActive = false
                    break
                }
                if listKeyFilters .contains(selectedFilter.key) && value > 0 {
                    textFieldIsActive = true
                }
            }
        }
            
        return ((allElemsContained.count>0) || textFieldIsActive)
    }
    
    fileprivate func textInputType()-> String{
        return "textbox"
    }
    
    fileprivate func categoryTitle() -> String{
        return "Kategori"
    }
    
    fileprivate func adjustImageTabBarButton(_ isActive:Bool){
        if isActive {
            var index : Int = Int(self.tabBarController.selectedIndex)
            if index == Int(UInt8.max){
                index = 0
            }
            if self.tabBarController.tabBar.tabBarButtons?.isEmpty == false {
                let button : MHVerticalTabBarButton = self.tabBarController.tabBar.tabBarButtons[Int(self.tabBarController.selectedIndex)];
                button.imageView.image = UIImage(named: "icon_unread.png")
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
            }
        }
    }
    
    // MARK: - MHVerticalTabBarController Delegate
    func done() {
        var params : [String: String] = [:]
        var labels : [String] = []
        for filter in selectedFilters {
            let filterParam = params[filter.key]
            let key = filter.key
            if !(labels.contains(key)){
                labels.append(key)
            }
            
            if params[filter.key] == filter.value {
                return;
            }
            
            var value : String?
            if filterParam != nil && filterParam != "" {
                value = "\(filterParam!),\(filter.value)"
            } else {
                value = filter.value
            }
            
            params[filter.key] = value
        }
        
        if selectedCategories.count > 0 {
            labels.append("category")
        }
        
        for filter in labels {
            AnalyticsManager.trackEventName("clickFilter", category: GA_EVENT_CATEGORY_FILTER, action: GA_EVENT_ACTION_CLICK, label: filter)
        }

        completionHandlerFilter(selectedCategories, selectedFilters, params)
    }
    
    func didTapResetButton(_ button: UIButton!) {
        selectedCategories = []
        selectedFilters = []
        
        listControllers.forEach { (controller) in
            if controller is CategoryFilterViewController {
                (controller as! CategoryFilterViewController).resetSelectedFilter()
            }
            if controller is FiltersTableViewController {
                (controller as! FiltersTableViewController).resetSelectedFilter()
            }
        }
        
        self.tabBarController.tabBar.tabBarButtons.forEach({$0.imageView.image = UIImage()})
    }
    
    func tabBarController(_ tabBarController: MHVerticalTabBarController!, didSelect viewController: UIViewController!) {
    }
    
}
