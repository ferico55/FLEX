//
//  SearchPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class SearchPage : Page, TokopediaTabBar, SearchBar {
    
   let searchButton = app.keyboards.buttons["Search"]
    
    func searchProduct(_ keyword: String) -> SearchResultProductPage {
        searchTextField.typeText(keyword)
        searchButton.tap()
        return SearchResultProductPage()
    }
    
    func searchCatalog(_ keyword: String) -> SearchResultCatalogPage
    {
        searchTextField.typeText(keyword)
        searchButton.tap()
        return SearchResultCatalogPage()
    }
    
    
    func searchShop(_ keyword: String) -> SearchResultShopPage
    {
        searchTextField.typeText(keyword)
        searchButton.tap()
        return SearchResultShopPage()
    }
    
    func searchPopularSearch(_ keyword: String) -> SearchResultPopularSearch
    {
        searchTextField.typeText(keyword)
        return SearchResultPopularSearch()
    }

    
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
    let productCell = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    
    func sorting ()
    {
        sort.tap()
        waitFor(element: filterSortPage, status: .Exists)
        doneButton.tap()
        waitFor(element: result, status: .Exists)
        XCTAssert(result.exists)
    }
    
    func filtering ()
    {
        filter.tap()
        //waitFor(element: filterSortPage, status: .Exists)
        //doneButton.tap()
        SearchPage.app/*@START_MENU_TOKEN@*/.otherElements["Terapkan"]/*[[".otherElements.matching(identifier: \"Kategori Harga Minimum Rp 100 Harga Maksimum Rp 95.979.500 Harga Grosir Cashback Brand Warna Lokasi Dukungan Pengiriman Kondisi Toko Rating #KreasiLokal Free Return Pre Order Terapkan\").otherElements[\"Terapkan\"]",".otherElements[\"Terapkan\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        waitFor(element: result, status: .Exists)
        XCTAssert(result.exists)
    }
    
    func changeGrid()
    {
        gridButton.tap()
        
        let firstButton = gridView.label
        let firstView = productCell.label
        
        XCTAssertTrue(firstButton == firstView)
        
        gridButton.tap()
        
        let secondButton = gridView.label
        let secondView = productCell.label
        
        XCTAssertTrue(secondButton == secondView)
        
        let thirdButton = gridView.label
        let thirdView = productCell.label
        
        XCTAssertTrue(thirdButton == thirdView)
    }
    
    func sharing ()
    {
        share.tap()
    }

    
}

class SearchResultProductPage : SearchPage {
    
    let productResult = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    let productTab = app.buttons["Produk"]
    
    func clickProduct() {
        waitFor(element: productResult, status: .Exists)
        productResult.tap()
    }

}

class SearchResultCatalogPage : SearchPage
{
    let productTab = app.buttons["Produk"]
    let catalogTab = app.buttons["Katalog"]
    
    let catalogResult = app.collectionViews["productCellCollection"].children(matching: .cell).element(boundBy: 0)
    let catalogShopList = app.buttons["Lihat Daftar Toko"]
    let buyProductOnCatalog = app.tables["ShopResultTable"].children(matching: .cell).children(matching: .button).element(boundBy: 0)

    func clickCatalog()
    {
        waitFor(element: productTab, status: .Exists)
        catalogTab.tap()
    }

}

class SearchResultShopPage : SearchPage
{
    let productTab = app.buttons["Produk"]
    let shopTab = app.buttons["Toko"]
    let shopResultTable = app.tables["shopResultTable"]
    let shopResultCell = app.tables["shopResultTable"].children(matching: .cell).element(boundBy: 0)
    
    func clickShop()
    {
        waitFor(element: productTab, status: .Exists)
        shopTab.tap()
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

