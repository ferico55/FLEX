//
//  FilterController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class FilterController: NSObject, FilterCategoryViewDelegate, EtalaseViewControllerDelegate,MHVerticalTabBarControllerDelegate {
    
    private var filter: QueryObject = QueryObject()
    private var listControllers : NSMutableArray = NSMutableArray()
    private var completionHandler:(QueryObject)->Void = {(arg:QueryObject) -> Void in}

    private var categoryType: FilterCategoryType = .Hotlist
    private var categoryList: NSArray = []
    private var shopID: String = ""
    
    // MARK: - Custom Init
    init(categoryType: FilterCategoryType, categoryList: NSArray, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.categoryType = categoryType
        self.categoryList = categoryList
        self.filter = selectedFilter
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(categoryType: FilterCategoryType, categoryList: NSArray, shopID:String, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.categoryType = categoryType
        self.categoryList = categoryList
        self.filter = selectedFilter
        self.shopID = shopID
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(shopID:String, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.filter = selectedFilter
        self.shopID = shopID
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.filter = selectedFilter
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    private func presentController(filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController)){
        self.adjustControllers(filters)
        
        let controller:MHVerticalTabBarController = MHVerticalTabBarController()
        controller.delegate = self
        controller.title = "Filter"
        controller.tabBarWidth = 120
        controller.tabBarItemHeight = 44
        controller.viewControllers = listControllers as [AnyObject]
        
        let navigation: UINavigationController = UINavigationController.init(rootViewController: controller)
        navigation.navigationBar.translucent = false
        presentedVC.navigationController!.presentViewController(navigation, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
        
    }
    
    // MARK: - Add View Controller on Tab bar
    private func adjustControllers(filters:[NSInteger]) {
        let type:FilterType=FilterType()

        for filter in filters {
            switch filter {
            case type.Category:
                self.addCategory(categoryType, categoryList: categoryList)
            case type.Etalase:
                self.addEtalase(shopID)
            case type.Shop:
                self.addShop()
            case type.Location:
                self.addLocation()
            case type.Condition:
                self.addCondition()
            case type.Price:
                self.addPrice()
            default: break
            }
        }
    }
    
    private func addCategory(type:FilterCategoryType, categoryList:NSArray)  {
        let controller : FilterCategoryViewController = FilterCategoryViewController()
        controller.filterType = type
        controller.selectedCategory = filter.selectedCategory
        controller.categories = categoryList.mutableCopy() as! NSMutableArray
        controller.delegate = self
        
        controller.tabBarItem.title = "Kategori"
        listControllers .addObject(controller)
    }
    
    private func addShop(){
        let items:NSMutableArray = NSMutableArray();
        let object1:FilterObject = FilterObject();
        object1.title = "Semua Toko";
        object1.filterID = "0";
        items.addObject(object1)
        let object2:FilterObject = FilterObject();
        object2.title = "Gold Merchant";
        object2.filterID = "1";
        items.addObject(object2)
        
        let controller: FilterTableViewController = FilterTableViewController.init(items: items.copy() as! [FilterObject], selectedObject: filter.selectedShop) { (selectedShop) in
            self.filter.selectedShop = selectedShop
        }

        controller.tabBarItem.title = "Toko";
        listControllers .addObject(controller)
    }
    
    private func addLocation(){
        let items:NSMutableArray = NSMutableArray();
        let names:NSMutableArray = NSMutableArray();
        names.addObject("Semua Lokasi")
        names.addObject("Jabodetabek")
        names.addObjectsFromArray(DBManager.getSharedInstance().LoadDataQueryLocationName("select d.district_name from ws_district d WHERE d.district_id IN (select distinct d.district_id from ws_shipping_city sc LEFT JOIN ws_district d ON sc.district_id = d.district_id order by d.district_name) order by d.district_name"))
        
        let id:NSMutableArray = NSMutableArray();
        id.addObject("0")
        id.addObject("2210,2228,5573,1940,1640,2197")
        id.addObjectsFromArray(DBManager.getSharedInstance().LoadDataQueryLocationName("select distinct sc.district_id from ws_shipping_city sc, ws_district d where sc.district_id = d.district_id order by d.district_name"))
        
        for (index, _) in names.enumerate() {
            let object : FilterObject = FilterObject()
            object.title = names[Int(index as NSNumber)] as! NSString
            object.filterID = id[Int(index as NSNumber)] as! NSString
            items.addObject(object)
        }
        
        let controller: FilterTableViewController = FilterTableViewController.init(items: items.copy() as! [FilterObject], selectedObject: filter.selectedLocation) { (selectedLocation) in
            self.filter.selectedLocation = selectedLocation
        }

        
        controller.tabBarItem.title = "Lokasi";
        listControllers .addObject(controller)
    }
    
    private func addPrice(){
        
        let controller:FilterPriceViewController = FilterPriceViewController.init(price: filter.selectedPrice) { (selectedPrice) in
            self.filter.selectedPrice = selectedPrice
        }

        controller.tabBarItem.title = "Harga";
        listControllers .addObject(controller)
    }
    
    private func addCondition(){
        let items:NSMutableArray = NSMutableArray();
        let object1:FilterObject = FilterObject();
        object1.title = "Semua Kondisi";
        object1.filterID = "0";
        items.addObject(object1)
        let object2:FilterObject = FilterObject();
        object2.title = "Baru";
        object2.filterID = "1";
        items.addObject(object2)
        let object3:FilterObject = FilterObject();
        object3.title = "Bekas";
        object3.filterID = "2";
        items.addObject(object3)
        
        let controller: FilterTableViewController = FilterTableViewController.init(items: items.copy() as! [FilterObject], selectedObject: filter.selectedCondition) { (selectedCondition) in
            self.filter.selectedCondition = selectedCondition
        }
        
        controller.tabBarItem.title = "Kondisi";
        listControllers .addObject(controller)
    }

    private func addEtalase(shopID:String) {
        let controller : EtalaseViewController = EtalaseViewController()
        controller.delegate = self;
        controller.shopId = shopID;
        controller.isEditable = false;
        controller.showOtherEtalase = false;
        controller.enableAddEtalase = false;
        
        controller.tabBarItem.title = "Etalase";
        listControllers .addObject(controller)
    }
    
    // MARK: - Filter Category Delegate
    func didSelectCategoryFilter(category: CategoryDetail!) {
        self.filter.selectedCategory = category
    }
    
    // MARK: - Filter Etalase Delegate
    func didSelectEtalaseFilter(selectedEtalase: EtalaseList!) {
        self.filter.selectedEtalase = selectedEtalase
    }
    
    // MARK: - MHVerticalTabBarController Delegate
    func done() {
        completionHandler(filter)
    }

    func tabBarController(tabBarController: MHVerticalTabBarController!, didSelectViewController viewController: UIViewController!) {
        
    }
}
