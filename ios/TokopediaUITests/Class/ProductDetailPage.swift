//
//  ProductDetailPage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/26/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class ProductDetail : Page, TokopediaTabBar {

    var page = Page()
    var homepage = HomePage()
    var hotlist = HotlistPage()
    
    let PDPView = app.otherElements["productDetailView"];
    let reviewButton = app.staticTexts["reviewButton"];
    let talkButton = app.images["icon_discussion_green"]
    let courierButton = app.images["icon_discussion_green"]
    let shareButton = app.buttons["icon share white"]
    let cartButton = app.buttons["icon cart white"]
    let moreButton = app.buttons["icon more plain"]
    let reportProductButton = app.buttons["Laporkan Produk"]
    let reportProductOption = app.textFields["Pilih Jenis Laporan"]
    let chooseProductOption = app.pickers.pickerWheels["Pilih Jenis Laporan"]
    let reportTextField = app.scrollViews.otherElements.children(matching: .textView).element
    let doneButton = app.toolbars.buttons["Done"]
    let submitReportButton = app.navigationBars["Laporkan Produk"].buttons["Submit"]
    let alertReport =  app.alerts["Sukses Laporkan Produk"].buttons["OK"]
    let productImageView = app.images["productImageView"]
    let downloadButton = app.buttons["btnDownload"]
    let productScrollView = app.scrollViews["productScrollView"]
    let wishlistButton = app.otherElements["wishlistButton"]
    let buyButton = app.buttons.element(matching: .button, identifier: "buyButton")
    let preorderButton = app.buttons["Preorder"]
    let favoriteButton = app.buttons["favoriteButton"]
    let unfavoriteButton = app.buttons["unfavoriteButton"]
    let sellerName = app.otherElements["sellerName"]
    let categoryLabel = app.buttons["productCategory"]
    let etalaseLabel = app.buttons["productEtalase"]
    let wholesaleButton = app.buttons["wholesaleButton"]
    let wholesaleNavigation = app.navigationBars["Harga Grosir"]
    let readmoreLabel = app.staticTexts["Baca Selengkapnya"]
    let descriptionNavigation = app.navigationBars["Deskripsi Produk"]
    let productRecommendView = app.otherElements["productRecommendView"].children(matching: .image).element(boundBy: 0)
    let preorderView = app.staticTexts["preorderView"]
    let officialStoreBadge = app.staticTexts["Produk dari Brand Resmi"]
    let freeReturnView = app.otherElements["freeReturnView"]
    let conditionView = app.staticTexts["conditionView"]
    let minimumBuyView = app.staticTexts["minimumBuyView"]
    let reputationBadge = app.images["reputationView"]
    let readReview = app.staticTexts["readMoreReview"]
    let readTalk = app.staticTexts["readMoreTalk"]
    let backButton = app.buttons["backButton"]
    // let reviewName = app.otherElements["reviewName"]
    // let cashbackView = app.staticTexts["cashbackView"]
    
    func clickReview() -> ReviewProductDetailPage {
        waitFor(element: reviewButton, status: .Exists)
        reviewButton.tap()
        return ReviewProductDetailPage()
    }
    
    func readMoreReview() -> ReviewProductDetailPage {
        waitFor(element: readReview, status: .Exists)
        readReview.tap()
        return ReviewProductDetailPage()
    }
    
    func clickTalk() -> TalkProductDetailPage {
        waitFor(element: talkButton, status: .Exists)
        talkButton.tap()
        return TalkProductDetailPage()
    }
    
    func readMoreTalk() -> TalkProductDetailPage {
        waitFor(element: readTalk, status: .Exists)
        readTalk.tap()
        return TalkProductDetailPage()
    }
    
    func clickCourier() -> CourierProductDetailPage {
        waitFor(element: courierButton, status: .Exists)
        courierButton.tap()
        return CourierProductDetailPage()
    }
    
    func report() {
        waitFor(element: moreButton, status: .Exists)
        moreButton.tap()
        waitFor(element: reportProductButton, status: .Exists)
        reportProductButton.tap()
        reportProductOption.tap()
        chooseProductOption.swipeUp()
        doneButton.tap()
        reportTextField.tap()
        reportTextField.typeText("qwerty coba ya ok")
        submitReportButton.tap()
        alertReport.tap()
    }
    
    func clickProductImage() {
        waitFor(element: productImageView, status: .Exists)
        productImageView.tap()
        waitFor(element: downloadButton, status: .Exists)
        downloadButton.tap()
    }
    
    func swipeProductImage() {
        waitFor(element: productScrollView, status: .Exists)
        productScrollView.swipeLeft()
        productScrollView.swipeLeft()
    }
    
    func clickBuy() -> AddToCartPage {
        waitFor(element: buyButton, status: .Exists)
        buyButton.tap()
        return AddToCartPage()
    }
    
    func clickPreorder() {
        waitFor(element: preorderButton, status: .Exists)
        preorderButton.tap()
    }
    
    func clickWishlist() {
        waitFor(element: wishlistButton, status: .Exists)
        wishlistButton.tap()
    }
    
    func clickFavorite() {
        favoriteButton.tap()
    }
    
    func clickUnfavorite() {
        unfavoriteButton.tap()
    }
    
    func isShopFavorite() -> Bool
    {
        if favoriteButton.exists
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func goToShop() {
        waitFor(element: sellerName, status: .Exists)
        sellerName.tap()
    }
    
    func clickCategory() {
        waitFor(element: categoryLabel, status: .Exists)
        categoryLabel.tap()
    }
    
    func clickEtalase() {
        waitFor(element: etalaseLabel, status: .Exists)
        etalaseLabel.tap()
    }
    
    func clickWholesale() {
        waitFor(element: wholesaleButton, status: .Exists)
        wholesaleButton.tap()
    }
    
    func clickProductDescription() {
        waitFor(element: readmoreLabel, status: .Exists)
        readmoreLabel.tap()
        
    }
    
    func clickOtherProduct() {
        waitFor(element: productRecommendView, status: .Exists)
        productRecommendView.tap()
    }
}

class ReviewProductDetailPage : ProductDetail {
    let reviewNavigation = app.navigationBars["Ulasan"]
}

class TalkProductDetailPage : ProductDetail {
    let talkNavigation = app.navigationBars["Diskusi"]
}

class CourierProductDetailPage : ProductDetail {
    let courierNavigation = app.navigationBars["Kurir"]
}

