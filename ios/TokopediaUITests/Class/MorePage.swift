//
//  MorePage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class MorePage : Page, TokopediaTabBar {
    let depositCell = app.tables.cells["depositCell"]
    let tokocashCell = app.tables.cells["tokocashCell"]
    let profilCell = app.tables.cells["profilCell"]
    let purchaseCell = app.tables.cells["purchaseCell"]
    let wishlistCell = app.tables.cells["wishlistCell"]
    let myShopCell = app.tables.cells["myShopCell"]
    let openShop = app.tables.buttons["openShop"]
    let messageCell = app.tables.cells["messageCell"]
    let talkCell = app.tables.cells["talkCell"]
    let reviewCell = app.tables.cells["reviewCell"]
    let ticketCell = app.tables.cells["ticketCell"]
    let resolutionCell = app.tables.cells["resolutionCell"]
    let shareFriendCell = app.tables.cells["shareFriendCell"]
    let contactCell = app.tables.cells["contactCell"]
    let privacyCell = app.tables.cells["privacyCell"]
    let shareCell = app.tables.cells["shareCell"]
    let pushNotifCell = app.tables.cells["pushNotifCell"]
    let logoutCell = app.tables.cells["logoutCell"]
    let versionCell = app.tables.cells["versionCell"]
    let shopCell = app.tables.cells["shopCell"]
    let salesCell = app.tables.cells["salesCell"]
    let productListCell = app.tables.cells["productListCell"]
    let etalaseCell = app.tables.cells["etalaseCell"]
    let topAdsCell = app.tables.cells["topAdsCell"]
    
    //let productDetailCell = app.tables.cells.matching(identifier: "productListCell").element(boundBy: 0)
    
    let logoutAlert = app.alerts["Apakah Anda ingin keluar?"]
    
    func waitForPurchase() {
        waitFor(element: purchaseCell, status: .Exists)
    }
    
    func goToPurchase() {
        goMorePage()
        waitForPurchase()
        purchaseCell.tap()
    }
    
    func goToSales() {
        goMorePage()
        waitFor(element: salesCell, status: .Exists)
        salesCell.tap()
    }
    
    func goToMyShop(){
        goMorePage()
        waitFor(element: shopCell, status: .Exists)
        shopCell.tap()
    }
    
    func goToInboxTalk()
    {
        goMorePage()
        waitFor(element: talkCell, status: .Exists)
        talkCell.tap()
    }
    
    func isBuyer() -> Bool {
        goMorePage()
        if (!salesCell.exists) {
            return true
        }
        else
        {
            return false
        }
    }
    
    func doLogout() -> Self {
        waitFor(element: logoutCell, status: .Exists)
        logoutCell.tap()
        logoutAlert.buttons["Iya"].tap()
        return self
    }
}


