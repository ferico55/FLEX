//
//  ListBankTests.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest
import AFNetworking
import UIKit
import RestKit

@testable import Tokopedia

class BankCellTests: XCTestCase {
    
    private var cell: BankCell?
    
    override func setUp() {
        super.setUp()
        let bank : Bank =
                Bank(name:"Bank BCA", picture:"https://ecs1.tokopedia.com/img/icon-bca.png", accountBanks:
                    [
                    DetailBank(number:"178 303 7878", branch:"BCA Permata Hijau", picture:"https://ecs1.tokopedia.com/img/icon-bca.png", accountName:"a/n PT. Tokopedia")
                    ]
                )
        
        cell = BankCell(bank: bank)

    }
    
    override func tearDown() {
        cell = nil
        super.tearDown()
    }

    func testCell() {
        XCTAssertNotNil(cell)
    }
}

class ListBankTests: XCTestCase {
    
    var navigation: UINavigationController!
    var controller: ListBankViewController!
    
    override func setUp() {
        super.setUp()
        controller = ListBankViewController()
        controller.viewDidLoad()
        
        navigation = UINavigationController(rootViewController: controller)
    }
    
    override func tearDown() {
        controller = nil
        navigation = nil
        super.tearDown()
    }
    
    func testControllerOutlet() {
        XCTAssertNotNil(controller)
    }
    
    func testTitleController() {
        XCTAssertTrue(controller.title == "Rekening Tokopedia")
    }
}
