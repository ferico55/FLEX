//
//  AddToCartPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class AddToCartPage : ProductDetail {

    var addAddress = AddAddress()
    
    let ATCNavigation = app.navigationBars["Beli"]
    let ATCTableView = app.tables["ATCTableView"]
    
    let shopName = app.staticTexts["shopName"]
    let productDescription = app.staticTexts["productDescription"]
    let processTime = app.staticTexts["processTime"]
    let preorder = app.buttons["preorderButton"]
    
    let productQuantity = app.textFields["productQuantity"]
    let plusQuantity = app.tables.cells.buttons["Increment"]
    let minQuantity = app.tables["ATCTableView"].cells.buttons["Decrement"]
    
    let noteForSeller = app.tables["ATCTableView"].textViews["noteForSeller"]

    let doneNavBar = app.navigationBars["Daftar Alamat"].buttons["Selesai"]
    let addressOption = app.staticTexts["addressOption"]
    let courierOption = app.staticTexts["courierOption"]
    let courierCell = app.tables.cells.staticTexts["JNE"]
    let packageOption = app.staticTexts["packageOption"]
    let packageCell = app.tables.cells.staticTexts["YES"]
    let insuranceOption = app.staticTexts["insuranceOption"]
    let productPrice = app.staticTexts["productPrice"]
    let courierPrice = app.staticTexts["courierPrice"]
    let totalPrice = app.staticTexts["totalPrice"]
    
    let ATCBuyButton = app.buttons["buyButton"]
    let purchaseButton = app.alerts["Produk berhasil dimasukkan ke Keranjang Belanja"].buttons["Bayar"]
    
    func addQuantity() {
        waitFor(element: plusQuantity, status: .Exists)
        plusQuantity.tap()
    }
    
    func deductQantity() {
        waitFor(element: minQuantity, status: .Exists)
        minQuantity.tap()
    }
    
    func inputQuantity() {
        waitFor(element: productQuantity, status: .Exists)
        productQuantity.tap()
        Page.app.buttons["MMNumberKeyboardDeleteKey"].tap()
        productQuantity.typeText("5")
    }
    
    func fillNoteForSeller() {
        waitFor(element: noteForSeller, status: .Exists)
        noteForSeller.tap()
        noteForSeller.typeText("Ini hanya catatan contoh yang digenerate machine")
    }
    
    func isHaveAddress() -> Bool {
        if(addressOption.label == "Tambah Alamat")
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func addNewAddress() {
        addressOption.tap()
        addAddress.fillAddress()
        XCTAssert(ATCNavigation.exists)
    }
    
    func chooseCourier() {
        courierOption.tap()
        courierCell.tap()
        done.tap()
    }
    
    func choosePackage() {
        packageOption.tap()
        packageCell.tap()
        done.tap()
    }
    
    func chooseInsurance() {
        waitFor(element: insuranceOption, status: .Exists)
        insuranceOption.tap()
    }
}
