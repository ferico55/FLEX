//
//  ShopInfoPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ShopInfoPage : MyShopPage {
    
    let myshop = MyShopPage()
    
    let offilneStore = app.tables.otherElements.buttons["offlineStore"]
    let numOfWhoFavMyShop = app.tables.buttons["numOfWhoFavMyShop"]
    let numOfItemSold = app.tables.buttons["itemSold"]
    let detailStatistic = app.tables.buttons["seeStatDetail"]
    let ownerName = app.tables.staticTexts["shopOwner"]
    let editSloganTextView = app.textViews.matching(identifier: "editShopTextView").element(boundBy: 0)
    let simpanButtonfromEdit = app.navigationBars["Informasi"].buttons["Simpan"]
    let editDescTextView = app.textViews.matching(identifier: "editShopTextView").element(boundBy: 1)
    let shopStatusBuka = app.tables.staticTexts["Buka"]
    let shopStatusTutup = app.tables.staticTexts["Tutup"]
    let setCloseShopButton = app.scrollViews.otherElements.buttons["Atur Jadwal Tutup"]
    let closeNowToggle = app.scrollViews.otherElements.switches["0"]
    let chooseDateUntilButton = app.scrollViews.otherElements.buttons["dateSampaiDengan"]
    let chooseDateStartFrom = app.scrollViews.otherElements.buttons["dateMulaiDari"]
    let closeNotesTextView = app.scrollViews.textViews["closedNote"]
    let chooseDatePicker = app.buttons["Pilih"]
    let cancelCloseShopButton = app.scrollViews.otherElements.buttons["Batal"]
    let openShopButton = app.scrollViews.otherElements.buttons["Buka Toko"]
    let setEditCloseShopButton = app.scrollViews.otherElements.buttons[" Ubah"]
    let aboutGM = app.tables.buttons["Tentang Gold Merchant"]
    let extendGM = app.tables/*@START_MENU_TOKEN@*/.buttons["Perpanjang Keanggotaan"]/*[[".cells.buttons[\"Perpanjang Keanggotaan\"]",".buttons[\"Perpanjang Keanggotaan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
    let shopInfoNavBar = app.navigationBars["Informasi Toko"]
    let ubahShopInfoButton = app.navigationBars["Informasi Toko"].buttons["Ubah"]
    let whoFavMyShopNavBar = app.navigationBars["Yang Memfavoritkan"]
    let detailStatisticNavBar = app.navigationBars["Statistik"]
    let profilePageNavBar = app.navigationBars["UserContainerView"]
    let backButtonfromEdit = app.navigationBars["Informasi"].buttons["Back"]
    let shopPageNavBar = app.navigationBars["Tokopedia.ShopView"]
    let aboutGMNavBar = app.navigationBars["Gold Merchant"]
    let shopStatusNavBar = app.navigationBars["Status Toko"]
    let deleteCloseShopScheduled = app.otherElements.buttons["hapusButton"]
    let arrowDown = app.tables.otherElements.buttons["arrowDown"]
    
    
//view shop info
    func seeWhoFavMyShop(){
        waitFor(element: numOfWhoFavMyShop, status: .Exists)
        numOfWhoFavMyShop.tap()
    }
    
    func seeDetailStat(){
        waitFor(element: detailStatistic, status: .Exists)
        detailStatistic.tap()
    }
    
    func seeOfflineStore(){
        waitFor(element: offilneStore, status: .Exists)
        offilneStore.tap()
    }
    
    func goToShopOwnerPage(){
        waitFor(element: ownerName, status: .Exists)
        ownerName.tap()
    }
    
//edit shop info
    func changeShopTagline(){
        waitFor(element: editSloganTextView, status: .Exists)
        editSloganTextView.tap()
        editSloganTextView.typeText("slogan baru ")
        simpanButtonfromEdit.tap()
    }
    
    func changeShopDescription(){
        waitFor(element: editDescTextView, status: .Exists)
        editDescTextView.tap()
        editDescTextView.typeText("deskripsi baru ")
        simpanButtonfromEdit.tap()
    }
    
    func seeShopStatus(){
        if shopStatusBuka.exists {
            shopStatusBuka.tap()
        }else{
            shopStatusTutup.tap()
        }
    }
    
    func isShopOpen(){
        waitFor(element: shopStatusBuka, status: .Exists)
        XCTAssert(shopStatusBuka.exists)
    }
    
    func isShopClosed(){
        waitFor(element: shopStatusTutup, status: .Exists)
        XCTAssert(shopStatusTutup.exists)
    }
    
    func setCloseShopNow(){
        waitFor(element: setCloseShopButton, status: .Exists)
        setCloseShopButton.tap()
        closeNowToggle.tap()
        chooseDateUntilButton.tap()
        chooseDatePicker.tap()
        closeNotesTextView.tap()
        closeNotesTextView.typeText("Ramadhan Tiba")
        setCloseShopButton.tap()
    }
    
    func setCloseShopScheduled(){
        waitFor(element: setCloseShopButton, status: .Exists)
        setCloseShopButton.tap()
        chooseDateStartFrom.tap()
        chooseDatePicker.tap()
        chooseDateUntilButton.tap()
        chooseDatePicker.tap()
        closeNotesTextView.tap()
        closeNotesTextView.typeText("Ramadhan Tiba")
        setCloseShopButton.tap()
    }
    
    func setCancelCloseShopNow(){
        waitFor(element: setCloseShopButton, status: .Exists)
        setCloseShopButton.tap()
        closeNowToggle.tap()
        chooseDateUntilButton.tap()
        chooseDatePicker.tap()
        closeNotesTextView.tap()
        closeNotesTextView.typeText("Ramadhan Tiba")
        cancelCloseShopButton.tap()
    }
    
    func setCancelCloseShopScheduled(){
        waitFor(element: setCloseShopButton, status: .Exists)
        setCloseShopButton.tap()
        chooseDateStartFrom.tap()
        chooseDatePicker.tap()
        chooseDateUntilButton.tap()
        chooseDatePicker.tap()
        closeNotesTextView.tap()
        closeNotesTextView.typeText("Ramadhan Tiba")
        cancelCloseShopButton.tap()
    }
    
    func openShop(){
        waitFor(element: openShopButton, status: .Exists)
        openShopButton.tap()
    }
    
    func extendCloseShop(){
        waitFor(element: setEditCloseShopButton, status: .Exists)
        setEditCloseShopButton.tap()
        chooseDateUntilButton.tap()
        chooseDatePicker.tap()
        closeNotesTextView.tap()
        closeNotesTextView.typeText("EDITED")
        setCloseShopButton.tap()
    }
    
    func seeAboutGM(){
        waitFor(element: aboutGM, status: .Exists)
        aboutGM.tap()
    }
    
    func goExtendGM() {
        waitFor(element: extendGM, status: .Exists)
        extendGM.tap()
    }
}
