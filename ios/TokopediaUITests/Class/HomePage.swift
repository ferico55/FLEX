//
//  HomePage.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/25/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import XCTest

class HomePage : Page, SearchBar, TokopediaTabBar {
    
    let promoTab = app.buttons["PROMO"]
    let feedTab = app.buttons["FEED"]
    let lastSeenTab = app.buttons["TERAKHIR DILIHAT"]
    let activationHomepage = app.buttons["Aktivasi"]
    let bannerView = app.otherElements["bannerSliderView"]
    let seeAllProduct = app.staticTexts["Lihat Semua Produk >"]
    let officialStoreCell = app.images["officialStore0"]
    let nonLoginNavbar = app.navigationBars["Masuk | Tokopedia"]
    let allOfficialStore = app.buttons["seeAllOfficialStore"]
    let financeNavbar = app.navigationBars["Pinjaman Modal"]
    let topPicksWebView = app.otherElements["topPicksCell"].descendants(matching: .image).element(boundBy: 0)
    let topPicksHotList = app.otherElements["topPicksCell"].descendants(matching: .image).element(boundBy: 1)
    
    func isActivatedTokocash() -> Bool {
        if (activationHomepage.exists)
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func clickActivatedTokoCash() -> TokoCashActivationPage {
        waitFor(element: activationHomepage, status: .Exists)
        activationHomepage.tap()
        return TokoCashActivationPage()
    }
    
    func swipeBanner() {
        bannerView.swipeLeft()
        bannerView.swipeLeft()
        bannerView.swipeLeft()
    }
    
    func clickBanner() {
        bannerView.swipeLeft()
        bannerView.swipeLeft()
        bannerView.tap()
    }
    
    func seeAllDigitalProduct() -> DigitalProductPage {
        seeAllProduct.tap()
        return DigitalProductPage()
    }
    
    func clickOfficialStore() {
        waitFor(element: officialStoreCell, status: .Exists)
        officialStoreCell.tap()
    }
    
    func clickSeeAllOfficialStore() {
        waitFor(element: allOfficialStore, status: .Exists)
        allOfficialStore.tap()
    }
    
    func goToCategory (category : String) {
        Page.app.staticTexts[category].tap()
    }
    
    func goToDigital (digital : String) {
        Page.app.staticTexts[digital].tap()
    }
    
    func goToFinance (finance : String) {
        Page.app.staticTexts[finance].tap()
    }
    
    func goToFeedPage() {
        goHomePage()
        waitFor(element: feedTab, status: .Exists)
        feedTab.tap()
    }
    
    func goToPromoPage() {
        goHomePage()
        waitFor(element: promoTab, status: .Exists)
        promoTab.tap()
    }
    
    func goToLastSeenPage() {
        goHomePage()
        waitFor(element: lastSeenTab, status: .Exists)
        lastSeenTab.tap()
    }
    
    func clickTopPicksWebView() {
        waitFor(element: topPicksWebView, status: .Exists)
        topPicksWebView.tap()
    }
    
    func clickTopPicksHotList() {
        waitFor(element: topPicksHotList, status: .Exists)
        topPicksHotList.tap()
    }
}

class TokoCashActivationPage : HomePage {
    
    let activationTokocash = app.buttons["Aktivasi"]
    let backToHomepage = app.buttons["Ke Halaman Utama"]
    
    func backToHomePage() {
        backToHomepage.tap()
    }
    
    func clickActivated() {
        waitFor(element: activationTokocash, status: .Exists)
        activationTokocash.tap()
    }
}

class DigitalProductPage : HomePage {
    
    let myTransaction = app.staticTexts["Transaksi Saya"]
    let subscribe = app.staticTexts["Langganan"]
    let favoriteNumber = app.staticTexts["Nomor Favorit"]
    let digitalNavbar = app.staticTexts["Pembayaran & Top Up"]
    
    let myTransactionNavbar = app.navigationBars["Daftar Transaksi | Tokopedia"]
    let subscribeNavbar = app.navigationBars["Langganan | Tokopedia"]
    let favoriteNumberNavbar = app.navigationBars["Favorite Numbers | Tokopedia"]
    
    func isdigitalProductPage() {
        XCTAssert(digitalNavbar.exists)
    }
    
    func clickMyTransaction() {
        waitFor(element: myTransaction, status: .Exists)
        myTransaction.tap()
    }
    
    func clickSubscribe() {
        waitFor(element: subscribe, status: .Exists)
        subscribe.tap()
    }
    
    func clickFavoriteNumber() {
        waitFor(element: favoriteNumber, status: .Exists)
        favoriteNumber.tap()
    }
}

class OfficialStorePage : HomePage {
    
    let allOfficialStoreNavbar = app.navigationBars["Official Store"]
    let allOfficialStoreBrands = app.otherElements["officialStoreBrands"]
    
    func swipeAllOfficialStore() {
        waitFor(element: allOfficialStoreBrands, status: .Exists)
        allOfficialStoreBrands.swipeUp()
        allOfficialStoreBrands.swipeUp()
        allOfficialStoreBrands.swipeUp()
    }
}


class TopPicks : HomePage {
    let topPicksNavbar = app.navigationBars["Top Picks"]
}
