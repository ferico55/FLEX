//
//  Analytics.m
//  Tokopedia
//
//  Created by Tokopedia on 11/10/15.
//  Copyright © 2015 TOKOPEDIA. All rights reserved.
//

#import "TPAnalytics.h"
#import "SearchAWSProduct.h"
#import "ProductFeedList.h"
#import "WishListObjectList.h"
#import "List.h"
#import "PromoProduct.h"
#import "TransactionCartList.h"
#import "PromoResult.h"
#import "Localytics.h"
#import "NSURL+Dictionary.h"

@interface TPAnalytics ()

@property (strong, nonatomic) TAGDataLayer *dataLayer;
@property (strong, nonatomic) UserAuthentificationManager *userManager;

@end

@implementation TPAnalytics

- (id)init {
    self = [super init];
    if (self) {
        self.dataLayer = [TAGManager instance].dataLayer;
        self.userManager = [[UserAuthentificationManager alloc] init];
        [self.dataLayer push:@{@"user_id" : [self.userManager getUserId]}];
    }
    return self;
}

+ (void)trackScreenName:(NSString *)screenName {
    TPAnalytics *analytics = [[self alloc] init];
    UserAuthentificationManager *auth = [UserAuthentificationManager new];
    if (auth.isLogin) {
        NSDictionary *authenticatedData = @{
        @"event": @"authenticated",
        @"contactInfo": @{
                @"userSeller": [auth.getShopId isEqualToString:@"0"]? @"0": @"1",
                @"userFullName": [auth.getUserLoginData objectForKey:@"full_name"]?:@"",
                @"userEmail": [auth.getUserLoginData objectForKey:@"user_email"]?:@"",
                @"userId": auth.getUserId,
                @"userMSISNVerified": [auth.getUserLoginData objectForKey:@"msisdn_is_verified"]?:@"",
                @"shopID": auth.getShopId
            },
        };
        [analytics.dataLayer push:authenticatedData];
        [analytics.dataLayer push:@{@"event": @"openScreen", @"screenName": screenName}];
    }
    
    [TPLocalytics trackScreenName:screenName];
}

+ (void)trackScreenName:(NSString *)screenName gridType:(NSInteger)gridType {
    if (!screenName || !gridType) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"openScreen",
        @"screenName" : screenName?:@"",
        @"gridType" : @(gridType)
    };
    [analytics.dataLayer push:data];
    
    [TPLocalytics trackScreenName:screenName];
}

+ (void)trackUserId {
    TPAnalytics *analytics = [[self alloc] init];
    if (analytics.userManager.isLogin) {
        [analytics.dataLayer push:@{@"user_id" : [analytics.userManager getUserId]?:@""}];
        [Localytics setValue:[analytics.userManager getUserId]?:@"" forProfileAttribute:@"user_id"];
        [Localytics setValue:[analytics.userManager getShopId]?:@"" forProfileAttribute:@"shop_id"];        
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
    if (!products) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *impressions = [NSMutableArray new];
    for (id product in products) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[product productFieldObjects]];
        NSString *listName = [analytics getProductListName:product];
        [dict setObject:listName forKey:@"list"];
        [impressions addObject:dict];
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"currencyCode" : @"IDR",
            @"impressions" : impressions
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackProductClick:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSString *list = [analytics getProductListName:product];
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
    [analytics.dataLayer push:data];
}

+ (void)trackProductView:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
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
    [analytics.dataLayer push:data];
}

+ (void)trackAddToCart:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
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
    [analytics.dataLayer push:data];
}

