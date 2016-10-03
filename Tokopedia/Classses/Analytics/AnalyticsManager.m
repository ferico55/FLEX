//
//  AnalyticsManager.m
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

#import "AnalyticsManager.h"
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishlistObjectList.h"
#import "List.h"
#import "NSURL+Dictionary.h"

@interface AnalyticsManager()

@property (strong, nonatomic) TAGDataLayer *dataLayer;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

@end

@implementation AnalyticsManager

- (id)init {
    self = [super init];
    if (self) {
        _dataLayer = [TAGManager instance].dataLayer;
        _userManager = [UserAuthentificationManager new];
        [_dataLayer push:@{@"user_id" : [_userManager getUserId]?:@""}];
    }
    
    return self;
}

// Localytics Tracking

+ (void)localyticsEvent:(NSString *)event {
    [Localytics tagEvent:event?:@""];
}

+ (void)localyticsEvent:(NSString *)event attributes:(NSDictionary *)attributes {
    [Localytics tagEvent:event?:@""
              attributes:attributes];
}

// GA Tracking

+ (void)trackScreenName:(NSString *)name {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        NSDictionary *data = @{
                               @"event" : @"authenticated",
                               @"contactInfo" : @{
                                       @"userSeller": [[manager.userManager getShopId] isEqualToString:@"0"]? @"0": @"1",
                                       @"userFullName": [[manager.userManager getUserLoginData] objectForKey:@"full_name"]?:@"",
                                       @"userEmail": [[manager.userManager getUserLoginData] objectForKey:@"user_email"]?:@"",
                                       @"userId": [manager.userManager getUserId],
                                       @"userMSISNVerified": [[manager.userManager getUserLoginData] objectForKey:@"msisdn_is_verified"]?:@"",
                                       @"shopID": [manager.userManager getShopId]
                                       }
                               };
        
        [manager.dataLayer push:data];
    }
    
    [manager.dataLayer push:@{@"event" : @"openScreen",
                              @"screenName" : name?:@""}];
    
    [Localytics tagScreen:name];
}

+ (void)trackScreenName:(NSString *)name gridType:(NSInteger)gridType {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openScreen",
                           @"screenName" : name?:@"",
                           @"gridType" : @(gridType)
                           };
    
    [manager.dataLayer push:data];
    
    [Localytics tagScreen:name?:@""];
}

+ (void)trackUserInformation {
    AnalyticsManager *manager = [[self alloc] init];
    
    if ([manager.userManager isLogin]) {
        [manager.dataLayer push:@{@"user_id" : [manager.userManager getUserId]?:@""}];
        
        [Localytics setValue:[manager.userManager getUserId]?:@"" forProfileAttribute:@"user_id"];
        [Localytics setValue:[manager.userManager getUserId]?:@"" forProfileAttribute:@"shop_id"];
    }
}

- (NSString *)getProductListName:(id)product {
    NSString *list = @"";
    if ([product isKindOfClass:[SearchAWSProduct class]]) {
        list = @"Search Results";
    } else if ([product isKindOfClass:[ProductFeedList class]]) {
        list = @"Product Feed";
    } else if ([product isKindOfClass:[WishListObjectList class]]) {
        list = @"Wish List";
    } else if ([product isKindOfClass:[List class]]) {
        list = @"Shop Product";
    }
    return list;
    
}

