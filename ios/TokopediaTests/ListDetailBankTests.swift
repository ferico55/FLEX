//
//  ListDetailBankTests.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

@testable import Tokopedia

class BankDetailCellTests: XCTestCase {
    
    private var cell: BankDetailCell?
    
    override func setUp() {
        super.setUp()
        let bank : DetailBank = DetailBank(number:"178 303 7878", branch:"BCA Permata Hijau", picture:"https://ecs1.tokopedia.com/img/icon-bca.png", accountName:"a/n PT. Tokopedia")
        cell = BankDetailCell(bank: bank)
    }
    
    override func tearDown() {
        cell = nil
        super.tearDown()
    }
    
    func testCell() {
        XCTAssertNotNil(cell)
    }
}

class ListDetailBankTests: XCTestCase {
    
    var controller: ListDetailBankViewController!
    
    override func setUp() {
        super.setUp()
        let banks : [DetailBank] =
        [DetailBank(number:"178 303 7878", branch:"BCA Permata Hijau", picture:"https://ecs1.tokopedia.com/img/icon-bca.png", accountName:"a/n PT. Tokopedia")]
        controller = ListDetailBankViewController.init(listBank: banks, title:"Bank BCA")
        controller.viewDidLoad()
    }
    
    override func tearDown() {
        controller = nil
        super.tearDown()
    }
    
    func testControllerOutlet() {
        XCTAssertNotNil(controller)
    }
    
    func testTitleController() {
        XCTAssertTrue(controller.title == "Bank BCA")
    }
}
