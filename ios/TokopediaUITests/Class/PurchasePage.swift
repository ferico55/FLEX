//
//  PurchasePage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 19/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class PurchasePage : MorePage {

    let purchaseStatus = app.tables.cells.element(boundBy: 0)
    let orderStatus = app.tables.cells.element(boundBy: 1)
    let orderConfirm = app.tables.cells.element(boundBy: 2)
    let listTransaction = app.tables.cells.element(boundBy: 3)
    
    let purchaseStatusNotif = app.tables.cells.element(boundBy: 0).children(matching: .staticText).element(boundBy: 1)
    let orderStatusNotif = app.tables.cells.element(boundBy: 1).children(matching: .staticText).element(boundBy: 1)
    let orderConfirmNotif = app.tables.cells.element(boundBy: 2).children(matching: .staticText).element(boundBy: 1)
    let listTransactionNotif = app.tables.cells.element(boundBy: 3).children(matching: .staticText).element(boundBy: 1)
    
    func goToPurchaseStatus() -> PurchaseStatus
    {
        waitFor(element: purchaseStatus, status: .Exists)
        purchaseStatus.tap()
        return PurchaseStatus()
    }
    
    func goToOrderStatus()
    {
        waitFor(element: orderStatus, status: .Exists)
        orderStatus.tap()
    }
    
    func goToOrderConfirm()
    {
        waitFor(element: orderConfirm, status: .Exists)
        orderConfirm.tap()
    }
    
    func goToListTransaction()
    {
        waitFor(element: listTransaction, status: .Exists)
        listTransaction.tap()
    }
    
    func isHavePurchaseStatus() -> Bool {
        
        if purchaseStatusNotif.label == "0"
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func backToMore() {
        back.tap()
    }
    
}

class PurchaseStatus : PurchasePage {
    
    let purchaseStatusNavbar = app.navigationBars["Status Pembayaran"]
    let bankAccount = app.tables.cells.staticTexts["Nomor Rekening Tokopedia"]
    let elipse = app.tables.buttons["elipseButton"]
    let cancelPayment = app.staticTexts["Batalkan Transaksi"]
    let changePayment = app.staticTexts["Ubah pesanan"]
    let cancelPaymentYes = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Ya"]
    let cancelPaymentNo = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Tidak"]
    let destinationBank = app.staticTexts["Rekening Tujuan"]
    let bankAccountName = app.staticTexts["Nama Pemilik Kartu"]
    let accountNumber = app.staticTexts["Nomor Rekening"]
    let note = app.staticTexts["Catatan (Optional)"]
    let saveButton = app.buttons["Simpan"]
    
    func isSuccess() {
        XCTAssert(purchaseStatusNavbar.exists)
    }
    
    func goToBankAccount(account : String) {
        let bankAccountCell = Page.app.tables.cells.staticTexts[account]
        waitFor(element: bankAccount, status: .Exists)
        bankAccount.tap()
        bankAccountCell.tap()
        XCTAssert(Page.app.navigationBars[account].exists)
    }
    
    func cancelTransaction() {
        elipse.tap()
        cancelPayment.tap()
        cancelPaymentYes.tap()
    }
    
    func changeTransaction() {
        elipse.tap()
        changePayment.tap()
        saveButton.tap()
    }
}
