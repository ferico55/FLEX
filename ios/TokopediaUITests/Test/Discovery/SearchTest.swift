//
//  SearchTest.swift
//  Tokopedia
//
//  Created by nakama on 8/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class SearchTest: XCTestCase {
    
    var homepage : HomePage = HomePage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSearchProduct() {
        let searchResult = homepage.goSearchPage().searchProduct("iPhone 7")
        waitFor(element: searchResult.productCell, status: .Exists)
        XCTAssert(searchResult.productCell.exists)
    }
    
    func testClickProductSearch() {
        let productResult = homepage.goSearchPage().searchProduct("iPhone 7").clickProduct()
        waitFor(element: productResult.PDPView, status: .Exists)
        XCTAssert(productResult.PDPView.exists)
    }
    
    func testSearchCatalog() {
        let searchResult = homepage.goSearchPage().searchCatalog("iPhone 7")
        waitFor(element: searchResult.productCell, status: .Exists)
        XCTAssert(searchResult.productCell.exists)
    }
    
    func testCatalogShopList() {
        let catalogResult = homepage.goSearchPage().searchCatalog("iPhone 7").clickCatalog()
        waitFor(element: catalogResult.catalogShopList, status: .Exists)
        XCTAssert(catalogResult.catalogShopList.exists)
    }
    
    func testBuyCatalog()
    {
        let catalogResult = homepage.goSearchPage().searchCatalog("iPhone 8").clickCatalog()
        let result = catalogResult.buyCatalog()
        waitFor(element: result.PDPView, status: .Exists)
        XCTAssert(result.PDPView.exists)
    }
    
    
    func testSearchShop()
    {
        let shopResult = homepage.goSearchPage().searchShop("Loving Store")
        waitFor(element: shopResult.shopResultCell, status: .Exists)
        XCTAssert(shopResult.shopResultCell.exists)
        shopResult.clickShop()
    }

//    func testButtomBarProduct() {
//        homepage.goToSearchPage().searchProduct("iPhone 7")
//        bar.sorting()
//        bar.filtering()
//        bar.changeGrid()
//        bar.sharing()
//    }
    
//    func testBottomBarCatalog()
//    {
//        homepage.goToSearchPage().searchCatalog("iPhone 7").clickCatalog()
//        bar.sorting()
//        bar.filtering()
//        bar.changeGrid()
//        bar.sharing()
//    }
//



}
