//
//  AddToCartTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class AddToCartTest: XCTestCase {
    
    var page = Page()
//    var productDetailTest = PDPTest()
    var productDetail = ProductDetail()
    var addToCart = AddToCartPage()
    var login = LoginPage()
    var more = MorePage()
    var home = HomePage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        XCUIApplication().launchEnvironment = ["animations": "0"]
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
//        if login.isLogout() {
//            login.goLoginPage()
//            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }
//productDetailTest.testBuyProduct()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func preCondition() {
//        more.goToLogout().doLogout()
//        login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        productDetailTest.testGoPDPFromWishlist()
        productDetail.clickBuy()
    }
    
    func testAddQtyProduct() {
        let qtyBefore = addToCart.productQuantity.value as! String
        let qtyAfter = String(Int(qtyBefore)! + 1)
        addToCart.addQuantity()
        XCTAssertTrue(addToCart.productQuantity.value as! String == qtyAfter)
    }
    
    func testDeductQtyProduct() {
        let qtyBefore = addToCart.productQuantity.value as! String
        let qtyAfter = String(Int(qtyBefore)! + 1 - 1)
        addToCart.addQuantity()
        addToCart.deductQantity()
        XCTAssertTrue(addToCart.productQuantity.value as! String == qtyAfter)
    }
    
    func testInputQuantity() {
        addToCart.inputQuantity()
        XCTAssertTrue(addToCart.productQuantity.value as! String == "5")
    }
    
    func testInputNoteForSeller() {
        addToCart.fillNoteForSeller()
        XCTAssertNotNil(addToCart.noteForSeller.value as! String)
        
    }
    
    func testChooseAddress() {
        if addToCart.isHaveAddress() {
            addToCart.addressOption.tap()
            page.done.tap()
            //addToCart.doneNavBar.tap()
            }else{
            addToCart.addNewAddress()
        }
    }
    
    func testChooseCourier() {
        addToCart.chooseCourier()
        addToCart.choosePackage()
    }
    
    func testATCProduct() {
        testAddQtyProduct()
        testInputNoteForSeller()
        testChooseAddress()
        testChooseCourier()
        addToCart.ATCBuyButton.tap()
        addToCart.purchaseButton.tap()
    }
}
