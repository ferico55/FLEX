//
//  MyShopPage.swift
//  Tokopedia
//
//  Created by Alwan M on 11/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class MyShopPage : MorePage {
    
    let app = XCUIApplication()
    
    let iconShopInfo = app.navigationBars.buttons["icon shop info"]
    let shopSettingButton = app.scrollViews.otherElements.buttons["Atur Toko"]
    let etalaseTabButton = app.tables.staticTexts["Etalase"]
    let produkTabButton = app.tables.staticTexts["Produk"]
    let lokasiTabButton = app.tables.staticTexts["Lokasi"]
    let catatanTabButton = app.tables.staticTexts["Catatan"]
    let pengirimanNavBar = app.navigationBars["Pengiriman"]
    let pembayaranNavBar = app.navigationBars["Pembayaran"]
    let provinceField = app.tables.staticTexts["Kode Pos"]
    let pengirimanTabButton = app.tables.staticTexts["Pengiriman"]
    let pembayaranTabButton = app.tables.staticTexts["Pembayaran"]
    
    func goToShopInfo(){
        waitFor(element: iconShopInfo, status: .Exists)
        iconShopInfo.tap()
    }
    
    func goToShopSetting(){
        waitFor(element: shopSettingButton, status: .Exists)
        shopSettingButton.tap()
    }
    
    func goToEtalaseTab(){
        waitFor(element: etalaseTabButton, status: .Exists)
        etalaseTabButton.tap()
    }
    
    func goToProdukTab(){
        waitFor(element: produkTabButton, status: .Exists)
        produkTabButton.tap()
    }
    
    func goToLokasiTab(){
        waitFor(element: lokasiTabButton, status: .Exists)
        lokasiTabButton.tap()
    }
    
    func goToCatatanTab(){
        waitFor(element: catatanTabButton, status: .Exists)
        catatanTabButton.tap()
    }
    
    func goToPengirimanTab(){
        waitFor(element: pengirimanTabButton, status: .Exists)
        pengirimanTabButton.tap()
    }
    
    func goToPembayaranTab(){
        waitFor(element: pembayaranTabButton, status: .Exists)
        pembayaranTabButton.tap()
    }
    
    
}
