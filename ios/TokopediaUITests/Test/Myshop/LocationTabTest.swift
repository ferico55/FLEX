//
//  LocationTabTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class LocationTabTest : XCTestCase {
    
    var more = MorePage()
    var login = LoginPage()
    var location = LocationTabPage()
    var myshop = MyShopPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
//        if login.isLogout() {
//            login.goLoginPage()
//            login.doLogin(email: "alwan.ubaidillah+101@tokopedia.com", password: "tokopedia2016").loginSuccess()
//        }
//        if more.isBuyer() {
//            login.swithAccountSeller()
//        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //LocationTab
    func testTapLokasiTab(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        waitFor(element: location.locationNavBar, status: .Exists)
        XCTAssert(location.locationNavBar.exists)
    }
    
    func testAddLocation(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        let locationCellCount = location.app.tables.cells.count
        
        if (locationCellCount == 3){
            location.deleteLocationBySwipe()
            sleep(2)
            location.listLocationCell.swipeDown()
            let locationNowCellCount = location.app.tables.cells.count
            location.addLocation()
            XCTAssertTrue(location.app.tables.cells.count == locationNowCellCount + 1)
            sleep(2)
        }else{
            let locationNowCellCount = location.app.tables.cells.count
            location.addLocation()
            XCTAssertTrue(location.app.tables.cells.count == locationNowCellCount + 1)
            sleep(2)
        }
    }
    
    func testAddLocationMoreThan3(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        var locationCellCount = location.app.tables.cells.count
        while (locationCellCount != 3){
            location.addLocation()
            locationCellCount = locationCellCount + 1
        }
        sleep(2)
        location.locationNavBar.buttons["Add"].tap()
        waitFor(element: location.addMoreThenTriAlert, status: .Exists)
        XCTAssert(location.addMoreThenTriAlert.exists)
        location.addMoreThenTriAlert.buttons["OK"].tap()
    }
    
    func testUpdateLocation(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        let locationListCount = location.app.tables.cells.count
        if (locationListCount < 1){
            location.addLocation()
            sleep(2)
        }
        location.updateLocation()
        waitFor(element: location.editLocationNavBar.buttons["Ubah"], status: .Exists)
        XCTAssert(location.editLocationNavBar.buttons["Ubah"].exists)
    }
    
    func testDeleteLocation(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        var locationListCount = location.app.tables.cells.count
        if (locationListCount < 1){
            location.addLocation()
            locationListCount = locationListCount + 1
            sleep(2)
        }
        location.deleteLocationBySwipe()
        XCTAssertTrue(location.app.tables.cells.count == locationListCount - 1)
    }
    
    func testDeleteLocationFromDetail(){
        myshop.goToShopSetting()
        myshop.goToLokasiTab()
        var locationListCount = location.app.tables.cells.count
        if (locationListCount < 1){
            location.addLocation()
            locationListCount = locationListCount + 1
            sleep(2)
        }
        location.deleteLocationFromDetail()
        XCTAssertTrue(location.app.tables.cells.count == locationListCount - 1)
    }
}
