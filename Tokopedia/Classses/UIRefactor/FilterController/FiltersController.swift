//
//  FiltersController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum Source :Int {
    case Hotlist, Product, Catalog, Shop, Directory, Default
    func simpleDescription() -> String {
        switch self {
        case .Hotlist:
            return "hot_product"
        case .Product:
            return "search_product"
        case .Catalog:
            return "search_catalog"
        case .Shop:
            return "search_shop"
        case .Directory:
            return "directory"
        case .Default:
            return ""
        }
    }
}

class FiltersController: NSObject, MHVerticalTabBarControllerDelegate {
    
    private var filterResponse : FilterData = FilterData()
    private var selectedCategories: [CategoryDetail] = []
    private var selectedFilters:[ListOption] = []
    private var listControllers : [UIViewController] = []
    private var completionHandlerFilter:([CategoryDetail], [ListOption], [String:String])->Void = {(CategoryDetail, ListOption, param) -> Void in}
    private var categories: [CategoryDetail] = []
    private let tabBarController:MHVerticalTabBarController = MHVerticalTabBarController()
    private var presentedController : UIViewController = UIViewController()
    
    private var selectedSort : ListOption = ListOption()
    private var completionHandlerSort:(ListOption, [String:String])->Void = {_ in }
    
    private var source : String = ""
    
    private var completionHandlerResponse:(FilterData)->Void = {_ in }
    
    private var rootCategoryID : String = ""
    
    init(source: String, filterResponse:FilterData, rootCategoryID:String, categories: [CategoryDetail], selectedCategories:[CategoryDetail], selectedFilters:[ListOption], presentedVC:(UIViewController), onCompletion: ((selectedCategories:[CategoryDetail], selectedFilters:[ListOption], paramFilter:[String : String]) -> Void), response:((FilterData) -> Void)){
        
        self.filterResponse = filterResponse
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.selectedFilters = selectedFilters
        self.completionHandlerFilter = onCompletion
        self.presentedController = presentedVC
        self.source = source
        self.rootCategoryID = rootCategoryID
        completionHandlerResponse = response
        
        super.init()
        
        self .presentControllerFilter()
    }
    
    init(searchDataSource: Source, filterResponse:FilterData, rootCategoryID:String, categories: [CategoryDetail], selectedCategories:[CategoryDetail], selectedFilters:[ListOption], presentedVC:(UIViewController), onCompletion: ((selectedCategories:[CategoryDetail], selectedFilters:[ListOption], paramFilter:[String : String]) -> Void), response:((FilterData) -> Void)){
        
        self.filterResponse = filterResponse
        self.categories = categories
        self.selectedCategories = selectedCategories
        self.selectedFilters = selectedFilters
        self.completionHandlerFilter = onCompletion
        self.presentedController = presentedVC
        self.source = searchDataSource.simpleDescription()
        self.rootCategoryID = rootCategoryID
        completionHandlerResponse = response
        
        super.init()
        
        self .presentControllerFilter()
    }
    
    init(source:String, sortResponse:FilterData, selectedSort: ListOption, presentedVC:(UIViewController), onCompletion: ((selectedSort:ListOption, paramSort:[String:String]) -> Void), response:((FilterData) -> Void)){
        
        self.selectedSort = selectedSort
        self.completionHandlerSort = onCompletion
        self.presentedController = presentedVC
        self.source = source
        
        self.filterResponse = sortResponse
        completionHandlerResponse = response
        
        super.init()
        
        self .presentControllerSort()
    }
    
    private func requestFilter(){
        RequestFilter.fetchFilter(source, success: { (response) in
            if(response.filter.count == 0){
                let vc : UIViewController = UIViewController()
                vc.view.backgroundColor = UIColor.whiteColor()
                self.setTabbarViewController([vc])
            } else {
                self.filterResponse = response
                self.completionHandlerResponse(response)
                self.adjustControllers()
                self.setTabbarViewController(self.listControllers)
            }
            }) { (error) in
                let vc : UIViewController = UIViewController()
                vc.view.backgroundColor = UIColor.whiteColor()
                self.setTabbarViewController([vc])
        }
    }
    
    private func setTabbarViewController(viewControllers:[UIViewController]){
        tabBarController.viewControllers = viewControllers as [AnyObject]
    }
    
    private func getTitle() -> String{
        return "Filter"
    }
    
    private func presentControllerFilter(){
        
        tabBarController.delegate = self
        tabBarController.title = self.getTitle()
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
        let controller : FilterSortViewController = FilterSortViewController.init(source:source, items: filterResponse.sort, selectedObject: selectedSort, onCompletion: { (selectedSort: ListOption, paramSort:[String:String]) in
                self.selectedSort = selectedSort
                self.completionHandlerSort(self.selectedSort, paramSort)
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
                let controller : CategoryFilterViewController = CategoryFilterViewController.init(rootCategoryID:rootCategoryID, selectedCategories: selectedCategories, initialCategories:categories) { (selectedCategory) in
                    self.selectedCategories = selectedCategory
                    self .adjustImageTabBarButton((self.selectedCategories.count>0))
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
                let controller: FiltersTableViewController = FiltersTableViewController.init(items: filter.options , selectedObjects: selectedFilters, showSearchBar: (filter.search.searchable.integerValue == 1), searchBarPlaceholder: filter.search.placeholder as String) { (selectedFilters) in
                    self.selectedFilters = selectedFilters
                    self.listControllers.forEach({ (controller) in
                        if controller.isKindOfClass(FiltersTableViewController){
                            (controller as! FiltersTableViewController).selectedObjects = selectedFilters
                        }
                    })
                    self .adjustImageTabBarButton(self.filterIsActive(filter.options, selectedFilters: selectedFilters))
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
            if selectedFilter.input_type == self.textInputType() {
                if listKeyFilters .contains(selectedFilter.key) {
                    textFieldIsActive = true
                }
            }
        }
            
        return ((allElemsContained.count>0) || textFieldIsActive)
    }
    
    private func textInputType()-> NSString{
        return "textbox"
    }
    
    private func categoryTitle() -> NSString{
        return "Kategori"
    }
    
    private func adjustImageTabBarButton(isActive:Bool){
        if isActive {
            var index : Int = Int(self.tabBarController.selectedIndex)
            if index == Int(UInt8.max){
                index = 0
            }
            if self.tabBarController.tabBar.tabBarButtons?.isEmpty == false {
                let button : MHVerticalTabBarButton = self.tabBarController.tabBar.tabBarButtons[Int(self.tabBarController.selectedIndex)];
                button.imageView.image = UIImage.init(named: "icon_unread.png")
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
        for filter in selectedFilters {
            let filterParam = params[filter.key]
            var value : String?
            if filterParam != nil && filterParam != "" {
                value = "\(filterParam!),\(filter.value)"
            } else {
                value = filter.value
            }
            
            params[filter.key] = value
        }

        completionHandlerFilter(selectedCategories, selectedFilters, params)
    }
    func didTapResetButton(button: UIButton!) {
        selectedCategories = []
        selectedFilters = []
        
        listControllers.forEach { (controller) in
            if controller.isKindOfClass(CategoryFilterViewController){
                (controller as! CategoryFilterViewController).resetSelectedFilter()
            }
            if controller.isKindOfClass(FiltersTableViewController){
                (controller as! FiltersTableViewController).resetSelectedFilter()
            }
        }
        
        self.tabBarController.tabBar.tabBarButtons.forEach({$0.imageView.image = UIImage()})
    }
    
    func tabBarController(tabBarController: MHVerticalTabBarController!, didSelectViewController viewController: UIViewController!) {
    }
    
}
