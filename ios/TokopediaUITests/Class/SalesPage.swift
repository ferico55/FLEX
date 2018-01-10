//
//  SalesPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 24/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class SalesPage : MorePage {
    
    let itemReplacement = app.tables.cells.element(boundBy: 0)
    let newOrder = app.tables.cells.element(boundBy: 1)
    let shippingConfirm = app.tables.cells.element(boundBy: 2)
    let listTransaction = app.tables.cells.element(boundBy: 3)
    
    let itemReplacementNotif = app.tables.cells.element(boundBy: 0).children(matching: .staticText).element(boundBy: 1)
    let newOrderNotif = app.tables.cells.element(boundBy: 1).children(matching: .staticText).element(boundBy: 1)
    let shippingConfirmNotif = app.tables.cells.element(boundBy: 2).children(matching: .staticText).element(boundBy: 1)
    let listTransactionNotif = app.tables.cells.element(boundBy: 3).children(matching: .staticText).element(boundBy: 1)
    
    func goToItemReplacement()
    {
        waitFor(element: itemReplacement, status: .Exists)
        itemReplacement.tap()
        
    }
    
    func goToNewOrder() -> NewOrderPage
    {
        waitFor(element: newOrder, status: .Exists)
        newOrder.tap()
        return NewOrderPage()
    }
    
    func goToShippingConfirm()
    {
        waitFor(element: shippingConfirm, status: .Exists)
        shippingConfirm.tap()
    }
    
    func goToListTransaction()
    {
        waitFor(element: listTransaction, status: .Exists)
        listTransaction.tap()
    }
    
    func isHaveNewOrder() -> Bool {
        
        if newOrderNotif.label == "0"
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


class NewOrderPage : SalesPage {
    
    let newOrderCell = app.tables.cells["newOrderCell"]
    let invoiceNumber = app.tables.cells["newOrderCell"].staticTexts["invoiceNumber"]
    let remainingDays = app.tables.cells["newOrderCell"].staticTexts["remainingDays"]
    let automaticallyCancel = app.tables.cells["newOrderCell"].staticTexts["automaticallyCancel"]
    let userView = app.tables.cells["newOrderCell"].otherElements["userView"]
    let userName = app.tables.cells["newOrderCell"].staticTexts["userName"]
    let purchaseDate = app.tables.cells["newOrderCell"].staticTexts["purchaseDate"]
    let paymentAmount = app.tables.cells["newOrderCell"].staticTexts["paymentAmount"]
    let dueDate = app.tables.cells["newOrderCell"].staticTexts["dueDate"]
    let statusView = app.tables.cells["newOrderCell"].otherElements["statusView"]
    let priceView = app.tables.cells["newOrderCell"].otherElements["priceView"]
    let lastStatusLabel = app.tables.cells["newOrderCell"].staticTexts["lastStatusLabel"]
    let acceptOrderButton = app.tables.children(matching: .staticText).matching(identifier: "newOrderCell").element(boundBy: 0).buttons["Terima"]
    let askBuyerButton = app.tables.children(matching: .staticText).matching(identifier: "newOrderCell").element(boundBy: 0).buttons["Tanya Pembeli"]
    let cancelOrderButton = app.tables.children(matching: .staticText).matching(identifier: "newOrderCell").element(boundBy: 0).buttons["Tolak"]
    
    func acceptOrder() {
        let acceptOrderAlert = Page.app.alerts["Terima Pesanan"]
        let acceptOrderYes = acceptOrderAlert.buttons["Terima Pesanan"]
        let acceptOrderNo = acceptOrderAlert.buttons["Batal"]
        
        acceptOrderButton.tap()
        acceptOrderNo.tap()
        acceptOrderButton.tap()
        acceptOrderYes.tap()
    }
    
    func rejectOrderWith(_ method : String, reason : String)
    {
        cancelOrderButton.tap()
        let rejectReasonCell = Page.app.tables["rejectReasonTable"].staticTexts[method]
        rejectReasonCell.tap()
        let rejectOrderTextView = Page.app.textViews["rejectOrderTextView"]
        
        switch method {
        case "Permintaan Pembeli":
            rejectOrderTextView.tap()
            rejectOrderTextView.typeText(reason)
            done.tap()
            break
        default:
            break
        }
        
    }
    
    
}

