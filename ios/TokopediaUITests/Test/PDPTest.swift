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
    var more = MorePage()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGoPDPFromSearch() {
        homepage.goToSearchPage().searchProduct("iPhone 7").clickProduct()
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
        homepage.goToSearchPage().searchProduct("iPhone po").clickProduct()
        waitFor(element: productDetail.preorderView, status: .Exists)
        XCTAssert(productDetail.preorderView.exists)
    }

    func testOfficialStoreBadge() {
        homepage.goToSearchPage().searchProduct("jbl t205").clickProduct()
        waitFor(element: productDetail.officialStoreBadge, status: .Exists)
        XCTAssert(productDetail.officialStoreBadge.exists)
    }

    func testFreeReturn() {
        homepage.goToSearchPage().searchProduct("jam tangan casio").clickProduct()
        waitFor(element: productDetail.freeReturnView, status: .Exists)
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
        if login.isLogout(){
            login.doLogin(email: "julius.gonawan+automationbuyer@tokopedia.com", password: "tokopedia2016").loginSuccess()
        }
        testGoPDPFromWishlist()
        productDetail.clickBuy()
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
    
/*    func testPromotedProduct() {
        var i = 1
        while i <= 10 {
            if login.isLogout() {
                login.goLoginPage()
                login.doLogin(email: "cancertainly16@gmail.com", password: "tokopedia2016").loginSuccess()
            }
            more.goToProductList()
            let promoButton = Page.app.buttons["Promosi"]
            promoButton.tap()
            let okAlert = Page.app.alerts.buttons["OK"]
            okAlert.tap()
            productDetail.backButton.tap()
            Page.app.buttons["Back"].tap()
            more.goToLogout().doLogout()
            waitFor(element: more.logoutCell, status: .NotExists)
            i += 1
            }
        
        }
 */
}
