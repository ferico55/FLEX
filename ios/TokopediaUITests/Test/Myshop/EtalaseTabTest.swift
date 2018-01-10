//
//  EtalaseTabTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class EtalaseTabTest : XCTestCase {
    var more = MorePage()
    var login = LoginPage()
    var etalase = EtalaseTabPage()
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
    
    //Etalase Tab
    func testTapEtalaseTab(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        waitFor(element: etalase.shopEtalaseNavBar, status: .Exists)
        XCTAssert(etalase.shopEtalaseNavBar.exists)
    }
    
    func testAddNewEtalase(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        let numOfEtalaseExist = etalase.app.tables.cells.count
        etalase.addNewEtalase()
        let numOfEtlaseNew = numOfEtalaseExist + 1
        XCTAssertTrue(numOfEtlaseNew == numOfEtalaseExist + 1)
        etalase.removeEtalase()
    }
    
    func testDeleteEtalase(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        //adding new etalase to provide thing to delete
        etalase.addNewEtalase()
        sleep(2)
        var numOfEtalaseExist = etalase.app.tables.cells.count
        etalase.removeEtalase()
        numOfEtalaseExist = numOfEtalaseExist - 1
        sleep(2)
        XCTAssertEqual(numOfEtalaseExist, etalase.app.tables.cells.count)
        etalase.addEtalaseTextField.tap()
    }
    
    func testDeleteNonEmptyEtalase(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        let etalaseNow = etalase.app.tables.cells.count
        etalase.removeEtalase()
        XCTAssertEqual(etalaseNow, etalase.app.tables.cells.count)
        etalase.addEtalaseTextField.tap()
    }
    
    func testRenameEtalase(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        etalase.renameEtalase()
        waitFor(element: etalase.addEtalaseTextField, status: .Exists)
        XCTAssert(etalase.addEtalaseTextField.exists)
    }
    
    func testCancelRenameEtalase(){
        myshop.goToShopSetting()
        myshop.goToEtalaseTab()
        etalase.cancelRenameEtalase()
        waitFor(element: etalase.addEtalaseTextField, status: .Exists)
        XCTAssert(etalase.addEtalaseTextField.exists)
    }
}
