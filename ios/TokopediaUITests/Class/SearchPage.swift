//
//  SearchPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class SearchPage : Page, TokopediaTabBar {

    let searchTextField =  app.navigationBars["Home"].searchFields["Cari produk atau toko"]
    let searchButton = app.keyboards.buttons["Search"]
    
    func search(_ keyword: String) -> SearchResultPage {
        searchTextField.typeText(keyword)
        searchButton.tap()
        return SearchResultPage()
    }
}

class SearchResultPage : SearchPage {
    
    let searchResultProductCell = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    
    func clickProduct() {
        waitFor(element: searchResultProductCell, status: .Exists)
        searchResultProductCell.tap()
    }
}
