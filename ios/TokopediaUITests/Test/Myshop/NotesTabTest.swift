//
//  NotesTabTest.swift
//  Tokopedia
//
//  Created by Alwan M on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class NotesTableTest: XCTestCase {
    
    var more = MorePage()
    var login = LoginPage()
    var notes = NotesTabPage()
    var myshop = MyShopPage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "alwan.ubaidillah+007@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        if more.isBuyer() {
            login.swithAccountSeller()
        }
        more.goToMyShop()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testTapCatatanTab(){
        myshop.goToShopSetting()
        myshop.goToCatatanTab()
        waitFor(element: notes.catatanNavBar, status: .Exists)
        XCTAssert(notes.catatanNavBar.exists)
    }
    
    func testAddCatatan(){
        myshop.goToShopSetting()
        myshop.goToCatatanTab()
        let listNoteCount = notes.app.tables.cells.count
        if (listNoteCount < 3){
            notes.addCatatan()
            XCTAssertTrue(notes.app.tables.cells.count == listNoteCount + 1 )
            sleep(2)
        }else{
            notes.deleteNote()
            let listnoteNew = notes.app.tables.cells.count
            notes.addCatatan()
            XCTAssertTrue(notes.app.tables.cells.count == listnoteNew + 1 )
            sleep(2)
        }
    }
    
    func testChangeNoteBySwipe(){
        myshop.goToShopSetting()
        myshop.goToCatatanTab()
        let listNoteCount = notes.app.tables.cells.count
        if (listNoteCount < 1){
            notes.addCatatan()
        }
        notes.changeNoteSwipe()
        waitFor(element: notes.catatanNavBar, status: .Exists)
        XCTAssert(notes.catatanNavBar.exists)
        sleep(2)
    }
    
    func testChangeNoteFromDetail(){
        myshop.goToShopSetting()
        myshop.goToCatatanTab()
        let listNoteCount = notes.app.tables.cells.count
        if (listNoteCount < 1){
            notes.addCatatan()
        }
        notes.changeNoteFromDetail()
        waitFor(element: notes.noteNameNavBar.buttons["Ubah"], status: .Exists)
        XCTAssert(notes.noteNameNavBar.exists)
        sleep(2)
    }
    
    func testDeleteNote(){
        myshop.goToShopSetting()
        myshop.goToCatatanTab()
        var listNoteCount = notes.app.tables.cells.count
        if (listNoteCount < 1){
            notes.addCatatan()
            listNoteCount = listNoteCount + 1
        }
        notes.deleteNote()
        XCTAssertTrue(notes.app.tables.cells.count == listNoteCount - 1)
        sleep(2)
    }
}
