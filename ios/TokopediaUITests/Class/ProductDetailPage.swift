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
    let courierButton = app.staticTexts["courierButton"]
    let shareButton = app.buttons["icon share white"]
    let cartButton = app.buttons["icon cart white"]
    let moreButton = app.buttons["icon more plain"]
    let reportProductButton = app.buttons["Laporkan Produk"]
    let productImageView = app.images["productImageView"]
    let productScrollView = app.scrollViews["productScrollView"]
    let wishlistButton = app.otherElements["wishlistButton"]
    let buyButton = app.buttons["Beli"]
    let preorderButton = app.buttons["Preorder"]
    let favoriteButton = app.buttons["favoriteButton"]
    let unfavoriteButton = app.buttons["unfavoriteButton"]
    let sellerName = app.otherElements["sellerName"]
    let categoryLabel = app.buttons["productCategory"]
    let etalaseLabel = app.buttons["productEtalase"]
    let wholesaleButton = app.buttons["wholesaleButton"]
    let readmoreLabel = app.staticTexts["Baca Selengkapnya"]
    let productRecommendView = app.otherElements["productRecommendView"].children(matching: .image).element(boundBy: 0)
    let preorderView = app.staticTexts["preorderView"]
    let officialStoreBadge = app.images["officialStoreBadgeImage"]
    let freeReturnView = app.otherElements["freeReturnView"]
    let conditionView = app.staticTexts["conditionView"]
    let minimumBuyView = app.staticTexts["minimumBuyView"]
    let reputationBadge = app.images["reputationView"]
    let readReview = app.staticTexts["readMoreReview"]
    let readTalk = app.staticTexts["readMoreTalk"]
    let backButton = app.buttons["backButton"]
//    static let reviewName = app.otherElements["reviewName"]
//    static let cashbackView = app.staticTexts["cashbackView"]
    
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
    
    func clickShare() {
        waitFor(element: shareButton, status: .Exists)
        shareButton.tap()
        page.cancel.tap()
    }
    
    func clickCart() {
        waitFor(element: cartButton, status: .Exists)
        cartButton.tap()
    }
    
    func clickReport() -> ReportProduct {
        waitFor(element: moreButton, status: .Exists)
        moreButton.tap()
        waitFor(element: reportProductButton, status: .Exists)
        reportProductButton.tap()
        return ReportProduct()
    }
    
    func clickBackFromProductDetail() {
        backButton.tap()
    }
    
    func clickProductImage() -> ProductImage {
        waitFor(element: productImageView, status: .Exists)
        productImageView.tap()
        return ProductImage()
    }
    
    func swipeProductImage() {
        waitFor(element: productScrollView, status: .Exists)
        productScrollView.swipeLeft()
        productScrollView.swipeLeft()
    }
    
    func clickBuy() {
        waitFor(element: buyButton, status: .Exists)
        buyButton.tap()
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
        categoryLabel.tap()
    }
    
    func clickEtalase() {
        etalaseLabel.tap()
    }
    
    func clickWholesale() -> Wholesale {
        waitFor(element: wholesaleButton, status: .Exists)
        wholesaleButton.tap()
        return Wholesale()
    }
    
    func clickProductDescription() -> ProductDescription {
        waitFor(element: readmoreLabel, status: .Exists)
        readmoreLabel.tap()
        return ProductDescription()
    }
    
    func clickOtherProduct() {
        waitFor(element: productRecommendView, status: .Exists)
        productRecommendView.tap()
    }
}

class ReviewProductDetailPage : ProductDetail {
    
    let reviewNavigation = app.navigationBars["Ulasan"]
    
    func backToPDP() {
        waitFor(element: reviewNavigation, status: .Exists)
        page.back.tap()
    }
    
    func isReviewDetailPage() {
        XCTAssert(reviewNavigation.exists)
    }
}

class TalkProductDetailPage : ProductDetail {
    
    let talkNavigation = app.navigationBars["Diskusi"]
    
    func backToPDP() {
        waitFor(element: talkNavigation, status: .Exists)
        page.back.tap()
    }
    
    func isTalkDetailPage() {
        XCTAssert(talkNavigation.exists)
    }
}

class CourierProductDetailPage : ProductDetail {
    
    let courierNavigation = app.navigationBars["Kurir"]
    
    func backToPDP() {
        waitFor(element: courierNavigation, status: .Exists)
        page.back.tap()
    }
}

class ReportProduct : ProductDetail {
    
    let reportProductOption = app.textFields["Pilih Jenis Laporan"]
    let chooseProductOption = app.pickers.pickerWheels["Pilih Jenis Laporan"]
    let reportTextField = app.scrollViews.otherElements.children(matching: .textView).element
    let doneButton = app.toolbars.buttons["Done"]

    let submitReportButton = app.navigationBars["Laporkan Produk"].buttons["Submit"]
    let alertReport =  app.alerts["Sukses Laporkan Produk"].buttons["OK"]
    
    func report() {
        reportProductOption.tap()
        chooseProductOption.swipeUp()
        doneButton.tap()
        reportTextField.tap()
        reportTextField.typeText("qwerty coba ya ok")
        submitReportButton.tap()
        alertReport.tap()
    }
}

class ProductImage : ProductDetail {
    let downloadButton = app.buttons["Download"]
    
    func downloadProductImage() {
        waitFor(element: downloadButton, status: .Exists)
        downloadButton.tap()
    }
}

class Wholesale : ProductDetail {
    let wholesaleNavigation = app.navigationBars["Harga Grosir"]
    
    func isWholesaleDetail() {
        waitFor(element: wholesaleNavigation, status: .Exists)
    }
}

class ProductDescription : ProductDetail {
     let descriptionNavigation = app.navigationBars["Deskripsi Produk"]
    
    func isDescriptionDetail() {
        waitFor(element: descriptionNavigation, status: .Exists)
    }
}
