//
//  Ultility.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

// MARK: TokopediaTabBar
protocol TokopediaTabBar {
    func goHomePage() -> HomePage
    func goHotlistPage() -> HotlistPage
    func goWishlistPage() -> WishlistPage
    func goCartPage() -> CartPage
    func goLoginPage() -> LoginPage
    func goMorePage() -> MorePage
}

extension TokopediaTabBar {
    var homeTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Home"]
    }
    
    var hotlistTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Hot List"]
    }
    
    var wishlistTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Wishlist"]
    }
    
    var cartTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Keranjang"]
    }
    
    var loginTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Login"]
    }
    
    var moreTabBar: XCUIElement
    {
        return Page.app.tabBars.buttons["Lainnya"]
    }
    
    @discardableResult
    func goHomePage() -> HomePage
    {
        homeTabBar.tap()
        return HomePage()
    }
    
    @discardableResult
    func goHotlistPage() -> HotlistPage
    {
        hotlistTabBar.tap()
        return HotlistPage()
    }
    
    @discardableResult
    func goWishlistPage() -> WishlistPage
    {
        wishlistTabBar.tap()
        return WishlistPage()
    }
    
    @discardableResult
    func goCartPage() -> CartPage
    {
        cartTabBar.tap()
        return CartPage()
    }
    
    @discardableResult
    func goLoginPage() -> LoginPage
    {
        loginTabBar.tap()
        return LoginPage()
    }
    
    @discardableResult
    func goMorePage() -> MorePage
    {
        moreTabBar.tap()
        return MorePage()
    }
}

// MARK: SearchBar
protocol SearchBar {
    func goToSearchPage() -> SearchPage
}

extension SearchBar {
    fileprivate var searchTextField: XCUIElement
    {
        return Page.app.navigationBars["Home"].searchFields["Cari produk atau toko"]
    }
    
    func goToSearchPage() -> SearchPage
    {
        searchTextField.tap()
        return SearchPage()
    }
}

// MARK: Wait element
enum UIStatus: String
{
    case Exists = "exists == true"
    case NotExists = "exists == false"
}

func waitFor(element: XCUIElement, status: UIStatus, timeout: TimeInterval = 20)
{
    UITest.sharedInstance.testCase.expectation(for: NSPredicate(format: status.rawValue), evaluatedWith: element, handler: nil)
    UITest.sharedInstance.testCase.waitForExpectations(timeout: timeout, handler: nil)
}
