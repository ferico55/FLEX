//
//  EditShopInfoTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class EditShopInfoTest: XCTestCase {
    var shopInfo = ShopInfoPage()
    var myshop = MyShopPage()
    var more = MorePage()
    var login = LoginPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "elly.susilowati+089@tokopedia.com", password: "tokopedia2015")
        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //edit shop info
    func testChangeShopTagline(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        shopInfo.changeShopTagline()
        waitFor(element: shopInfo.shopPageNavBar, status: .Exists)
        XCTAssert(shopInfo.shopPageNavBar.exists)
    }
    
    func testChangeShopDescription(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        shopInfo.changeShopDescription()
        waitFor(element: shopInfo.shopPageNavBar, status: .Exists)
        XCTAssert(shopInfo.shopPageNavBar.exists)
    }
    
    func testSeeShopStatus(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        shopInfo.seeShopStatus()
        waitFor(element: shopInfo.shopStatusNavBar, status: .Exists)
        XCTAssert(shopInfo.shopStatusNavBar.exists)
    }
    
    func testSetCloseShopNow(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        
        if (shopInfo.shopStatusTutup.exists){
            shopInfo.seeShopStatus()
            shopInfo.openShop()
            shopInfo.shopStatusNavBar.buttons["Tutup"].tap()
        }
        
        shopInfo.seeShopStatus()
        shopInfo.setCloseShopNow()
        waitFor(element: shopInfo.setEditCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setEditCloseShopButton.exists)
    }
    
    func testCancelCloseShopNow(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        shopInfo.seeShopStatus()
        shopInfo.setCancelCloseShopNow()
        waitFor(element: shopInfo.setCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setCloseShopButton.exists)
    }
    
    func testSetCloseShopScheduled(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        
        if (shopInfo.shopStatusTutup.exists){
            shopInfo.seeShopStatus()
            shopInfo.openShop()
            shopInfo.shopStatusNavBar.buttons["Tutup"].tap()
        }
        
        shopInfo.seeShopStatus()
        shopInfo.setCloseShopScheduled()
        waitFor(element: shopInfo.deleteCloseShopScheduled, status: .Exists)
        XCTAssert(shopInfo.deleteCloseShopScheduled.exists)
    }
    
    func testCancelCloseShopScheduled(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        shopInfo.seeShopStatus()
        shopInfo.setCancelCloseShopScheduled()
        waitFor(element: shopInfo.setCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setCloseShopButton.exists)
    }
    
    func testOpenShopfromClose(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        
        if (shopInfo.shopStatusBuka.exists) {
            shopInfo.seeShopStatus()
            shopInfo.setCloseShopNow()
            shopInfo.shopStatusNavBar.buttons["Tutup"].tap()
        }
        
        shopInfo.seeShopStatus()
        shopInfo.openShop()
        waitFor(element: shopInfo.setCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setCloseShopButton.exists)
    }
    
    func testDeleteSheduledCloseShop(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        
        if (shopInfo.shopStatusBuka.exists) {
            shopInfo.seeShopStatus()
            shopInfo.setCloseShopScheduled()
            shopInfo.shopStatusNavBar.buttons["Tutup"].tap()
        }
        
        shopInfo.seeShopStatus()
        shopInfo.deleteCloseShopScheduled.tap()
        waitFor(element: shopInfo.setCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setCloseShopButton.exists)
    }
    
    func testExtendCloseShop(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        
        if (shopInfo.shopStatusBuka.exists) {
            shopInfo.seeShopStatus()
            shopInfo.setCloseShopNow()
            shopInfo.shopStatusNavBar.buttons["Tutup"].tap()
        }
        
        shopInfo.seeShopStatus()
        shopInfo.extendCloseShop()
        waitFor(element: shopInfo.setEditCloseShopButton, status: .Exists)
        XCTAssert(shopInfo.setEditCloseShopButton.exists)
    }
    
    func testSeeAboutGoldMerchant(){
        myshop.goToShopInfo()
        shopInfo.ubahShopInfoButton.tap()
        if (shopInfo.extendGM.exists){
            shopInfo.goExtendGM()
            waitFor(element: shopInfo.app.navigationBars.buttons["icon menu group 9"], status: .Exists)
            XCTAssert(shopInfo.app.navigationBars.buttons["icon menu group 9"].exists)
        } else {
            shopInfo.seeAboutGM()
            waitFor(element: shopInfo.aboutGMNavBar, status: .Exists)
            XCTAssert(shopInfo.aboutGMNavBar.exists)
        }
    }
}
