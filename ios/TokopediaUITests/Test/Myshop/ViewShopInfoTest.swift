//
//  viewShopInfoTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ViewShopInfoTest: XCTestCase {
    var myshop = MyShopPage()
    var shopInfo = ShopInfoPage()
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
            login.doLogin(email: "alwan.ubaidillah+007@tokopedia.com", password: "tokopedia2020").loginSuccess()
        }
        if more.isBuyer() {
            login.swithAccountSeller()
        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
//view shop info
    func testOpenShopInfo(){
        myshop.goToShopInfo()
        waitFor(element: shopInfo.shopInfoNavBar, status: .Exists)
        XCTAssert(shopInfo.shopInfoNavBar.exists)
    }
    
    //static number of favorite shop only, if there is changes this test will fail
    func testWhoFavoriteMyShop(){
        myshop.goToShopInfo()
        shopInfo.seeWhoFavMyShop()
        waitFor(element: shopInfo.whoFavMyShopNavBar, status: .Exists)
        XCTAssert(shopInfo.whoFavMyShopNavBar.exists)
    }
    
    func testSeeDetailStat(){
        myshop.goToShopInfo()
        shopInfo.seeDetailStat()
        waitFor(element: shopInfo.detailStatisticNavBar, status: .Exists)
        XCTAssert(shopInfo.detailStatisticNavBar.exists)
    }
    
    func testVisitShopOwner(){
        myshop.goToShopInfo()
        shopInfo.goToShopOwnerPage()
        waitFor(element: shopInfo.profilePageNavBar, status: .Exists)
        XCTAssert(shopInfo.profilePageNavBar.exists)
    }
}
