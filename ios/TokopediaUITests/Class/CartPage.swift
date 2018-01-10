//
//  CartPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class CartPage : Page, TokopediaTabBar {
    

    var login = LoginPage()
    var addToCart = AddToCartPage()
    
    let cartTab = app.tabBars.buttons["Keranjang"]
    let productName = app.staticTexts["productName"]
    let cartTable = app.tables["cartTableView"]
    let noResultView = app.scrollViews["noResultView"]
    let noLoginView = app.otherElements["noLoginView"]
    let webViews = app.webViews
    let processing = app.staticTexts["Processing"]

    let deleteInvoiceButton = app.buttons["icon cancel grey"]
    let editProductButton = app.buttons["editButton"]
    let edit = app.buttons["Edit"]
    let delete = app.buttons["Hapus"]
    let noteForSeller = app.tables.cells.textViews["noteForSeller"]
    let shippingDetail = app.tables.cells.staticTexts["Detail Pengiriman"]
    
    let partialOrder = app.tables.cells.staticTexts["Stock Tersedia Sebagian"]
    
    let dropshipper = app.switches["switch"]
    let dropshipName = app.textFields["Nama Pengirim"]
    let dropshipTelp = app.textFields["Nomor Telepon"]
    
    let promoButton = app.tables.cells.buttons["promoButton"]
    let promoField = app.textFields["promoTextField"]
    let promoOKButton = app.alerts["Kode Promo"].buttons["OK"]
    let promoCancelButton = app.alerts["Kode Promo"].buttons["Batal"]
    let promoAmount = app.staticTexts["promoAmount"]
    
    let donation = app.otherElements["donationCheckBox"]
    
    let subtotalCost = app.staticTexts["subtotalCost"]
    let insuranceCost = app.staticTexts["insuranceCost"]
    let shippingCost = app.staticTexts["shippingCost"]
    let totalCost = app.staticTexts["totalCost"]
    let grandTotal = app.staticTexts["grandTotal"]
    
    let checkoutButton = app.buttons["checkoutButton"]
    
    func waitPageLoaded() {
        if login.isLogout() {
            waitFor(element: noLoginView, status: .Exists)
        }
        else{
            if !userHaveCart() {
                waitFor(element: noResultView, status: .Exists)
            }
        }
    }
    
    func userHaveCart() -> Bool {
        if cartTab.value as! String == "" {
            return false
        }
        else
        {
            return true
        }
    }
    
    func deleteInvoice() -> DeleteInvoice {
        waitFor(element: deleteInvoiceButton, status: .Exists)
        deleteInvoiceButton.tap()
        return DeleteInvoice()
    }
    
    func deleteProduct() -> DeleteProduct {
        waitFor(element: editProductButton, status: .Exists)
        editProductButton.tap()
        delete.tap()
        return DeleteProduct()
    }
    
    func editProduct() -> EditProduct {
        waitFor(element: editProductButton, status: .Exists)
        editProductButton.tap()
        edit.tap()
        return EditProduct()
    }
    
    func editShipping() -> EditShipping {
        waitFor(element: shippingDetail, status: .Exists)
        shippingDetail.tap()
        return EditShipping()
    }
    
    func setPartialOrder() {
        partialOrder.tap()
    }
    
    func inputDropshipper() {
        waitFor(element: dropshipper, status: .Exists)
        dropshipper.tap()
        dropshipName.tap()
        dropshipName.typeText("Automate By UI")
        dropshipTelp.tap()
        dropshipTelp.typeText("089693339986")
    }
    
    func inputPromo() {
        promoButton.tap()
        promoField.tap()
        promoField.typeText("yoshuakeren")
        promoOKButton.tap()
    }
    
    func checkDonation() {
        donation.tap()
    }
    
    func checkoutCart() -> methodPayment {
        waitFor(element: checkoutButton, status: .Exists)
        checkoutButton.tap()
        return methodPayment()
    }

}

class DeleteInvoice : CartPage {

    let deleteInvoiceOK = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Ya"]
    let deleteInvoiceCancel = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Tidak"]
    
    func doDeleteInvoice() {
        waitFor(element: deleteInvoiceOK, status: .Exists)
        deleteInvoiceOK.tap()
        let cartRow = String(cartTable.cells.count)
        XCTAssertTrue(cartRow == "0")
    }
    
    func cancelDeleteInvoice() {
        waitFor(element: deleteInvoiceCancel, status: .Exists)
        let cartRowBefore = String(cartTable.cells.count)
        deleteInvoiceCancel.tap()
        let cartRowAfter = String(cartTable.cells.count)
        XCTAssertTrue(cartRowBefore == cartRowAfter)
    }
    
}

class DeleteProduct : CartPage {
    
