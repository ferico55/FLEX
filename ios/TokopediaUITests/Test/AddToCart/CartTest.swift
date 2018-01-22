////
////  CartTest.swift
////  Tokopedia
////
////  Created by Julius Gonawan on 10/13/17.
////  Copyright © 2017 TOKOPEDIA. All rights reserved.
////
//
//import XCTest
//
//class CartTest: XCTestCase {
//    
//    var page = Page()
//    var addToCart = AddToCartPage()
//    var cart = CartPage()
//    var login = LoginPage()
//    var addToCartTest = AddToCartTest()
//    var productDetailTest = PDPTest()
//    var productDetail = ProductDetail()
//    
//    override func setUp() {
//        super.setUp()
//        continueAfterFailure = false
//        Page.app.launch()
//        XCUIApplication().launchEnvironment = ["animations": "0"]
//        UITest.sharedInstance.testCase = self
//        if onBoarding.isOnBoarding() {
//            onBoarding.skipOnBoarding()
//        }
//        if login.isLogout() {
//            login.goLoginPage()
//            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }
//        cart.goCartPage()
//        if !cart.userHaveCart() {
//            productDetailTest.testBuyProduct()
//            addToCartTest.testATCProduct()
//        }
//   }
//    
//    override func tearDown() {
//        super.tearDown()
//    }
//    
//    
//    func testDeleteInvoice() {
//        cart.deleteInvoice().cancelDeleteInvoice()
//        cart.deleteInvoice().doDeleteInvoice()
//    }
//    
//    func testDeleteProduct() {
//        cart.deleteProduct().cancelDeleteProduct()
//        cart.deleteProduct().doDeleteProduct()
//    }
//    
//    func testInputQtyProduct() {
//        cart.editProduct().inputQuantity()
//    }
//    
//    func testAddQtyProduct() {
//        cart.editProduct().addQuantity()
//    }
//    
//    func testDeductQtyProduct() {
//        cart.editProduct().deductQuantity()
//    }
//    
//    func testChangeAddress() {
//        cart.editShipping().changeAddress()
//    }
//   
//    func testChangeCourier() {
//        cart.editShipping().changeCourier()
//    }
//    
//    func testChangePackage() {
//        cart.editShipping().changePackage()
//    }
//    
//    func testPartialOrder() {
//        cart.setPartialOrder()
//        page.done.tap()
//    }
//    
//    func testDropshipper() {
//        cart.inputDropshipper()
//    }
//    
//    func testPromo() {
//        cart.inputPromo()
//        waitFor(element: cart.processing, status: .NotExists)
//        XCTAssert(cart.promoAmount.exists)
//    }
//    
//    func testDonation() {
//        let grandTotalBefore = cart.grandTotal.label.components(separatedBy: "Rp ")
//        guard let grandTotalBeforeInt = Int(grandTotalBefore[1].replacingOccurrences(of: ".", with: "")) else {
//            return
//        }
//        cart.checkDonation()
//        let grandTotalAfter = cart.grandTotal.label.components(separatedBy: "Rp ")
//        guard let grandTotalAfterInt = Int(grandTotalAfter[1].replacingOccurrences(of: ".", with: "")) else {
//            return
//        }
//        XCTAssertTrue(grandTotalAfterInt > grandTotalBeforeInt)
//    }
//    
//    func testCheckoutWithTokoCash() {
//        cart.checkoutCart().checkoutWith(with: "TokoCash")
//    }
//    
//    func testCheckoutWithManual() {
//        cart.checkoutCart().checkoutWith(with: "Transfer Manual")
//    }
//}

