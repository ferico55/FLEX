//
//  Page.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 10/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class UITest{
    static let sharedInstance = UITest()
    var testCase: XCTestCase!
}

class Page{
    static let app: XCUIApplication = {
        let app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        return app
    }()
    
    let back = app.buttons["Back"]
    let cancel = app.buttons["Cancel"]
    let done = app.buttons["Selesai"]
    let save = app.buttons["Simpan"]
    let backWebView = app.buttons["icon arrow white"]
}
