//
//  WishlistPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class WishlistPage : Page, TokopediaTabBar {
    
    
    let wishlistView = app.collectionViews["wishlistView"]
    let wishlistName = app.staticTexts.matching(identifier: "productName").element(boundBy: 0)
    let wishlistCount = app.collectionViews["wishlistView"].children(matching: .cell).matching(identifier: "wishlistCell").count
    let wishlistCell = app.collectionViews["wishlistView"].children(matching: .cell).matching(identifier: "wishlistCell").element(boundBy: 0)
    let wishlistSearchTextField =  app.collectionViews["wishlistView"].textFields["Cari wishlist kamu"]
    let wishlistSearchButton = app.keyboards.buttons["Search"]
    let resultCountLabel = app.staticTexts["resultCountLabel"]
    let seeAllWishlist = app.collectionViews["wishlistView"].scrollViews.otherElements.buttons["Lihat semua Wishlist"]
    let resetWishlistSearch = app.collectionViews["wishlistView"].buttons["Reset"]
    let wishlistTrashImage = app.images.matching(identifier: "deleteWishlist").element(boundBy: 0)
    let deleteButton = app.alerts["Hapus Wishlist"].buttons["Hapus"]
    let cancelButton = app.alerts["Hapus Wishlist"].buttons["Batal"]
    let noResultWishlist = app.otherElements["noResultView"]
    let startSearchProduct = app.collectionViews["wishlistView"].scrollViews.otherElements.buttons["Mulai cari produk"]
    let buyWishlist = app.collectionViews["wishlistView"].children(matching: .cell).matching(identifier: "wishlistCell").element(boundBy: 0).buttons["Beli"]
    
    
    func waitForPageLoaded(){
        waitFor(element: wishlistCell, status: .Exists)
    }
    
    func clickWishlistCell() -> ProductDetail {
        waitForPageLoaded()
        wishlistCell.tap()
        return ProductDetail()
    }
    
    func searchWishlist(_ keyword: String) {
        waitForPageLoaded()
        wishlistSearchTextField.tap()
        wishlistSearchTextField.typeText(keyword)
        wishlistSearchButton.tap()
    }
    
    func removeWishlist(_ action : String){
        waitForPageLoaded()
        wishlistTrashImage.tap()
        if (action == "yes"){
            deleteButton.tap()
        }
        else{
            cancelButton.tap()
        }
    }
}