+ (void)trackProductImpressions:(NSArray *)products {
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *impressions = [NSMutableArray new];
    
    for (id product in products) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[product productFieldObjects]];
        NSString *listName = [manager getProductListName:product];
        [dict setObject:listName forKey:@"list"];
        [impressions addObject:dict];
    }
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"impressions" : impressions
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackProductClick:(id)product {
    if (!product) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSString *list = [manager getProductListName:product];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"productClick",
                           @"ecommerce" : @{
                                   @"click" : @{
                                           @"actionField" : @{
                                                   @"list" : list
                                                   },
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackProductView:(id)product {
    if (!product) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"detail" : @{
                                           @"actionField" : @{
                                                   @"list" : @"Produk Detail"
                                                   },
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackProductAddToCart:(id)product {
    if (!product) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"addToCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"add" : @{
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    [manager.dataLayer push:data];
}

+ (void)trackRemoveProductFromCart:(id)product {
    if (!product) return;
    AnalyticsManager *analytics = [[self alloc] init];
    NSDictionary *productFieldObjects = [product productFieldObjects];
    NSDictionary *data = @{
                           @"event" : @"removeFromCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"remove" : @{
                                           @"products" : @[productFieldObjects]
                                           }
                                   }
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackRemoveProductsFromCart:(NSArray *)shops {
    if (!shops) return;
    AnalyticsManager *analytics = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    for(TransactionCartList *list in shops) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [products addObject:detailProduct.productFieldObjects];
        }
    }
    
    NSDictionary *data = @{
                           @"event" : @"removeFromCart",
                           @"ecommerce" : @{
                                   @"currencyCode" : @"IDR",
                                   @"remove" : @{
                                           @"products" : products
                                           }
                                   }
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackPromoClick:(PromoResult *)promoResult {
    if (!promoResult || !promoResult.product) return;
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"promotionClick",
                           @"ecommerce" : @{
                                   @"promoClick" : @{
                                           @"promotions" : @[promoResult.productFieldObjects]
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackCheckout:(NSArray *)shops step:(NSInteger)step option:(NSString *)option {
    if (!shops || !step || !option) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    
    for (TransactionCartList *shop in shops) {
        for (ProductDetail *product in shop.cart_products) {
            [products addObject:product.productFieldObjects];
        }
    }
    
    NSDictionary *data = @{
                           @"ecommerce" : @{
                                   @"checkout" : @{
                                           @"actionField" : @{
                                                   @"step" : @(step)?:@(0),
                                                   @"option" : option?:@""
                                                   },
                                           @"products" : products
                                           }
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon {
    if (!purchaseID || !carts) return;
    AnalyticsManager *manager = [[self alloc] init];
    NSMutableArray *purchasedItems = [NSMutableArray array];
    NSInteger revenue = 0;
    NSInteger shipping = 0;
    
    for (TransactionCartList *cart in carts) {
        for (ProductDetail *product in cart.cart_products) {
            [purchasedItems addObject:@{
                                        @"name" : product.product_name?:@"",
                                        @"sku" : product.product_id?:@"",
                                        @"price" : product.product_price?:@"",
                                        @"currency" : @"IDR",
                                        @"quantity" : product.product_quantity?:@""
                                        }];
            revenue = revenue + [cart.cart_total_amount integerValue];
            shipping = shipping + [cart.cart_shipping_rate integerValue];
        }
    }
    
    NSString *shippingString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:shipping]];
    NSString *revenueString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:revenue]];
    
    NSDictionary *transactionData = @{
                                      @"event" : @"transaction",
                                      @"transactionId" : purchaseID?:@"",
                                      @"transactionTotal" : revenueString?:@"",
                                      @"transactionShipping" : shippingString?:@"",
                                      @"transactionCurrency" : @"IDR",
                                      @"transactionProducts" : purchasedItems?:@""
                                      };
    
    NSDictionary *purchaseData = @{
                                   @"event" : @"purchase",
                                   @"transactionID" : purchaseID,
                                   @"ecommerce" : @{
                                           @"purchase" : @{
                                                   @"actionField" : @{},
                                                   @"products" : purchasedItems?:@""}
                                           }
                                   };
    
    [manager.dataLayer push:transactionData];
    [manager.dataLayer push:purchaseData];
}

+ (void)trackLoginUserID:(NSString *)userID {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"login",
                           @"eventCategory" : @"UX",
                           @"eventAction" : @"User Sign In",
                           @"eventLabel" : @"User ID",
                           @"eventValue" : userID?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackExceptionDescription:(NSString *)description {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"exception",
                           @"exception.description" : description?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackOnBoardingClickButton:(NSString *)buttonName {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"onBoardingClick",
                           @"buttonName" : buttonName?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSnapSearchCategory:(NSString *)categoryName {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"snapSearchCategory",
                           @"categoryName" : categoryName?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSnapSearchAddToCart:(ProductDetail *)product {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"snapSearchAddToCart",
                           @"productId" : product.product_id?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackAuthenticatedWithLoginResult:(LoginResult *)result {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"authenticated",
                           @"contactInfo" : @{
                                   @"userSeller" : result.seller_status?:@"",
                                   @"userFullName" : result.full_name?:@"",
                                   @"userEmail" : result.email?:@"",
                                   @"userId" : result.user_id?:@"",
                                   @"userMSISNVerified" : result.msisdn_is_verified?:@"",
                                   @"shopId" : result.shop_id?:@""
                                   }
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSuccessSubmitReview:(NSInteger)status {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"successSubmitReview",
                           @"submitReviewStatus" : @(status)?:@(0)
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackSearchInboxReview {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"searchInboxReview"
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackPushNotificationAccepted:(BOOL)accepted {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"pushNotificationPermissionRequest",
                           @"pushNotificationAllowed" : @(accepted)
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackOpenPushNotificationSetting {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : @"openPushNotificationSetting"
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackCampaign:(NSURL *)url {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"utmSource" : [url.parameters objectForKey:@"utm_source"]?:@"",
                           @"utmMedium" : [url.parameters objectForKey:@"utm_medium"]?:@"",
                           @"utmCampaign" : [url.parameters objectForKey:@"utm_campaign"]?:@"",
                           @"utmContent" : [url.parameters objectForKey:@"utm_content"]?:@"",
                           @"utmTerm" : [url.parameters objectForKey:@"utm_term"]?:@"",
                           @"gclid" : [url.parameters objectForKey:@"gclid"]?:@""
                           };
    
    [manager.dataLayer push:data];
}

+ (void)trackEventName:(NSString *)event category:(NSString *)category action:(NSString *)action label:(NSString *)label {
    AnalyticsManager *manager = [[self alloc] init];
    
    NSDictionary *data = @{
                           @"event" : event?:@"",
                           @"eventCategory" : category?:@"",
                           @"eventAction" : action?:@"",
                           @"eventLabel" : label?:@""
                           };
    
    [manager.dataLayer push:data];
}

@end