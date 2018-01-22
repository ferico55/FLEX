////
////  PurchaseTest.swift
////  Tokopedia
////
////  Created by Julius Gonawan on 19/10/17.
////  Copyright © 2017 TOKOPEDIA. All rights reserved.
////
//
//import XCTest
//
//class PurchaseTest: XCTestCase {
//    
//    var more = MorePage()
//    var purchase = PurchasePage()
//    var purchaseStatus = PurchaseStatus()
//    var cart = CartPage()
//    var cartTest = CartTest()
//    var addToCart = AddToCartPage()
//    var addToCartTest = AddToCartTest()
//    var productDetailTest = PDPTest()
//    var login = LoginPage()
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
//            login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia2020").loginSuccess()
//        }
//        more.goToPurchase()
//    }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    func testGoToPurchaseStatus() {
//        purchase.goToPurchaseStatus().isSuccess()
//    }
//    
//    func testBankAccount() {
//        purchase.goToPurchaseStatus().goToBankAccount(account: "Bank BCA")
//    }
//    
//    func testCancelPayment() {
//        
//        if !purchase.isHavePurchaseStatus() {
//            purchase.backToMore()
//            if cart.userHaveCart(){
//                cartTest.testCheckoutWithManual()
//                more.goToPurchase()
//            }
//            else{
//                productDetailTest.testBuyProduct()
//                addToCartTest.testATCProduct()
//                cartTest.testCheckoutWithManual()
//                more.goToPurchase()
//            }
//        }
//        
//        purchase.goToPurchaseStatus().cancelTransaction()
//        XCTAssert(!purchaseStatus.elipse.exists)
//    }
//    
//    func testChangePayment() {
//        purchase.goToPurchaseStatus().changeTransaction()
//    }
//    
//    
//}

