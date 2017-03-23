//
//  DonationTests.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import XCTest

@testable import Tokopedia

class DonationTests: XCTestCase {
    
    var donation:Donation!
    var mappingTest:RKMappingTest?
    var totalPayment = 0
    
    override func setUp() {
        super.setUp()
        
        totalPayment = 100
        
        RKTestFixture.setFixtureBundle(Bundle.main)
        let parsedJSON = RKTestFixture.parsedObject(withContentsOfFixture: "donation.json")
        mappingTest = RKMappingTest(mapping: Donation.mapping(), sourceObject: parsedJSON, destinationObject: donation)
        mappingTest?.performMapping()
        donation = mappingTest?.destinationObject as! Donation!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMappingOfName(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_name", destinationKeyPath: "name", value: "Top100"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Name hasn't set up")
    }
    
    func testMappingOfTitle(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_note_title", destinationKeyPath: "title", value: "TopDonasi100"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Title hasn't set up")
    }
    
    func testMappingOfPopUpTitle(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_popup_title", destinationKeyPath: "popUpTitle", value: "Berbagi untuk Sesama, Dimulai dari Tokopedia"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Pop Up title hasn't set up")
    }
    
    func testMappingOfInfo(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_note_info", destinationKeyPath: "info", value: "Donasi Rp 100"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Info hasn't set up")
    }
    
    func testMappingOfPopUpInfo(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_popup_info", destinationKeyPath: "popUpInfo", value: "Donasi yang terkumpul selama Desember 2016-Maret 2017 akan disalurkan oleh Lembaga Kemanusiaan Nasional PKPU untuk merenovasi sekolah di daerah Cilincing."))
        XCTAssertTrue((mappingTest?.evaluate)!, "Pop Up Info hasn't set up")
    }
    
    func testMappingOfValueIdr(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_value_idr", destinationKeyPath: "valueIdr", value: "Rp 100"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Value IDR hasn't set up")
    }
    
    func testMappingOfValue(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_value", destinationKeyPath: "value", value: "100"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Value hasn't set up")
    }
    
    func testMappingOfPopUpImage(){
        mappingTest?.addExpectation(RKPropertyMappingTestExpectation.init(sourceKeyPath: "donation_popup_image", destinationKeyPath: "popUpImage", value: "https://ecs7.tokopedia.net/img/donasi/top_donasi.png"))
        XCTAssertTrue((mappingTest?.evaluate)!, "Pop up image hasn't set up")
    }
    
    func testSelectDonation() {
        donation.isSelected = true
        
        let total = totalPayment + Int(donation.usedDonationValue)!
        
        XCTAssertTrue(total == 200)
    }
    
    func testUnselectDonation() {
        donation.isSelected = false
        
        let total = totalPayment + Int(donation.usedDonationValue)!
        
        XCTAssertTrue(total == 100)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
