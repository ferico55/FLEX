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
    
    let searchButton = app.keyboards.buttons["Search"]
    let productTab = app.buttons["Produk"]
    let catalogTab = app.buttons["Katalog"]
    let shopTab = app.buttons["Toko"]
    let productCell = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)

    func searchProduct(_ keyword: String) -> SearchResultProductPage {
        searchTextField.typeText(keyword)
        searchButton.tap()
        return SearchResultProductPage()
    }
    
    func searchCatalog(_ keyword: String) -> SearchResultCatalogPage
    {
        searchTextField.typeText(keyword)
        searchButton.tap()
        if waitFor(element: catalogTab, status: .Exists) == .timedOut {
            //handle when timeout
            return SearchResultCatalogPage()
        }
        else
        {
            catalogTab.tap()
            return SearchResultCatalogPage()
        }
    }
    
    
    func searchShop(_ keyword: String) -> SearchResultShopPage
    {
        searchTextField.typeText(keyword)
        searchButton.tap()
        waitFor(element: shopTab, status: .Exists)
        shopTab.tap()
        return SearchResultShopPage()
    }
    
    func searchPopularSearch(_ keyword: String) -> SearchResultPopularSearch
    {
        searchTextField.typeText(keyword)
        return SearchResultPopularSearch()
    }

    
}


class SearchResultProductPage : SearchPage {
    func clickProduct() -> ProductDetail {
        waitFor(element: productCell, status: .Exists)
        productCell.tap()
        return ProductDetail()
    }

}

class SearchResultCatalogPage : SearchPage {
    let catalogShopList = app.buttons["Lihat Daftar Toko"]
    let buyProductOnCatalog = app.buttons.matching(identifier: "buyButton").element(boundBy: 0)

    func clickCatalog() -> Self {
        if waitFor(element: productCell, status: .Exists) == .timedOut {
            //handle when timeout
            return self
        }
        else
        {
            productCell.tap()
            return self
        }
    }

    func buyCatalog() -> ProductDetail {
        if waitFor(element: catalogShopList, status: .Exists) == .timedOut {
            //handle when timeout
            return ProductDetail()
        }
        else
        {
            catalogShopList.tap()
            waitFor(element: buyProductOnCatalog, status: .Exists)
            buyProductOnCatalog.tap()
            return ProductDetail()
        }
    }
    
}

class SearchResultShopPage : SearchPage
{
    let shopResultTable = app.tables["shopResultTable"]
    let shopResultCell = app.tables["shopResultTable"].children(matching: .cell).element(boundBy: 0)

    func clickShop()
    {
        shopResultCell.tap()
    }
}

class SearchResultPopularSearch: SearchPage
{
    let popularSearch = app.collectionViews.children(matching: .cell)
    let rowsatu = app.collectionViews["searchView"]
    
//    func clickPopularSearch()
//    {
//        //waitFor(element: productTab, status: .Exists)
//        if row > 5
//        {
//            popularSearch.element(boundBy: 6).tap()
//        } else
//            
//        {
//            popularSearch.element(boundBy: 1).tap()
//        }
//    }
}

class bottomBar : SearchPage
{
    let sort = app.staticTexts["Urutkan"]
    let filter = app.staticTexts["Filter"]
    let share = app.buttons["Bagi"]
    let filterSortPage = app.tables["filterSortPage"]
    let doneButton = app.buttons["Selesai"]
    let gridButton = app.buttons["Tampilan"]
    let gridView = app.buttons["gridButton"]
    let copy = app.otherElements["Copy"]
    let result = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    //let productCell = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    
    //    func sorting ()
    //    {
    //        sort.tap()
    //        waitFor(element: filterSortPage, status: .Exists)
    //        doneButton.tap()
    //        waitFor(element: result, status: .Exists)
    //        XCTAssert(result.exists)
    //    }
    //
    //    func filtering ()
    //    {
    //        filter.tap()
    //        //waitFor(element: filterSortPage, status: .Exists)
    //        //doneButton.tap()
    //        SearchPage.app/*@START_MENU_TOKEN@*/.otherElements["Terapkan"]/*[[".otherElements.matching(identifier: \"Kategori Harga Minimum Rp 100 Harga Maksimum Rp 95.979.500 Harga Grosir Cashback Brand Warna Lokasi Dukungan Pengiriman Kondisi Toko Rating #KreasiLokal Free Return Pre Order Terapkan\").otherElements[\"Terapkan\"]",".otherElements[\"Terapkan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
    //        waitFor(element: result, status: .Exists)
    //        XCTAssert(result.exists)
    //    }
    //
    //    func changeGrid()
    //    {
    //        gridButton.tap()
    //
    //        let firstButton = gridView.label
    //        let firstView = productCell.label
    //
    //        XCTAssertTrue(firstButton == firstView)
    //
    //        gridButton.tap()
    //
    //        let secondButton = gridView.label
    //        let secondView = productCell.label
    //
    //        XCTAssertTrue(secondButton == secondView)
    //
    //        let thirdButton = gridView.label
    //        let thirdView = productCell.label
    //
    //        XCTAssertTrue(thirdButton == thirdView)
    //    }
    //
    //    func sharing ()
    //    {
    //        share.tap()
    //    }
    
    
}


