//
//  PDPTest.swift
//  Tokopedia
//
//  Created by nakama on 8/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.


import XCTest

class PDPTest: XCTestCase {
    
    var homepage = HomePage()
    var wishlist = WishlistPage()
    var productDetail = ProductDetail()

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        Page.app.launch()
        UITest.sharedInstance.testCase = self
        if onBoarding.isOnBoarding() {
            onBoarding.skipOnBoarding()
        }
        if !homepage.isUserLogin() {
            LoginTest().testLoginBuyer()
        }
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOpenProductFromWishlist() {
        homepage.goWishlistPage()
        wishlist.searchWishlist("Do More")
        wishlist.clickWishlistCell()
    }
    
    func testPreorder() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.preorderView, status: .Exists)
        XCTAssert(productDetail.preorderView.exists)
    }
    
    func testFreeReturn() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.freeReturnView, status: .Exists)
        XCTAssert(productDetail.freeReturnView.exists)
    }

    func testOfficialStoreBadge() {
        homepage.goSearchPage().searchProduct("jbl t205").clickProduct()
        waitFor(element: productDetail.officialStoreBadge, status: .Exists)
        XCTAssert(productDetail.officialStoreBadge.exists)
    }

    func testCondition() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.conditionView, status: .Exists)
        XCTAssert(productDetail.conditionView.exists)
    }

    func testMinimumBuy() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.conditionView, status: .Exists)
        XCTAssert(productDetail.minimumBuyView.exists)
    }

    func testOpenReview() {
        testOpenProductFromWishlist()
        let reviewView = productDetail.clickReview()
        waitFor(element: reviewView.reviewNavigation, status: .Exists)
        XCTAssert(reviewView.reviewNavigation.exists)
    }
    
    func testOpenTalk() {
        testOpenProductFromWishlist()
        let talkView = productDetail.clickTalk()
        waitFor(element: talkView.talkNavigation, status: .Exists)
        XCTAssert(talkView.talkNavigation.exists)
    }
    
//    func testOpenCourier() {
//        homepage.goWishlistPage()
//        testOpenProductFromWishlist()
//        let courierView = productDetail.clickCourier()
//        waitFor(element: courierView.courierNavigation, status: .Exists)
//        XCTAssert(courierView.courierNavigation.exists)
//    }
    
    func testOpenCancelShare() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.shareButton, status: .Exists)
        productDetail.shareButton.tap()
    }

    func testOpenCart() {
        testOpenProductFromWishlist()
        productDetail.cartButton.tap()
    }

//    func testReportProduct() {
//        homepage.goWishlistPage()
//        testOpenProductFromWishlist()
//        productDetail.report()
//    }
    
    func testDownloadProductImage() {
        testOpenProductFromWishlist()
        productDetail.clickProductImage()
    }
    
    func testSwipeProductImage() {
        testOpenProductFromWishlist()
        productDetail.swipeProductImage()
    }

    func testBuyProduct() {
        testOpenProductFromWishlist()
        let addToCart = productDetail.clickBuy()
        waitFor(element: addToCart.ATCNavigation, status: .Exists)
        XCTAssert(addToCart.ATCNavigation.exists)
    }

    func testWishlist() {
        homepage.goSearchPage().searchProduct("jbl t205").clickProduct()
        productDetail.clickWishlist()
    }

    func testFavorite() {
        testOpenProductFromWishlist()
        if waitFor(element: productDetail.favoriteButton, status: .Exists) == .completed
        {
            productDetail.clickFavorite()
        }
        else
        {
            productDetail.clickUnfavorite()
        }
    }
    
    func testUnfavorite() {
        testOpenProductFromWishlist()
        if waitFor(element: productDetail.unfavoriteButton, status: .Exists) == .completed
        {
            productDetail.clickUnfavorite()
        }
        else
        {
            productDetail.clickFavorite()
            
        }
    }

    func testReputationBadge() {
        testOpenProductFromWishlist()
        waitFor(element: productDetail.reputationBadge, status: .Exists)
        XCTAssert(productDetail.reputationBadge.exists)
    }

//    func testSellerName() {
//        homepage.goWishlistPage()
//        testOpenProductFromWishlist()
//        waitFor(element: productDetail.sellerName, status: .Exists)
//        productDetail.sellerName.tap()
//    }
    
    func testGoToCategory() {
        testOpenProductFromWishlist()
        productDetail.clickCategory()
    }

    func testGoToEtalase() {
        testOpenProductFromWishlist()
        productDetail.clickEtalase()
    }

    func testGoToWholesale() {
        testOpenProductFromWishlist()
        productDetail.clickWholesale()
        waitFor(element: productDetail.wholesaleNavigation, status: .Exists)
        XCTAssert(productDetail.wholesaleNavigation.exists)
    }

    func testReadMoreDescription() {
        testOpenProductFromWishlist()
        productDetail.clickProductDescription()
        waitFor(element: productDetail.descriptionNavigation, status: .Exists)
        XCTAssert(productDetail.descriptionNavigation.exists)
    }
        
    func testReadMoreReview() {
        testOpenProductFromWishlist()
        let reviewView = productDetail.readMoreReview()
        waitFor(element: reviewView.reviewNavigation, status: .Exists)
        XCTAssert(reviewView.reviewNavigation.exists)
    }

    func testReadMoreTalk() {
        testOpenProductFromWishlist()
        let talkView = productDetail.readMoreTalk()
        waitFor(element: talkView.talkNavigation, status: .Exists)
        XCTAssert(talkView.talkNavigation.exists)
    }
    
}
