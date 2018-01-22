////
////  ProductTabTest.swift
////  Tokopedia
////
////  Created by Alwan M on 28/11/17.
////  Copyright © 2017 TOKOPEDIA. All rights reserved.
////
//
//import Foundation
//import XCTest
//
//class ProductTabTest : XCTestCase {
//    
//    var more = MorePage()
//    var login = LoginPage()
//    var product = ProductTabPage()
//    var myshop = MyShopPage()
//    var home = HomePage()
//    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//        Page.app.launch()
//        UITest.sharedInstance.testCase = self
//        if onBoarding.isOnBoarding() {
//            onBoarding.skipOnBoarding()
//        }
//        if login.isLogout() {
//            login.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+007@tokopedia.com", password: "tokopedia2020").loginSuccess()
//        }else{
//            home.goMorePage()
//            more.goToLogout().doLogout()
//            sleep(1)
//            login.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+007@tokopedia.com", password: "tokopedia2020").loginSuccess()
//        }
//        if more.isBuyer() {
//            login.swithAccountSeller()
//        }
//        more.goToMyShop()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    //Produk Tab
//    func testTapProdukTab(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        waitFor(element: product.produkNavBar, status: .Exists)
//        XCTAssert(product.produkNavBar.exists)
//    }
//    
//    func testSearchProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.searchProductTab()
//        waitFor(element: product.produkNavBar, status: .Exists)
//        XCTAssert(product.produkNavBar.exists)
//    }
//    
//    func testSortProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.sortProductTab()
//        waitFor(element: product.produkNavBar, status: .Exists)
//        XCTAssert(product.produkNavBar.exists)
//    }
//    
//    func testFilterProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.filterProductTab()
//        waitFor(element: product.filterButton, status: .Exists)
//        XCTAssert(product.filterButton.exists)
//    }
//    
//    func testSetEmptyStock(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.setEmptyStock()
//        waitFor(element: product.productList, status: .Exists)
//        XCTAssert(product.productList.exists)
//    }
//    
//    func testCancelSetEmptyStock(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.cancelSetEmptyStock()
//        waitFor(element: product.productList, status: .Exists)
//        XCTAssert(product.productList.exists)
//    }
//    
//    func testActiveStock(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.setActiveStock()
//        waitFor(element: product.productList, status: .Exists)
//        XCTAssert(product.productList.exists)
//    }
//    
//    func testCancelActiveStock(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.cancelActiveStock()
//        waitFor(element: product.productList, status: .Exists)
//        XCTAssert(product.productList.exists)
//    }
//    
//    func testDeleteProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        let productCellsCount = product.app.tables.cells.count
//        
//        if (!product.productList.exists){
//            product.addProduct()
//            product.app.tables.containing(.cell, identifier:"productList").element.swipeDown()
//        }
//        
//        product.deleteProduct()
//        XCTAssertTrue(product.app.tables.cells.count == productCellsCount - 1)
//    }
//    
//    func testCancelDeleteProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        product.cancelDeleteProduct()
//        waitFor(element: product.productList, status: .Exists)
//        XCTAssert(product.productList.exists)
//    }
//    
//    func testDuplicateProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        let productCellsCount = product.app.tables.cells.count
//        product.duplicateProduct()
//        //waiting time while uploading product
//        sleep(7)
//        XCTAssertTrue(product.app.tables.cells.count == productCellsCount + 1)
//    }
//    
//    func testAddProduct(){
//        myshop.goToShopSetting()
//        myshop.goToProdukTab()
//        let productCellCount = product.app.tables.cells.count
//        product.addProduct()
//        if (product.app.tables.cells.count != productCellCount){
//            waitFor(element: product.productList, status: .Exists)
//            XCTAssert(product.app.tables.cells.count == productCellCount + 1)
//        }
//    }
//
//}

