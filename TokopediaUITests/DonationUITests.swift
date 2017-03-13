//
//  DonationUITests.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

class DonationUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testShowDonationPopUp(){
        let app = XCUIApplication()
        app.tabBars.buttons["Keranjang"].tap()
        
        let table = app.tables.containing(.cell, identifier:"donationCell").element
        table.swipeUp()
        let keranjangButton = XCUIApplication().tabBars.buttons["Keranjang"]
        keranjangButton.tap()
        
        let iconInfoGreySmallButton = app.tables.buttons["icon info grey small"]
        iconInfoGreySmallButton.tap()
        
        let exists = NSPredicate(format: "exists == 1")
        
        let cancelButton = app.otherElements.containing(.button, identifier:"icon cancel").children(matching: .image).element
        let title = app.staticTexts["Berbagi untuk Sesama, Dimulai dari Tokopedia"]
        let description = app.staticTexts["Donasi yang terkumpul selama Desember 2016-Maret 2017 akan disalurkan oleh Lembaga Kemanusiaan Nasional PKPU untuk merenovasi sekolah di daerah Cilincing."]
        expectation(for: exists, evaluatedWith: cancelButton, handler: nil)
        expectation(for: exists, evaluatedWith: title, handler: nil)
        expectation(for: exists, evaluatedWith: description, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
        cancelButton.tap()
        
    }
    
    func testCheckoutWithDonation(){
        let app = XCUIApplication()
        app.tabBars.buttons["Keranjang"].tap()
        
        let table = app.tables.containing(.cell, identifier:"donationCell").element
        table.swipeUp()
        
        XCUIApplication().tables.otherElements["donationCheckBox"].tap()
        
        let pilihMetodePembayaranButton = app.tables.buttons["Pilih Metode Pembayaran"]
        pilihMetodePembayaranButton.tap()
        
        let detailTransaction = app.staticTexts["Detail Transaksi"]
        waitForElementToAppear(detailTransaction)
        detailTransaction.tap()
        
        let donationText = app.staticTexts["Partisipasi Donasi di Tokopedia"]
        waitForElementToAppear(donationText)
    }
}
