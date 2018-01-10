//
//  EtalaseTabPage.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class EtalaseTabPage : MyShopPage {
    let myshop = MyShopPage()
    let addEtalaseTextField = app.tables.textFields[" Tambah Etalase"]
    let addEtalaseButton = app.tables.buttons["Tambah"]
    let etalaselists = app.tables.staticTexts["New Etalase"]
    let etalaseCellDelete = app.tables.buttons["Hapus"]
    let etalaseName = app.tables.cells.element(boundBy: 0)
    let alertEditEtalase = app.alerts["Edit Etalase"].collectionViews.cells.children(matching: .textField).element.typeText("op")
    let okAlertEditEtalase = app.alerts["Edit Etalase"].buttons["OK"]
    let batalAlertEditEtalase = app.alerts["Edit Etalase"].buttons["Batal"]
    let shopEtalaseNavBar = app.navigationBars["Etalase"].buttons["Back"]
    
    
    //Etalase Tab
    
    
    func addNewEtalase(){
        waitFor(element: addEtalaseTextField, status: .Exists)
        addEtalaseTextField.tap()
        addEtalaseTextField.typeText("New Etalase")
        addEtalaseButton.tap()
    }
    
    func removeEtalase(){
        if etalaselists.exists{
            waitFor(element: etalaselists, status: .Exists)
            etalaselists.swipeLeft()
            etalaseCellDelete.tap()
        }else{
            app.tables.staticTexts["Etalase 1"].swipeLeft()
            etalaseCellDelete.tap()
        }
    }
    
    func renameEtalase(){
        waitFor(element: etalaseName, status: .Exists)
        etalaseName.tap()
        alertEditEtalase
        okAlertEditEtalase.tap()
    }
    
    func cancelRenameEtalase(){
        waitFor(element: etalaseName, status: .Exists)
        etalaseName.tap()
        alertEditEtalase
        batalAlertEditEtalase.tap()
    }

}
