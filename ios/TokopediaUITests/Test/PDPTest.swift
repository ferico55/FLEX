//
//  PDPTest.swift
//  Tokopedia
//
//  Created by nakama on 8/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class PDPTest: XCTestCase {
    
    var page = Page()
    var homepage = HomePage()
    var login = LoginPage()
    var wishlist = WishlistPage()
    var productDetail = ProductDetail()
    var reviewProductDetail  = ReviewProductDetailPage()
    var addToCart = AddToCartPage()
    var wholesale = Wholesale()
    var productDescription = ProductDescription()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGoPDPFromSearch() {
        homepage.goToSearchPage().search("iPhone 7").clickProduct()
        XCTAssert(productDetail.PDPView.exists)
    }
    
    func testGoPDPFromWishlist() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
    }

    func testPreorder() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.preorderView.exists)
    }

    func testOfficialStoreBadge() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.officialStoreBadge.exists)
    }

    func testFreeReturn() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.freeReturnView.exists)
    }

    func testCondition() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.conditionView.exists)
    }

    func testMinimumBuy() {
        if login.isLogout() {
            login.goLoginPage()
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        wishlist.goWishlistPage()
        wishlist.clickWishlistCell(product: "Do More")
        XCTAssert(productDetail.minimumBuyView.exists)
    }

    func testOpenReview() {
        testGoPDPFromSearch()
        productDetail.clickReview().backToPDP()
    }
    
    func testOpenTalk() {
        testGoPDPFromSearch()
        productDetail.clickTalk().backToPDP()
    }

    func testOpenCourier() {
        testGoPDPFromSearch()
        productDetail.clickCourier().backToPDP()
    }

    func testOpenCancelShare() {
        testGoPDPFromSearch()
        productDetail.clickShare()
    }

    func testOpenCart() {
        testGoPDPFromSearch()
        productDetail.clickCart()
        
        if login.isShouldLogin(){
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            productDetail.clickCart()
        }
    }

    func testReportProduct() {
        testGoPDPFromSearch()
        productDetail.clickReport().report()
        if login.isShouldLogin(){
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            productDetail.clickReport().report()
        }
        
    }

    func testBackPreviousPage() {
        testGoPDPFromSearch()
        productDetail.clickBackFromProductDetail()
    }

    func testDownloadProductImage() {
        testGoPDPFromSearch()
        productDetail.clickProductImage().downloadProductImage()
    }

    func testSwipeProductImage() {
        testGoPDPFromSearch()
        productDetail.swipeProductImage()
    }
    
    func testBuyProduct() {
        testGoPDPFromSearch()
        productDetail.clickBuy()
        
        if login.isShouldLogin(){
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            productDetail.clickBuy()
        }
        XCTAssert(addToCart.ATCNavigation.exists)
    }

    func testWishlist() {
        testGoPDPFromSearch()
        productDetail.clickWishlist()
        
        if login.isShouldLogin(){
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
            productDetail.clickWishlist()
        }
        
    }
    
    func testFavorite() {
        testGoPDPFromSearch()
        
        if(productDetail.favoriteButton.exists)
        {
            productDetail.clickFavorite()
            
            if login.isShouldLogin(){
                login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
                page.back.tap()
                testGoPDPFromSearch()
                if productDetail.isShopFavorite()
                {
                    productDetail.clickUnfavorite()
                }
                else
                {
                    productDetail.clickFavorite()
                }
                
            }
        }
        else
        {
            productDetail.clickUnfavorite()
        }
    }

    func testUnfavorite() {
        testGoPDPFromSearch()
        
        if(productDetail.unfavoriteButton.exists)
        {
            productDetail.clickUnfavorite()
        }
        else
        {
            productDetail.clickFavorite()
            
            if login.isShouldLogin(){
                login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
                page.back.tap()
                testGoPDPFromSearch()
                if productDetail.isShopFavorite()
                {
                    productDetail.clickUnfavorite()
                }
                else
                {
                    productDetail.clickFavorite()
                }
                
            }
        }
    }
    
    func testReputationBadge() {
        testGoPDPFromSearch()
        XCTAssert(productDetail.reputationBadge.exists)
    }

    func testGoToShop() {
        testGoPDPFromSearch()
        productDetail.goToShop()
    }

    func testGoToCategory() {
        testGoPDPFromSearch()
        productDetail.clickCategory()
    }

    func testGoToEtalase() {
        testGoPDPFromSearch()
        productDetail.clickEtalase()
    }

    func testGoToWholesale() {
        testGoPDPFromSearch()
        productDetail.clickWholesale().isWholesaleDetail()
    }
    
    func testReadMoreDescription() {
        testGoPDPFromSearch()
        productDetail.clickProductDescription().isDescriptionDetail()
    }

    func testOtherProduct() {
        testGoPDPFromSearch()
        productDetail.clickOtherProduct()
        XCTAssert(productDetail.PDPView.exists)
    }
    
    func testReadMoreReview() {
        testGoPDPFromSearch()
        productDetail.readMoreReview().isReviewDetailPage()
    }
    
    func testReadMoreTalk() {
        testGoPDPFromSearch()
        productDetail.readMoreTalk().isTalkDetailPage()
    }
    
}
