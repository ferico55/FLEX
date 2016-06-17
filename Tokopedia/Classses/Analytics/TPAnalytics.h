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

@interface TPAnalytics : NSObject

+ (void)trackScreenName:(NSString *)screeName;
+ (void)trackScreenName:(NSString *)screeName gridType:(NSInteger)gridType;

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

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts;

+ (void)trackLoginUserID:(NSString *)userID;
+ (void)trackExeptionDescription:(NSString *)description;

+ (void)trackOnBoardingClickButton:(NSString *)buttonName;

+ (void)trackSnapSearchCategory:(NSString *)categoryName;
+ (void)trackSnapSearchAddToCart:(ProductDetail *)product;

+ (void)trackSuccessSubmitReview;
+ (void)trackSearchInboxReview;

@end
