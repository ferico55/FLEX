//
//  SearchTest.swift
//  Tokopedia
//
//  Created by nakama on 8/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class SearchTest: XCTestCase {
    
    var homepage = HomePage()
    var search = SearchPage()
    var product = SearchResultProductPage()
    var catalog = SearchResultCatalogPage()
    var shop = SearchResultShopPage()
    var login = LoginTest()
    var popular = SearchResultPopularSearch()
    var bar = bottomBar()

    
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
        homepage.goToSearchPage().searchProduct("iPhone 7").clickProduct()
    }
    
    func testButtomBarProduct() {
        homepage.goToSearchPage().searchProduct("iPhone 7")
        bar.sorting()
        bar.filtering()
        bar.changeGrid()
        bar.sharing()           
    }
    
    //    func testSearchAutoComplete()
    //    {
    //        homepage.goToSearchPage()
    //        waitFor(element: popular.rowsatu, status: .Exists)
    //
    //    }
    
    func testSearchCatalog()
    {
        homepage.goToSearchPage().searchCatalog("iPhone 7").clickCatalog()
        //catalog.buttonGridType()
    }
    
    func testBottomBarCatalog()
    {
        homepage.goToSearchPage().searchCatalog("iPhone 7").clickCatalog()
        bar.sorting()
        bar.filtering()
        bar.changeGrid()
        bar.sharing()
    }
    
    
    func testCatalogDetail()
    {
        homepage.goToSearchPage().searchCatalog("iPhone 7").clickCatalog()
        waitFor(element: bar.result, status: .Exists)
        bar.result.tap()
    }
    
    func testCatalogShopList()
    {
        homepage.goToSearchPage().searchCatalog("iPhone 7").clickCatalog()
        waitFor(element: bar.result, status: .Exists)
        bar.result.tap()
        waitFor(element: catalog.catalogShopList, status: .Exists)
        catalog.catalogShopList.tap()
        waitFor(element: catalog.buyProductOnCatalog, status: .Exists)
        XCTAssert(catalog.buyProductOnCatalog.exists)
        catalog.buyProductOnCatalog.tap()
    }
    
    func testSearchShop()
    {
        homepage.goToSearchPage().searchShop("Cherrish Store").clickShop()
        waitFor(element: shop.shopResultCell, status: .Exists)
        shop.shopResultCell.tap()
    }

}
