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
    func goSearchPage() -> SearchPage
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
    
    var searchTextField: XCUIElement
    {
        return Page.app.navigationBars["Home"].searchFields["Cari Produk atau Toko"]
    }
    
    @discardableResult
    func goHomePage() -> HomePage
    {
        waitFor(element: homeTabBar, status: .Exists)
        homeTabBar.tap()
        return HomePage()
    }
    
    @discardableResult
    func goHotlistPage() -> HotlistPage
    {
        waitFor(element: hotlistTabBar, status: .Exists)
        hotlistTabBar.tap()
        return HotlistPage()
    }
    
    @discardableResult
    func goWishlistPage() -> WishlistPage
    {
        waitFor(element: wishlistTabBar, status: .Exists)
        wishlistTabBar.tap()
        return WishlistPage()
    }
    
    @discardableResult
    func goCartPage() -> CartPage
    {
        waitFor(element: cartTabBar, status: .Exists)
        cartTabBar.tap()
        return CartPage()
    }
    
    @discardableResult
    func goLoginPage() -> LoginPage
    {
        waitFor(element: loginTabBar, status: .Exists)
        loginTabBar.tap()
        return LoginPage()
    }
    
    @discardableResult
    func goMorePage() -> MorePage
    {
        waitFor(element: moreTabBar, status: .Exists)
        moreTabBar.tap()
        return MorePage()
    }
    
    @discardableResult
    func goSearchPage() -> SearchPage
    {
        waitFor(element: searchTextField, status: .Exists)
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

func waitFor(element: XCUIElement, status: UIStatus, timeout: TimeInterval = 30) -> XCTWaiterResult
{
    let predicate = UITest.sharedInstance.testCase.expectation(for: NSPredicate(format: status.rawValue), evaluatedWith: element, handler: nil)
    let result = XCTWaiter().wait(for: [predicate], timeout: timeout)
    return result
}