+ (void)trackRemoveProductFromCart:(id)product {
    if (!product) return;
    TPAnalytics *analytics = [[self alloc] init];
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
    TPAnalytics *analytics = [[self alloc] init];
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

+ (void)trackPromoImpression:(NSArray *)products {
    if (!products) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *promotions = [NSMutableArray new];
    for (PromoProduct *product in products) {
        [promotions addObject:product.productFieldObjects];
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"promoView" : @{
                @"promotions" : promotions
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackPromoClick:(PromoResult *)promoResult {
    if (!promoResult || !promoResult.product) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"promotionClick",
        @"ecommerce" : @{
            @"promoClick" : @{
                @"promotions" : @[promoResult.productFieldObjects]
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackCheckout:(NSArray *)shops
                 step:(NSInteger)step
               option:(NSString *)option {
    if (!shops || !step || !option) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *products = [NSMutableArray new];
    for(TransactionCartList *list in shops) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [products addObject:detailProduct.productFieldObjects];
        }
    }
    NSDictionary *data = @{
        @"ecommerce" : @{
            @"checkout" : @{
                @"actionField" : @{
                    @"step" : @(step)?:0,
                    @"option" : option?:@""
                },
                @"products" : products
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackCheckoutOption:(NSString *)option step:(NSInteger)step {
    if (!option || !step) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": @"checkoutOption",
        @"ecommerce" : @{
            @"checkout_option" : @{
                @"actionField" : @{
                    @"step" : @(step)?:0,
                    @"option" : option?:@""
                }
            }
        }
    };
    [analytics.dataLayer push:data];
}

+ (void)trackPurchaseID:(NSString *)purchaseID carts:(NSArray *)carts coupon:(NSString *)coupon {
    if (!purchaseID || !carts) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSMutableArray *purchasedItems = [NSMutableArray array];
    NSInteger revenue = 0;
    NSInteger shipping = 0;
    for(TransactionCartList *list in carts) {
        for(ProductDetail *detailProduct in list.cart_products) {
            [purchasedItems addObject:@{
                @"name"     : detailProduct.product_name?:@"",
                @"sku"      : detailProduct.product_id?:@"",
                @"price"    : detailProduct.product_price?:@"",
                @"currency" : @"IDR",
                @"quantity" : detailProduct.product_quantity?:@""
            }];
            revenue += [list.cart_total_amount integerValue];
            shipping += [list.cart_shipping_rate integerValue];
        }
    }
    NSString *shippingString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:shipping]];
    NSString *revenueString = [NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:revenue]];
    NSDictionary *data = @{
        @"event" : @"transaction",
        @"transactionId" : purchaseID?:@"",
        @"transactionTotal" : revenueString,
        @"transactionShipping" : shippingString,
        @"transactionCurrency" : @"IDR",
        @"transactionProducts" : purchasedItems
    };
    [analytics.dataLayer push:data];
    NSDictionary *purchaseData = @{
        @"event": @"purchase",
        @"transactionID": purchaseID,
        @"ecommerce": @{
            @"purchase": @{
                @"actionField": @{
                    @"id": purchaseID,
                    @"revenue": revenueString,
                    @"shipping": shippingString,
                    @"coupon": coupon?:@"",
                },
                @"products" : purchasedItems
            }
        }
    };
    [analytics.dataLayer push:purchaseData];
}

+ (void)trackLoginUserID:(NSString *)userID {
    if (!userID) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
       @"event" : @"login",
       @"eventCategory" : @"UX",
       @"eventAction" : @"User Sign In",
       @"eventLabel" : @"User ID",
       @"eventValue" : userID?:@""
    };
    [analytics.dataLayer push:data];
}

+ (void)trackExeptionDescription:(NSString *)description {
    if (!description) return;
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event" : @"exception",
                           @"exception.description":description?:@""
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackOnBoardingClickButton:(NSString *)buttonName {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
            @"event" : @"onBoardingClick",
            @"buttonName" : buttonName,
    };
    [analytics.dataLayer push:data];
}

+ (void)trackSnapSearchCategory:(NSString *)categoryName {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event" : @"snapSearchCategory",
        @"categoryName" : categoryName,
    };
    [analytics.dataLayer push:data];
}

+ (void)trackSnapSearchAddToCart:(ProductDetail *)product {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": @"snapSearchAddToCart",
        @"productId": product.product_id,
    };
    [analytics.dataLayer push:data];
}

+ (void)trackAuthenticated:(NSDictionary *)data {
    TPAnalytics *analytics = [[self alloc] init];
    [analytics.dataLayer push:data];
}

+ (void)trackSuccessSubmitReview:(NSInteger)status {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"successSubmitReview",
						   @"submitReviewStatus": @(status)
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackSearchInboxReview {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"searchInboxReview"
                           };
    [analytics.dataLayer push:data];
}

+ (void)trackPushNotificationAccepted:(BOOL)accepted {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                            @"event": @"pushNotificationPermissionRequest",
                            @"pushNotificationAllowed": @(accepted)
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackOpenPushNotificationSetting {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
                           @"event": @"openPushNotificationSetting"
                           };
    
    [analytics.dataLayer push:data];
}

+ (void)trackCampaign:(NSURL *)url {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"utmSource": [url.parameters objectForKey:@"utm_source"]?:@"",
        @"utmMedium": [url.parameters objectForKey:@"utm_medium"]?:@"",
        @"utmCampaign": [url.parameters objectForKey:@"utm_campaign"]?:@"",
        @"utmContent": [url.parameters objectForKey:@"utm_content"]?:@"",
        @"utmTerm": [url.parameters objectForKey:@"utm_term"]?:@"",
        @"gclid": [url.parameters objectForKey:@"gclid"]?:@"",
    };
    [analytics.dataLayer push:data];
}

+ (void)trackClickEvent:(NSString *)event category:(NSString *)category label:(NSString *)label {
    TPAnalytics *analytics = [[self alloc] init];
    NSDictionary *data = @{
        @"event": event,
        @"eventCategory": category,
        @"eventLabel": label
    };
    [analytics.dataLayer push:data];
}

@end
