//
//  AnalyticsManager.h
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TAGDataLayer.h"
#import "TAGManager.h"
#import "PromoResult.h"
#import "ProductDetail.h"
#import "LoginResult.h"

@interface AnalyticsManager : NSObject

// Localytics
+ (void)localyticsEvent:(NSString *)event;
+ (void)localyticsEvent:(NSString *)event attributes:(NSDictionary *)attributes;

// Google Analytics (via GTM)
+ (void)trackScreenName:(NSString *)name;
+ (void)trackScreenName:(NSString *)name gridType:(NSInteger)gridType;
+ (void)trackUserInformation;
+ (void)trackProductImpressions:(NSArray *)products;
+ (void)trackProductClick:(id)product;
+ (void)trackProductView:(id)product;
+ (void)trackProductAddToCart:(id)product;
+ (void)trackRemoveProductFromCart:(id)product;
+ (void)trackRemoveProductsFromCart:(NSArray *)shops;
+ (void)trackPromoClick:(PromoResult *)promoResult;
+ (void)trackCheckout:(NSArray *)shops step:(NSInteger)step option:(NSString *)option;
+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon;
+ (void)trackLoginUserID:(NSString *)userID;
+ (void)trackExceptionDescription:(NSString *)description;
+ (void)trackOnBoardingClickButton:(NSString *)buttonName;
+ (void)trackSnapSearchCategory:(NSString *)categoryName;
+ (void)trackSnapSearchAddToCart:(ProductDetail *)product;
+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result;
+ (void)trackSuccessSubmitReview:(NSInteger)status;
+ (void)trackSearchInboxReview;
+ (void)trackPushNotificationAccepted:(BOOL)accepted;
+ (void)trackOpenPushNotificationSetting;
+ (void)trackCampaign:(NSURL *)url;
+ (void)trackEventName:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label;


// AppsFlyer


@end
