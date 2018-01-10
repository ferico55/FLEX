//
//  ShopSettingPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ShopSettingPage : MyShopPage {
    
    let myshop = MyShopPage()
    
    let informasiTabButton = app.tables.staticTexts["Informasi"]
    let shopSettingNavBar = app.navigationBars["Pengaturan Toko"]
    let shopInfoEditNavBar = app.navigationBars["Informasi"]
    
    
    //Atur Toko
    
    
    func goToInformasiTab(){
        waitFor(element: informasiTabButton, status: .Exists)
        informasiTabButton.tap()
    }
}
