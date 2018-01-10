//
//  ShopSettingTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ShopSettingTest : XCTestCase {
    
    var more = MorePage()
    var login = LoginPage()
    var shopSetting = ShopSettingPage()
    var myshop = MyShopPage()
    
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
            login.doLogin(email: "alwan.ubaidillah+007@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        if more.isBuyer() {
            login.swithAccountSeller()
        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGoToShopSetting(){
        myshop.goToShopSetting()
        waitFor(element: shopSetting.shopSettingNavBar, status: .Exists)
        XCTAssert(shopSetting.shopSettingNavBar.exists)
    }
    
    func testTapInformasiTab(){
        myshop.goToShopSetting()
        shopSetting.goToInformasiTab()
        waitFor(element: shopSetting.shopInfoEditNavBar, status: .Exists)
        XCTAssert(shopSetting.shopInfoEditNavBar.exists)
    }
}
