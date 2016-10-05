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
#import "NSNumberFormatter+IDRFormater.h"

typedef NS_ENUM(NSInteger, EventCategoryType) {
    EventCategoryTypeHomepage,
    EventCategoryTypeRegister,
    
};

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

+ (void)localyticsValue:(NSObject *)value profileAttribute:(NSString *)attribute {
    [Localytics setValue:value forProfileAttribute:attribute];
}

+ (void)localyticeValue:(NSObject *)value profileAttribute:(NSString *)attribute scope:(LLProfileScope)scope {
    [Localytics setValue:value forProfileAttribute:attribute withScope:scope];
}

+ (void)localyticsSetCustomerID:(NSString *)userID {
    [Localytics setCustomerId:userID?:@""];
}

+ (void)localyticsSetCustomerFullName:(NSString *)fullName {
    [Localytics setCustomerFullName:fullName?:@""];
}

+ (void)localyticsTrackCartView:(TransactionCartResult *)cart {
    NSInteger itemsInCart = 0;
    for (TransactionCartList *c in cart.list) {
        for (ProductDetail *product in c.cart_products) {
            itemsInCart = itemsInCart + [product.product_quantity integerValue];
        }
    }
    
    NSDictionary *attributes = @{
                                 @"Items in Cart" : @(itemsInCart),
                                 @"Value of Cart" : cart.grand_total_idr?:@""
                                 };
    
    [self localyticsEvent:@"Cart Viewed" attributes:attributes];
}

+ (void)localyticsTrackATC:(ProductDetail *)product {
    NSString *productID = product.product_id;
    NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:product.product_price];
    NSString *total = [NSString stringWithFormat:@"%zd", [product.product_total_price integerValue]];
    NSString *productQuantity = product.product_quantity;
    
    NSDictionary *attributes = @{
                                 @"Product Id" : productID?:@"",
                                 @"Category" : product.product_cat_name?:@"",
                                 @"Price" : price?:@(0),
                                 @"Value of Cart" : total?:@"",
                                 @"Items in Cart" : productQuantity?:@""
                                 };
    
    NSString *profileAttribute = @"Profile : Last date has product in cart";
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [self localyticsEvent:@"Product Added to Cart" attributes:attributes];
    [self localyticeValue:currentDate profileAttribute:profileAttribute scope:LLProfileScopeApplication];
}

+ (NSString *)providerWithMethod:(NSString *)method {
    if ([method isEqualToString:@"1"]) {
        return @"Facebook";
    } else if ([method isEqualToString:@"2"]) {
        return @"Google";
    } else if ([method isEqualToString:@"4"]) {
        return @"Yahoo";
    } else if ([method isEqualToString:@"0"]) {
        return @"Email";
    } else {
        return @"";
    }
}

+ (void)localyticsTrackRegistration:(NSString *)method success:(BOOL)success {
    NSString *provider = [self providerWithMethod:method];
    
    NSDictionary *attributes = @{
                                 @"Success" : success? @"Yes" : @"No",
                                 @"Previous Screen" : @"Login",
                                 @"Method" : provider?:@""
                                 };
    
    [self localyticsEvent:@"Registration Summary" attributes:attributes];
}

+ (void)localyticsTrackLogin:(BOOL)success {
    [self localyticsValue:success?@"Yes":@"No" profileAttribute:@"Is Login"];
    [self localyticsEvent:@"Login" attributes:@{@"success" : success?@"Yes":@"No"}];
}

+ (void)localyticsTrackWithdraw:(BOOL)success {
    [self localyticsEvent:@"Deposit Withdraw" attributes:@{@"Success" : success?@"Yes":@"No"}];
}

+ (void)localyticsTrackShipmentConfirmation:(BOOL)success {
    [self localyticsEvent:@"Shipment Confirmation" attributes:@{@"Success" : success?@"Yes":@"No"}];
}

+ (void)localyticsTrackReceiveConfirmation:(BOOL)success {
    [self localyticsEvent:@"Receive Confirmation" attributes:@{@"Success" : success?@"Yes":@"No"}];
}

+ (void)localyticsTrackGiveReview:(BOOL)success accuracy:(NSInteger)accuracy quality:(NSInteger)quality {
    [self localyticsEvent:@"Give Review" attributes:@{@"Success" : success?@"Yes":@"No",
                                                      @"Accuracy" : [@(accuracy) stringValue]?:@"",
                                                      @"Quality" : [@(quality) stringValue]?:@""}];
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
        
        [self localyticsValue:[manager.userManager getUserId]?:@"" profileAttribute:@"user_id"];
        [self localyticsValue:[manager.userManager getShopId]?:@"" profileAttribute:@"shop_id"];
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

+ (void)trackProductView:(Product *)product {
    if (!product) return;
    if (product.data.breadcrumb.count == 0) return;
    
    // GA Tracking
    AnalyticsManager *manager = [[self alloc] init];
    NSDictionary *productFieldObjects = [product.data.info productFieldObjects];
    
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
    
    // Localytics Tracking
    NSNumber *price = [[NSNumberFormatter IDRFormatter] numberFromString:product.data.info.price?:product.data.info.product_price];
    Breadcrumb *category = product.data.breadcrumb[product.data.breadcrumb.count - 1];
    
    NSDictionary *attributes = @{
                                 @"Product ID" : product.data.info.product_id?:@"",
                                 @"Category" : category.department_name?:@"",
                                 @"Price" : price?:@(0),
                                 @"Price Alert" : product.data.info.product_price_alert?:@"",
                                 @"Wishlist" : product.data.info.product_already_wishlist?:@""
                                 };
    
    [self localyticsEvent:@"Product Viewed" attributes:attributes];
    
    // AppsFlyer Tracking
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventContentView
                                      withValues:@{
                                                   AFEventParamPrice : price?:@"",
                                                   AFEventParamContentId : product.data.info.product_id?:@"",
                                                   AFEventParamCurrency : @"IDR",
                                                   AFEventParamContentType : @"Product"
                                                   }];
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

+ (void)trackLogin:(Login *)login {
    // GA Tracking
    [self trackAuthenticatedWithLoginResult:login.result];
    
    // Localytics Tracking
    [self localyticsTrackLogin:YES];
    [self localyticsSetCustomerID:login.result.user_id];
    [self localyticsSetCustomerFullName:login.result.full_name];
    [self localyticsValue:login.result.user_id?:@"" profileAttribute:@"user_id"];
    [self localyticsValue:login.result.email?:@"" profileAttribute:@"user_email"];
    
    // AppsFlyer Tracking
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventLogin withValue:nil];
}

@end