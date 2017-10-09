//
//  CategoryIntermediaryPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class Intermediary : HomePage {
    
    var homepage = HomePage()
    var hotlist = HotlistPage()
    
    let intermediaryScrollView =  app.scrollViews["intermediaryScrollView"]
    let intermediaryBanner = app.otherElements["intermediaryBanner"]
    let intermediarySubcategory = app.otherElements["intermediarySubcategory"]
    let subcategoryCell = app.images.containing(.image, identifier:"subcategoryCell").element(boundBy: 0)
    
    let productCuratedCell = app.otherElements["productCuratedCell"].children(matching: .cell).element(boundBy: 0)
    let horizontalHotlist = app.otherElements["horizontalHotlist"]
    let squareHotlist = app.otherElements.containing(.other, identifier: "squareHotlist").element(boundBy: 0)
    let verticalHotlist = app.otherElements.containing(.other, identifier: "verticalHotlist").element(boundBy: 0)
    
    let intermediaryOfficialStoreCell = app.otherElements.containing(.other, identifier: "officialStoreView").element(boundBy: 0)
    
    let intermediaryVideo = app.otherElements["intermediaryVideo"]
    let seeAllCategory = app.buttons["seeAllCategory"]
    
    let expandSubcategory = app.buttons["expandSubcategory"]
    let hideSubcategory = app.buttons["hideSubcategory"]
    
    func swipeIntermediary() {
        waitFor(element: intermediaryScrollView, status: .Exists)
        intermediaryScrollView.swipeUp()
        intermediaryScrollView.swipeUp()
        intermediaryScrollView.swipeUp()
        intermediaryScrollView.swipeDown()
        intermediaryScrollView.swipeDown()
        intermediaryScrollView.swipeDown()
    }
    
    override func swipeBanner() {
        waitFor(element: intermediaryBanner, status: .Exists)
        intermediaryBanner.swipeLeft()
        intermediaryBanner.swipeLeft()
        intermediaryBanner.swipeLeft()
    }
    
    func clickSubcategory() {
        waitFor(element: subcategoryCell, status: .Exists)
        subcategoryCell.tap()
    }
    
    func clickCuratedProduct() {
        waitFor(element: productCuratedCell, status: .Exists)
        productCuratedCell.tap()
    }
    
    func clickHorizontalHotlist() {
        waitFor(element: horizontalHotlist, status: .Exists)
        horizontalHotlist.tap()
    }
    
    func clickSquareHotlist() {
        waitFor(element: squareHotlist, status: .Exists)
        squareHotlist.tap()
    }
    
    func clickVerticalHotlist() {
        waitFor(element: verticalHotlist, status: .Exists)
        verticalHotlist.tap()
    }
    
    func clickIntermediaryOfficialStore() {
        waitFor(element: intermediaryOfficialStoreCell, status: .Exists)
        intermediaryOfficialStoreCell.tap()
    }
    
    func clickExpandSubcategory() {
        waitFor(element: subcategoryCell, status: .Exists)
        expandSubcategory.tap()
    }
    
    func clickHideSubcategory() {
        waitFor(element: subcategoryCell, status: .Exists)
        hideSubcategory.tap()
    }
    
    func clickVideo() {
        waitFor(element: intermediaryVideo, status: .Exists)
        intermediaryVideo.tap()
    }
    
    func clickSeeAllCategory() {
        waitFor(element: seeAllCategory, status: .Exists)
        seeAllCategory.tap()
    }
    
}
