//
//  Analytics.h
//  Tokopedia
//
//  Created by Tokopedia on 11/10/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAGDataLayer.h"
#import "TAGManager.h"
#import "ProductDetail.h"
#import "LoginResult.h"

@interface TPAnalytics : NSObject

+ (void)trackScreenName:(NSString *)screenName;
+ (void)trackScreenName:(NSString *)screenName gridType:(NSInteger)gridType;

+ (void)trackUserId;

+ (void)trackProductImpressions:(NSArray *)products;
+ (void)trackProductClick:(id)product;
+ (void)trackProductView:(id)product;

+ (void)trackAddToCart:(id)product;
+ (void)trackRemoveProductFromCart:(id)product;
+ (void)trackRemoveProductsFromCart:(NSArray *)shops;

+ (void)trackPromoImpression:(NSArray *)products;
+ (void)trackPromoClick:(id)product;

+ (void)trackCheckout:(NSArray *)shops
                 step:(NSInteger)step
               option:(NSString *)option;

+ (void)trackCheckoutOption:(NSString *)option
                       step:(NSInteger)step;

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon;

+ (void)trackLoginUserID:(NSString *)userID;
+ (void)trackExeptionDescription:(NSString *)description;

+ (void)trackOnBoardingClickButton:(NSString *)buttonName;

+ (void)trackSnapSearchCategory:(NSString *)categoryName;
+ (void)trackSnapSearchAddToCart:(ProductDetail *)product;

+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result;
+ (void)trackSuccessSubmitReview:(NSInteger)status;
+ (void)trackSearchInboxReview;

+ (void)trackPushNotificationAccepted:(BOOL)accepted;
+ (void)trackOpenPushNotificationSetting;

+ (void)trackCampaign:(NSURL *)url;

+ (void)trackClickEvent:(NSString *)event category:(NSString *)category label:(NSString *)label;

+ (void)trackSearchWithAction:(NSString *)action keyword:(NSString *)keyword;

+ (void)trackClickRegisterOnPage:(NSString *)page;
+ (void)trackSuccessRegisterWithChannel:(NSString *)channel;
+ (void)trackErrorRegisterWithFieldName:(NSString *)name;
+ (void)trackAbandonRegisterWithFieldName:(NSString *)name;
+ (void)trackSearchNoResultWithKeyword:(NSString *)keyword;

+ (void)trackLoginCTAButton;
+ (void)trackSuccessLoginWithChannel:(NSString *)channel;
+ (void)trackErrorLoginWithFieldName:(NSString *)name;
+ (void)trackAbandonLoginWithFieldName:(NSString *)name;

+ (void)trackRegisterThroughLogin;

+ (void)trackAddToCartEvent:(NSString *)event action:(NSString *)action label:(NSString *)label;

+ (void)trackClickCartLabel:(NSString *)label;

+ (void)trackClickCategoryWithCategoryName:(NSString *)name;
+ (void)trackClickBuyFromWishlist;
+ (void)trackViewProductFromWishlistWithProductName:(NSString *)name;

+ (void)trackFilterWithSelectedFilters:(NSArray<NSString *> *)filters;
+ (void)trackSortWithSortName:(NSString *)name;

+ (void)trackClickProductOnProductFeedWithProductName:(NSString *)name;
+ (void)trackClickProductOnRecentlyViewedWithProductName:(NSString *)name;
+ (void)trackClickShopOnFavoriteShopWithShopName:(NSString *)name;

+ (void)trackClickSearchResultTabWithName:(NSString *)name;
+ (void)trackClickHotlistProductWithName:(NSString *)name;

+ (void)trackGoToHomepageTabWithIndex:(NSInteger)index;

+ (void)trackClickTabBarItemWithName:(NSString *)name;
+ (void)trackClickOnMorePageWithEventName:(NSString *)eventName eventLabel:(NSString *)eventLabel;
+ (void)trackClickNotificationWithEventName:(NSString *)eventName eventLabel:(NSString *)eventLabel;

+ (void)trackPaymentEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label;

+ (void)trackProductDetailPageWithEvent:(NSString *)event action:(NSString *)action label:(NSString *)label;

+ (void)trackAddToWishlist;

+ (void)trackInboxMessageAction:(NSString *)action label:(NSString *)label;
+ (void)trackInboxTalkAction:(NSString *)action label:(NSString *)label;
+ (void)trackInboxReviewAction:(NSString *)action label:(NSString *)label;
+ (void)trackInboxResolutionAction:(NSString *)action label:(NSString *)label;

+ (void)trackEtalaseAction:(NSString *)action label:(NSString *)label;

+ (void)trackClickCheckoutCTAButton;

+ (void)trackForgetPasswordEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label;
+ (void)trackSecurityQuestionEvent:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label;

+ (void)trackClickCreateShop;

@end
