//
//  FilterController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/27/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class FilterController: NSObject, EtalaseViewControllerDelegate,MHVerticalTabBarControllerDelegate {
    
    private var filter: QueryObject = QueryObject()
    private var listControllers : [UIViewController] = []
    private var completionHandler:(QueryObject)->Void = {(arg:QueryObject) -> Void in}

    private var categoryType: CategoryFilterType = .Hotlist
    private var categoryList: [CategoryDetail] = []
    private var shopID: String = ""
    private let tabBarController:MHVerticalTabBarController = MHVerticalTabBarController()

    
    // MARK: - Custom Init
    init(categoryType: CategoryFilterType, categoryList: NSArray, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.categoryType = categoryType
        self.categoryList = categoryList as! [CategoryDetail]
        self.filter = selectedFilter.copy() as! QueryObject
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(categoryType: CategoryFilterType, categoryList: NSArray, shopID:String, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.categoryType = categoryType
        self.categoryList = categoryList as! [CategoryDetail]
        self.filter = selectedFilter.copy() as! QueryObject
        self.shopID = shopID
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(shopID:String, filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.filter = selectedFilter.copy() as! QueryObject
        self.shopID = shopID
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    init(filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController), onCompletion: ((QueryObject) -> Void)){
        self.filter = selectedFilter.copy() as! QueryObject
        self.completionHandler = onCompletion
        
        super.init()
        
        self .presentController(filters, selectedFilter: selectedFilter, presentedVC: presentedVC)
    }
    
    private func presentController(filters:[NSInteger], selectedFilter:QueryObject, presentedVC:(UIViewController)){
        self.adjustControllers(filters)
        
        tabBarController.delegate = self
        tabBarController.title = "Filter"
        tabBarController.tabBarWidth = 120
        tabBarController.tabBarItemHeight = 44
        tabBarController.viewControllers = listControllers as [AnyObject]
        tabBarController.showResetButton = true
        
        let navigation: UINavigationController = UINavigationController.init(rootViewController: tabBarController)
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
            case type.shipment:
                self.addShipment()
            case type.preorder:
                self.addPreOrder()
            default: break
            }
        }
    }
    
    private func addCategory(type:CategoryFilterType, categoryList:NSArray)  {
        
        self .adjustImageTabBarButton(filter.selectedCategory.count)
        
        let controller : CategoryFilterViewController = CategoryFilterViewController.init(selectedCategories: filter.selectedCategory, filterType: .Hotlist, initialCategories:self.categoryList) { (selectedCategory) in
            self.filter.selectedCategory = selectedCategory
            self .adjustImageTabBarButton(selectedCategory.count)
        }
        
        controller.tabBarItem.title = "Kategori"

        listControllers .append(controller)
    }
    
    private func addShop(){
        
        self .adjustImageTabBarButton(filter.selectedShop.count)

        let object:FilterObject = FilterObject();
        object.title = "Gold Merchant";
        object.filterID = "1";
        
        let controller: FilterSwitchViewController = FilterSwitchViewController.init(items: [object], selectedObjects: filter.selectedShop) { (selectedShop) in
            self.filter.selectedShop = selectedShop
            self .adjustImageTabBarButton(selectedShop.count)
        }
        
        controller.tabBarItem.title = "Toko";

        listControllers .append(controller)
    }
    
    private func addLocation(){
        
        self .adjustImageTabBarButton(filter.selectedLocation.count)

        let controller : LocationFilterViewController = LocationFilterViewController.init(selectedObjects:filter.selectedLocation) { (selectedLocation) in
            self.filter.selectedLocation = selectedLocation
            self .adjustImageTabBarButton(selectedLocation.count)
        }
                
        controller.tabBarItem.title = "Lokasi";

        listControllers .append(controller)
    }
    
    private func addPrice(){
        
        if (Int(filter.selectedPrice.priceMax) == 0 && Int(filter.selectedPrice.priceMax) == 0 && filter.selectedPrice.priceWholesale == false){
            self .adjustImageTabBarButton(0)
        } else {
            self .adjustImageTabBarButton(1)
        }
        
        let controller:FilterPriceViewController = FilterPriceViewController.init(price: filter.selectedPrice) { (selectedPrice) in
            self.filter.selectedPrice = selectedPrice
            if (Int(selectedPrice.priceMax) == 0 && Int(selectedPrice.priceMax) == 0 && selectedPrice.priceWholesale == false){
                self .adjustImageTabBarButton(0)
            } else {
                self .adjustImageTabBarButton(1)
            }
        }

        controller.tabBarItem.title = "Harga";

        listControllers .append(controller)
    }
    
    private func addCondition(){
        let items:NSMutableArray = NSMutableArray();
        let object1:FilterObject = FilterObject();
        object1.title = "Baru";
        object1.filterID = "1";
        items.addObject(object1)
        let object2:FilterObject = FilterObject();
        object2.title = "Bekas";
        object2.filterID = "2";
        items.addObject(object2)
        
        let controller: FilterTableViewController = FilterTableViewController.init(items: items.copy() as! [FilterObject], selectedObjects: filter.selectedCondition, showSearchBar: false) { (selectedCondition) in
            self.filter.selectedCondition = selectedCondition
            self .adjustImageTabBarButton(selectedCondition.count)

        }
        
        controller.tabBarItem.title = "Kondisi";

        listControllers .append(controller)
    }
    
    private func addPreOrder(){
        let object:FilterObject = FilterObject();
        object.title = "Preorder";
        object.filterID = "1";
        
        let controller: FilterSwitchViewController = FilterSwitchViewController.init(items: [object], selectedObjects: filter.selectedShop) { (selectedShop) in
            self.filter.selectedShop = selectedShop
            self .adjustImageTabBarButton(selectedShop.count)

        }
        
        controller.tabBarItem.title = "Preorder";

        listControllers .append(controller)
    }
    
    private func addShipment(){
        
        self .adjustImageTabBarButton(filter.selectedShipping.count)

        let items:NSMutableArray = NSMutableArray();
        let object:FilterObject = FilterObject();
        object.title = "SiCepat";
        object.filterID = "11";
        items.addObject(object)
        let object1:FilterObject = FilterObject();
        object1.title = "JNE";
        object1.filterID = "1";
        items.addObject(object1)
        let object2:FilterObject = FilterObject();
        object2.title = "TIKI";
        object2.filterID = "2";
        items.addObject(object2)
        let object3:FilterObject = FilterObject();
        object3.title = "RPX";
        object3.filterID = "3";
        items.addObject(object3)
        let object4:FilterObject = FilterObject();
        object4.title = "Wahana";
        object4.filterID = "6";
        items.addObject(object4)
        let object5:FilterObject = FilterObject();
        object5.title = "First";
        object5.filterID = "9";
        items.addObject(object5)
        let object6:FilterObject = FilterObject();
        object6.title = "Pos Indonesia";
        object6.filterID = "4";
        items.addObject(object6)
        let object7:FilterObject = FilterObject();
        object7.title = "Cahaya";
        object7.filterID = "7";
        items.addObject(object7)
        let object8:FilterObject = FilterObject();
        object8.title = "Pandu";
        object8.filterID = "8";
        items.addObject(object8)
        
        let controller: FilterTableViewController = FilterTableViewController.init(items: items.copy() as! [FilterObject], selectedObjects: filter.selectedShipping, showSearchBar: false) { (selectedShipping) in
            self.filter.selectedShipping = selectedShipping
            self .adjustImageTabBarButton(selectedShipping.count)
        }
        
        controller.tabBarItem.title = "Pengiriman";
        listControllers .append(controller)
    }

    
    private func addEtalase(shopID:String) {
        
        let controller : EtalaseViewController = EtalaseViewController()
        controller.delegate = self;
        controller.shopId = shopID;
        controller.isEditable = false;
        controller.showOtherEtalase = false;
        controller.enableAddEtalase = false;
        
        controller.tabBarItem.title = "Etalase";
        listControllers .append(controller)
    }
    
    private func adjustImageTabBarButton(dataCount:Int){
        if dataCount > 0 {
            
            let button : MHVerticalTabBarButton = self.tabBarController.tabBar.tabBarButtons[Int(self.tabBarController.selectedIndex)];
            button.imageView.image = UIImage.init(named: "icon_unread.png")
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
    
    // MARK: - Filter Etalase Delegate
    func didSelectEtalaseFilter(selectedEtalase: EtalaseList!) {
        self.filter.selectedEtalase = selectedEtalase
    }
    
    // MARK: - MHVerticalTabBarController Delegate
    func done() {
        completionHandler(self.filter)
    }
    func didTapResetButton(button: UIButton!) {
        self.filter = QueryObject()
//        listControllers.forEach { $0.resetSelectedFilter() }
    }

    func tabBarController(tabBarController: MHVerticalTabBarController!, didSelectViewController viewController: UIViewController!) {
    }
}