    let deleteProductOK = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Ya"]
    let deleterProductCancel = app.alerts["Konfirmasi Pembatalan Transaksi"].buttons["Tidak"]
    
    func doDeleteProduct() {
        waitFor(element: deleteProductOK, status: .Exists)
        deleteProductOK.tap()
        let cartRow = String(cartTable.cells.count)
        XCTAssertTrue(cartRow == "0")
    }
    
    func cancelDeleteProduct() {
        waitFor(element: deleterProductCancel, status: .Exists)
        let cartRowBefore = String(cartTable.cells.count)
        deleterProductCancel.tap()
        let cartRowAfter = String(cartTable.cells.count)
        XCTAssertTrue(cartRowBefore == cartRowAfter)
    }
}

class EditProduct : CartPage {
    
    let productQuantity = app.textFields["productQuantity"]
    let plusQuantity = app.buttons["Increment"]
    let minQuantity = app.buttons["Decrement"]
    let noteForSellerDetail = app.textViews["noteForSeller"]
    
    func inputQuantity() {
        waitFor(element: productQuantity, status: .Exists)
        productQuantity.tap()
        Page.app.buttons["MMNumberKeyboardDeleteKey"].tap()
        productQuantity.typeText("2")
        save.tap()
        
    }
    
    func addQuantity() {
        waitFor(element: plusQuantity, status: .Exists)
        plusQuantity.tap()
        save.tap()
    }
    
    func deductQuantity() {
        waitFor(element: minQuantity, status: .Exists)
        minQuantity.tap()
        save.tap()
    }
    
    func inputNote() {
        waitFor(element: noteForSellerDetail, status: .Exists)
        noteForSellerDetail.tap()
        noteForSellerDetail.typeText("this is additional notes from cart")
        let note = noteForSellerDetail.value as! String
        save.tap()
        XCTAssertTrue(note == noteForSeller.value as! String)
    }

}


class EditShipping : CartPage {
    
    let address = app.tables.cells.staticTexts["addressDetail"]
    let courier = app.tables.cells.staticTexts["courierDetail"]
    let courierCell = app.tables.cells.staticTexts["TIKI"]
    let package = app.tables.cells.staticTexts["packageDetail"]
    let packageCell = app.tables.cells.staticTexts["Reguler"]
    let insuranceDetail = app.tables.cells.staticTexts["insuranceDetail"]
    let shippingDetailCost = app.tables.cells.staticTexts["shipping"]
    let insuranceDetailCost = app.tables.cells.staticTexts["insurance"]
    
    func changeAddress() {
        waitFor(element: address, status: .Exists)
        address.tap()
        done.tap()
        back.tap()
    }
    
    func changeCourier() {
        courier.tap()
        courierCell.tap()
        done.tap()
        waitFor(element: processing, status: .NotExists)
        let newShipping = Page.app.tables.cells.staticTexts["shipping"].value as! String
        back.tap()
        XCTAssertTrue(newShipping == shippingCost.value as! String)
    }
    
    func changePackage() {
        package.tap()
        packageCell.tap()
        done.tap()
        waitFor(element: processing, status: .NotExists)
        let newShipping = Page.app.tables.cells.staticTexts["shipping"].value as! String
        back.tap()
        XCTAssertTrue(newShipping == shippingCost.value as! String)
    }
    
}

class methodPayment : CartPage {
    
    let pay = app.webViews.otherElements["Payment"].staticTexts["Bayar"]
    
    func checkoutWith(with : String) {
        let method = Page.app.webViews.otherElements["Payment"].staticTexts[with]
        //let doneScrooge = Page.app.toolbars.buttons["Done"]
        //let checkOrder = Page.app.webViews.buttons["Cek Status Pemesanan"]
        let checkoutTokoCashSuccess = Page.app.webViews.staticTexts["Pembayaran Berhasil"]
        let checkoutSuccess = Page.app.webViews.staticTexts["Checkout Berhasil"]
        waitFor(element: method, status: .Exists)
        if(with == "TokoCash"){
            method.tap()
            waitFor(element: pay, status: .Exists)
            pay.tap()
            waitFor(element: pay, status: .NotExists)
            waitFor(element: checkoutTokoCashSuccess, status: .Exists)
            backWebView.tap()
        }
        else if(with == "Transfer Manual"){
            //let accountNumber  = Page.app.webViews.otherElements["Payment"].children(matching: .textField).element(boundBy: 0)
            //let accountName = Page.app.webViews.otherElements["Payment"].children(matching: .textField).element(boundBy: 1)
            method.tap()
            waitFor(element: pay, status: .Exists)
            pay.tap()
            waitFor(element: pay, status: .NotExists)
            waitFor(element: checkoutSuccess, status: .Exists)
            backWebView.tap()
        }
    }
}
