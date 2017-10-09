//
//  HomepageTest.swift
//  Tokopedia
//
//  Created by Julius Gonawan on 9/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class HomepageTest: XCTestCase {
    
    var homepage = HomePage()
    var login = LoginPage()
    var tokocashActivation = TokoCashActivationPage()
    var digitalProduct = DigitalProductPage()
    var officialStorePage = OfficialStorePage()
    var topPicks = TopPicks()
    var hotlistPage = HotlistPage()
    var feed = FeedPage()
    var lastseen = LastSeenPage()
    var productDetail = ProductDetail()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        homepage.goHomePage()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testActivatedTokocash() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            homepage.goHomePage()
            if !homepage.isActivatedTokocash() {
                homepage.clickActivatedTokoCash().clickActivated()
                tokocashActivation.backToHomePage()
                XCTAssert(homepage.homeTabBar.exists)
            }
        }
        if !homepage.isActivatedTokocash() {
            homepage.clickActivatedTokoCash().clickActivated()
            tokocashActivation.backToHomePage()
            XCTAssert(homepage.homeTabBar.exists)
        }
    }
    
    func testSwipeBanner() {
        homepage.swipeBanner()
    }
    
    func testClickBanner() {
        homepage.clickBanner()
    }
    
    func testSeeAllProduct() {
        homepage.seeAllDigitalProduct().isdigitalProductPage()
    }
    
    func testSeeMyTransaction() {
        homepage.seeAllDigitalProduct().clickMyTransaction()
        
        if login.isLogout() {
            waitFor(element: digitalProduct.nonLoginNavbar, status: .Exists)
            XCTAssert(digitalProduct.nonLoginNavbar.exists)
        }
        else {
            waitFor(element: digitalProduct.myTransactionNavbar, status: .Exists)
            XCTAssert(digitalProduct.myTransactionNavbar.exists)
        }
    }
    
    func testSeeSubscribe() {
        homepage.seeAllDigitalProduct().clickSubscribe()
        
        if login.isLogout() {
            waitFor(element: digitalProduct.nonLoginNavbar, status: .Exists)
            XCTAssert(digitalProduct.nonLoginNavbar.exists)
        }
        else {
            waitFor(element: digitalProduct.subscribeNavbar, status: .Exists)
            XCTAssert(digitalProduct.subscribeNavbar.exists)
        }
    }
    
    func testSeeFavoriteNumbers() {
        homepage.seeAllDigitalProduct().clickFavoriteNumber()
        
        if login.isLogout() {
            waitFor(element: digitalProduct.nonLoginNavbar, status: .Exists)
            XCTAssert(digitalProduct.nonLoginNavbar.exists)
        }
        else {
            waitFor(element: digitalProduct.favoriteNumberNavbar, status: .Exists)
            XCTAssert(digitalProduct.favoriteNumberNavbar.exists)
        }
    }
    
    func testOfficialStore() {
        homepage.clickOfficialStore()
    }
    
    func testSeeAllOfficialStore() {
        homepage.clickSeeAllOfficialStore()
        XCTAssert(officialStorePage.allOfficialStoreNavbar.exists)
        officialStorePage.swipeAllOfficialStore()
    }
    
    func testGoToCategory() {
        homepage.goToCategory(category : "Fashion Wanita")
    }
    
    func testGoToDigital() {
        homepage.goToDigital(digital : "Pulsa")
    }
    
    func testGoToFinance() {
        homepage.goToFinance(finance : "Pinjaman Modal")
        XCTAssert(homepage.financeNavbar.exists)
    }
    
    func testTopPicksWebView() {
        topPicks.clickTopPicksWebView()
        XCTAssert(topPicks.topPicksNavbar.exists)
    }
    
    func testTopPicksHotList() { //this not always have toppicks hotlist
        topPicks.clickTopPicksHotList()
        XCTAssert(hotlistPage.hotlistResultView.exists)
    }
    
    func testSwipeFeed() {
        if login.isLogout()
        {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            feed.goToFeedPage()
            feed.swipeFeed()
            
        }
        else
        {
            feed.goToFeedPage()
            feed.swipeFeed()
        }
    }
    
    func testLastSeen() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+buyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            homepage.goToLastSeenPage()
            lastseen.swipeLastSeen()
            lastseen.tapLastSeenCell()
            XCTAssert(productDetail.PDPView.exists)
        }
        homepage.goToLastSeenPage()
        lastseen.swipeLastSeen()
        lastseen.tapLastSeenCell()
        XCTAssert(productDetail.PDPView.exists)
    }
    
}
